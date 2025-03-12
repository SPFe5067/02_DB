-- TCL (Transaction Control Language) : 트랜잭션 제어 언어
-- COMMIT, ROLLBACK, SAVEPOINT

-- DML : 데이터 조작언어로 데이터의 삽입/삭제/수정
--> 트랜잭션은 DML과 관련되어 있음..

/* TRANSACTION 이란?
 * - 데이터베이스의 논리적 연산 단위
 * - 데이터 변경 사항을 묶어서 하나의 트랜잭션에 담아 처리함.
 * - 트랜잭션의 대상이 되는 데이터 변경 사항 : INSERT, UPDATE, DELETE, MERGE
 *
 * INSERT 수행 ------------------------------------------------> DB 반영 (X)
 *
 * INSERT 수행 -----> 트랜잭션에 추가 ---> COMMIT -------------> DB 반영 (O)
 *
 * INSERT 10번 수행 --> 1개 트랜잭션에 10개 추가 --> ROLLBACK --> DB 반영 (X)
 *
 *
 * 1 ) COMMIT : 메모리 버퍼(트랜잭션)에 임시 저장된 데이터 변경 사항을 DB에 반영
 *
 * 2 ) ROLLBACK : 메모리 버퍼(트랜잭션)에 임시 저장된 데이터 변경 사항을 삭제하고
 *                마지막 COMMIT 상태로 돌아감 (DB에 변경 내용 반영 X)
 *
 *
 * 3 ) SAVEPOINT : 메모리 버퍼(트랜잭션)에 저장 지점을 정의하여
 *                ROLLBACK 수행 시 전체 작업을 삭제하는 것이 아닌
 *                저장 지점까지만 일부 ROLLBACK
 *
 *
 * [SAVEPOINT 사용법]
 *
 * ...
 * SAVEPOINT "포인트명1";
 *
 * ...
 * SAVEPOINT "포인트명2";
 *
 * ...
 * ROLLBACK TO "포인트명1"; -- 포인트1 지점까지 데이터 변경사항 삭제
 *
 *
 * ** SAVEPOINT 지정 및 호출 시 이름에 ""(쌍따옴표) 붙여야함 !!! ***
 *
 * */
-------------------------------------------------------------------------------------------------------------------------------
--새로운 DEPARTMENT2에 INSERT
SELECT * FROM DEPARTMENT2;

INSERT INTO DEPARTMENT2 VALUES('T1', '개발1팀','L2');
INSERT INTO DEPARTMENT2 VALUES('T2', '개발2팀','L2');
INSERT INTO DEPARTMENT2 VALUES('T3', '개발3팀','L2');

--INSERT 확인
SELECT * FROM DEPARTMENT2;
--삽입은 되었으나 영구반영은 되지 않은 상태.

ROLLBACK;
SELECT * FROM DEPARTMENT2;
--영구 반영되지 않아 롤백의 영향을 받음.

--COMMIT 후 롤백 되는지
INSERT INTO DEPARTMENT2 VALUES('T1', '개발1팀','L2');
INSERT INTO DEPARTMENT2 VALUES('T2', '개발2팀','L2');
INSERT INTO DEPARTMENT2 VALUES('T3', '개발3팀','L2');
SELECT * FROM DEPARTMENT2;

COMMIT;
ROLLBACK;
SELECT * FROM DEPARTMENT2; -- COMMIT 하여 영구반영하여 ROLLBACK의 영향을 받지 않음.
--------------------------------------------------------------------------------------------------------------------------------------------
--SAVEPOINT 확인
INSERT INTO DEPARTMENT2 VALUES('T4','개발4팀', 'L2');
SAVEPOINT "SP1";

INSERT INTO DEPARTMENT2 VALUES('T5','개발5팀', 'L2');
SAVEPOINT "SP2";

INSERT INTO DEPARTMENT2 VALUES('T6','개발6팀', 'L2');
SAVEPOINT "SP3";

SELECT * FROM DEPARTMENT2;

ROLLBACK TO "SP1";
SELECT * FROM DEPARTMENT2; -- 개발 4팀만 남음

ROLLBACK TO "SP2"; --SP1 구문을 사용하였기에 SP2를 작성한 이력 또한 사라짐.


INSERT INTO DEPARTMENT2 VALUES('T5','개발5팀', 'L2');
SAVEPOINT "SP2";

INSERT INTO DEPARTMENT2 VALUES('T6','개발6팀', 'L2');
SAVEPOINT "SP3";

SELECT * FROM DEPARTMENT2;

-- 개발팀 전체 삭제 해보기
DELETE FROM DEPARTMENT2
WHERE DEPT_ID LIKE 'T%';

--SP2 지점까지 롤백
ROLLBACK TO "SP2";
--개발 5팀까지 롤백

ROLLBACK TO "SP1";
SELECT * FROM DEPARTMENT2;
--개발 4팀까지 롤백

ROLLBACK;
--COMMIT 하여둔 개발 3팀까지 남음
