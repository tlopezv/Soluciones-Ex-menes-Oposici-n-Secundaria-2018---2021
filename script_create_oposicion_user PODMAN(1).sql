/**

-- Arrancamos nuestra imagen Docker con MySQL: Container "my-mysql" sobre el puerto 3307

-- #####################################################################################
-- #####################################################################################
-- Después de instalar la Imagen: https://hub.docker.com/_/mysql
--      # podman pull mysql

-- Puedo ver las imagenes que tengo en mi docker
--      # podman images

--        REPOSITORY                                         TAG         IMAGE ID      CREATED       SIZE
--        docker.io/library/mysql                            latest      8189e588b0e8  2 months ago  579 MB
--        container-registry.oracle.com/database/enterprise  21.3.0.0    da441e2c6de2  8 months ago  8.04 GB
--        container-registry.oracle.com/database/enterprise  latest      da441e2c6de2  8 months ago  8.04 GB

-- Crearemos el contenedor "my-mysql" exponiendo el puerto 3307 de nuesto equipo
--      # podman run --name my-mysql -p 3307:3306 -e MYSQL_ROOT_PASSWORD=admin -d mysql

-- Y puedo ver que contenedores tengo
--      # podman container ls

--        CONTAINER ID  IMAGE                           COMMAND     CREATED      STATUS        PORTS                   NAMES
--        e28b0e4a8157  docker.io/library/mysql:latest  mysqld      8 weeks ago  Up 5 minutes  0.0.0.0:3307->3306/tcp  my-mysql

-- Y ver cuáles están en ejecución:
--      # podman ps

--        CONTAINER ID  IMAGE                           COMMAND     CREATED      STATUS        PORTS                   NAMES
--        e28b0e4a8157  docker.io/library/mysql:latest  mysqld      8 weeks ago  Up 6 minutes  0.0.0.0:3307->3306/tcp  my-mysql

-- ####

-- ########
-- Podman al contrario que Docker, se ejecuta en un proceso, no en un servicio. Por lo que, primero debemos de arrancar la
-- maquina de Podman: (https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md#starting-machine)

--      # podman machine start


-- También podemos listar las maquinas de podman que tenemos instaladas: (https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md#starting-machine)

--      # podman machine ls

--        NAME                     VM TYPE     CREATED     LAST UP            CPUS        MEMORY      DISK SIZE
--        podman-machine-default*  wsl         7 days ago  Currently running  8           527.2MB     15.25GB

-- ########

-- Para parar el contenedor "my-mysql":
--      # podman container stop my-mysql

--        my-mysql

-- Para volverlo a arrancar:
--      # podman container start my-mysql

--        my-mysql

-- Y comprobamos que está arrancado:
--      # podman container ls

--        CONTAINER ID  IMAGE                                                       COMMAND               CREATED         STATUS                   PORTS                   NAMES
--        e28b0e4a8157  docker.io/library/mysql:latest                              mysqld                33 seconds ago  Up 34 seconds            0.0.0.0:3307->3306/tcp  my-mysql
-- ####

-- Copiamos dicho script de nuesto HOST al contenedor:
--      # wsl -d podman-machine-default -u user enterns podman cp "/mnt/c/Proyectos/Bases de Datos/MySQL/script_create_oposicion_user PODMAN.sql" my-mysql:/tmp

-- Y abrimos una terminal interactiva con nuesto contenedor:
--      # podman exec -it my-mysql sh

--        sh-4.4#
    
-- Dentro de la terminal interactiva comprobamos que se encuentra nuestro fichero:
--      sh-4.4# ls -la /tmp/

--        total 56
--        drwxrwxrwt  2 root root 4096 Jun 23 11:41  .
--        dr-xr-xr-x 18 root root 4096 Apr 26 20:37  ..
--        -rwxrwxrwx  1 root root 7002 May  2 17:49  create-book-table.sql
--        -rwxrwxrwx  1 root root 5762 Apr 26 21:28  create-tables.sql
--        -rwxrwxrwx  1 root root 7245 May  3 21:26  create_table_usuarios.sql
--        -rwxrwxrwx  1 root root 6254 Jun 23 11:41 'script_create_oposicion_user PODMAN.sql'
--        -rwxrwxrwx  1 root root 8035 May  2 16:51  script_ddl_create_user_codejava.sql
--        -rwxrwxrwx  1 root root 6489 Apr 26 20:55  script_ddl_create_user_javaguides.sql

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
    | codejava         | %         |
    | javaguides       | %         |
    | root             | %         |
    | mysql.infoschema | localhost |
    | mysql.session    | localhost |
    | mysql.sys        | localhost |
    | root             | localhost |
    +------------------+-----------+
    7 rows in set (0.00 sec)

-- ejecutamos este script:

mysql> source /tmp/script_create_oposicion_user PODMAN.sql

    Query OK, 0 rows affected (0.02 sec)

    Query OK, 0 rows affected (0.01 sec)

    Query OK, 0 rows affected (0.01 sec)

    +------------------+-----------+
    | user             | host      |
    +------------------+-----------+
    | codejava         | %         |
    | javaguides       | %         |
    | oposicion        | %         |
    | root             | %         |
    | mysql.infoschema | localhost |
    | mysql.session    | localhost |
    | mysql.sys        | localhost |
    | root             | localhost |
    +------------------+-----------+
    8 rows in set (0.01 sec)

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