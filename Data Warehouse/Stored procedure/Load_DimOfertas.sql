USE [TecnoNic_DW]
GO
/****** Object:  StoredProcedure [dbo].[Load_DimOfertas]    Script Date: 11/6/2024 23:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE or alter PROCEDURE [dbo].[Load_DimOfertas]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime = '9999-12-31';
    DECLARE @LastDateLoaded datetime;

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [LineageKey]
                               FROM int.Lineage
                               WHERE [TableName] = N'dim_Ofertas'
                               AND [FinishLoad] IS NULL
                               ORDER BY [LineageKey] DESC);

    UPDATE initial
    SET initial.[Valid To] = modif.[Valid From]
    FROM 
        dim_Ofertas AS initial INNER JOIN 
        staging_Ofertas AS modif ON initial.[_Source Key] = modif.[_Source Key]
    WHERE initial.[Valid To] = @EndOfTime;

    IF NOT EXISTS (SELECT 1 FROM dim_Ofertas WHERE [_Source Key] = '')
        INSERT dim_Ofertas
               ([_Source Key], [Nombre], [Descripcion], [Descuento], [Cod Descuento], 
                [Fecha Lanzamiento], [Fecha Caducidad], [Valid From], [Valid To], [Lineage Key])
        VALUES ('', 'Unknown', 'Unknown', 0, 0, 
                '1753-01-01', '1753-01-01', '1753-01-01', '9999-12-31', -1);

    INSERT dim_Ofertas
           ([_Source Key], [Nombre], [Descripcion], [Descuento], [Cod Descuento], 
            [Fecha Lanzamiento], [Fecha Caducidad], [Valid From], [Valid To], [Lineage Key])
    SELECT  [_Source Key], [Nombre], [Descripcion], [Descuento], [Cod Descuento], 
            [Fecha Lanzamiento], [Fecha Caducidad], [Valid From], [Valid To], @LineageKey
    FROM staging_Ofertas;

    UPDATE [int].Lineage
        SET 
            FinishLoad = SYSDATETIME(),
            Status = 'S',
            @LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;

    UPDATE [int].[IncrementalLoads]
        SET [LoadDate] = @LastDateLoaded
    WHERE [TableName] = N'dim_Ofertas';

    COMMIT;

    RETURN 0;
END;
