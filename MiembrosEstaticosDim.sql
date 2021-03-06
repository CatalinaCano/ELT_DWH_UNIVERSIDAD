/**
* Miembros estaticos de una Dimensión
* Valida que no exista ningun registro en la dimension y en caso de que sea verdadero
* Inserta los registros de miembros estáticos.
**/

If (Select Count(*) From DimTransportadora) = 0
Begin
    
   SET IDENTITY_INSERT DimTransportadora ON  
		Insert Into DimTransportadora (SkTransportadora,IdTransportadora,DsTransportadora,ModoTransporte,activo)
		Values (-2,'-2','NO APLICA','NO APLICA','-2' )

		Insert Into DimTransportadora(SkTransportadora,IdTransportadora,DsTransportadora,ModoTransporte,activo)
		Values (-1,'-1','NO DEFINIDO','NO DEFINIDO','-1' )

		SET IDENTITY_INSERT DimTransportadora OFF
	Dbcc CHECKIDENT(DimTransportadora, RESEED, 1 ); --El comando RESEED hacia que los registros	nuevos empezaran desde el numero especificado
End