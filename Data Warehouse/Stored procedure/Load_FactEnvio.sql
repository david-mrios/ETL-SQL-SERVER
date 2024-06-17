USE [TecnoNic_DW]
GO
/****** Object:  StoredProcedure [dbo].[Load_FactEnvio]    Script Date: 11/6/2024 23:14:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE or alter PROCEDURE [dbo].[Load_FactEnvio]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime = '9999-12-31';
    DECLARE @LastDateLoaded datetime;

    BEGIN TRAN;
		
    DECLARE @LineageKey int = ISNULL((SELECT TOP(1) [LineageKey]
                                      FROM int.Lineage
                                      WHERE [TableName] = N'Fact_Envio'
                                      AND [FinishLoad] IS NULL
                                      ORDER BY [LineageKey] DESC), -1);

		UPDATE s
	SET 
		s.[Pedido Key] = COALESCE((
									SELECT TOP(1) p.[Pedido Key]
									FROM dim_Pedido AS p
									WHERE REPLACE(p.[_Source Key], 'XML|', '') = CAST(s.[_Source Pedido Key] AS NVARCHAR(50))
									AND s.[Modified Date] >= p.[Valid From]
									AND s.[Modified Date] < p.[Valid To]
									ORDER BY p.[Valid From]
								  ), (
									SELECT TOP(1) p.[Pedido Key]
									FROM dim_Pedido AS p
									WHERE p.[_Source Key] = ''
								  ), 0),
		s.[Oferta Key] = COALESCE((
									SELECT TOP(1) o.[Oferta Key]
									FROM dim_Ofertas AS o
									WHERE REPLACE(o.[_Source Key], 'XML|', '') = CAST(s.[_Source Oferta Key] AS NVARCHAR(50))
									AND s.[Modified Date] >= o.[Valid From]
									AND s.[Modified Date] < o.[Valid To]
									ORDER BY o.[Valid From]
								  ), (
									SELECT TOP(1) o.[Oferta Key]
									FROM dim_Ofertas AS o
									WHERE o.[_Source Key] = ''
								  ), 0),
		s.[Area Envio Key] = COALESCE((
										SELECT TOP(1) a.[Area Envio Key]
										FROM dim_AreaEnvio AS a
										WHERE REPLACE(a.[_Source Key], 'XML|', '') = CAST(s.[_Source Area Envio Key] AS NVARCHAR(50))
										AND s.[Modified Date] >= a.[Valid From]
										AND s.[Modified Date] < a.[Valid To]
										ORDER BY a.[Valid From]
									  ), (
										SELECT TOP(1) a.[Area Envio Key]
										FROM dim_AreaEnvio AS a
										WHERE a.[_Source Key] = ''
									  ), 0),
		s.[Cliente Key] = COALESCE((
									SELECT TOP(1) c.[Cliente Key]
									FROM dim_Cliente AS c
									WHERE REPLACE(c.[_Source Key], 'XML|', '') = CAST(s.[_Source Cliente Key] AS NVARCHAR(50))
									AND s.[Modified Date] >= c.[Valid From]
									AND s.[Modified Date] < c.[Valid To]
									ORDER BY c.[Valid From]
								  ), 0),
		s.[Producto Key] = COALESCE((
									SELECT TOP(1) p.[Producto Key]
									FROM dim_Producto AS p
									WHERE REPLACE(p.[_Source Key], 'XML|', '') = CAST(s.[_Source Producto Key] AS NVARCHAR(50))
									AND s.[Modified Date] >= p.[Valid From]
									AND s.[Modified Date] < p.[Valid To]
									ORDER BY p.[Valid From]
								  ), 0),
		s.[Ubicacion Key] = COALESCE((
									SELECT TOP(1) u.[Ubicacion Key]
									FROM dim_Ubicacion AS u
									WHERE REPLACE(u.[_Source Key], 'XML|', '') = CAST(s.[_Source Ubicacion Key] AS NVARCHAR(50))
									AND s.[Modified Date] >= u.[Valid From]
									AND s.[Modified Date] < u.[Valid To]
									ORDER BY u.[Valid From]
								  ), 0)
	FROM [dbo].[staging_Envio] AS s;


    -- Eliminar datos de la tabla de hechos que estén presentes ahora en la tabla de staging
    DELETE f
    FROM [dbo].[Fact_Envio] AS f
    WHERE f.[_Source Pedido Key] IN (SELECT [_Source Pedido Key] FROM [dbo].[staging_Envio]);

    -- Insertar desde staging a la tabla de hechos
    INSERT INTO [dbo].[Fact_Envio]
           ([Pedido Key]
           ,[Oferta Key]
           ,[Area Envio Key]
           ,[Cliente Key]
           ,[Producto Key]
           ,[Ubicacion Key]
           ,[Empresa Envio]
           ,[Metodo Envio]
           ,[Fecha Envio]
           ,[Fecha Entrega]
           ,[_Source Pedido Key]
           ,[Lineage Key])
    SELECT 
            [Pedido Key]
           ,[Oferta Key]
           ,[Area Envio Key]
           ,[Cliente Key]
           ,[Producto Key]
           ,[Ubicacion Key]
           ,[Empresa Envio]
           ,[Metodo Envio]
           ,[Fecha Envio]
           ,[Fecha Entrega]
           ,[_Source Pedido Key]
           ,@LineageKey
    FROM [dbo].[staging_Envio]

    -- Actualizar la tabla de linaje con la fecha de finalización y el estado
    UPDATE [int].Lineage
        SET 
            FinishLoad = SYSDATETIME(),
            Status = 'S',
            LastLoadedDate = GETDATE()
    WHERE [LineageKey] = @LineageKey;

    -- Actualizar la tabla de fechas de carga con la fecha más reciente para Fact_Envio
    UPDATE [int].[IncrementalLoads]
        SET [LoadDate] = ISNULL(@LastDateLoaded, GETDATE())
    WHERE [TableName] = N'Fact_Envio';

    COMMIT;

    RETURN 0;
END;
