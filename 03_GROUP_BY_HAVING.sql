/*SELECT문의 해석 순사
 * 
 * 5 : SELECT 컬럼명 [AS 별칭, 계산식, 함수]
 * 1 : FROM 테이블명
 * 2 : WHERE 컬럼명 | 함수식 비교 연산자 비교값
 * 3 : GROUP BY 그룹을 묶을 컬럼명
 * 4 : HAVING 그룹함수식 비교연산자 비교값
 * 6 : ORDER BY 컬럼명 | 별칭 | 컬럼순번 정렬방식(ASC/DESC) [NULLS FIRST |LAST]
 * 
 */

--* GROUP BY 절 : 같은 값들이 여러개 기록된 컬럼을 가지고
--							 같은 값들을 하나의 그룹으로 묶음

-- GROUP BY 컬럼명 | 함수식, ..
--여러개의 값을 묶어서 하나로 처리할 목적으로 사용함
--그룹으로 묶은 값에 대해서 SELECT 절에서 그룹함수로 사용함

--그룹함수는 단 한개의 결과값만 산출하기 때문에 그룹이 여러개일 경우 오류 발생
--여러개의 결과값을 산출하기 위해 그룹함수가 적용된 그룹의 기준을 ORDER BY 절에 기술하여 사용

--EMPLOYEE 테이블에서 부서코드, 부서별 급여 합 조회
SELECT *FROM EMPLOYEE;

SELECT DEPT_CODE FROM EMPLOYEE;

SELECT SUM(SALARY) FROM EMPLOYEE e ;

SELECT DEPT_CODE, SUM(SALARY) FROM EMPLOYEE GROUP BY DEPT_CODE;
-- DEPT_CODE 컬럼을 그룹으로 묶어, 그 그룹의 급여 합계(SUM(SALARY))를 구함

--EMPLOYEE 테이블에서 직급코드가 같은 사람의 직급코드, 급여평균, 인원 수를 직급코드 오름차순으로 조회
SELECT JOB_CODE, ROUND(AVG(SALARY)),COUNT(*) 
FROM EMPLOYEE e 
GROUP BY JOB_CODE
ORDER BY JOB_CODE;

--EMPLOYEE 테이블에서 성별과 성별 별 인원수 급여합을 인원수 오름차 순으로 조회
SELECT DECODE(SUBSTR(EMP_NO,8,1), '1', '남성', '2', '여성') 성별, COUNT(*) "인원수", SUM(SALARY) "급여합"

FROM EMPLOYEE
GROUP BY DECODE(SUBSTR(EMP_NO,8,1), '1', '남성', '2', '여성')
ORDER BY COUNT(*);

----------------------------------------------------------------------------------------------------
-- WHERE 절 GROUP BY 절 혼합하여 사용하기
--> WHERE 절은 각 컬럼값에 대한 조건
--> HAVING 절은 그룹에 대한 조건

--EMPLOYEE 테이블에서 부서코드가 D5,D6인 부서의 부서코드, 평균급여, 인원 수 조회
SELECT DEPT_CODE, ROUND(AVG(SALARY)), COUNT(*)
FROM EMPLOYEE
WHERE DEPT_CODE IN('D5','D6')
GROUP BY DEPT_CODE
ORDER BY DEPT_CODE;

--EMPLOYEE 테이블에서 2000년도 이후 입사자들의 직급별 급여 합을 조회
SELECT * FROM EMPLOYEE;

SELECT JOB_CODE, SUM(SALARY)
FROM EMPLOYEE
WHERE HIRE_DATE >= TO_DATE('2000-01-01')
--WHERE EXTRACT(YEAR FROM HIRE_DATE) >= 2000
--WHERE SUBSTR( TO_CHAR(HIRE_DATE,'YYYY'),1,4)>='2000'
GROUP BY JOB_CODE;
-----------------------------------------------------------------------------------------------------
--여러 컬럼을 묶어서 그룹으로 지정 가능 --> 그룹 내의 그룹이 가능
--GROUP BY 사용 시 주의사항
--SELECT 문에 GROUP BY절을 사용하는 경우
--SELECT절에 명시한 조회하려는 컬럼 중
--모두 GROUP BY 절에 작성되어 있어야 함.

--EMPLOYEE 테이블에서 부서별로 같은 직급인 사원의 인원수를 조회
--부서코드 오름차순, 직급코드 내림차순으로 정렬
--부서코드 직급코드 인원수
SELECT DEPT_CODE, JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY DEPT_CODE, JOB_CODE
ORDER BY DEPT_CODE, JOB_CODE DESC;

----------------------------------------------------------------------------------------------------
--HAVING 절 그룹함수로 구해 올 그룹에 대한 조건을 설정할 때 사용
--HAVING 컬럼명 | 함수식 비교연산자 비교값

--EMPLOYEE 테이블에서 부서별 평균 급여가 300 이상인 부서의 부서코드, 평균급여 조회 부서코드 오름차순
SELECT DEPT_CODE, ROUND(AVG(SALARY))
FROM EMPLOYEE
GROUP BY DEPT_CODE
HAVING AVG(SALARY) >= 3000000
ORDER BY DEPT_CODE;

--EMPLOYEE 테이블에서 직급별 인원수가 5명 이하인 직급코드 조회 직급코드 오름차순
SELECT JOB_CODE,COUNT(*)
FROM EMPLOYEE
GROUP BY JOB_CODE
HAVING COUNT(*) <= 5
ORDER BY JOB_CODE;

--HAVING 절에는 그룹함수가 반드시 작성됨

---------------------------------------------------------------------------------------
--집계함수 (ROLLUP,CUBE)
--그룹 별 산출 결과 값의 집계를 계산하는 함수
--(그룹별로 중간 집계 결과를 추가)
--GROUP BY 절에서만 사용할 수 있는 함수
--ROLLUP : GROUP BY 절에서 가장 먼저 작성된 컬럼의 중간 집계를 처리하는 함수
SELECT DEPT_CODE, JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY ROLLUP (DEPT_CODE, JOB_CODE )
ORDER BY 1;

--CUBE : GROUP BY 절에 작성된 모든 컬럼의 중간 집계를 처리하는 함수
SELECT DEPT_CODE, JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY CUBE (DEPT_CODE, JOB_CODE )
ORDER BY 1;

--------------------------------------------------------------------------------------
/* 집합 연산자 (SET OPERATOR)
 * 
 * -- 여러 SELECT의 결과(RESULT SET)를 하나의 결과로 만드는 연산자
 * 
 * - UNION (합집합) : 두 SELECT 결과를 하나로 합침. 단 중복은 하나만 작성
 * 
 * - INTERSECT (교집합) : 두 SELECT 결과 중 중복되는 부분만 조회
 * 
 * - UNION ALL : UNION + INTERSECT 합집합에서 중복되는 부분 제거하지 않음
 * 
 * - MINUS (차집합) : A에서 A,B 교집합 부분을 제거하고 조회
 */

--EMPLOYEE 테이블에서 부서코드가 'D5'인 사원의 사번, 이름, 부서코드, 급여 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE e 
WHERE DEPT_CODE = 'D5'
MINUS

--급여가 300 이상인 사번,이름,부서코드, 급여 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY > 3000000;

--(주의 사항) 집합 연산자를 사용하기 위한 SELECT 문들은
--조회하는 컬럼의 타입과 갯수가 모두 동일해야 한다.
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE e 
WHERE DEPT_CODE = 'D5'
UNION 
SELECT EMP_ID,EMP_NAME,DEPT_CODE,1
FROM EMPLOYEE
WHERE SALARY > 3000000;

-- 서로 다른 테이블이지만
-- 컬럼의 타입, 개수만 일치하면
-- 집합 연산자 사용 가능!

SELECT EMP_ID, EMP_NAME
FROM EMPLOYEE e 
UNION 
SELECT DEPT_ID, DEPT_TITLE
FROM DEPARTMENT;










