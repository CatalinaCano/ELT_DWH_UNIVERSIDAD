 --Drop la función si existe
  IF OBJECT_ID('UscPLM.EndComma') IS NOT NULL
    DROP FUNCTION UscPLM.EndComma;
  GO

 
 CREATE FUNCTION UscPLM.EndComma (@inStr VARCHAR(8000))
  RETURNS VARCHAR(8000)
  AS
 BEGIN
 
 DECLARE 
 @Cadena VARCHAR(8000) = @inStr,
 @len INT,
 @cont INT ,
 @outStr VARCHAR(8000);
 SET @len = LEN(@Cadena)
 SET @cont = @len
 SET @outStr =  @Cadena


WHILE @cont <=  @len  AND @cont >0
BEGIN
   IF SUBSTRING (@outStr,@cont,@cont) = ',' 
	BEGIN 
	   SET @outStr = SUBSTRING (@outStr,1,@cont-1) ;
	   SET @cont = @cont -1;
	END
   ELSE
       BREAK;
     
END;
 



  RETURN @outStr
  END
  GO

  


 -- SELECT UscPLM.EndComma ('B16,B59,B54,T32,,,,,,')



 