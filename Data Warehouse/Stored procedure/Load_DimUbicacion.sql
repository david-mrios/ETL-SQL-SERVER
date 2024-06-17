USE [TecnoNic_DW]
GO
/****** Object:  StoredProcedure [dbo].[Load_DimUbicacion]    Script Date: 11/6/2024 23:14:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE or alter PROCEDURE [dbo].[Load_DimUbicacion]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime = '9999-12-31';
    DECLARE @LastDateLoaded datetime;

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [LineageKey]
                               FROM int.Lineage
                               WHERE [TableName] = N'dim_Ubicacion'
                               AND [FinishLoad] IS NULL
                               ORDER BY [LineageKey] DESC);

    UPDATE initial
    SET initial.[Valid To] = modif.[Valid From]
    FROM 
        dim_Ubicacion AS initial INNER JOIN 
        staging_Ubicacion AS modif ON initial.[_Source Key] = modif.[_Source Key]
    WHERE initial.[Valid To] = @EndOfTime;

    IF NOT EXISTS (SELECT 1 FROM dim_Ubicacion WHERE [_Source Key] = '')
        INSERT dim_Ubicacion
               ([_Source Key]
               ,[Direccion Envio]
               ,[Estado Envio]
               ,[Pais Envio]
               ,[Ciudad Envio]
               ,[Valid From]
               ,[Valid To]
               ,[Lineage Key])
        VALUES ('', 'Unknown', 'Unknown', 'Unknown', 'Unknown', '1753-01-01', '9999-12-31', -1);

    INSERT dim_Ubicacion
           ([_Source Key]
           ,[Direccion Envio]
           ,[Estado Envio]
           ,[Pais Envio]
           ,[Ciudad Envio]
           ,[Valid From]
           ,[Valid To]
           ,[Lineage Key])
    SELECT  [_Source Key]
           ,[Direccion Envio]
           ,[Estado Envio]
           ,[Pais Envio]
           ,[Ciudad Envio]
           ,[Valid From]
           ,[Valid To]
           ,@LineageKey
    FROM staging_Ubicacion;

    UPDATE [int].Lineage
        SET 
            FinishLoad = SYSDATETIME(),
            Status = 'S',
            @LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;

    UPDATE [int].[IncrementalLoads]
        SET [LoadDate] = @LastDateLoaded
    WHERE [TableName] = N'dim_Ubicacion';

    COMMIT;

    RETURN 0;
END;
