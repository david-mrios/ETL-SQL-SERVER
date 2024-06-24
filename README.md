<div align="center">

# Proceso ETL en SQL SERVER

## Hecho por:

<br/>

<p> <strong> 1. Carlos Manuel Vargas López. </strong></p>
<p> <strong> 2. Iris Violeta Talavera. </strong></p>
<p> <strong> 3. David Antonio Membreño Ríos. </strong></p>
<p> <strong> 4. Jocsan Stiven Mejía Villereal. </strong></p>
<p> <strong> 5. Jether Alejandro Martínez Solís. </strong></p>

<br/>

<p align="center">
  <img src="https://th.bing.com/th/id/OIP.wp7VLwfL8Z8gsOHP1J3i8wHaEn?rs=1&pid=ImgDetMain" alt="Texto alternativo" width="400">
</p>

</div>



## Introducción
Este proyecto documenta el proceso de Extracción, Transformación y Carga (ETL) para el Data Warehouse (DW) de TecnoNic_DW. Se detalla la creación y carga de las dimensiones, el esquema de staging, y los procedimientos almacenados necesarios para gestionar estas operaciones. Además, se hace uso del DLL TecnoNic para procedimientos específicos de carga.

## Contenido
1. Arquitectura del Data Warehouse
2. Arquitectura del DLL
3. Esquema INT
4. Procedimientos Almacenados del Data Warehouse y del DLL
5. Carga de Datos

## Arquitectura del Data Warehouse
El Data Warehouse TecnoNic_DW está organizado en dos niveles principales:

1. **Staging**: Área temporal para la carga y transformación de datos antes de moverlos a las tablas finales.
2. **Dimensiones**: Tablas dimensionales que contienen los datos maestros para el análisis.

## SCHEMA INT

El esquema de INT es fundamental para la transformación y limpieza de datos antes de su carga en las dimensiones y las Staging. Incluye las siguientes tablas:

- **lineagekey**: Para el seguimiento del origen de los datos.
- **incrementaload**: Para manejar cargas incrementales de datos.

## Procedimientos Almacenados

### Carga de Staging
Los procedimiento almacenado `load_staging` en el DLL TecnoNic se encarga de cargar los datos en las tablas de staging. Este proceso incluye la inserción de datos en las tablas lineagekey e incrementaload, asegurando que los datos temporales estén listos para ser transformados y cargados en las dimensiones.

### Carga de Dimensiones
Los procedimiento almacenado `load_dim` maneja la carga y actualización de datos en las dimensiones. Este proceso incluye la inserción de nuevos registros y la actualización de registros existentes, asegurando la integridad y la coherencia de los datos en el Data Warehouse.

## Carga de Datos

1. **Cargar Staging**: Utilizar los procedimiento `load_staging` para cargar los datos en las tablas de staging. Este paso prepara los datos para su transformación y limpieza.
   
2. **Cargar Dimensiones**: Utilizar los procedimiento `load_dim` para cargar y actualizar los datos en las tablas dimensionales. Este paso finaliza el proceso ETL, asegurando que los datos estén correctamente estructurados para el análisis.

## Conclusión
Este README proporciona una guía sobre cómo estructurar y cargar datos en el Data Warehouse TecnoNic_DW. Los procedimientos almacenados `load_staging` y `load_dim` son esenciales para el flujo de ETL y garantizan que los datos se procesen y carguen correctamente. Personalice las tablas y procedimientos según las necesidades específicas de su proyecto para asegurar una implementación exitosa.

## Visita el repositorio sobre la ejecución de un ETL en un proyecto SSIS 

[Proyecto SSIS](https://github.com/david-mrios/ETL-SSIS.git)

