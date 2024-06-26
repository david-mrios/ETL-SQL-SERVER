USE [TecnoNic]
GO
/****** Object:  StoredProcedure [dbo].[Load_StagingAreaEnvio]    Script Date: 11/6/2024 23:09:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Crear o modificar el procedimiento para cargar datos en staging_AreaEnvio
CREATE or alter PROCEDURE [dbo].[Load_StagingAreaEnvio]
    @LastLoadDate DATETIME,
    @NewLoadDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT
        'XML|' + CONVERT(NVARCHAR(50), A.Id) AS [_Source Key],
        CONVERT(nvarchar(100), A.NombreArea) AS [Area], 
        CONVERT(decimal(10,2),A.CostoEnvio) AS [Costo Envio], 
        CONVERT(datetime,A.ModifiedDate) AS [Valid From],
        CONVERT(DATETIME, '9999-12-31') AS [Valid To]
    FROM 
        Area_Envios AS A
    WHERE 
        A.ModifiedDate > @LastLoadDate AND A.ModifiedDate <= @NewLoadDate;

    RETURN 0;
END;
