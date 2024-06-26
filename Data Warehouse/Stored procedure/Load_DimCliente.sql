USE [TecnoNic_DW]
GO
/****** Object:  StoredProcedure [dbo].[Load_DimCliente]    Script Date: 11/6/2024 23:13:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE or alter PROCEDURE [dbo].[Load_DimCliente]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime = '9999-12-31';
    DECLARE @LastDateLoaded datetime;

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [LineageKey]
                               FROM int.Lineage
                               WHERE [TableName] = N'dim_Cliente'
                               AND [FinishLoad] IS NULL
                               ORDER BY [LineageKey] DESC);

    UPDATE initial
    SET initial.[Valid To] = modif.[Valid From]
    FROM 
        Dim_Cliente AS initial INNER JOIN 
        Staging_Cliente AS modif ON initial.[_Source Key] = modif.[_Source Key]
    WHERE initial.[Valid To] = @EndOfTime;

    IF NOT EXISTS (SELECT 1 FROM Dim_Cliente WHERE [_Source Key] = '')
        INSERT Dim_Cliente
               ([_Source Key], [Nombre], [Apellido], [Email], [Telefono], 
                [Direccion], [Ciudad], [Pais], [Estado], [Codigo Postal], 
                [Puntos Fidelidad], [Valid From], [Valid To], [Lineage Key])
        VALUES ('', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 
                'Unknown', 'Unknown', 'Unknown', 'Unknown', 0, 
                0, '1753-01-01', '9999-12-31', -1);

    INSERT dim_Cliente
           ([_Source Key], [Nombre], [Apellido], [Email], [Telefono], 
            [Direccion], [Ciudad], [Pais], [Estado], [Codigo Postal], 
            [Puntos Fidelidad], [Valid From], [Valid To], [Lineage Key])
    SELECT  [_Source Key], [Nombre], [Apellido], [Email], [Telefono], 
            [Direccion], [Ciudad], [Pais], [Estado], [Codigo Postal], 
            [Puntos Fidelidad], [Valid From], [Valid To], @LineageKey
    FROM staging_Cliente;

    UPDATE [int].Lineage
        SET 
            FinishLoad = SYSDATETIME(),
            Status = 'S',
            @LastDateLoaded = LastLoadedDate
    WHERE [LineageKey] = @LineageKey;

    UPDATE [int].[IncrementalLoads]
        SET [LoadDate] = @LastDateLoaded
    WHERE [TableName] = N'dim_Cliente';

    COMMIT;

    RETURN 0;
END;
