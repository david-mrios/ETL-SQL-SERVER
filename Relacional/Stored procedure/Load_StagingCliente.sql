USE [TecnoNic]
GO
/****** Object:  StoredProcedure [dbo].[Load_StagingCliente]    Script Date: 11/6/2024 23:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Crear o modificar el procedimiento para cargar datos
CREATE or alter PROCEDURE [dbo].[Load_StagingCliente]
    @LastLoadDate DATETIME,
    @NewLoadDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT 
        'XML|' + CONVERT(NVARCHAR, C.Id) AS [_Source Key],
        CONVERT(NVARCHAR(100), C.Nombre) AS [Nombre],
        CONVERT(NVARCHAR(100), C.Apellido) AS [Apellido],
        CONVERT(NVARCHAR(100), C.Email) AS [Email],
        CONVERT(NVARCHAR(100), C.Telefono) AS Telefono,
		CONVERT(NVARCHAR(100), C.Direccion) AS [Direccion],
		CONVERT(NVARCHAR(100), C.Ciudad) AS [Ciudad],
		CONVERT(NVARCHAR(100), C.Pais) AS [Pais],
		CONVERT(NVARCHAR(100), C.Estado) AS [Estado],
        CONVERT(INT, C.Codigo_Postal) AS [Codigo Postal],
        CONVERT(INT, P.Puntos ) AS [Puntos Fidelidad],
        CONVERT(DATETIME, ISNULL(C.ModifiedDate, '1753-01-01')) AS [Valid From],
        CONVERT(DATETIME, '9999-12-31') AS [Valid To]
    FROM 
        Clientes AS C
    INNER JOIN 
        Programa_Fidelidades AS P ON P.ClienteId = C.Id	
    WHERE 
        C.ModifiedDate > @LastLoadDate AND C.ModifiedDate <= @NewLoadDate;

    RETURN 0;
END;
