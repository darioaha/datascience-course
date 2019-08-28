/*
Conexion DB
jdbc:postgresql://172.27.100.115:54320/db_g3
 */

SET search_path TO negocio, public;

-----------Analisis--------------

SELECT t.* FROM negocio.sga_alumnos t;

-- personas con mas de una propuesta curricular activa
SELECT t.persona, count(t.*) FROM negocio.sga_alumnos t
WHERE calidad = 'A'
GROUP BY t.persona
ORDER BY 2 DESC;

SELECT t.* FROM negocio.sga_propuestas t
where propuesta in (289,115,95,103,132,140,143,163,164,300,162,187,195,200,35,290,240,179,308,311,307,288,318,334);

-- Modalidad Presencial o a distancia
Select * from negocio.sga_modalidad_cursada;

-- Activo o Pasivo en la Propuesta curricular
Select * from negocio.sga_alumnos_calidad;

SELECT p.nombre as propuesta, t.* FROM negocio.sga_alumnos t
inner join negocio.sga_propuestas p ON t.propuesta = p.propuesta
where persona = 210995;

select * from negocio.sga_ubicaciones
where ubicacion IN (13,16,33,40,38);

select * from negocio.mug_localidades
where localidad = 10460;


-- Cantidad de Alumnos
SELECT count(distinct alumno) FROM negocio.sga_alumnos t;
-- Cantidad alumnos: 1.001.753
SELECT count(distinct persona) FROM negocio.sga_alumnos t;
-- Cantidad alumnos: 647.119

------------------------------------Feature-------------------------------------
------------------ Dias dentro de la Universidad -----------------------------------
--------------------------------------------------------------------------------
SELECT t.* FROM negocio.sga_alumnos t;
SELECT * FROM negocio.sga_insc_cursada;

-- fecha minima por alumno
SELECT a.persona, MIN(fecha_inscripcion) as fecha_insc FROM negocio.sga_insc_cursada ic
INNER JOIN  negocio.sga_alumnos a ON a.alumno = ic.alumno
GROUP BY 1;
-- 414.371 Registros

-- fecha minima por persona
--DROP VIEW vw_dateinsc;
CREATE VIEW vw_dateinsc AS
    SELECT a.persona, MIN(fecha_inscripcion) as fecha_insc FROM negocio.sga_insc_cursada ic
    INNER JOIN  negocio.sga_alumnos a ON a.alumno = ic.alumno
    GROUP BY 1;
-- 414.371 Registros

CREATE VIEW vw_days_insc AS
    select persona, EXTRACT(DAY FROM TIMESTAMP '2019-08-05' - fecha_insc) AS dias_inscripcion from vw_dateinsc;

SELECT * FROM vw_days_insc;

------------------------------------Feature-------------------------------------
------------- Dias desde la ultimo cambio de plan ------------------------------
--------------------------------------------------------------------------------

select * from negocio.sga_alumnos_hist_planes;

-- drop view vw_dateinsc_last_plan;
CREATE VIEW vw_dateinsc_last_plan AS
    SELECT a.persona, MAX(fecha) as fecha_insc FROM negocio.sga_alumnos_hist_planes hp
    INNER JOIN  negocio.sga_alumnos a ON a.alumno = hp.alumno
    GROUP BY 1;

SELECT persona, EXTRACT(DAY FROM TIMESTAMP '2019-08-05' - fecha_insc) AS dias_inscripcion
FROM vw_dateinsc_last_plan
ORDER BY 2 ASC;
-- 644.101 Registros


------------------------------------Feature-------------------------------------
---------------------- Cantidad de Cambios de plan -----------------------------
-- Se refiere a la cantidad de cambios de versiones de plan no de carreras
--------------------------------------------------------------------------------
--DROP VIEW vw_cambios_plan;
CREATE VIEW vw_cambios_plan AS
    SELECT a.persona, pv.plan,count(p.plan_version) as cambios_plan_cant
    FROM negocio.sga_alumnos_hist_planes p
    INNER JOIN negocio.sga_planes_versiones pv ON p.plan_version = pv.plan_version
    INNER JOIN  negocio.sga_alumnos a ON a.alumno = p.alumno
    GROUP BY 1,2;

SELECT persona, count(plan) AS cant_cambios_plan
FROM vw_cambios_plan
GROUP BY 1;
-- 644.101

------------------------------------Feature-------------------------------------
-------------------- Cantidad de Inasistencias ---------------------------------
-- Cantidad de inasistencias
--------------------------------------------------------------------------------
SELECT t.* FROM negocio.sga_alumnos t
WHERE t.alumno NOT IN (SELECT DISTINCT a.alumno FROM negocio.sga_clases_asistencia a
	WHERE cant_inasistencias > 0);

SELECT DISTINCT a.alumno FROM negocio.sga_clases_asistencia a
WHERE cant_inasistencias > 0;

SELECT * FROM negocio.sga_clases_asistencia a;

------------------------------------Feature-------------------------------------
-------------- Cantidad de inscripciones fuera de termino ----------------------
-- Cantidad de veces que el alumno se inscribio fuera de termino
--------------------------------------------------------------------------------
SELECT persona, COUNT(fuera_de_termino) from negocio.sga_insc_cursada ic
INNER JOIN  negocio.sga_alumnos a ON a.alumno = ic.alumno
GROUP BY 1;

------------------------------------Feature-------------------------------------
------- Cantidad de dias desde la ultima inscripcion al plan mas vigente--------
-- Cantidad de dias desde la ultima inscripcion a el plan mas vigente
-- Agarro MIN de fecha porque supongo que es la primer incripcion sobre el plan
--------------------------------------------------------------------------------

--DROP VIEW vw_cambios_plan_incripcion;
CREATE VIEW vw_cambios_plan_incripcion AS
    SELECT a.persona,pv.plan ,MIN(p.fecha) as fecha_insc
        FROM negocio.sga_alumnos_hist_planes p
	        INNER JOIN negocio.sga_planes_versiones pv ON p.plan_version = pv.plan_version
		        INNER JOIN  negocio.sga_alumnos a ON a.alumno = p.alumno
			    GROUP BY 1,2;
			-- 644.101 Registros

-- Max fecha_insc supongo que es la fecha en la que se inscribio al ultimo plan
SELECT persona, EXTRACT(DAY FROM TIMESTAMP '2019-08-05' - max(fecha_insc)) AS dias_inscripcion_plan
FROM vw_cambios_plan_incripcion
GROUP BY 1
ORDER BY 2 DESC;
-- 644.101

SELECT persona, EXTRACT(DAY FROM TIMESTAMP '2019-08-05' - max(fecha_insc)) AS dias_inscripcion_plan
FROM vw_cambios_plan_incripcion
GROUP BY 1
HAVING EXTRACT(DAY FROM TIMESTAMP '2019-08-05' - max(fecha_insc)) < 8000 /*8 mil dias son 21 años aprox*/
ORDER BY 2 ASC;
-- 482.033 registros aprox


------------------------------------Feature-------------------------------------
------- Promedio de finales--------
-- Parseo de notas que con letras
--------------------------------------------------------------------------------

select * from negocio.sga_eval_detalle_cursadas;
select * from negocio.sga_eval_detalle;
select distinct nota from negocio.sga_eval_detalle
order by 1 desc;

select distinct escala_nota from negocio.sga_eval_detalle
Where nota = 'A';

select distinct nota from negocio.sga_eval_detalle
order by 1 desc;

select * from negocio.sga_escalas_notas_det
where escala_nota in (171,191,112,3,47,178,169,151,89,95,40,19,157,127,37,1,42,134,59,117,133,193,170,45,118,60,105,2,159,124,144,7)
and valor_numerico is null;

UPDATE negocio.sga_escalas_notas_det
SET valor_numerico = 2
where descripcion = 'Reprobado';

UPDATE negocio.sga_escalas_notas_det
SET valor_numerico = 2
where descripcion = 'No aprobado';


UPDATE negocio.sga_escalas_notas_det
SET valor_numerico = 5
where descripcion = 'Aprobado';

UPDATE negocio.sga_escalas_notas_det
SET valor_numerico = 8
where descripcion = 'Promocionado';

SELECT * FROM negocio.sga_escalas_notas_det
Where valor_numerico is null;

/*
    SS	10.000
    S	4.000
    I	1.000
    R	2.000
    B	6.000
    D	8.000
    --otra
    P   8.00
    R   2
    NA  2
    A   5
*/

SELECT *
FROM negocio.sga_eval_detalle ed
INNER JOIN negocio.sga_escalas_notas_det en ON (ed.escala_nota = en.escala_nota and ed.nota = en.nota)
WHERE valor_numerico notnull;
-- 3.206.911 Registros


/*No verifique todos los valores numericos posibles por si algunos se pasa del rango 0-10*/
SELECT a.persona, SUM(en.valor_numerico) as sum_notas, COUNT(en.valor_numerico) count_notas
FROM negocio.sga_eval_detalle ed
INNER JOIN negocio.sga_escalas_notas_det en ON (ed.escala_nota = en.escala_nota and ed.nota = en.nota)
INNER JOIN  negocio.sga_alumnos a ON a.alumno = ed.alumno
WHERE valor_numerico notnull
GROUP BY 1;
-- 166.980 Registros

SELECT a.persona, SUM(en.valor_numerico)/COUNT(en.valor_numerico) as promedio
FROM negocio.sga_eval_detalle ed
INNER JOIN negocio.sga_escalas_notas_det en ON (ed.escala_nota = en.escala_nota and ed.nota = en.nota)
INNER JOIrsona, dato_censal

-- drop view vw_datos_economicos_x_persona
CREATE VIEW vw_datos_economicos_x_persona AS
    SELECT distinct on (persona) persona,
                                 hde.costeo_estudios_beca,
				                                 hde.costeo_estudios_familiar,
								                                 hde.costeo_estudios_plan_social,
												                                 hde.costeo_estudios_trabajo
																    FROM negocio.his_datos_economicos hde
																    INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = hde.dato_censal
																    ORDER BY persona ASC;

																SELECT * FROM vw_datos_economicos_x_persona
																where costeo_estudios_beca = 'S'
																AND costeo_estudios_familiar = 'S'
																/*AND costeo_estudios_plan_social = 'S'
AND costeo_estudios_trabajo = 'N'*/
;

--------------------------------------------------------------------------------
--- Ver como conviene realizar el pasaje de estas
--------------------------------------------------------------------------------


------------------------------------Feature-------------------------------------
------------------ Datos persona: Sexo de la persona-----------------
-- Sexo de la persona
--------------------------------------------------------------------------------
SELECT persona,sexo FROM negocio.mdp_personas;


------------------------------------Feature-------------------------------------
------------------ Datos persona: Tiene Beca?-----------------
-- Indica si la persona tiene una beca
--------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             hde.beca
	FROM negocio.his_datos_economicos hde
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = hde.dato_censal
	ORDER BY persona ASC;
	-- 665.845 Registros

------------------------------------Feature-------------------------------------
------------------ Tiene PC en su casa-----------------
-- Variable boolean que indica si tiene o no pc en su casa
--------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             mda.tecnologia_pc_casa
	FROM negocio.mdp_datos_actividades mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	ORDER BY persona ASC;
	-- 665.690 Registros

-- Cuantos no tiene pc en su casa
SELECT distinct on (persona) persona,
             mda.tecnologia_pc_casa
	FROM negocio.mdp_datos_actividades mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE tecnologia_pc_casa = 'N'
	ORDER BY persona ASC;
	---359.548 Registros


------------------------------------Feature-------------------------------------
------------------ Tiene Internet en su casa-----------------
-- Variable boolean que indica si tiene o no internet en su casa
--------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             mda.tecnologia_int_casa
	FROM negocio.mdp_datos_actividades mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	ORDER BY persona ASC;
	-- 665.690 Registros

-- Cuantos no tiene pc en su casa
SELECT distinct on (persona) persona,
             mda.tecnologia_int_casa
	FROM negocio.mdp_datos_actividades mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE tecnologia_int_casa = 'N'
	ORDER BY persona ASC;
	---130.606 Registros


------------------------------------Feature-------------------------------------
------------------ Nivel de Idioma Ingles-----------------
-- Nivel de Idioma Ingles
--------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             mda.nivel_idioma_ingles
	FROM negocio.mdp_datos_actividades mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	ORDER BY persona ASC;
	-- 665.690 Registros

-- registros no nulos en nivel de ingles
SELECT distinct on (persona) persona,
             mda.nivel_idioma_ingles
	FROM negocio.mdp_datos_actividades mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE nivel_idioma_ingles is not null
	ORDER BY persona ASC;
	-- 350.350


------------------------------------Feature-------------------------------------
------------------ Hace algun deporte-----------------
-- Variable boolean que indica si la persona hace deporte
--------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             mda.deportes
	FROM negocio.mdp_datos_actividades mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	ORDER BY persona ASC;
	-- 665.690 Registros

-- ver registros de personas que no hacen deportes
SELECT distinct on (persona) persona,
             mda.deportes
	FROM negocio.mdp_datos_actividades mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE mda.deportes = 'N'
	ORDER BY persona ASC;
	-- 428790 personas no hacen deporte



------------------------------------Feature-------------------------------------
------------------ Trabajo que realiza: Tipo de trabajador -----------------
-- Motivo por el cual estudia la carrera
--1	Patrón (tiene empleados)
--2	Cuenta propia / Independiente
--3	Obrero o empleado (asalariado)
--4	Pasante
--------------------------------------------------------------------------------

SELECT distinct on (persona) persona,
             mda.trabajo_hace
	FROM negocio.mdp_datos_economicos mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE mda.trabajo_hace is not null
	ORDER BY persona ASC;


	------------------------------------Feature-------------------------------------
------------------ Trabajo relacionado con la carrera -----------------
-- Indica si el trabajo esta relacionado con la carrera de forma total, parcial o no esta relacionado
--select * from negocio.mdp_trabajo_carrera;
--1	Total
--2	Parcial
--3	Sin relación
--------------------------------------------------------------------------------

SELECT distinct on (persona) persona,
             mda.trabajo_carrera
	FROM negocio.mdp_datos_economicos mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE mda.trabajo_carrera is not null
	ORDER BY persona ASC;


	------------------------------------Feature-------------------------------------
------------------ Estado Civil del estudiante  -----------------
--1	Soltero
--2	Casado
--3	Separado
--4	Divorciado
--5	Unión consensual
--6	Viudo
--------------------------------------------------------------------------------
--select * from negocio.mdp_estados_civiles;
SELECT distinct on (persona) persona,
             mda.estado_civil
	FROM negocio.mdp_datos_personales mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE estado_civil is not null
	ORDER BY persona ASC;
	-- 579.796 Registros


----------------------------------Feature-------------------------------------
------------------  Situacion Madre -----------------
 -- V-Vive / N-No Vive / D-Desconoce
------------------------------------------------------------------------------

SELECT distinct on (persona) persona,
             mda.situacion_madre
	FROM negocio.mdp_datos_personales mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE situacion_madre is not null
	ORDER BY persona ASC;
	-- 424.763 Registros

----------------------------------Feature-------------------------------------
------------------  Situacion Padre -----------------
 -- V-Vive / N-No Vive / D-Desconoce
------------------------------------------------------------------------------

SELECT distinct on (persona) persona,
             mda.situacion_padre
	FROM negocio.mdp_datos_personales mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE situacion_padre is not null
	ORDER BY persona ASC;
	-- 421.859 Registros

----------------------------------Feature-------------------------------------
------------------  Cantidad de hijos -----------------
------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             mda.cantidad_hijos
	FROM negocio.mdp_datos_personales mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE cantidad_hijos is not null
	ORDER BY persona ASC;
	-- 665.094


----------------------------------Feature-------------------------------------
------------------  Cobertura de salud -----------------
--1 Por ser familiar a cargo (de padre, madre, cónyuge o tutor)
--2	Por su propio trabajo
--3	Como afiliado voluntario (a obra social o prepaga)
--4	Otorgada por la universidad (por ser estudiante)
--5 Carece de cobertura de salud
------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             mda.cobertura_salud
	FROM negocio.mdp_datos_personales mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE cobertura_salud is not null
	ORDER BY persona ASC;
	-- 658.778 Registros


----------------------------------Feature-------------------------------------
------------------  Localidad en que habita en periodo lectivo -----------------
-- Solamente tenemos los codigos
------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             mda.periodo_lectivo_localidad
	FROM negocio.mdp_datos_personales mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE periodo_lectivo_localidad is not null
	ORDER BY persona ASC;
	-- 508.889 Registros

----------------------------------Feature-------------------------------------
------------------  Localidad de procedencia -----------------
-- Solamente tenemos los codigos
------------------------------------------------------------------------------
SELECT distinct on (persona) persona,
             mda.procedencia_localidad
	FROM negocio.mdp_datos_personales mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE procedencia_localidad is not null
	ORDER BY persona ASC;
	-- 455.802 Registros

----------------------------------Feature-------------------------------------
------------------  Categoria vive con:-----------------
-- select * from negocio.mdp_vive_con;
--1	Solo
--2	Con compañeros
--3	Con familia de origen (padres, hermanos, abuelos)
--4	Con su pareja/hijos
--5	Otros
------------------------------------------------------------------------------

SELECT distinct on (persona) persona,
             mda.vive_con
	FROM negocio.mdp_datos_personales mda
	INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
	WHERE vive_con is not null
	ORDER BY persona ASC;
	-- 455.802 Registros


----------------------------------Feature-------------------------------------
------------------ Motivo de eleccion de la institucion -----------------
------------------------------------------------------------------------------

select persona,tipo from negocio.mdp_datos_salud;

SELECT distinct on (persona) persona,
                    mda.mot_economico,
		                    mda.mot_prestigio,
				                    mda.mot_difusion,
						                    mda.mot_recomendacion_amigos,
								                    mda.mot_recomendacion_estudiantes,
										                    mda.mot_sistema_ingreso,
												                    mda.mot_ubicacion
														FROM negocio.mdp_eleccion_institucion mda
														INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
														ORDER BY persona ASC;
														-- 665.801 Registros

-- cantidad de personas que pusieron que si en al menos 1 motivo
SELECT distinct on (persona) persona,
                    mda.mot_economico,
		                    mda.mot_prestigio,
				                    mda.mot_difusion,
						                    mda.mot_recomendacion_amigos,
								                    mda.mot_recomendacion_estudiantes,
										                    mda.mot_sistema_ingreso,
												                    mda.mot_ubicacion
														FROM negocio.mdp_eleccion_institucion mda
														INNER JOIN negocio.his_datos_censales hdc ON hdc.dato_censal = mda.dato_censal
														WHERE mda.mot_economico = 'S'
														    OR mda.mot_prestigio = 'S'
														    OR mda.mot_difusion = 'S'
														    OR mda.mot_recomendacion_amigos = 'S'
														    OR mda.mot_recomendacion_estudiantes = 'S'
														    OR mda.mot_sistema_ingreso = 'S'
														    OR mda.mot_ubicacion = 'S'
														ORDER BY persona ASC;
														-- 11.247 registros





