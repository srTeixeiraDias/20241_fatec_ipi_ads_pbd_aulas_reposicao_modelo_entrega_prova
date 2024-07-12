-- ----------------------------------------------------------------
-- 1 Base de dados e criação de tabela
--escreva a sua solução aqui

CREATE TABLE tb_students_data (
	id_students_data SERIAL PRIMARY KEY,
	stutendid VARCHAR(15),
	salary INT,
	mother_edu INT,
	father_edu INT,
	prep_study INT,
	prep_exam INT,
	grade INT
);

-- ----------------------------------------------------------------
-- 2 Resultado em função da formação dos pais
--escreva a sua solução aqui

--V1
DO $$
	DECLARE
	cur_count_students_parents_edu REFCURSOR;
	v_count_students INT;
	BEGIN
		OPEN cur_count_students_parents_edu FOR
		SELECT COUNT(*) 
		FROM tb_students_data 
		WHERE mother_edu = 6 
			OR father_edu = 6;
		
		LOOP
			FETCH cur_count_students_parents_edu INTO v_count_students;
			EXIT WHEN NOT FOUND;
			RAISE NOTICE '%', v_count_students;
		END LOOP;
		CLOSE cur_count_students_parents_edu;
	END;
$$

--V2
DO $$
	DECLARE
	cur_count_students_parents_edu REFCURSOR;
	v_count_students INT := 0;
	v_line_studens INT;
	BEGIN
		OPEN cur_count_students_parents_edu FOR
		SELECT *
		FROM tb_students_data 
		WHERE mother_edu = 6 
			OR father_edu = 6;
		
		LOOP
			FETCH cur_count_students_parents_edu INTO v_line_studens;
			EXIT WHEN NOT FOUND;
			v_count_students := v_count_students + 1;
		END LOOP;
		RAISE NOTICE '%', v_count_students;
		CLOSE cur_count_students_parents_edu;
	END;
$$


-- ----------------------------------------------------------------
-- 3 Resultado em função dos estudos
--escreva a sua solução aqui

DO $$
	DECLARE
		v_line_students INT;
		v_count_students INT := 0;
		v_alone_study INT := 1;
		v_fail_grade INT := 0;
		cur_count_studens_alone_approved CURSOR(alone_study INT, fail_grade INT) FOR
			SELECT * FROM tb_students_data  
			WHERE prep_study = alone_study AND grade > fail_grade;
	BEGIN
		OPEN cur_count_studens_alone_approved(
			alone_study := v_alone_study,
			fail_grade := v_fail_grade
		);
		LOOP
			FETCH cur_count_studens_alone_approved INTO v_line_students;
			EXIT WHEN NOT FOUND;
			v_count_students := v_count_students + 1;
		END LOOP;
		IF v_count_students = 0 THEN v_count_students := -1;
		END IF;
		RAISE NOTICE '%', v_count_students;
		CLOSE cur_count_studens_alone_approved;
	END;
$$


-- ----------------------------------------------------------------
-- 4 Salário versus estudos
--escreva a sua solução aqui

DO $$
	DECLARE
		v_line_students INT;
		v_min_salary INT := 5;
		v_frequency INT := 2;
		v_count_students INT := 0;
		cur_count_studens CURSOR(min_salary INT, frequency INT) FOR
			SELECT * FROM tb_students_data  
			WHERE prep_exam = frequency AND salary = min_salary;
	BEGIN
		OPEN cur_count_studens(
			frequency := v_frequency,
			min_salary := v_min_salary
		);
		LOOP
			FETCH cur_count_studens INTO v_line_students;
			EXIT WHEN NOT FOUND;
			v_count_students := v_count_students + 1;
		END LOOP;
		RAISE NOTICE '%', v_count_students;
		CLOSE cur_count_studens;
	END;
$$

-- ----------------------------------------------------------------
-- 5. Limpeza de valores NULL
--escreva a sua solução aqui

DO $$
    DECLARE
        cur_delete REFCURSOR;
        v_tupla RECORD;
    BEGIN
        OPEN cur_delete SCROLL FOR 
        SELECT * FROM tb_students_data;
        LOOP
        FETCH cur_delete INTO v_tupla;
        EXIT WHEN NOT FOUND;
        IF v_tupla.stutendid ISNULL 
			OR v_tupla.salary ISNULL
			OR v_tupla.mother_edu ISNULL
			OR v_tupla.father_edu ISNULL
			OR v_tupla.prep_study ISNULL
			OR v_tupla.prep_exam ISNULL
			OR v_tupla.grade ISNULL
			THEN 
            	DELETE FROM tb_students_data WHERE
                	CURRENT OF cur_delete;
        END IF;
		END LOOP;
 
        LOOP
        FETCH BACKWARD FROM cur_delete INTO v_tupla;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%', v_tupla;
        END LOOP;
 
        CLOSE cur_delete;
    END;
$$

-- ----------------------------------------------------------------