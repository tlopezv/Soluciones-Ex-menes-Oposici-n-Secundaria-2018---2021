
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
--      # docker cp "C:\Proyectos\Bases de Datos\MySQL\ejercicio2_2021_informatica.sql" my-mysql:/tmp/

-- Y abrimos una terminal interactiva con nuesto contenedor:
--      # docker exec -it my-mysql sh

--        sh-4.4#
    
-- Dentro de la terminal interactiva comprobamos que se encuentra nuestro fichero:
--      sh-4.4# ls -la /tmp/

--        total 44
--        drwxrwxrwt 1 root root  4096 Mar 18 17:16 .
--        drwxr-xr-x 1 root root  4096 Mar 18 17:16 ..
--        -rwxr-xr-x 1 root root 12551 Mar 18 17:16 ejercicio2_2021_informatica.sql
--        -rwxr-xr-x 1 root root  8418 Mar 14 22:40 ejercicio4_2018_informatica.sql
--        -rwxr-xr-x 1 root root  4666 Mar 14 22:25 script_create_oposicion_user.sql

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

mysql> source /tmp/ejercicio2_2021_informatica.sql

**/

-- ***  Lenguaje de Definición de Datos (DDL) ***

-- Creamos la Base de Datos 'exam2021'

CREATE DATABASE IF NOT EXISTS exam2021 CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Le indicamos que utilice dicha Base de Datos 'exam2021'

USE exam2021;

-- Creamos la tabla 'usuario'
CREATE TABLE IF NOT EXISTS Usuario (
    usrId INT AUTO_INCREMENT PRIMARY KEY COMMENT 'La clave de usuario la genera internamente el propio gestor de base de datos.',
    nombre VARCHAR(30) NOT NULL COMMENT 'Nombre del usuario; obligatorio.',
    apellido1 VARCHAR(30) NOT NULL COMMENT 'Primer apellido del usuario; obligatorio.',
    apellido2 VARCHAR(30) COMMENT 'Segundo apellido del usuario',
    pais VARCHAR(3) NOT NULL COMMENT 'El país es un código de 3 caracteres; obligatorio.',
    tel INT COMMENT 'Teléfono del usuario.',
    fechaNac DATE NOT NULL COMMENT 'Fecha de nacimiento del usuario; obligatorio.',
    email VARCHAR(80) NOT NULL UNIQUE COMMENT 'Correo electrónico del usuario; obligatorio.' -- No puede haber dos usuarios o más con la misma dirección de correo electrónico.
);

-- Creamos la tabla 'redsocial'
CREATE TABLE IF NOT EXISTS RedSocial (
    nombre VARCHAR(30) PRIMARY KEY COMMENT 'Nombre de la red social',
    url VARCHAR(50) NOT NULL UNIQUE COMMENT 'URL de la red social',
    fechaLanzamiento DATE COMMENT 'Fecha de lanzamiento',
    logo BLOB COMMENT 'El fichero de imagen correspondiente al logo de la red social está almacenado en la carpeta /var/lib/mysql-files'
);

-- Creamos la tabla 'suscripcion'
CREATE TABLE IF NOT EXISTS Suscripcion (
    usrId INT COMMENT 'Identificador del usuario',
    nomRS VARCHAR(30) COMMENT 'Nombre de la red social',
    fechaIncorp TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de suscripción; si se desconoce se presupone que es la fecha y hora actuales',
    PRIMARY KEY (usrId, nomRS),
    CONSTRAINT fk_usrId
    FOREIGN KEY (usrId)
        REFERENCES Usuario(usrId)
            ON DELETE RESTRICT -- No se permite el borrado de usuarios con seguidores en alguna red social ;Si no especificamos esto, por defecto sería esta opción.
            ON UPDATE CASCADE,
    CONSTRAINT fk_nomRS
    FOREIGN KEY (nomRS)
        REFERENCES RedSocial(nombre)
            ON DELETE RESTRICT -- No se permite el borrado de redes sociales con usuarios suscritos; Si no especificamos esto, por defecto sería esta opción. 
            ON UPDATE CASCADE -- Es posible que una red social cambie de nombre
);

-- Creamos la tabla 'seguidores'
CREATE TABLE IF NOT EXISTS Seguidores (
    seguidoId INT COMMENT 'Identificador de usuario seguido',
    seguidorId INT COMMENT 'Identificador de usuario seguidor',
    nomRS VARCHAR(30) COMMENT 'Nombre de la red social',
    PRIMARY KEY (seguidoId, seguidorId, nomRS),
    CONSTRAINT fk_seguidoId
    FOREIGN KEY (seguidoId)
        REFERENCES Suscripcion(usrId)
            ON DELETE RESTRICT -- No se permite el borrado de usuarios con seguidores en alguna red social ;Si no especificamos esto, por defecto sería esta opción.
            ON UPDATE CASCADE,
    CONSTRAINT fk_seguidorId
    FOREIGN KEY (seguidorId)
        REFERENCES Suscripcion(usrId)
            ON DELETE RESTRICT -- No se permite el borrado de usuarios con seguidores en alguna red social ;Si no especificamos esto, por defecto sería esta opción.
            ON UPDATE CASCADE,
    CONSTRAINT fk_nomRS_seguidores
    FOREIGN KEY (nomRS)
        REFERENCES Suscripcion(nomRS)
            ON DELETE RESTRICT -- No se permite el borrado de redes sociales con usuarios suscritos; Si no especificamos esto, por defecto sería esta opción. 
            ON UPDATE CASCADE -- Es posible que una red social cambie de nombre
);

-- ***  Lenguaje de Manipulación de Datos (DML) ***

-- Iniciamos una transacción:
START TRANSACTION;

-- He insertamos los datos:
-- Datos de la tabla 'usuarios':
INSERT INTO Usuario(nombre, apellido1, apellido2, pais, tel, fechaNac, email) VALUES ('Alberto','Martínez','Cifuentes','esp','916665544','1945-08-01','albertomc@gmail.com');
INSERT INTO Usuario(nombre, apellido1, apellido2, pais, tel, fechaNac, email) VALUES ('María Ángeles','Robledo','González','esp','936667545','1976-10-15','mangelesrg@gmail.com');
INSERT INTO Usuario(nombre, apellido1, apellido2, pais, tel, fechaNac, email) VALUES ('José María','Viñuelas','Piez','esp','925662513','1987-12-24','josemvp@gmail.com');
INSERT INTO Usuario(nombre, apellido1, apellido2, pais, tel, fechaNac, email) VALUES ('Cristina','Lorente','Soria','esp','954446625','1954-01-14','crisls@gmail.com');

-- ####
-- Antes de insertar datos en la tabla 'RedSocial':
-- Nos dicen: "Cuando se da de alta una red social, ha de asumirse que el fichero de imagen correspondiente a su logo está almacenado en la carpeta /var/lib/mysql-files del propio servidor"

-- Luego tenemos que copiar los ficheros de nuestro HOST al contenedor:

-- Copiamos dichos ficheros de nuesto HOST al contenedor:
--      # docker cp "C:\Proyectos\Bases de Datos\MySQL\logos\LinkedIn_Logo.svg" my-mysql:/var/lib/mysql-files/
--      # docker cp "C:\Proyectos\Bases de Datos\MySQL\logos\Logo_Facebook.png" my-mysql:/var/lib/mysql-files/
--      # docker cp "C:\Proyectos\Bases de Datos\MySQL\logos\Logo-Instagram-PNG.png" my-mysql:/var/lib/mysql-files/

-- Y abrimos una terminal interactiva con nuesto contenedor:
--      # docker exec -it my-mysql sh

--        sh-4.4#
    
-- Dentro de la terminal interactiva comprobamos que se encuentra nuestro fichero:
--      sh-4.4# ls -la /var/lib/mysql-files/

--        total 200
--         drwxr-x--- 1 mysql mysql  4096 Mar 18 17:29 .
--        drwxr-xr-x 1 root  root   4096 Feb 24 00:37 ..
--        -rwxr-xr-x 1 root  root  57695 Mar 18 14:58 LinkedIn_Logo.svg
--        -rwxr-xr-x 1 root  root  53940 Mar 18 14:58 Logo-Instagram-PNG.png
--        -rwxr-xr-x 1 root  root  73087 Mar 18 14:57 Logo_de_Facebook.png
-- ####

-- Datos de la tabla 'redsocial':
INSERT INTO RedSocial(nombre, url, fechaLanzamiento, logo) VALUES ('facebook','www.facebook.com','2004-02-04',LOAD_FILE('/var/lib/mysql-files/Logo_Facebook.png'));
INSERT INTO RedSocial(nombre, url, fechaLanzamiento, logo) VALUES ('instagram','www.instagram.com','2010-10-01',LOAD_FILE('/var/lib/mysql-files/Logo-Instagram-PNG.png'));
INSERT INTO RedSocial(nombre, url, fechaLanzamiento, logo) VALUES ('linkedIn','www.linkedIn.com','2003-05-01',LOAD_FILE('/var/lib/mysql-files/LinkedIn_Logo.svg'));

-- Datos de la tabla 'Suscripcion':
INSERT INTO Suscripcion(usrId,nomRS,fechaIncorp) SELECT usrId, 'facebook','2011-03-12' FROM Usuario WHERE nombre = 'Alberto' AND apellido1 = 'Martínez' AND apellido2 = 'Cifuentes';
INSERT INTO Suscripcion(usrId,nomRS,fechaIncorp) SELECT usrId, 'instagram','2012-11-23' FROM Usuario WHERE nombre = 'María Ángeles' AND apellido1 = 'Robledo' AND apellido2 = 'González';
INSERT INTO Suscripcion(usrId,nomRS,fechaIncorp) SELECT usrId, 'facebook','2013-09-22' FROM Usuario WHERE nombre = 'José María' AND apellido1 = 'Viñuelas' AND apellido2 = 'Piez';
INSERT INTO Suscripcion(usrId,nomRS,fechaIncorp) SELECT usrId, 'instagram','2015-01-09' FROM Usuario WHERE nombre = 'Cristina' AND apellido1 = 'Lorente' AND apellido2 = 'Soria';
INSERT INTO Suscripcion(usrId,nomRS) SELECT usrId, 'facebook' FROM Usuario WHERE nombre = 'Cristina' AND apellido1 = 'Lorente' AND apellido2 = 'Soria';

-- Datos de la tabla 'Seguidores':
INSERT INTO Seguidores(seguidoId,seguidorId,nomRS) SELECT usrId as seguidoId, (SELECT u.usrId FROM Usuario u WHERE u.nombre = 'José María' AND u.apellido1 = 'Viñuelas' AND u.apellido2 = 'Piez') as seguidorId,'facebook' FROM Usuario WHERE nombre = 'Alberto' AND apellido1 = 'Martínez' AND apellido2 = 'Cifuentes';
INSERT INTO Seguidores(seguidoId,seguidorId,nomRS) SELECT usrId as seguidoId, (SELECT u.usrId FROM Usuario u WHERE u.nombre = 'Alberto' AND u.apellido1 = 'Martínez' AND u.apellido2 = 'Cifuentes') as seguidorId, 'facebook' FROM Usuario WHERE nombre = 'José María' AND apellido1 = 'Viñuelas' AND apellido2 = 'Piez';
INSERT INTO Seguidores(seguidoId,seguidorId,nomRS) SELECT usrId as seguidoId, (SELECT u.usrId FROM Usuario u WHERE u.nombre = 'Cristina' AND u.apellido1 = 'Lorente' AND u.apellido2 = 'Soria') as seguidorId, 'instagram' FROM Usuario WHERE nombre = 'María Ángeles' AND apellido1 = 'Robledo' AND apellido2 = 'González';
INSERT INTO Seguidores(seguidoId,seguidorId,nomRS) SELECT usrId as seguidoId, (SELECT u.usrId FROM Usuario u WHERE u.nombre = 'María Ángeles' AND u.apellido1 = 'Robledo' AND u.apellido2 = 'González') as seguidorId, 'instagram' FROM Usuario WHERE nombre = 'Cristina' AND apellido1 = 'Lorente' AND apellido2 = 'Soria';
INSERT INTO Seguidores(seguidoId,seguidorId,nomRS) SELECT usrId as seguidoId, (SELECT u.usrId FROM Usuario u WHERE u.nombre = 'Cristina' AND u.apellido1 = 'Lorente' AND u.apellido2 = 'Soria') as seguidorId, 'facebook' FROM Usuario WHERE nombre = 'Alberto' AND apellido1 = 'Martínez' AND apellido2 = 'Cifuentes';

-- Confirmamos todas las inserciones de datos en la Base de Datos 'exam2021'
COMMIT;

-- Describa la consulta SQL con la que obtener el número de países
-- en los que tiene seguidores cada usuario (en el conjunto de las redes sociales
-- a las que está suscrito indistintamente)

  SELECT principal.nombre, principal.apellido1, principal.apellido2, count(principal.pais_seguidor)
    FROM (  SELECT DISTINCT nombre, apellido1, apellido2, 
  	   		         (  SELECT u2.pais
                        FROM Usuario u2
                       WHERE u2.usrId = seg.seguidorId) as pais_seguidor
              FROM Usuario usu, Seguidores seg 
             WHERE seg.seguidoId = usu.usrId) principal
GROUP BY principal.nombre, principal.apellido1, principal.apellido2;

  SELECT principal.nombre, principal.apellido1, principal.apellido2, count(principal.pais_seguidor)
    FROM (  SELECT DISTINCT nombre, apellido1, apellido2, 
  	   		         (  SELECT u2.pais
                        FROM Usuario u2
                       WHERE u2.usrId = seg.seguidorId) as pais_seguidor
              FROM Usuario usu
              JOIN Seguidores seg ON seg.seguidoId = usu.usrId) principal
GROUP BY principal.nombre, principal.apellido1, principal.apellido2;

-- Si las consultas sobre suscripciones que han tenido lugar en
-- determinadas fechas son muy frecuentes, describa con detalle cómo debería
-- proceder el administrador de la base de datos para optimizar este tipo de
-- consultas. Precise las sentencias del lenguaje de definición de datos (DDL,
-- Data Definition Language) de las que haría uso.
-- DROP INDEX idx_fechaIncorp ON Suscripcion;

-- DROP INDEX idx_fechaIncorp_Suscr ON Suscripcion;

CREATE INDEX idx_fechaIncorp_Suscr
ON Suscripcion(fechaIncorp);

SHOW INDEXES FROM Suscripcion;

EXPLAIN
  SELECT *
    FROM Suscripcion
   WHERE fechaIncorp BETWEEN '2011-03-12' AND '2011-03-22';
   
   
--  La tabla o relación "Seguidores" cumple a 1FN porque en cada celda sólo hay un valor
-- También cumple la 2FN porque no tenemos dependencias parciales con atributos no clave (ya que todos son clave)
-- También cumple la 3FN porque no tenemos dependencias transitivas con atributos no clave (ya que todos son clave)
-- Tambien cumple la FNBC porque todos los atributos son clave, por lo tanto todas las relaciones dependen de la clave.
-- Deberíamos avanzar a 4FN porque tenemos dependencias multievaluadas, ya que el atributo "seguidoId" determina tanto a "seguidorId" como a "nomRS".
-- Para corregirlo lo suyo sería dividir dicha tabla o relación. Pero como ya en la tabla "Suscripcion" tenemos la relación que determina "usrId" y el "nomRS".
-- Bastaría con dejar en la tabla "Seguidores" sólo los atributos "seguidoId" y "seguidorId"

ALTER TABLE Seguidores DROP nomRS;