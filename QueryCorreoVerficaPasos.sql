DECLARE 

@correoDestinatarios as varchar(1000) = 'dnieto@latino-bi.com;dpatarroto@latino-bi.com;ccano@latino-bi.com;dianasm@totto.com;dramirez@latino-bi.com'
,@perfilDeCorreos as varchar(255) = 'Notifica_SQL'

,@Msg as varchar(MAX)
,@NumofFails as smallint
,@JobName as varchar(1000)
,@Subj as varchar(1000)
,@i as smallint = 1


--------------- Conseguir lista de pasos con errores ------------
SELECT *
INTO #Errs

FROM

    (
    SELECT 
      rank() over (PARTITION BY step_id ORDER BY step_id) rn
    , ROW_NUMBER() over (partition by step_id order by run_date desc, run_time desc) ReverseTryOrder
    ,j.name job_name
    ,run_status
    , step_id
    , step_name
    , [message]

    FROM    msdb.dbo.sysjobhistory h
    join msdb.dbo.sysjobs j on j.job_id = h.job_id

    WHERE   instance_id > COALESCE((SELECT MAX(instance_id) FROM msdb.dbo.sysjobhistory
                                    WHERE job_id = $(ESCAPE_SQUOTE(JOBID)) AND step_id = 0), 0)
            AND h.job_id = $(ESCAPE_SQUOTE(JOBID))
    ) as agg

WHERE ReverseTryOrder = 1 ---Escoger el ultimo intento
  AND run_status <> 1 -- Mostrar solo los que fallaron


SET @NumofFails = ISNULL(@@ROWCOUNT,0)---Guardar numero de fallos


------------------------- Si hubieron fallos, crear correo y enviar ------------------------------------------------
IF  @NumofFails <> 0
    BEGIN

        DECLARE @PluralS as char(1) = CASE WHEN @NumofFails > 1 THEN 's' ELSE '' END --- Gramática
		DECLARE @PluralRON as char(4) = CASE WHEN @NumofFails > 1 THEN 'aron' ELSE 'ó' END --- Gramática
        SELECT top 1 @Subj = 'El Job ''' + job_name + ''' tuvo ' + CAST(@NumofFails as varchar(3)) + ' paso' + @PluralS + ' que fall'+ @PluralRON
                    ,@Msg =  'Detalle del fallo:' +CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)

                        FROM dbo.#Errs


        WHILE @i <= @NumofFails 
        BEGIN
            SELECT @Msg = @Msg + 'Paso ' + CAST(step_id as varchar(3)) + ': ' + step_name  +CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)

            + [message] +CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10) FROM dbo.#Errs
            WHERE rn = @i


            SET @i = @i + 1
        END
			SET @Msg=@Msg+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)+CHAR(13) + CHAR(10)  --Mandar aviso por defecto del correo bien abajo
            exec msdb.dbo.sp_send_dbmail
            @recipients = @correoDestinatarios,
            @subject = @Subj,
            @profile_name = @perfilDeCorreos,
            @body = @Msg


    END