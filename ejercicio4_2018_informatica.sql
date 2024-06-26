/**

-- Después de ejecutar "script_create_oposicion_user.sql"
-- Deberíamos de tener creado el contenedor "my-mysql"

-- #####################################################################################
-- #####################################################################################

-- Puedo ver las imagenes que tengo en mi docker
--      # docker images

--        REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
--        mariadb      latest    6e11fcfc66ad   12 days ago   401MB
--        postgres     latest    3b6645d2c145   13 days ago   379MB
--        mysql        latest    4f06b49211c0   2 weeks ago   530MB

-- Y puedo ver que contenedores tengo
--      # docker container ls -a

--        CONTAINER ID   IMAGE     COMMAND                  CREATED             STATUS                     PORTS     NAMES
--        7a63f3fcec7b   mysql     "docker-entrypoint.s…"   About an hour ago   Exited (0) 5 seconds ago             my-mysql

-- Y ver cuáles están en ejecución:
--      # docker ps -a

--        CONTAINER ID   IMAGE     COMMAND                  CREATED             STATUS                     PORTS     NAMES
--        7a63f3fcec7b   mysql     "docker-entrypoint.s…"   About an hour ago   Exited (0) 2 minutes ago             my-mysql

-- ####
-- Para parar el contenedor "my-mysql":
--      # docker container stop my-mysql

--        my-mysql

-- Para volverlo a arrancar:
--      # docker container start my-mysql

--        my-mysql

-- Y comprobamos que está arrancado:
--      # docker container ls

--        CONTAINER ID   IMAGE     COMMAND                  CREATED             STATUS          PORTS                               NAMES
--        7a63f3fcec7b   mysql     "docker-entrypoint.s…"   About an hour ago   Up 46 seconds   33060/tcp, 0.0.0.0:3307->3306/tcp   my-mysql
-- ####

-- Copiamos dicho script de nuesto HOST al contenedor:
--      # docker cp "C:\Proyectos\Bases de Datos\MySQL\ejercicio4_2018_informatica.sql" my-mysql:/tmp/

-- Y abrimos una terminal interactiva con nuesto contenedor:
--      # docker exec -it my-mysql sh

--        sh-4.4#
    
-- Dentro de la terminal interactiva comprobamos que se encuentra nuestro fichero:
--      sh-4.4# ls -la /tmp/

--        total 24
--        drwxrwxrwt 1 root root 4096 Mar 14 22:19 .
--        drwxr-xr-x 1 root root 4096 Mar 14 22:19 ..
--        -rwxr-xr-x 1 root root 8400 Mar 14 22:18 ejercicio4_2018_informatica.sql
--        -rwxr-xr-x 1 root root 3867 Mar 14 20:38 script_create_oposicion_user.sql

-- #####################################################################################
-- #####################################################################################

-- Y conectamos con el usuario "oposicion" (creado con el script "script_create_oposicion_user.sql")

sh-4.4# mysql -u oposicion -p1234

    mysql: [Warning] Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 8
    Server version: 8.0.32 MySQL Community Server - GPL

    Copyright (c) 2000, 2023, Oracle and/or its affiliates.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

-- ejecutamos este script:

mysql> source /tmp/ejercicio4_2018_informatica.sql

**/

-- ***  Lenguaje de Definición de Datos (DDL) ***

-- Creamos la Base de Datos 'exam2018'

CREATE DATABASE IF NOT EXISTS exam2018;

-- Le indicamos que utilice dicha Base de Datos 'exam2018'

USE exam2018;

-- Creamos la tabla 'proyecto'
CREATE TABLE IF NOT EXISTS proyecto (
    CODIGO INT PRIMARY KEY COMMENT 'Código del proyecto',
    NOMBRE VARCHAR(90) UNIQUE NOT NULL COMMENT 'Nombre del Proyecto'
);

-- Creamos la tabla 'empleado'
CREATE TABLE IF NOT EXISTS empleado (
    ID INT PRIMARY KEY COMMENT 'Identificador del empleado',
    NOMBRE VARCHAR(90) NOT NULL COMMENT 'Nombre del empleado',
    DNI VARCHAR(5) UNIQUE NOT NULL COMMENT 'Número del DNI',
    JEFE INT COMMENT 'Identificador del empleado que es el Jefe de dicho Empleado',
    CONSTRAINT fk_jefe
        FOREIGN KEY (JEFE)
        REFERENCES empleado(ID)
        ON UPDATE CASCADE -- 'Cuando un empleado se elimina, su jefe sigue permaneciendo. Y si la persona actualiza su identificación, se actualiza automáticamente para todos aquellos que esa persona sea su jefe.'
);

-- Creamos la tabla 'asignacion'
CREATE TABLE IF NOT EXISTS asignacion (
    ID INT COMMENT 'Corresponderá con el Identificador del empleado que tiene asignado un proyecto',
    CODIGO INT COMMENT 'Corresponderá con el Código de proyecto que tiene asignado un empleado',
    CONSTRAINT pk_asignacion
        PRIMARY KEY (ID,CODIGO),
    CONSTRAINT fk_id_asig
        FOREIGN KEY (ID)
        REFERENCES empleado(ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE, -- 'Si un empleado se elimina o actualiza, se eliminan o actualizan las asignaciones de proyecto que pudiera tener.'
    CONSTRAINT fk_codigo_asig
        FOREIGN KEY (CODIGO)
        REFERENCES proyecto(CODIGO)
        ON DELETE CASCADE
        ON UPDATE CASCADE -- 'Cuando un proyecto es eliminado o modificado, se eliminan o modifican automáticamente las asignaciones correspondientes.'
);

-- Creamos la tabla 'vehiculo'
CREATE TABLE IF NOT EXISTS vehiculo (
    MATRICULA VARCHAR(7) PRIMARY KEY COMMENT 'Matrícula del vehículo',
    MARCA VARCHAR(25) NOT NULL COMMENT 'Marca del vehículo',
    MODELO VARCHAR(90) NOT NULL COMMENT 'Modelo del vehículo',
    PERSONA INT COMMENT 'Identificador del empleado que tiene asignado dicho vehículo o NULO',
    CONSTRAINT fk_persona
        FOREIGN KEY (PERSONA)
        REFERENCES empleado(ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE -- 'Cuando un empleado es eliminado, el vehículo que pudiera tener concertado no es eliminado y si la persona actualiza su identificación, automáticamente se actualiza también en su vehículo si lo tuviera.'
);

-- ***  Lenguaje de Manipulación de Datos (DML) ***

-- Iniciamos una transacción:
START TRANSACTION;

-- He insertamos los datos:
-- Datos de la tabla 'proyecto':
INSERT INTO proyecto(CODIGO, NOMBRE) VALUES (101,'GRANATE');
INSERT INTO proyecto(CODIGO, NOMBRE) VALUES (102,'RUBI');
INSERT INTO proyecto(CODIGO, NOMBRE) VALUES (103,'ESMERALDA');

-- Datos de la tabla 'empleado'
INSERT INTO empleado(ID, NOMBRE, DNI, JEFE) VALUES (10,'ANA MARTIN','1111A',NULL);
INSERT INTO empleado(ID, NOMBRE, DNI, JEFE) VALUES (15,'JUAN LOPEZ','2222B',10);
INSERT INTO empleado(ID, NOMBRE, DNI, JEFE) VALUES (20,'CARMEN DIAZ','3333C',10);
INSERT INTO empleado(ID, NOMBRE, DNI, JEFE) VALUES (25,'ERNESTO GOMEZ','4444D',20);
INSERT INTO empleado(ID, NOMBRE, DNI, JEFE) VALUES (30,'SILVIA GONZALEZ','5555E',15);
INSERT INTO empleado(ID, NOMBRE, DNI, JEFE) VALUES (35,'FERNANDO SIERRA','7777F',15);

-- Datos de la tabla 'asignacion'
INSERT INTO asignacion(ID, CODIGO) VALUES (10,101);
INSERT INTO asignacion(ID, CODIGO) VALUES (15,101);
INSERT INTO asignacion(ID, CODIGO) VALUES (20,101);
INSERT INTO asignacion(ID, CODIGO) VALUES (10,102);
INSERT INTO asignacion(ID, CODIGO) VALUES (15,102);
INSERT INTO asignacion(ID, CODIGO) VALUES (30,102);
INSERT INTO asignacion(ID, CODIGO) VALUES (35,102);
INSERT INTO asignacion(ID, CODIGO) VALUES (20,103);
INSERT INTO asignacion(ID, CODIGO) VALUES (25,103);
INSERT INTO asignacion(ID, CODIGO) VALUES (30,103);

-- Datos de la tabla 'vehiculo'
INSERT INTO vehiculo(MATRICULA, MARCA, MODELO, PERSONA) VALUES ('2345AAA','Seat','Altea',NULL);
INSERT INTO vehiculo(MATRICULA, MARCA, MODELO, PERSONA) VALUES ('1234BBB','Opel','Astra',15);
INSERT INTO vehiculo(MATRICULA, MARCA, MODELO, PERSONA) VALUES ('5555CCC','Seat','Ibiza',NULL);
INSERT INTO vehiculo(MATRICULA, MARCA, MODELO, PERSONA) VALUES ('9876DDD','Lexus','LC',10);
INSERT INTO vehiculo(MATRICULA, MARCA, MODELO, PERSONA) VALUES ('1111FFF','Seat','Ibiza',NULL);
INSERT INTO vehiculo(MATRICULA, MARCA, MODELO, PERSONA) VALUES ('2222GGG','Opel','Astra',20);

-- Confirmamos todas las inserciones de datos en la Base de Datos 'exam2018'
COMMIT;

-- 2.1. Listado de los empleados que tienen jefe y nombre de su jefe. 
    
    SELECT e.*,
           j.nombre as 'Nombre Jefe'
     FROM empleado e, empleado j
    WHERE e.jefe IS NOT NULL
      AND e.jefe = j.id;

--    +----+-----------------+-------+------+-------------+
--    | ID | NOMBRE          | DNI   | JEFE | Nombre Jefe |
--    +----+-----------------+-------+------+-------------+
--    | 15 | JUAN LOPEZ      | 2222B |   10 | ANA MARTIN  |
--    | 20 | CARMEN DIAZ     | 3333C |   10 | ANA MARTIN  |
--    | 30 | SILVIA GONZALEZ | 5555E |   15 | JUAN LOPEZ  |
--    | 35 | FERNANDO SIERRA | 7777F |   15 | JUAN LOPEZ  |
--    | 25 | ERNESTO GOMEZ   | 4444D |   20 | CARMEN DIAZ |
--    +----+-----------------+-------+------+-------------+
--    5 rows in set (0.00 sec)

-- 2.2. Listado de todas las personas y si tienen vehículo asignado matrículas del mismo.
   SELECT e.*,
          v.matricula
     FROM empleado e
LEFT JOIN vehiculo v ON e.id = v.persona;

--    +----+-----------------+-------+------+-----------+
--    | ID | NOMBRE          | DNI   | JEFE | matricula |
--    +----+-----------------+-------+------+-----------+
--    | 10 | ANA MARTIN      | 1111A | NULL | 9876DDD   |
--    | 15 | JUAN LOPEZ      | 2222B |   10 | 1234BBB   |
--    | 20 | CARMEN DIAZ     | 3333C |   10 | 2222GGG   |
--    | 25 | ERNESTO GOMEZ   | 4444D |   20 | NULL      |
--    | 30 | SILVIA GONZALEZ | 5555E |   15 | NULL      |
--    | 35 | FERNANDO SIERRA | 7777F |   15 | NULL      |
--    +----+-----------------+-------+------+-----------+
--    6 rows in set (0.00 sec)

-- 2.3. Nombre y código de proyecto del proyecto que tenga más personal asignado.
SELECT *
  FROM proyecto p 
 WHERE p.codigo = (  SELECT b.codigo 
                       FROM (  SELECT count(*) as cuenta, aux.codigo 
                                 FROM asignacion aux
                             GROUP BY aux.codigo
                             ORDER BY 1 desc LIMIT 1) b 
                  );

--    +--------+--------+
--    | CODIGO | NOMBRE |
--    +--------+--------+
--    |    102 | RUBI   |
--    +--------+--------+
--    1 row in set (0.00 sec)