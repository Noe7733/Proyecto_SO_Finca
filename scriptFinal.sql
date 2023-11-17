create database FincaOriginal;

--\c finca



create table terreno(
  numTerreno integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  nombreT varchar(50) NOT NULL,
  primary key(numTerreno)
);
+
create table loteCafe(
  numLote integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  tipoGrano varchar(25) NOT NULL,
  numTerreno integer NOT NULL,
  primary key(numLote),
  CONSTRAINT numTerreno foreign key (numTerreno)
  References terreno(numTerreno) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE
);

create  table Recoleccion(
  idRecoleccion integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  numLote integer NOT NULL,
  cantTotalCafe numeric(10, 2) DEFAULT NULL constraint cantTotalCafeInv check(cantTotalCafe > 0),
  fecha date,
  statusR varchar(25)   DEFAULT 'PENDIENTE' NOT NULL,
  primary key(idRecoleccion),
  CONSTRAINT numloteFKey foreign key(numLote)
  References loteCafe(numLote) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE
);

create table tipoCafe(
    idTipo integer GENERATED ALWAYS AS IDENTITY,
    descripcion varchar,
    primary key(idTipo)
);

INSERT INTO tipoCafe (descripcion) VALUES ('VERDE');
INSERT INTO tipoCafe (descripcion) VALUES ('MADURO');
INSERT INTO tipoCafe (descripcion) VALUES ('SOBREMADURO');
INSERT INTO tipoCafe (descripcion) VALUES ('SECO');

create table Clasificacion(
  idRecoleccion integer NOT NULL,
  idTipo integer, 
  cantCompCafe numeric(10,2),
  primary key(idRecoleccion, idTipo),
  CONSTRAINT idRecoleccionFKey foreign key(idRecoleccion)
  References Recoleccion(idRecoleccion) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT idTipoFKey foreign key(idTipo)
  References tipoCafe(idTipo) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE
);

create table Despulpado(
  idDespulpado integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  idRecoleccion integer NOT NULL,
  fecha date,
  hora time,
 statusD varchar(25)   DEFAULT 'PENDIENTE' NOT NULL,
  primary key(idDespulpado),
  CONSTRAINT idDespulpadoFKey foreign key(idDespulpado)
  References Despulpado(idDespulpado) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE
);

create table Tanques(
  idTanque integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  maxKGT numeric(10,2),
  statusT varchar(25) DEFAULT 'DISPONIBLE' NOT NULL, --D disponible  O ocupado
  primary key(idTanque)
);

create table Fermentacion(
  idFermentacion integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  idDespulpado integer NOT NULL,
  idTanque integer,
  tempMin integer,
  tempMax integer,
  fechaFi date,
  timepoFi time,
  fechaFf date,
  tiempoFf time,
  statusF varchar(25)   DEFAULT 'PENDIENTE' NOT NULL, -- P proceso y F finalizado
  primary key(idFermentacion),
  CONSTRAINT idDespulpadoFKey foreign key(idDespulpado)
  References Despulpado(idDespulpado) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT idTanqueFKey foreign key(idTanque)
  References Tanques(idTanque) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE
);


create table Lavado(
  idLavado integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  idFermentacion integer NOT NULL,
  kgLavados numeric(10,2),
  fecha date,
  hora time,
  statusL varchar(25)   DEFAULT 'PENDIENTE' NOT NULL, --  
  primary key(idLavado),
  CONSTRAINT idFermentacionFKey foreign key(idFermentacion)
  References Fermentacion(idFermentacion) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE
);


create table Cuartos(
  idCuarto integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  maxKGC numeric(10,2),
  estado varchar(30) DEFAULT 'DISPONIBLE' NOT NULL,
  primary key(idCuarto)
);

create table Secado(
  idSecado integer NOT NULL GENERATED ALWAYS AS IDENTITY,
  idLavado integer NOT NULL,
  idCuarto integer,
  tipoSecado varchar(25),
  kgSecados numeric(10,2),
  fechaIni date,
  horaIni time,
  fechaFin date,
  horaFin time,
   statusS varchar(25)   DEFAULT 'PENDIENTE' NOT NULL,
  primary key(idSecado),
  CONSTRAINT idLavadoFKey foreign key(idLavado)
  References Lavado(idLavado) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT idCuartoFKey foreign key(idCuarto)
  References Cuartos(idCuarto) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE
);

create table Usuarios(
  idUsu integer  NOT NULL GENERATED ALWAYS AS IDENTITY,
  nombreUsu varchar NOT NULL,
  contraUsu varchar NOT NULL,
  nombre varchar NOT NULL,
  apPat varchar NOT NULL,
  apMat varchar NOT NULL,
  numTel varchar NOT NULL,
  primary key(idUsu)
);

---------------------------------------------
--------PLs para las tablas - RECOLECCION
---------------------------------------------

CREATE OR REPLACE PROCEDURE crearRecoleccion()
AS $$
DECLARE
    -- Declaración de cursores
    curltecafe CURSOR FOR SELECT numLote AS lte FROM loteCafe ORDER BY numLote;
    curtpocafe CURSOR FOR SELECT idTipo AS tpo FROM tipoCafe ORDER BY idTipo;
    currecole CURSOR FOR SELECT idRecoleccion AS id FROM recoleccion ORDER BY idRecoleccion;

    vcursorlte   RECORD;        
    vcursortpo   RECORD;       
    vcursorrecole   RECORD;   
    vnumlote INTEGER; 
    vidrecoleccion INTEGER;
    Vidtipo INTEGER;

BEGIN

    OPEN curltecafe;

    LOOP
        FETCH curltecafe INTO vcursorlte;
        EXIT WHEN NOT FOUND;

        SELECT numLote INTO vnumlote FROM recoleccion WHERE numLote = vcursorlte.lte;

        IF NOT FOUND THEN
            INSERT INTO recoleccion (numLote) VALUES (vcursorlte.lte);
        END IF;
    END LOOP;
    CLOSE curltecafe;

    OPEN currecole;
    LOOP
        FETCH currecole INTO vcursorrecole;
        EXIT WHEN NOT FOUND; 

        OPEN curtpocafe;

        LOOP
            FETCH curtpocafe INTO vcursortpo;
            EXIT WHEN NOT FOUND;

            SELECT idRecoleccion, idtipo INTO vidrecoleccion FROM Clasificacion WHERE idRecoleccion = vcursorrecole.id and idtipo = vcursortpo.tpo;
            --SELECT idTipo INTO 
            IF NOT FOUND THEN 
                INSERT INTO Clasificacion (idRecoleccion, idTipo) VALUES (vcursorrecole.id, vcursortpo.tpo);
            END IF;
        END LOOP;

        -- Cierra el cursor curtpocafe
        CLOSE curtpocafe;
    END LOOP;

    -- Cierra el cursor currecole
    CLOSE currecole;
END;
$$ LANGUAGE plpgsql;

call crearRecoleccion(); 




---Creacion de pl para actualizar datos de la clasificacion - recoleccion -

CREATE OR REPLACE PROCEDURE actualizarclasificacion (IN pidRecoleccion INTEGER,IN pnumlote INTEGER, IN pcantVerde NUMERIC(10,2), IN pcantMaduro NUMERIC(10,2), IN pcantSobreMaduro NUMERIC(10,2), IN pcantSeco NUMERIC(10,2), INOUT pRes INTEGER) AS $$
DECLARE 
    vrlotecafe RECORD;
    vrrecoleccion RECORD;
    vrclasificacion RECORD;
    vSuma NUMERIC(10,2);
    vhoraFormateada TEXT;
    vFecha date;
    --vHora time;
    vRes INTEGER;

BEGIN
    select into vrlotecafe * from lotecafe where numLote = pnumlote FOR UPDATE;
    IF FOUND THEN
        select into vrrecoleccion * from recoleccion where idRecoleccion = pidRecoleccion AND numLote = pnumlote FOR UPDATE; 

        IF FOUND THEN

            vSuma = (pcantVerde + pcantMaduro + pcantSobreMaduro + pcantSeco);
            
            IF vSuma> 0 THEN
                vHoraFormateada := TO_CHAR(current_timestamp AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS');
               -- Extraer la fecha y la hora
                vFecha := CAST(vHoraFormateada AS DATE);
                --vHora := CAST(vHoraFormateada AS TIME);

                UPDATE Clasificacion SET cantCompCafe = pcantVerde WHERE idTipo = 1 AND idRecoleccion = pidRecoleccion;

                UPDATE Clasificacion SET cantCompCafe = pcantMaduro where idTipo = 2 and idRecoleccion = pidRecoleccion;
                UPDATE Clasificacion SET cantCompCafe = pcantSobreMaduro where idTipo = 3 and idRecoleccion = pidRecoleccion;
                 UPDATE Clasificacion SET cantCompCafe = pcantSeco where idTipo = 4 and idRecoleccion = pidRecoleccion;

                UPDATE recoleccion SET statusr = 'FINALIZADO', fecha = vFecha, cantTotalCafe= vSuma WHERE numlote = pnumlote;

                vRes:= 1;
                Commit;
            ELSE
              vRes:=4; -- El valor de la suma es menor a cero
            END IF;
        ELSE
            vRes:= 3; -- no eixste el id recoleccion ni el lote
        END IF;
    ELSE
        vRes:=2; -- no existe numlote o no esta disponible
    END IF;
    IF vRes > 1 THEN
        Rollback;
    END IF;
    pRes := vRes;
END;
$$ LANGUAGE plpgsql;


---------------------------------------------
--------PLs para las tablas - DESPULPADO
---------------------------------------------



CREATE OR REPLACE PROCEDURE crearDespulpado()  
AS $$
DECLARE
    currecole CURSOR FOR SELECT idrecoleccion As idRec from recoleccion where statusR = 'FINALIZADO' ORDER BY idRecoleccion;
    vcursorreco RECORD;
    vIdRecoleccion INTEGER;


BEGIN
    OPEN  currecole;
    LOOP
        FETCH currecole INTO vcursorreco;
        EXIT WHEN NOT FOUND;


        select idRecoleccion INTO vIdRecoleccion from  Despulpado where idRecoleccion = vcursorreco.idRec;

        IF NOT FOUND THEN
            --si no existe, realizar la insercion
          INSERT INTO despulpado (idRecoleccion) VALUES (vcursorreco.idRec);  --insert de todos los finalizados
        
        END IF;

    END LOOP;
    
    CLOSE currecole;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM recoleccion;
SELECT * FROM clasificacion;
SELECT * FROM despulpado;




---Creacion de pl para actualizar despulpado 

CREATE OR REPLACE PROCEDURE actualizardespulpado (IN piddespulpado INTEGER, IN pidRecoleccion INTEGER,  INOUT pRes INTEGER) AS $$
DECLARE  
    vrrecoleccion RECORD;
    vrdespulpado RECORD;
    vhoraFormateada TEXT;
    vFecha date;
    vHora time;
    vRes INTEGER;

BEGIN

    select into vrrecoleccion * from recoleccion where idrecoleccion = pidRecoleccion and statusr = 'FINALIZADO' FOR UPDATE;

    IF FOUND THEN
        select into vrdespulpado * from despulpado where idrecoleccion = pidRecoleccion and idDespulpado = piddespulpado FOR UPDATE;

        IF  FOUND THEN


            vHoraFormateada := TO_CHAR(current_timestamp AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS');
            -- Extraer la fecha y la hora
            vFecha := CAST(vHoraFormateada AS DATE);
            vHora := CAST(vHoraFormateada AS TIME);
            -- Actualiza el despulpado y formatea la hora
            UPDATE despulpado SET statusD = 'FINALIZADO', fecha = vFecha, hora = vHora WHERE idDespulpado = piddespulpado AND idRecoleccion = pidRecoleccion;

            vRes:= 1;
            Commit;
            
        ELSE
            vRes:= 3; -- no existe el idrecoleccion o el iddespulpado
        END IF;
    ELSE
        vRes:=2; -- el idrecoleccion o estatus no es correcto
    END IF;

    IF vRes > 1 THEN
        Rollback;
    END IF;
    pRes := vRes;
END;
$$ LANGUAGE plpgsql;


---------------------------------------------
--------PLs para las tablas - FERMENTACION
---------------------------------------------

CREATE OR REPLACE PROCEDURE crearFermentacion()
AS $$
DECLARE


    curredespul CURSOR FOR SELECT idDespulpado AS idDes FROM despulpado WHERE statusD = 'FINALIZADO' ORDER BY idDespulpado;
    vcursordespu RECORD;
    vIdDespulpado INTEGER;

BEGIN

    OPEN curredespul;

    LOOP
        FETCH curredespul INTO vcursordespu;
        EXIT WHEN NOT FOUND;

        -- Verificar si el idDespulpado ya existe en la tabla Fermentacion
        SELECT idDespulpado INTO vIdDespulpado FROM Fermentacion WHERE idDespulpado = vcursordespu.idDes;

        IF NOT FOUND THEN
            -- Si no existe, realizar la inserción
            INSERT INTO Fermentacion (idDespulpado) VALUES (vcursordespu.idDes);
        END IF;

    END LOOP;

    CLOSE curredespul;
END;
$$ LANGUAGE plpgsql;

-- Pl para actualizar la fermentacion  para iniciarla

CREATE OR REPLACE PROCEDURE actualizarFermentacion (IN pidFermentacion INTEGER, IN piddespulpado INTEGER, IN pidtanque INTEGER, In ptempMax INTEGER, In ptempMin integer,  INOUT pRes INTEGER) AS $$
DECLARE  
    vrRecoleccion RECORD;  --Sacar el idrecoleccion y linkear el cantTotalcafe
    vrDespulpado RECORD;    --PAra validar el estatus como finalizado
    vrFermetacion RECORD;   --Para seleccionar la tabla 
    vrTanques RECORD;        --Seleccionar el tanque, estatus y maxKGT
    vhoraFormateada TEXT;     
    vFecha DATE;
    vHora  TIME;

    vRes INTEGER;

BEGIN
    select into vrDespulpado * from despulpado where iddespulpado = piddespulpado and statusd = 'FINALIZADO' for update;

    IF FOUND THEN 
        select into vrRecoleccion * from recoleccion where idrecoleccion = vrDespulpado.idrecoleccion for update;

        IF FOUND THEN
            select into vrTanques * from tanques where idTanque = pidtanque and statusT = 'DISPONIBLE' for update;
            IF FOUND THEN
                select into vrFermetacion * from fermentacion where idFermentacion = pidFermentacion for update;
                IF FOUND THEN
                        vHoraFormateada := TO_CHAR(current_timestamp AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS');
                        -- Extraer la fecha y la hora
                        vFecha := CAST(vHoraFormateada AS DATE);
                         vHora := CAST(vHoraFormateada AS TIME);
                        -- Actualizar la fermentación y formatear la hora
                        UPDATE fermentacion SET idTanque = pidtanque, tempMax = ptempMax, tempMin = ptempMin, statusF = 'PROCESO',
                        timepoFi = vHora, fechaFi= vFecha WHERE idFermentacion = pidFermentacion AND idDespulpado = piddespulpado;

                        UPDATE Tanques SET maxKGT = vrRecoleccion.cantTotalCafe ,statusT= 'OCUPADO' WHERE idTanque = pidtanque;

                        vRes := 1;
                        COMMIT;
                ELSE
                    vRes := 5; -- no se encontró el idfermentacion en la tabla fermentacion
                END IF;
            ELSE
                vRes := 4; -- no se encontró el idtanque o disponibilidad en la tabla
            END IF;
        ELSE
            vRes := 3; -- el idrecoleccion no se encontró en la tabla
        END IF;
    ELSE
        vRes := 2; -- iddespulpado no existe o el estatus no se encuentra disponible
    END IF;
    IF vRes > 1 THEN
        Rollback;
    END IF;
    pRes := vRes;
END;
$$ LANGUAGE plpgsql;


-- PL para actualizar la fermentacion a finalizacion

CREATE OR REPLACE PROCEDURE actualizarFermentacionFinalizacion (IN pidFermentacion INTEGER, IN piddespulpado INTEGER,  INOUT pRes INTEGER) AS $$
DECLARE  
    vrRecoleccion RECORD;  --Sacar el idrecoleccion y linkear el cantTotalcafe
    vrDespulpado RECORD;    --PAra validar el estatus como finalizado
    vrFermetacion RECORD;   --Para seleccionar la tabla 
    vrTanques RECORD;        --Seleccionar el tanque, estatus y maxKGT
    vhoraFormateada TEXT;     
    vFecha DATE;
    vHora TIME;

    vRes INTEGER;

BEGIN

    select  into vrFermetacion * from fermentacion where idfermentacion = pidFermentacion and iddespulpado = piddespulpado for update;

    IF FOUND THEN
        select into vrTanques * from tanques where idtanque = vrFermetacion.idtanque AND statusT = 'OCUPADO' FOR UPDATE;
        IF FOUND THEN
            -- Actualizar la fermentación y formatear la hora
            vHoraFormateada := TO_CHAR(current_timestamp AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS');
            -- Extraer la fecha y la hora
            vFecha := CAST(vHoraFormateada AS DATE);
            vHora := CAST(vHoraFormateada AS TIME);
            -- Actualizar la fermentación y formatear la hora
            UPDATE fermentacion SET  statusF = 'FINALIZADO', tiempoFf = vHora, fechaFf = vFecha 
            WHERE idFermentacion = pidFermentacion AND idDespulpado = piddespulpado;
            UPDATE Tanques SET maxKGT = NULL ,statusT= 'DISPONIBLE' WHERE idTanque = vrTanques.idtanque;
            vRes := 1;
             COMMIT;
        ELSE
            vRes:=3 ; --tanque no existe
        END IF;
    ELSE
        vRes:= 2; -- NO SE ENCONTRO IDFERMENTACION NI ID DESPULPADO
    END IF;
    IF vRes > 1 THEN
        Rollback;
    END IF;
    pRes := vRes;
END;
$$ LANGUAGE plpgsql;


---------------------------------------------
--------PLs para las tablas - LAVADO
---------------------------------------------

CREATE OR REPLACE PROCEDURE crearLavado()
AS $$
DECLARE
    currefermen CURSOR FOR SELECT idFermentacion AS idFer FROM fermentacion WHERE statusF = 'FINALIZADO' ORDER BY idFermentacion;
    vcursorfermen RECORD;
    vidfermentacion INTEGER;

BEGIN
    OPEN currefermen;
    LOOP
        FETCH currefermen INTO vcursorfermen;
        EXIT WHEN NOT FOUND;

        --verificar si el idfermentacion ya exIste en la tabla lavado
        SELECT idFermentacion INTO vidfermentacion FROM Lavado WHERE idfermentacion = vcursorfermen.idFer;

        IF NOT FOUND THEN
            --Si no existe, realizar la insercion
            INSERT INTO Lavado (idfermentacion) VALUES (vcursorfermen.idFer);
        END IF;

    END LOOP;
    CLOSE currefermen;
END;
$$ LANGUAGE plpgsql;

call crearLavado();



-- Pl para actualizar el lavado

CREATE OR REPLACE PROCEDURE actualizarLavado (IN pidlavado INTEGER, IN pidFermentacion INTEGER,  INOUT pRes INTEGER) AS $$
DECLARE  

    vrDespulpado RECORD;    --PAra validar el estatus como finalizado
    vrFermetacion RECORD;   --Para seleccionar la tabla 
    vrRecoleccion RECORD;
    vrLavado RECORD;
    vhoraFormateada TEXT;     
    vFecha date;
    vHora time;

    vRes INTEGER;

BEGIN

    SELECT INTO vrFermetacion * FROM fermentacion WHERE idfermentacion = pidFermentacion AND statusF = 'FINALIZADO' FOR UPDATE;

    IF FOUND THEN 
        SELECT INTO vrLavado * FROM Lavado WHERE idLavado = pidlavado FOR UPDATE;
        IF FOUND THEN
            SELECT INTO vrDespulpado * FROM despulpado WHERE iddespulpado = vrFermetacion.iddespulpado FOR UPDATE;
            IF FOUND THEN 

                SELECT INTO vrRecoleccion * from recoleccion where idrecoleccion = vrdespulpado.idRecoleccion FOR UPDATE;

                IF FOUND THEN 
                    vHoraFormateada := TO_CHAR(current_timestamp AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS');
                    -- Extraer la fecha y la hora
                    vFecha := CAST(vHoraFormateada AS DATE);
                    vHora := CAST(vHoraFormateada AS TIME);
                    -- Actualizar la fermentación y formatear la hora
                    UPDATE Lavado SET fecha = vFecha , hora = vHora,
                                        kgLavados = vrrecoleccion.cantTotalCafe, statusL = 'FINALIZADO' where idlavado = pidlavado and idfermentacion = pidFermentacion;
                    vRes := 1;
                    COMMIT;
                ELSE
                    vRes := 5; -- no se encontró el idrecoleccion en la tabla recoleccion
                END IF;
            ELSE
                vRes := 4; -- no existe el iddespulpado en tabla de despulpado
            END IF;
        ELSE
            vRes := 3; -- el idlavado no existe en tabla lavado
        END IF;
    ELSE
        vRes := 2; -- idfermentacion no existe o no esta disponible fermentacion
    END IF;
    IF vRes > 1 THEN
        Rollback;
    END IF;
    pRes := vRes;
END;
$$ LANGUAGE plpgsql;


---------------------------------------------
--------PLs para las tablas - SECADO
---------------------------------------------

CREATE OR REPLACE PROCEDURE crearSecado()     
AS $$
DECLARE
    currelavado CURSOR FOR SELECT  idlavado AS idLav FROM  lavado WHERE statusL = 'FINALIZADO' ORDER BY idLavado;
    vcursorlava RECORD;
    vidlavado INTEGER;
BEGIN
    OPEN currelavado;
    LOOP
        FETCH currelavado INTO vcursorlava;
        EXIT WHEN NOT FOUND;

        SELECT idLavado INTO vidlavado FROM Secado WHERE idLavado = vcursorlava.idLav;

        IF NOT FOUND THEN   
            INSERT INTO Secado (idLavado) VALUES (vcursorlava.idLav);
        END IF;
    
    END LOOP;
    CLOSE currelavado;
END;
$$ LANGUAGE plpgsql;

call crearSecado();


--PL para actualizar el secado e iniciarlo

CREATE OR REPLACE PROCEDURE actualizarSecado (IN pidsecado INTEGER, IN pidlavado INTEGER, IN pidCuarto INTEGER, IN ptipoSecado VARCHAR,  INOUT pRes INTEGER) AS $$
DECLARE  
    vrDespulpado RECORD;    --PAra validar el estatus como finalizado
    vrFermetacion RECORD;   --Para seleccionar la tabla 
    vrRecoleccion RECORD;
    vrLavado RECORD;
    vrCuartoS RECORD;
    vhoraFormateada TEXT;     
    vFecha date;
    vHora time;

    vRes INTEGER;

BEGIN

    SELECT INTO vrLavado * FROM lavado WHERE idLavado = pidlavado AND statusL = 'FINALIZADO' FOR UPDATE;
    IF FOUND THEN
        SELECT INTO vrFermetacion * FROM fermentacion WHERE idfermentacion = vrLavado.idFermentacion AND statusF = 'FINALIZADO' FOR UPDATE;
        
        IF FOUND THEN
            SELECT INTO vrDespulpado * FROM despulpado WHERE iddespulpado = vrFermetacion.iddespulpado AND statusD = 'FINALIZADO' FOR UPDATE;
            
            IF FOUND THEN 
                SELECT INTO vrRecoleccion * from recoleccion where idrecoleccion = vrdespulpado.idRecoleccion AND statusr = 'FINALIZADO' FOR UPDATE;

                IF FOUND THEN 
                    SELECT INTO vrCuartos * from Cuartos where idCuarto = pidCuarto and estado = 'DISPONIBLE' FOR UPDATE;

                    IF FOUND THEN 
                        vHoraFormateada := TO_CHAR(current_timestamp AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS');
                        -- Extraer la fecha y la hora
                        vFecha := CAST(vHoraFormateada AS DATE);
                        vHora := CAST(vHoraFormateada AS TIME);
                        -- Actualizar la fermentación y formatear la hora   kgSecados = vrrecoleccion.cantTotalCafe
                        UPDATE Secado SET idCuarto = pidCuarto, tipoSecado = ptipoSecado, fechaini = vFecha, horaIni = vHora, statusS = 'PROCESO'
                                        WHERE idSecado = pidsecado and idlavado = pidlavado;
                        UPDATE cuartos SET maxKGC = vrrecoleccion.cantTotalCafe  ,estado= 'OCUPADO' 
                        WHERE idCuarto = vrCuartos.idCuarto;
                        vRes := 1;
                        COMMIT;
                    ELSE
                        vRes:= 6; --no existe cuarto o no ta disponible
                    END IF;
                ELSE
                    vRes := 5; -- no se encontró el idrecoleccion en la tabla recoleccion
                END IF;
            ELSE
                vRes := 4; -- no existe el iddespulpado en tabla de despulpado
            END IF;
        ELSE
            vRes := 3; -- el idFermentacion no se encuentra en tabla fermentacion
        END IF;
    ELSE
        vRes := 2; -- idlavado no se encuentra en tabla lavado
    END IF;
    IF vRes > 1 THEN
        Rollback;
    END IF;
    pRes := vRes;
END;
$$ LANGUAGE plpgsql;


--PL para actualizar el secado finalizandolo

CREATE OR REPLACE PROCEDURE actualizarSecadoFinalizacion (IN pidsecado INTEGER, IN pidlavado INTEGER,  INOUT pRes INTEGER) AS $$
DECLARE  
    vrRecoleccion RECORD;  --Sacar el idrecoleccion y linkear el cantTotalcafe
    vrDespulpado RECORD;    --PAra validar el estatus como finalizado
    vrFermetacion RECORD;   --Para seleccionar la tabla 
    vrCuartos RECORD;        --Seleccionar el tanque, estatus y maxKGT
    vrSecado RECORD;
    vhoraFormateada TEXT;     
    vFecha DATE;
    vHora TIME;

    vRes INTEGER;

BEGIN
    select  into vrSecado * from Secado where  idSecado = pidsecado and idlavado = pidlavado for update;

    IF FOUND THEN
        select into vrCuartos * from cuartos where idCuarto = vrSecado.idCuarto AND estado = 'OCUPADO' FOR UPDATE;
        IF FOUND THEN
            
            vHoraFormateada := TO_CHAR(current_timestamp AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD HH24:MI:SS');
            
            vFecha := CAST(vHoraFormateada AS DATE);
            vHora := CAST(vHoraFormateada AS TIME);
            UPDATE Secado SET statusS = 'FINALIZADO', horaFin = vHora, fechaFin = vFecha, kgSecados = vrCuartos.maxKGC
            WHERE idSecado = pidsecado and idlavado = pidlavado;

            UPDATE cuartos SET maxKGC = NULL ,estado= 'DISPONIBLE' WHERE idCuarto = vrCuartos.idCuarto;
            vRes := 1;
             COMMIT;
        ELSE
            vRes:=3 ; --tanque no existe
        END IF;
    ELSE
        vRes:= 2; -- NO SE ENCONTRO IDFERMENTACION NI ID DESPULPADO
    END IF;
    IF vRes > 1 THEN
        Rollback;
    END IF;
    pRes := vRes;
END;
$$ LANGUAGE plpgsql;



---------------------------------------------
--------PLs para las tablas - CONSULTAS
---------------------------------------------

---------------------------------------------------------------------------------
-- Mostrar el tiempo que dura el proceso de un determinado lote de café, desde 
-- la recoleccion hasta el secado.

CREATE OR REPLACE FUNCTION verprocesolotes(num_lote integer)
RETURNS TABLE (
    numLote integer,
    fechaRecoleccion date,
    fechaDespulpado date,
    fechaFermentacionInicio date,
    fechaFermentacionFin date,
    fechaLavado date,
    fechaSecadoInicio date,
    fechaSecadoFin date
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.numLote,
        r.fecha AS fechaRecoleccion,
        d.fecha AS fechaDespulpado,
        f.fechaFi AS fechaFermentacionInicio,
        f.fechaFf AS fechaFermentacionFin,
        l.fecha AS fechaLavado,
        s.fechaIni AS fechaSecadoInicio,
        s.fechaFin AS fechaSecadoFin
    FROM
        Recoleccion r
    LEFT JOIN Despulpado d ON r.idRecoleccion = d.idRecoleccion
    LEFT JOIN Fermentacion f ON d.idDespulpado = f.idDespulpado
    LEFT JOIN Lavado l ON f.idFermentacion = l.idFermentacion
    LEFT JOIN Secado s ON l.idLavado = s.idLavado
    WHERE
        r.numLote = num_lote;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM  verprocesolotes(15);


---------------------------------------------------------------------------------
-- Mostrar los datos de la fase en la que se encuentra cada lote de cafe


CREATE OR REPLACE VIEW vistaProcesoLote AS
SELECT DISTINCT ON (r.numLote)
    r.numLote,
    r.statusR AS estadoRecoleccion,
    d.statusD AS estadoDespulpado,
    l.statusL AS estadoLavado,
    s.statusS AS estadoSecado
FROM
    Recoleccion r
LEFT JOIN Despulpado d ON r.idRecoleccion = d.idRecoleccion
LEFT JOIN Lavado l ON r.idRecoleccion = l.idFermentacion
LEFT JOIN Secado s ON l.idLavado = s.idLavado
ORDER BY
    r.numLote,
    r.fecha;


select * from vistaProcesoLote order by numLote asc;

---------------------------------------------------------------------------------
-- Mostrar los tanques y cuartos disponibles en cualquier momento. 


CREATE OR REPLACE VIEW TanquesCuartosDisponibles AS
SELECT
    t.idTanque AS idRecurso,
    t.statusT AS estadoRecurso,
    NULL::INTEGER AS idCuarto,
    NULL::VARCHAR(30) AS estadoCuarto
FROM
    Tanques t
WHERE
    t.statusT = 'DISPONIBLE'

UNION ALL

SELECT
    NULL::INTEGER AS idRecurso,
    NULL::VARCHAR(30) AS estadoRecurso,
    c.idCuarto AS idCuarto,
    c.estado AS estadoCuarto
FROM
    Cuartos c
WHERE
    c.estado = 'DISPONIBLE';


SELECT * FROM TanquesCuartosDisponibles;

---------------------------------------------------------------------------------
-- Mostrar cual es el mes en el que se ha recolectado mas cantidad de cafe

-- Crear la vista
CREATE OR REPLACE VIEW vistaRecolecciondemes AS
SELECT
    CASE
        WHEN EXTRACT(MONTH FROM fecha) = 1 THEN 'enero'
        WHEN EXTRACT(MONTH FROM fecha) = 2 THEN 'febrero'
        WHEN EXTRACT(MONTH FROM fecha) = 3 THEN 'marzo'
        WHEN EXTRACT(MONTH FROM fecha) = 4 THEN 'abril'
        WHEN EXTRACT(MONTH FROM fecha) = 5 THEN 'mayo'
        WHEN EXTRACT(MONTH FROM fecha) = 6 THEN 'junio'
        WHEN EXTRACT(MONTH FROM fecha) = 7 THEN 'julio'
        WHEN EXTRACT(MONTH FROM fecha) = 8 THEN 'agosto'
        WHEN EXTRACT(MONTH FROM fecha) = 9 THEN 'septiembre'
        WHEN EXTRACT(MONTH FROM fecha) = 10 THEN 'octubre'
        WHEN EXTRACT(MONTH FROM fecha) = 11 THEN 'noviembre'
        WHEN EXTRACT(MONTH FROM fecha) = 12 THEN 'diciembre'
    END AS mes,
    COALESCE(SUM(cantTotalCafe), 0) AS totalCafeRecolectado
FROM
    Recoleccion
GROUP BY
    mes
ORDER BY
    totalCafeRecolectado DESC
LIMIT 1;

select *from vistaRecolecciondemes;

---------------------------------------------------------------------------------
--Mostrar cual es el tipo e caf que se ha recolectado mas en un aniio (verde, 
--maduro, seco o sobre maduro)

CREATE OR REPLACE VIEW vistaTipoMayorAnioRec AS
SELECT
    anio,
    tipoCafe,
    totalRecolectado,
    totalCafeClasificado
FROM (
    SELECT
        EXTRACT(YEAR FROM r.fecha) AS anio,
        tc.descripcion AS tipoCafe,
        COUNT(*) AS totalRecolectado,
        SUM(c.cantCompCafe) AS totalCafeClasificado,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM r.fecha) ORDER BY SUM(c.cantCompCafe) DESC) AS row_num
    FROM
        Clasificacion c
    JOIN
        Recoleccion r ON c.idRecoleccion = r.idRecoleccion
    JOIN
        tipoCafe tc ON c.idTipo = tc.idTipo
    WHERE
        c.cantCompCafe > 1
    GROUP BY
        anio,
        tipoCafe
) subquery
WHERE
    subquery.row_num = 1;

select *from vistaTipoMayorAnioRec;

---------------------------------------------------------------------------------
--Mostrar el promedio del tiempo al mes del secado de los lotes de cafe

CREATE OR REPLACE VIEW vistaPromedioTiempoSecado AS
SELECT
    TO_CHAR(s.fechaIni, 'TMMonth') AS mes,
    TO_CHAR(AVG(EXTRACT(EPOCH FROM (s.fechaFin + s.horaFin - s.fechaIni - s.horaIni)) / 3600), 'FM00.00') AS promedioTiempoSecado
FROM
    Secado s
GROUP BY
    mes
ORDER BY
    mes;

select *from vistaPromedioTiempoSecado;


-- VISTA CREADA PARA LA TABLA RECOLECCIÓN

CREATE OR REPLACE PROCEDURE crearRecoleccion()
AS $$
DECLARE
    curltecafe CURSOR FOR SELECT numLote AS lte FROM loteCafe ORDER BY numLote;
    curtpocafe CURSOR FOR SELECT idTipo AS tpo FROM tipoCafe ORDER BY idTipo;
    currecole CURSOR FOR SELECT idRecoleccion AS id FROM recoleccion ORDER BY idRecoleccion;

    vcursorlte   RECORD;
    vcursortpo   RECORD;
    vcursorrecole   RECORD;
BEGIN

    TRUNCATE TABLE recoleccion CASCADE;
    TRUNCATE TABLE clasificacion CASCADE;

    OPEN curltecafe;

    LOOP
        FETCH curltecafe INTO vcursorlte;
        EXIT WHEN NOT FOUND;

        INSERT INTO recoleccion (numLote) VALUES (vcursorlte.lte);

    END LOOP;

    CLOSE curltecafe;

    OPEN currecole;

    LOOP
        FETCH currecole INTO vcursorrecole;
        EXIT WHEN NOT FOUND;

        OPEN curtpocafe;

        LOOP
            FETCH curtpocafe INTO vcursortpo;
            EXIT WHEN NOT FOUND;

            INSERT INTO clasificacion (idRecoleccion, idTipo) VALUES (vcursorrecole.id, vcursortpo.tpo);

        END LOOP;

        CLOSE curtpocafe;

    END LOOP;

    CLOSE currecole;
END;
$$ LANGUAGE plpgsql;

CALL crearRecoleccion();






