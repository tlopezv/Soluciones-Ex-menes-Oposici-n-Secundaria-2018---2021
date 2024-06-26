/**

-- Arrancamos nuestra imagen Docker con MySQL: Container "my-mysql" sobre el puerto 3307

-- #####################################################################################
-- #####################################################################################
-- Después de instalar la Imagen: https://hub.docker.com/_/mysql
--      # docker pull mysql

-- Puedo ver las imagenes que tengo en mi docker
--      # docker images

--        REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
--        mariadb      latest    6e11fcfc66ad   12 days ago   401MB
--        postgres     latest    3b6645d2c145   13 days ago   379MB
--        mysql        latest    4f06b49211c0   2 weeks ago   530MB

-- Crearemos el contenedor "my-mysql" exponiendo el puerto 3307 de nuesto equipo
--      # docker run --name my-mysql -p 3307:3306 -e MYSQL_ROOT_PASSWORD=admin -d mysql

-- Y puedo ver que contenedores tengo
--      # docker container ls

--        CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                               NAMES
--        7a63f3fcec7b   mysql     "docker-entrypoint.s…"   9 seconds ago   Up 7 seconds   33060/tcp, 0.0.0.0:3307->3306/tcp   my-mysql

-- Y ver cuáles están en ejecución:
--      # docker ps -a

--        CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                               NAMES
--        7a63f3fcec7b   mysql     "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   33060/tcp, 0.0.0.0:3307->3306/tcp   my-mysql

-- Copiamos dicho script de nuesto HOST al contenedor:
--      # docker cp "C:\Proyectos\Bases de Datos\MySQL\script_create_oposicion_user.sql" my-mysql:/tmp/

-- Y abrimos una terminal interactiva con nuesto contenedor:
--      # docker exec -it my-mysql sh

--        sh-4.4#
    
-- Dentro de la terminal interactiva comprobamos que se encuentra nuestro fichero:
--      sh-4.4# ls -la /tmp/

--        total 12
--        drwxrwxrwt 1 root root 4096 Mar 14 20:34 .
--        drwxr-xr-x 1 root root 4096 Mar 14 20:34 ..
--        -rwxr-xr-x 1 root root 3448 Mar 14 20:28 script_create_oposicion_user.sql

-- #####################################################################################
-- #####################################################################################

-- Y conectamos con el usuario "root"

sh-4.4# mysql -u root -padmin

    mysql: [Warning] Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 8
    Server version: 8.0.32 MySQL Community Server - GPL

    Copyright (c) 2000, 2023, Oracle and/or its affiliates.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

-- Comprobamos todos los usuarios creados:

mysql>   SELECT user, host
    ->     FROM mysql.user;
    
    +------------------+-----------+
    | user             | host      |
    +------------------+-----------+
    | root             | %         |
    | mysql.infoschema | localhost |
    | mysql.session    | localhost |
    | mysql.sys        | localhost |
    | root             | localhost |
    +------------------+-----------+
    5 rows in set (0.00 sec)

-- ejecutamos este script:

mysql> source /tmp/script_create_oposicion_user.sql

    Query OK, 0 rows affected (0.01 sec)

    +------------------+-----------+
    | user             | host      |
    +------------------+-----------+
    | oposicion        | %         |
    | root             | %         |
    | mysql.infoschema | localhost |
    | mysql.session    | localhost |
    | mysql.sys        | localhost |
    | root             | localhost |
    +------------------+-----------+
    6 rows in set (0.00 sec)

mysql> exit

    Bye

**/

-- Y creamos el usuario Para los ejercicios de Base de Datos de la Oposición
-- Usuario: oposicion
-- Contraseña: 1234

CREATE USER 'oposicion'@'%' IDENTIFIED BY '1234';

-- Le damos todos los privilegios (permitimos hacer cualquier acción) al usuario 'bytecode' sober la Base de Datos 'blog'
GRANT ALL PRIVILEGES ON *.* TO 'oposicion' @'%';

-- Nos aseguramos de volver a cargar de nuevo todos los privilegios, para que se tengan en cuenta los recién creados.
FLUSH PRIVILEGES;

-- Volvermos a comprobar todos los usuarios creados:

  SELECT user,host 
    FROM mysql.user;