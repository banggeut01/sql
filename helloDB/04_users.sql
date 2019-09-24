.mode csv
.import users.csv users

-- 1. 나이가 30 이상인 사람
SELECT * FROM users WHERE age >= 30;
-- 2. 1에서 이름만
SELECT first_name FROM users WHERE age >= 30;
-- 3. age 30이상, 성이 김인 사람의 성과 나이
SELECT last_name, age FROM users WHERE age >= 30 and last_name='김';
-- 4. 3의 인원수
SELECT COUNT(*) FROM users WHERE age >= 30 and last_name='김';
-- 5. 전체 데이터 개수
SELECT count(*) FROM users;
-- 6. 전체 평균 나이
SELECT AVG(age) FROM users;
-- 7. 30세 이상의 평균 나이
SELECT AVG(age) FROM users WHERE age >= 30;
-- 8. balance(계좌잔액) 가장 높은 사람과 액수?
SELECT first_name, MAX(balance) FROM users;
-- 9. 30세 이상의 평균 잔액
SELECT AVG(balance) FROM users WHERE age >= 30;
-- 10. 20대인 사람
SELECT first_name FROM users WHERE age LIKE '2_';
-- 11. 지역번호가 02인 사람(서울)
SELECT count(*) FROM users WHERE phone LIKE '02-%';
-- 12. 이름이 준으로 끝나는 사람
SELECT first_name FROM users WHERE first_name LIKE '%준';
-- 13. 중간번호가 5114인 사람
SELECT count(*) FROM users WHERE phone LIKE '%-5114-%';
-- 14. 나이 많은 사람 10명
SELECT first_name FROM users ORDER BY age DESC LIMIT 10;
-- 15. 나이, 성순으로 오름차순 10명
SELECT age, last_name, first_name FROM users ORDER BY age ASC, last_name ASC LIMIT 10;
-- 16. 15에서 10번째만
SELECT age, last_name, first_name FROM users ORDER BY age, last_name ASC LIMIT 1 OFFSET 9;