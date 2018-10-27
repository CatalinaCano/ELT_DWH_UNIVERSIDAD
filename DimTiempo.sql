create table DIM_TIEMPO
(
    SkFecha int not null,
    Fecha date not null, 
    Año smallint not null,
    Trimestre smallint not null,
    Mes smallint not null,
    Semana smallint not null,
    Dia smallint not null,
    DiaSemana smallint not null,
    NTrimestre char(7) not null,
    NMes char(15) not null,
    NMes3L char(3) not null,
    NSemana char(10) not null,
    NDia char(6) not null,
    NDiaSemana char(10) not null
    constraint PK_DIM_TIEMPO PRIMARY KEY CLUSTERED
    (
        Fecha asc
    )
)

/*Script de carga*/
DECLARE @FechaDesde as smalldatetime, @FechaHasta as smalldatetime
DECLARE @FechaAAAAMMDD int
DECLARE @Año as smallint, @Trimestre char(2), @Mes smallint
DECLARE @Semana smallint, @Dia smallint, @DiaSemana smallint
DECLARE @NTrimestre char(7), @NMes char(15)
DECLARE @NMes3l char(3)
DECLARE @NSemana char(10), @NDia char(6), @NDiaSemana char(10)
--Set inicial por si no coincide con los del servidor
SET DATEFORMAT dmy
SET DATEFIRST 1

BEGIN TRANSACTION
    --Borrar datos actuales, si fuese necesario
    --TRUNCATE TABLE FROM DI_TIEMPO
   
    --RAngo de fechas a generar: del 01/01/2006 al 31/12/Año actual+2
    SELECT @FechaDesde = CAST('20060101' AS smalldatetime)
    SELECT @FechaHasta = CAST(CAST(YEAR(GETDATE())+2 AS CHAR(4)) + '1231' AS smalldatetime)
   
    WHILE (@FechaDesde <= @FechaHasta) BEGIN
    SELECT @FechaAAAAMMDD = YEAR(@FechaDesde)*10000+
                            MONTH(@FechaDesde)*100+
                            DATEPART(dd, @FechaDesde)
    SELECT @Año = DATEPART(yy, @FechaDesde)
    SELECT @Trimestre = DATEPART(qq, @FechaDesde)
    SELECT @Mes = DATEPART(m, @FechaDesde)
    SELECT @Semana = DATEPART(wk, @FechaDesde)
    SELECT @Dia = RIGHT('0' + DATEPART(dd, @FechaDesde),2)
    SELECT @DiaSemana = DATEPART(DW, @FechaDesde)
    SELECT @NMes = DATENAME(mm, @FechaDesde)
    SELECT @NMes3l = LEFT(@NMes, 3)
    SELECT @NTrimestre = 'T' + CAST(@Trimestre as CHAR(1)) + '/' + RIGHT(@Año, 2)
    SELECT @NSemana = 'Sem ' +CAST(@Semana AS CHAR(2)) + '/' + RIGHT(RTRIM(CAST(@Año as CHAR(4))),2)
    SELECT @NDia = CAST(@Dia as CHAR(2)) + ' ' + RTRIM(@NMes)
    SELECT @NDiaSemana = DATENAME(dw, @FechaDesde)
    INSERT INTO DIM_TIEMPO
    (
        SkFecha,
        Fecha,
        Año,
        Trimestre,
        Mes,
        Semana,
        Dia,
        DiaSemana,
        NTrimestre,
        NMes,
        NMes3L,
        NSemana,
        NDia,
        NDiaSemana
    ) VALUES
    (
        @FechaAAAAMMDD,
        @FechaDesde,
        @Año,
        @Trimestre,
        @Mes,
        @Semana,
        @Dia,
        @DiaSemana,
        @NTrimestre,
        @NMes,
        @NMes3l,
        @NSemana,
        @NDia,
        @NDiaSemana
    )
   
    --Incremento del bucle
    SELECT @FechaDesde = DATEADD(DAY, 1, @FechaDesde)
    END
    COMMIT TRANSACTION