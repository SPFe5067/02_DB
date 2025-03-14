/*SUBQUEARY(서브 쿼리 = 내부 쿼리)
 * 하나의 SQL문 안에 포함된 또 다른 SQL문
 * 메인쿼리(== 외부 쿼리, 기존 쿼리)를 위해 보조역할을 하는 쿼리문
 * 
 * --메인 쿼리가 SELECT 문일 때
 * --SELECT, FROM, WHERE, HAVING 절 에서 사용 가능
 * 
 * 
 * 
 */

-- 서브쿼리 예시 1.
--부서 코드가 노옹철 사원과 같은 소속의 직원의 이름, 부서코드 조회
SELECT*FROM EMPLOYEE;


--메인쿼리
SELECT EMP_NAME ,DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = (
SELECT DEPT_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철');
--서브쿼리
SELECT DEPT_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철';

--서브쿼리 예시2
--전 직원의 평균 급여보다 많은 급여를 받고있는 직원의 사번, 이름, 직급코드, 급여 조회
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE e 
WHERE SALARY > (SELECT CEIL(AVG(SALARY)) FROM EMPLOYEE e );
-------------------------------------------------------------------------------------------------------------
/* 서브쿼리 유형
 * 
 * - 단일행 (단일열) 서브쿼리 : 서브쿼리의 조회 결과 값의 개수가 1개일 때
 * 
 * - 다중행 (단일열) 서브쿼리 : 서브쿼리의 조회 결과 값의 개수가 여러개일 때
 * 
 * - 다중열 서브쿼리 : 서브쿼리의 SELECT 절에 나열된 항목수가 여러개일 때
 * 
 * - 다중행 다중열 서브쿼리 : 조회 결과 행 수와 열 수가 여러개일 때
 * 
 * - 상(호연)관 서브쿼리 : 서브쿼리가 만든 결과 값을 메인쿼리가 비교 연산할 때
 * 						메인쿼리 테이블의 값이 변경되면 
 * 						서브쿼리의 결과값도 바뀌는 서브쿼리
 * 
 * - 스칼라 서브쿼리 : 상관 쿼리이면서 결과 값이 하나인 서브쿼리
 * 
 * ** 서브쿼리 유형에 따라 서브쿼리 앞에 붙는 연산자가 다름 ** 
 * 
 * */		
--1. 단일행 서브쿼리
--서브쿼리의 조회 결과 값의 개수가 1개인 서브쿼리
--단일행 서브쿼리 앞에는 비교 연산자 사용
-- <, >, <=, >=, =,( !=, <>, ^=)

--전직원의 급여평균보다 많은 급여를 받는 직원의 이름, 직급명, 부서명, 급여를 직급순으로 정렬하여 조회
SELECT*FROM EMPLOYEE;
SELECT*FROM JOB;
SELECT*FROM DEPARTMENT;

SELECT EMPLOYEE.EMP_NAME,  JOB.JOB_NAME, DEPARTMENT.DEPT_TITLE, EMPLOYEE.SALARY
FROM EMPLOYEE, JOB, DEPARTMENT
WHERE (EMPLOYEE.JOB_CODE = JOB.JOB_CODE)
AND (EMPLOYEE.DEPT_CODE = DEPARTMENT.DEPT_ID)
AND (EMPLOYEE.SALARY > (SELECT CEIL(AVG(e.SALARY)) FROM EMPLOYEE e ))
ORDER BY EMPLOYEE.JOB_CODE;


--가장 적은 급여를 받는 직원의 사번, 이름, 직급명, 부서코드, 급여, 입사일 조회

SELECT EMPLOYEE.EMP_ID, EMPLOYEE.EMP_NAME, JOB.JOB_NAME, DEPARTMENT.DEPT_TITLE,  EMPLOYEE.SALARY, EMPLOYEE.HIRE_DATE
FROM EMPLOYEE, JOB, DEPARTMENT
WHERE (EMPLOYEE.JOB_CODE = JOB.JOB_CODE)
AND (EMPLOYEE.DEPT_CODE = DEPARTMENT.DEPT_ID)
AND EMPLOYEE.SALARY = (
        SELECT MIN(e.SALARY) 
        FROM EMPLOYEE e
    );


--노옹철 사원의 급여보다 많이 받는 직원의
--사번, 이름, 부서명, 직급명, 급여

SELECT EMPLOYEE.EMP_ID, EMPLOYEE.EMP_NAME, DEPARTMENT.DEPT_TITLE, JOB.JOB_NAME, EMPLOYEE.SALARY
FROM EMPLOYEE, JOB, DEPARTMENT
WHERE (EMPLOYEE.JOB_CODE = JOB.JOB_CODE)
AND (EMPLOYEE.DEPT_CODE = DEPARTMENT.DEPT_ID)
AND EMPLOYEE.SALARY  > (SELECT e.SALARY FROM EMPLOYEE e WHERE EMP_NAME = '노옹철' );

-- 부서별(부서 없는 사람 포함) 급여의 합계중 가장 큰 부서의 부서명, 급여 합계를 조회
SELECT MAX(SUM (SALARY))
FROM EMPLOYEE
GROUP BY DEPT_CODE;

SELECT DEPT_TITLE, SUM(SALARY)
FROM EMPLOYEE
LEFT JOIN DEPARTMENT ON(DEPT_ID = DEPT_CODE )
GROUP BY DEPT_TITLE
HAVING SUM(SALARY) = (SELECT MAX(SUM (SALARY))
											FROM EMPLOYEE
											GROUP BY DEPT_CODE);
-----------------------------------------------------------------------------------------------------
--2. 다중행 서브쿼리
--서브쿼리의 조회 결과 값의 개수가 여러행일 때
/*다중행 서브쿼리 앞에는 일반 비교연산자 사용 불가
 * IN/NOT IN : 여러개의 결과 값 중에서 하나라도 일치하는 값이 있다면
 * 						 혹은 없다면 이라는 의미(가장 많이 사용!
 * 
 * >ANY, ANY< : 한개라도 큰 경우 혹은 한개라도 작은 경우
 * 							비교하려는 가장 작은 값보다 큰가 / 가장 큰 값 보다 작은가
 * 
 *  >ALL, ALL< : 여러개의 결과값의 모든 값보다 큰/ 작은 경우
 * 							 가장 큰값 보다 큰가/ 가장 작은값 보다 작은가
 * 
 * EXISTS / NOT EXISTS : 값이 존재하는가 / 값이 존재하지 않는가
 * 
 * 
 */

--부서별 최고 급여를 받는 직원의
--이름, 직급, 부서, 급여 부서오름차순

SELECT MAX(SALARY)
FROM EMPLOYEE e
GROUP BY DEPT_CODE;

SELECT EMP_NAME, JOB_CODE, DEPT_CODE, SALARY
FROM EMPLOYEE 
WHERE SALARY IN (SELECT MAX(SALARY)
								 FROM EMPLOYEE e
								 GROUP BY DEPT_CODE)
ORDER BY DEPT_CODE;

--사수에 해당하는 직원에 대해 조회
--사번, 이름, 부서명, 직급명, 구분(사수/사원)

SELECT * FROM EMPLOYEE;

SELECT DISTINCT(MANAGER_ID)
FROM EMPLOYEE 
WHERE MANAGER_ID IS NOT NULL;

SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME			
FROM EMPLOYEE 
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID);

--사수에 해당하는 직원에 대한 정보 추출 조회 (구분 '사수')
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사수' 구분
FROM EMPLOYEE 
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID IN (SELECT DISTINCT(MANAGER_ID)
									FROM EMPLOYEE 
									WHERE MANAGER_ID IS NOT NULL);
--일반 직원에 해당하는 직원에 대한 정보 추출 조회 (구분 '사원')
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사원' 구분
FROM EMPLOYEE 
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID NOT IN  (SELECT DISTINCT(MANAGER_ID)
									FROM EMPLOYEE 
									WHERE MANAGER_ID IS NOT NULL)
ORDER BY JOB_CODE;

--3,4,5 의 조회 결과를 하나로 조회
--1. 집합 연산자 (UNION 합집합)
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사수' 구분
FROM EMPLOYEE 
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID IN (SELECT DISTINCT(MANAGER_ID)
									FROM EMPLOYEE 
									WHERE MANAGER_ID IS NOT NULL)
UNION
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사원' 구분
FROM EMPLOYEE 
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID NOT IN  (SELECT DISTINCT(MANAGER_ID)
									FROM EMPLOYEE 
									WHERE MANAGER_ID IS NOT NULL);

--2. 선택함수 사용
-- DECODE();
-- CASE WHEN 조건 1 THEN 값1...ELSE END
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, 
CASE WHEN EMP_ID IN (SELECT DISTINCT(MANAGER_ID)
									FROM EMPLOYEE 
									WHERE MANAGER_ID IS NOT NULL)
					THEN '사수'
					ELSE '사원'
					END 구분
FROM EMPLOYEE 
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
ORDER BY EMP_ID;

--대리 직급의 직원들 중에서
--과장 직급의 최소 급여보다
--많이 받는 직원의
--사번, 이름, 직급명, 급여 조회

SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE 
JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '대리';

SELECT SALARY
FROM EMPLOYEE
JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '과장';

--방법 1) ANY 사용하기
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE 
JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '대리'
AND SALARY > ANY (SELECT SALARY
FROM EMPLOYEE
JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '과장');
--방법 2) MIN을 이용해서 단일행 서브쿼리로 만들기
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE 
JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '대리'
AND SALARY > (SELECT MIN(SALARY) FROM EMPLOYEE JOIN JOB USING (JOB_CODE) WHERE JOB_NAME = '과장');

--차장 직급의 급여 중 가장 큰 값 보다 많이 받는 과장 직급의 직원
--사번, 이름, 직급, 급여 조회
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE 
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '과장' 
AND SALARY > ALL (SELECT SALARY FROM EMPLOYEE JOIN JOB USING(JOB_CODE) WHERE JOB_NAME = '차장');
-- >ALL 가장 큰 값보다 큰가 / <ALL  가장 작은값 보다 작은가

--서브쿼리 중첩 사용 응용
--LOCATION 테이블 에서 NATIONAL_CODE가 KO인 경우 LOCAL_CODE와 
--DEPARTMENT_CODE 테이블의 LOCATION_ID와 동일한 DEPT_ID가
--EMPLOYEE 테이블의 DEPT_CODE와 동일한 사원 조회해라
SELECT * FROM LOCATION;
SELECT LOCAL_CODE
FROM LOCATION 
WHERE NATIONAL_CODE = 'KO';

SELECT DEPT_ID
FROM DEPARTMENT 
WHERE LOCATION_ID = (SELECT LOCAL_CODE
FROM LOCATION 
WHERE NATIONAL_CODE = 'KO');

SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE IN (SELECT DEPT_ID
FROM DEPARTMENT 
WHERE LOCATION_ID = (SELECT LOCAL_CODE
FROM LOCATION 
WHERE NATIONAL_CODE = 'KO'));

------------------------------------------------------------------------------------
--다중열 서브쿼리
--서브쿼리 SELECT 절에 나열된 컬럼 수가 여러개 일 때

--퇴사한 여직원과 같은 부서, 같은 직급에 해당하는
--사원의 이름, 직급코드, 부서코드, 입사일 조회
SELECT * FROM EMPLOYEE;

SELECT DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE ENT_YN = 'Y' AND SUBSTR(EMP_NO,8,1) = '2';

SELECT EMP_NAME, JOB_CODE, DEPT_CODE, HIRE_DATE
FROM EMPLOYEE
WHERE (JOB_CODE, DEPT_CODE) = (SELECT JOB_CODE, DEPT_CODE
															 FROM EMPLOYEE
															 WHERE ENT_YN = 'Y' AND SUBSTR(EMP_NO,8,1) = '2');
-- 서브쿼리의 조회된 컬럼과 비교하여 일치하는 행만 조회 (컬럼 순서 중요)
-----------------------------------------------------------------------------------------------------------
--1. 노옹철 사원과 같은 부서, 같은 직급인 사원을 조회(단, 노옹철 제외)
-- 사번, 이름, 부서코드, 직급코드, 부서명, 직급명
SELECT * FROM DEPARTMENT;
SELECT * FROM EMPLOYEE;

SELECT EMP_ID, EMP_NAME, DEPT_CODE, JOB.JOB_CODE, DEPT_TITLE, JOB_NAME
FROM EMPLOYEE,DEPARTMENT, JOB
WHERE EMPLOYEE.JOB_CODE = JOB.JOB_CODE
AND EMPLOYEE.DEPT_CODE = DEPARTMENT.DEPT_ID
AND(EMPLOYEE.DEPT_CODE, EMPLOYEE.JOB_CODE ) = (SELECT EMPLOYEE.DEPT_CODE, EMPLOYEE.JOB_CODE FROM EMPLOYEE WHERE EMP_NAME = '노옹철')
AND EMPLOYEE.EMP_NAME != '노옹철';


--2. 2000년도에 입사한 사원의 부서와 직급이 같은 사원을 조회
-- 사번, 이름, 부서코드, 직급코드, 입사일
SELECT DEPT_CODE, JOB_CODE 
FROM EMPLOYEE
WHERE HIRE_DATE BETWEEN '2000-01-01' AND '2000-12-31';

SELECT EMP_ID, EMP_NAME, DEPT_CODE, JOB_CODE, HIRE_DATE
FROM EMPLOYEE 
WHERE (DEPT_CODE, EMPLOYEE.JOB_CODE ) = (SELECT DEPT_CODE, JOB_CODE 
FROM EMPLOYEE
WHERE HIRE_DATE BETWEEN '2000-01-01' AND '2000-12-31');

--3. 77년생 여자 사원과 동일한 부서이면서 동일한 사수를 가지고 있는 사원 조회
-- 사번, 이름, 부서코드, 사수번호, 주민번호, 입사일
SELECT DEPT_CODE, MANAGER_ID
FROM EMPLOYEE 
WHERE SUBSTR(EMP_NO,8,1)='2' AND EMP_NO LIKE'77%';

SELECT EMP_ID, EMP_NAME, DEPT_CODE, MANAGER_ID, EMP_NO, HIRE_DATE
FROM EMPLOYEE
WHERE (DEPT_CODE, MANAGER_ID) =(SELECT DEPT_CODE, MANAGER_ID
FROM EMPLOYEE 
WHERE SUBSTR(EMP_NO,8,1)='2'  AND EMP_NO LIKE'77%')
AND EMP_NO LIKE'77%';

--4. 다중행 다중열 서브쿼리
--서브쿼리 조회 결과 행 수와 열 수가 여러개 일 때

--본인이 소속된 직급의 평균 급여를 받고 있는 직원의
--사번, 이름, 직급코드, 급여 단, 급여 평균은 10000원 단위로 계산하라(TRUNC(컬럼명, -4))

SELECT JOB_CODE, TRUNC( AVG(SALARY), -4)
FROM EMPLOYEE 
GROUP BY JOB_CODE;

SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE (JOB_CODE, SALARY) IN (SELECT JOB_CODE, TRUNC( AVG(SALARY), -4)
FROM EMPLOYEE 
GROUP BY JOB_CODE);
-----------------------------------------------------------------------------------------------------












