CREATE TABLE classmates (
    name TEXT,
    age INT,
    address TEXT
);

-- INSERT INTO
-- 삽입 몇개의 컬럼
INSERT INTO classmates (name, age) VALUES('홍길동', 23);
-- 모든 열의 데이터를 넣을 때는 컬럼명을 명시할 필요가 없다.
sqlite> INSERT INTO classmates VALUES ('홍길동', 23, '서울');
-- 여러개의 레코드
INSERT INTO classmates
VALUES ('박진희', 28, '세종'), ('연용흠', 26, '군대');

-- SELECT
-- 모든 컬럼 조회
SELECT * FROM classmates;
-- 특정 컬럼 조회
SELECT rowid, name FROM classmates;
-- 제한 걸기
SELECT rowid, name FROM classmates LIMIT 1 OFFSET 2;
-- 조건 걸기
SELECT rowid, name FROM classmates WHERE address='서울';
-- 중복 제거
sqlite> SELECT DISTINCT age FROM classmates;

-- DELETE FROM
DELETE FROM classmates WHERE rowid=(
SELECT rowid FROM classmates WHERE name='연용흠');

-- rowid
-- 마지막 데이터를 삭제하고 새롭게 추가해보면,
-- id가 다시 활용되는 것을 볼 수 있다.
-- 이를 방지하려면, AUTOINCREMENT (django에서 id값)
CREATE TABLE tests (
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL
);

-- UPDATE
UPDATE classmates SET name='지니어스박' WHERE rowid=(SELECT rowid FROM classmates WHERE name='박진희');
