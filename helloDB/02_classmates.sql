-- DDL(데이터 정의 언어)
-- 관계형데이터베이스 구조를 정의하기 위한 명령어
-- CREATE DROP ALTER
-- 테이블 생성
CREATE TABLE classmates (
    id INTEGER PRIMARY KEY,
    name TEXT
);

-- 테이블 목록 조회
.tables

-- 테이블 스키마 조회
.schema classmates

-- 테이블 삭제
DROP TABLE classmates;