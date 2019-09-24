# Database

## DBMS

- MySQL
- SQLite
- Oracle

## 구성요소

- 스키마

  - 설계도(django에서 model만드는 것과 동일)
  - 테이블 형식 정의

- 테이블

  - 열(컬럼/필드), 행(레코드/값)을 모아놓은 데이터 집합

- PK(기본키)

- SQL(Structured Query Language) 

  - RDBMS 관리하기 위한 언어

  - 세 가지 종류
    - DDL(Definition) : 구조(테이블, 스키마) 정의
    - DML(조작) : I, U, D, S
    - DCL(제어) : 권한

- 실습

  - bit.do/hello_db > sqlite.zip 다운로드

# SQLite

## 시작하기

- 실행

  ```bash
  $ sqlite3 db.sqlite3
  ```

- db생성

  ```sqlite
  sqlite> .databases
  ```

- `hellodb.csv`가져와 `example` table만들기

  ```sqlite
  -- csv 파일 import로 테이블 생성
  sqlite> .mode csv
  sqlite> .import hellodb.csv examples
  -- 조회
  sqlite> SELECT * FROM examples;
  1,"길동","홍",600,"충청도",010-2424-1232
  
  -- header 보이기
  sqlite> .headers on
  -- 테이블 형태로 보이기
  sqlite> .mode column
  sqlite> SELECT * FROM examples;
  id          first_name  last_name   age         country     phone
  ----------  ----------  ----------  ----------  ----------  -------------
  1           길동          홍           600         충청도         010-2424-1232
  
  -- 스키마 조회
  sqlite> .schema examples
  CREATE TABLE examples(
    "id" TEXT,
    "first_name" TEXT,
    "last_name" TEXT,
    "age" TEXT,
    "country" TEXT,
    "phone" TEXT
  );
  ```

  * SQLite는 따로 PK를 지정하지 않으면 자동으로 증가하는 **rowid**컬럼을 정의한다.

- - - 
    - 

## DDL

> CREATE, DROP, ALTER

* `CREATE` 테이블 생성

  ```sqlite
  CREATE TABLE classmates (
      id INTEGER PRIMARY KEY,
      name TEXT
  );
  ```

* 테이블 목록 조회

  ```sqlite 
  sqlite> .tables
  classmates  examples
  ```

* 테이블 스키마 조회

  ```sqlite
  sqlite> .schema classmates
  CREATE TABLE classmates (
      id INTEGER PRIMARY KEY,
      name TEXT
  );
  ```

* `DROP` 테이블 삭제

  ```sqlite
  sqlite> DROP TABLE classmates;
  sqlite> .tables
  examples
  ```

* `ALTER` 테이블 구조 변경

  - 테이블명 바꾸기 `RENAME TO`

    ```sqlite
    ALTER TABLE articles RENAME TO news;
    ```

  - 컬럼 추가하기

    ```sqlite
    vsqlite> ALTER TABLE news ADD COLUMN created_at DATETIME NOT NULL;
    Error: Cannot add a NOT NULL column with default value NULL
    ```

    - error를 해결하는 방법
      - not null 조건 없애거나
      - DEFAULT 값을 지정한다.

    ```sqlite
    sqlite> ALTER TABLE news ADD COLUMN created_at DATETIME NOT NULL DEFAULT 1;
    sqlite> .schema news
    CREATE TABLE IF NOT EXISTS "news" (
    title TEXT NOT NULL,
    content TEXT NOT NULL
    , created_at DATETIME NOT NULL DEFAULT 1);
    ```

  - 스키마 변경; 컬럼의 속성 타입을 바꾸고자 할 때 (**이 부분은 나중에 배울 것**)

    - 특정 테이블 이름을 변경한다.
    - 임시 공간에 테이블 데이터들 옮겨놓고, 진행해야한다.

## DML

* 삽입 INSERT

  ```sqlite
  sqlite> INSERT INTO classmates (name, age) VALUES('홍길동', 23);
  sqlite> .headers on -- 컬럼명을 보이게 함
  sqlite> SELECT * FROM classmates;
  name|age|address
  홍길동|23|
  ```

  ```sqlite
  -- 모든 열의 데이터를 넣을 때는 컬럼명을 명시할 필요가 없다.
  sqlite> INSERT INTO classmates VALUES ('홍길동', 23, '서울');
  ```

* SELECT

  ```sqlite
  -- 원하는 컬럼명으로 조회
  sqlite> SELECT name, age FROM classmates;
  name|age
  홍길동|30
  박진희|28
  연용흠|26
  -- 레코드 갯수에 제한
  sqlite> SELECT name FROM classmates LIMIT 1;
  name
  홍길동
  -- 모든 컬럼 조회
  sqlite> SELECT * FROM classmates;
  name|age|address
  홍길동|30|서울
  박진희|28|세종
  연용흠|26|군대
  ```

  * LIMIT와 OFFSET은 한 세트!

    ```sqlite
    sqlite> SELECT name, age FROM classmates LIMIT 1 OFFSET 2;
    name|age
    연용흠|26
    ```

    두칸 띄고 한칸만 출력!

  * where 조건 걸기

    ```sqlite
    sqlite> SELECT rowid, name FROM classmates WHERE address='서울';
    rowid|name
    1|홍길동
    ```

  * DISTINCT 중복제거

    ```sqlite
    sqlite> SELECT DISTINCT age FROM classmates;
    ```

  * LIKE column LIKE '2_'

    * `_` : 한개의 문자 **반드시**
      * `1___` : 1로 시작하는 네글자 문자
    * `%` : 모든 문자

  * ORDER BY ASC|DESC;

* DELETE

  * PK기준으로 삭제하는 것이 좋음

    ```sqlite
    sqlite> DELETE FROM classmates WHERE rowid=3;
    ```

* UPDATE

  ```sqlite
  UPDATE classmates SET name='지니어스박' WHERE rowid=1;
  ```

  

## 무결성

* PK

  * rowid

    * SQLite는 따로 PK를 지정하지 않으면 자동으로 증가하는 **rowid**컬럼을 정의한다.

    * rowid는 가장 마지막 id에 이어서 생성된다.

    * AUTOINCREMENT옵션

      * rowid처럼 가장 마지막 id에 이어서 생성되지 않음

      * 한번 쓰였던 id는 사용되지 않는다.

      * 웹 서비스에서 5번 글로 조회할 수 있다.

        만약 5번 글이 지워지고 새로운 글이 5번이 된다면,

        사용자는 5번글이 삭제 되었구나가 아닌 5번글이 수정되었구나 인식할 수 있는 문제가 있다.

      ```sqlite
      CREATE TABLE tests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
      );
      -- rowid 5까지 레코드 생성
      sqlite> SELECT * FROM tests;
      1|1
      2|1
      3|1
      4|1
      5|1
      -- 레코드 모두 삭제 후 값넣어보기
      sqlite> DELETE FROM tests;
      sqlite> INSERT INTO tests (name) VALUES ('1');
      -- 그 다음 id값은 6이다.
      sqlite> SELECT * FROM TESTs;
      6|1
      ```

      

* NOT NULL

  * 스키마 정의시 해주면 된다.

  * 꼭 필요한 정보라면 NULL값이 들어가면 안된다.

    ```sqlite
    CREATE TABLE classmates (
    id INT PRIMARY KEY,
    name TEXT NOT NULL,
    age INT NOT NULL,
    address TEXT NOT NULL
    );
    ```

## ETC

* 중첩 SQL

  * 이름이 '연용흠'인 행을 지우기

    ```sqlite
    DELETE FROM classmates WHERE rowid=(
    SELECT rowid FROM classmates WHERE name='연용흠');
    ```

    

