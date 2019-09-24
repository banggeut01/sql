# SQL과 django ORM

* 참고사이트
  * [django 공식문서](https://docs.djangoproject.com/en/2.2/topics/db/queries/)
  * [aggregation](https://docs.djangoproject.com/en/2.2/topics/db/aggregation/)
  * [orm 간단 설명 블로그](https://brownbears.tistory.com/63)

## 기본 준비 사항

* https://bit.do/djangoorm에서 csv 파일 다운로드

* django app

  * `django_extensions` 설치

  * `users` app 생성

  * csv 파일에 맞춰 `models.py` 작성 및 migrate

    아래의 명령어를 통해서 실제 쿼리문 확인

    ```bash
    $ python manage.py sqlmigrate users 0001
    ```
    
    ```sqlite
    BEGIN;
    --
    -- Create model User
    --
    CREATE TABLE "users_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "first_name" varchar(10) NOT NULL, "last_name" varchar(10) NOT NULL, "age" integer NOT NULL, "country" varchar(10) NOT NULL, "phone" varchar(15) NOT NULL, "balance" integer NOT NULL);
    COMMIT;
    ```
    
    

* `db.sqlite3` 활용

  * `sqlite3`  실행

    ```bash
    $ ls
    db.sqlite3 manage.py ...
    $ sqlite3 db.sqlite3
    ```

  * csv 파일 data 로드

    ```sqlite
    sqlite > .tables
    auth_group                  django_admin_log
    auth_group_permissions      django_content_type
    auth_permission             django_migrations
    auth_user                   django_session
    auth_user_groups            auth_user_user_permissions  
    users_user
    sqlite > .mode csv
    sqlite > .import users.csv users_user
    sqlite > SELECT COUNT(*) FROM user_users;
    100
    ```

* 확인

  * sqlite3에서 스키마 확인

    ```sqlite
    sqlite > .schema users_user
    CREATE TABLE IF NOT EXISTS "users_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "first_name" varchar(10) NOT NULL, "last_name" varchar(10) NOT NULL, "age" integer NOT NULL, "country" varchar(10) NOT NULL, "phone" varchar(15) NOT NULL, "balance" integer NOT NULL);
    ```

    

## 문제

> 아래의 문제들을 sql문과 대응되는 orm을 작성 하세요.

### Tip

* Djago ORM에서 실제 query 조회해보기

  * `print`필수!

  ```shell
  print(User.objects.filter(age=30).values('first_name').query)
  SELECT "users_user"."first_name" FROM "users_user" WHERE "users_user"."age" = 30
  ```

  

### 기본 CRUD 로직

1. 모든 user 레코드 조회

   ```python
   # orm
   User.objects.all()
   ```

      ```sql
   -- sql
   SELECT * FROM users_user;
      ```

2. user 레코드 생성

   ```python
   # orm
   User.objects.create(first_name='진희', last_name='박',
       ...: age=28, country='세종', phone='010-5325-3683')
   # IntegrityError: NOT NULL constraint failed: users_user.balance
   
   # 정상
   User.objects.create(first_name='진희', last_name='박', age=28, country='세종', phone='010-5325-3683', balance=35826)
   ```

   ```sql
   -- sql
   sqlite> INSERT INTO users_user (first_name, last_name, age, country, phone)
      ...> VALUES ('진희', '박', 28, '세종', '010-5325-3683');
   -- Error: NOT NULL constraint failed: users_user.balance
   
   INSERT INTO users_user
   VALUES ('진희', '박', 28, '세종', '010-5325-3683', 35826);
   -- Error: table users_user has 7 columns but 6 values were supplied
   
   -- 정상
   INSERT INTO users_user (first_name, last_name, age, country, phone, balance) 
   VALUES ('진희', '박', 28, '세종', '010-5325-3683', 35826);
   ```

   * 하나의 레코드를 빼고 작성 후 `NOT NULL` constraint 오류를 orm과 sql에서 모두 확인 해보세요.

   

3. 해당 user 레코드 조회

   ```python
   # orm
   # 단일 데이터
   User.objects.get(id=101)
   # 여러 데이터
   User.objects.filter(age=30).values('first_name')
   type(User.objects.filter(age=30).values('first_name')[0]) # => dict
   # 모든 필드 보이게
   User.objects.filter(age=30).values()
   ```

      ```sql
   -- sql
   SELECT * FROM users_user;
      ```

4. 해당 user 레코드 수정

   ```python
   # orm
   user = User.objects.get(pk=101)
   user.age = 20
   user.save()
   ```

      ```sql
   -- sql
   UPDATE users_user SET first_name='지니' WHERE id=101;
      ```

5. 해당 user 레코드 삭제

   ```python
   # orm
   user = User.objects.get(pk=101)
user.delete()
   ```
   
      ```sql
   -- sql
   DELETE FROM users_user WHERE id=102;
      ```

### 조건에 따른 쿼리문

1. 전체 인원 수 

   ```python
   # orm
   len(User.objects.all())
   ```

      ```sql
   -- sql
   SELECT count(*) FROM users_user;
      ```

2. 나이가 30인 사람의 이름

   ```python
   # orm
   User.objects.filter(age=30).values('first_name')
   ```

      ```sql
   -- sql
   SELECT first_name FROM users_user WHERE age=30;
      ```

3. 나이가 30살 이상인 사람의 인원 수

   * `gte`: greater than
   * `lte`: less than
   * ex) `age__gte`, `age__range`

   ```python
   # orm
   User.objects.filter(age__gte=30).count()
   ```

   ```sql
   -- sql
   SELECT count(*) FROM users_user WHERE age>=30;
   ```

4. 나이가 30이면서 성이 김씨인 사람의 인원 수

   ```python
   # orm
   User.objects.filter(age__gte=30, last_name='김').count()
   ```

      ```sql
   -- sql
   SELECT count(*) FROM users_user WHERE age>=30 and last_name='김';
      ```

5. 지역번호가 02인 사람의 인원 수

   ```python
   # orm
   User.objects.filter(phone__startswith='02').count()
   ```

      ```sql
   -- sql
   SELECT count(*) FROM users_user WHERE phone LIKE '02-%';
      ```

6. 거주 지역이 강원도이면서 성이 황씨인 사람의 이름

   ```python
   # orm
   User.objects.filter(last_name='황', country='강원도').values('first_name', 'last_name')
   ```

      ```sql
   -- sql
   SELECT last_name, first_name FROM users_user WHERE country='강원도' and last_name='황';
      ```



### 정렬 및 LIMIT, OFFSET

1. 나이가 많은 사람 10명

   ```python
   # orm
   User.objects.order_by('age')[:10]
   User.objects.order_by('age')[:10].values('first_name', 'last_name', 'age')
   ```

      ```sql
   -- sql
   SELECT * FROM users_user ORDER BY age DESC LIMIT 10;
      ```

2. 잔액이 적은 사람 10명

   ```python
   # orm
   User.objects.order_by('-balance')[:10]
   ```

      ```sql
   -- sql
   SELECT * FROM users_user ORDER BY age DESC LIMIT 10;
      ```

3. 성, 이름 내림차순 순으로 5번째 있는 사람

      ```python
   # orm
   User.objects.order_by('-last_name', '-first_name')[4]
   ```
```
   
      ```sql
   -- sql
   sqlite> SELECT * FROM users_user ORDER BY last_name DESC, first_name DESC LIMIT 1 OFFSET 4;
   67|보람|허|28|충청북도|016-4392-9432|82000
```



### 표현식

1. 전체 평균 나이

   ```python
   # orm
   from djnago.db.models import Avg
   User.objects.all().aggregate(Avg('age'))
   {'age__avg': 28.23}
   ```

      ```sql
   -- sql
   SELECT AVG(age) FROM users_user;
   28.23
      ```

2. 김씨의 평균 나이

   ```python
   # orm
   from djnago.db.models import Avg
   User.objects.filter(last_name='김').aggregate(Avg('age'))
   {'age__avg': 28.782608695652176}
   ```

      ```sql
   -- sql
   SELECT AVG(age) FROM users_user WHERE last_name='김';
   28.7826086956522
      ```

3. 계좌 잔액 중 가장 높은 값

   ```python
   # orm
   from django.db.models import Max
   User.objects.all().aggregate(Max('balance'))
   {'balance__max': 1000000}
   ```

      ```sql
   -- sql
   SELECT MAX(balance) FROM users_user;
   1000000
      ```

4. 계좌 잔액 총액

      ```python
   # orm
   from django.db.models import Sum
User.objects.all().aggregate(Sum('balance'))
   {'balance__sum': 14425040}
   ```
   
      ```sql
   -- sql
   SELECT SUM(balance) FROM users_user;
   14425040
      ```