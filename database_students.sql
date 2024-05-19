drop table course;--200
drop table student;--1000
drop table teacher;--100
drop table score;--10000
drop table COURSE_NAME_GEN;
drop function random_name;
--drop function course_copy;
drop function select_random_course;
drop function random_cno;

CREATE TABLE COURSE (cno INT primary key , cname VARCHAR( 100 ) , tno INT, clevel text) ;
CREATE TABLE STUDENT (sno INT primary key , sname VARCHAR( 50 ) , gen text, sgroup VARCHAR (6 )) ;
CREATE TABLE TEACHER (tno INT primary key , tname VARCHAR (50 ) , gen text) ;
CREATE TABLE SCORE (cno INT, sno INT , degree INT, essay_text_len INT, test_preparation INT) ;

--select cname, degree, sname, s.gen as sgen, t.gen as tgen, essay_text_len, test_preparation from score, student s, teacher t, course where course.cno=score.cno and s.sno=score.sno and t.tno=course.tno;

Create or replace function random_string(gender text) returns text as
$$
declare
  result_fname text := '';
  result_sname text := '';
  i integer := 0;
begin
  if gender='Female' then
  select CASE 
  	WHEN ceil(random()*10)=1 THEN 'Marina'
	WHEN ceil(random()*10)=2 THEN 'Anna'
	WHEN ceil(random()*10)=3 THEN 'Olga'
	WHEN ceil(random()*10)=4 THEN 'Olessya'
	WHEN ceil(random()*10)=5 THEN 'Alexandra'
	WHEN ceil(random()*10)=6 THEN 'Zoya'
	WHEN ceil(random()*10)=7 THEN 'Rinata'
	WHEN ceil(random()*10)=8 THEN 'Inga'
	WHEN ceil(random()*10)=9 THEN 'Svetlana'
	ELSE 'Alena'
  END into result_fname;
  select CASE 
  	WHEN ceil(random()*10)=1 THEN 'Ivanova'
	WHEN ceil(random()*10)=2 THEN 'Lubennikova'
	WHEN ceil(random()*10)=3 THEN 'Petrova'
	WHEN ceil(random()*10)=4 THEN 'Balonnikova'
	WHEN ceil(random()*10)=5 THEN 'Koshkina'
	WHEN ceil(random()*10)=6 THEN 'Bibikova'
	WHEN ceil(random()*10)=7 THEN 'Fakeeva'
	WHEN ceil(random()*10)=8 THEN 'Lapushkina'
	WHEN ceil(random()*10)=9 THEN 'Tarashkova'
	ELSE 'Lodochkina'
  END into result_sname;
  else
  select CASE 
  	WHEN ceil(random()*10)=1 THEN 'Petr'
	WHEN ceil(random()*10)=2 THEN 'Sergey'
	WHEN ceil(random()*10)=3 THEN 'Andrey'
	WHEN ceil(random()*10)=4 THEN 'Konstantin'
	WHEN ceil(random()*10)=5 THEN 'Oleg'
	WHEN ceil(random()*10)=6 THEN 'Alexandr'
	WHEN ceil(random()*10)=7 THEN 'Igor'
	WHEN ceil(random()*10)=8 THEN 'Stepan'
	WHEN ceil(random()*10)=9 THEN 'Pavel'
	ELSE 'Kirill'
  END into result_fname;
  select CASE 
  	WHEN ceil(random()*10)=1 THEN 'Ivanov'
	WHEN ceil(random()*10)=2 THEN 'Lubennikov'
	WHEN ceil(random()*10)=3 THEN 'Petrov'
	WHEN ceil(random()*10)=4 THEN 'Balonnikov'
	WHEN ceil(random()*10)=5 THEN 'Koshkin'
	WHEN ceil(random()*10)=6 THEN 'Bibikov'
	WHEN ceil(random()*10)=7 THEN 'Fakeev'
	WHEN ceil(random()*10)=8 THEN 'Lapushkin'
	WHEN ceil(random()*10)=9 THEN 'Tarashkov'
	ELSE 'Lodochkin'
  END into result_sname;
  end if;
  return result_fname || ' ' || result_sname;
end;
$$ language plpgsql;
insert into student (sno, gen, sgroup) select id, CASE WHEN random()<0.25 THEN 'Female' ELSE 'Male' END, 
			       CASE 
			       WHEN random()>=0.89 THEN 'ClassE' 
			       WHEN random()>=0.79 THEN 'ClassB'
			       WHEN random()>=0.58 THEN 'ClassA'
			       WHEN random()>=0.32 THEN 'ClassD'
			       ELSE 'ClassC'
			       END as sgroup
from generate_series(1,3000) id;

update student set sname = random_string(gen);

insert into teacher (tno, gen) select id, CASE WHEN random()<0.5 THEN 'Female' ELSE 'Male' END from generate_series(1,100) id;
update teacher set tname = random_string(gen);

CREATE TABLE COURSE_NAME_GEN (clevel VARCHAR( 100 ), cname VARCHAR( 200 )); 

\COPY COURSE_NAME_GEN FROM '/home/alena/conf/Beginer_courses.csv' WITH (FORMAT csv, DELIMITER ',', QUOTE '"');
\COPY COURSE_NAME_GEN FROM '/home/alena/conf/Intermediate_courses.csv' WITH (FORMAT csv, DELIMITER ',', QUOTE '"');
\COPY COURSE_NAME_GEN FROM '/home/alena/conf/Expert_courses.csv' WITH (FORMAT csv, DELIMITER ',', QUOTE '"');

create or replace function select_random_course(length int) returns void as
$$
declare
  i int := 0;
  course_name text;
  cl text;
  --module int := 1;
begin
  for i in 1..length loop
  	select cname, clevel into course_name, cl from COURSE_NAME_GEN where cname not in (select cname from course) order by random() limit 1;
  	--select cno into module from course where cno not in (select c1.cno from course c1, course c2 where c1.cno = c2.module and c1.cno = i) order by random() limit 1;
  	insert into course values (i, course_name, trunc(random() * 99 + 1), cl);
  end loop;
end;
$$ language plpgsql;

select select_random_course(10);
select count(*) from course;
--select count(*) from course c1, course c2 where c1.cno= c2.module and c1.module = c2.cno;
--CREATE TABLE SCORE (sno INT , cno INT , degree INT) ;

-- Beginner Level 85 to 100
-- Intermediate Level 70 to 90
-- Beginner Level 50 to 75
create or replace function random_cno(length int, rand int) returns void as
$$
declare
  i int := 0;
  st int;
  c int;
  gr varchar(6);
begin
  for i in 1..length loop
  	select cno into c from course order by random() limit 1;
  	select sno, sgroup into st, gr from student where sno not in (select sno from score where cno = c) order by random() limit 1;
	insert into score(sno, cno) values (st, c);
	update public.score set degree = (select case 
	when gr = 'ClassE' then CASE WHEN random()<=0.8 THEN trunc(random() * 20 + 70) ELSE trunc(random() * 10 + 90) END
	when gr = 'ClassD' then CASE WHEN random()<=0.7 THEN trunc(random() * 30 + 50) WHEN random()<=0.9 THEN trunc(random() * 10 + 80) ELSE trunc(random() * 10 + 90) END
	when gr = 'ClassC' then CASE WHEN random()<=0.7 THEN trunc(random() * 15 + 60) WHEN random()<=0.9 THEN trunc(random() * 5 + 85) ELSE trunc(random() * 10 + 90) END
	when gr = 'ClassB' then CASE WHEN random()<=0.7 THEN trunc(random() * 20 + 70) WHEN random()<=0.9 THEN trunc(random() * 20 + 40) ELSE trunc(random() * 10 + 90) END
	when gr = 'ClassA' then CASE WHEN random()<=0.7 THEN trunc(random() * 30 + 40) WHEN random()<=0.9 THEN trunc(random() * 20 + 70) ELSE trunc(random() * 10 + 30) END
	else 0
	END)
	where score.sno = st and score.cno = c;
  end loop;
  update public.score set essay_text_len = (select CASE WHEN random()<0.7 then degree*10+random()*5+2 else 0 end),
  	test_preparation = (select case when degree > 80 then 1 else 0 end);
end;
$$ language plpgsql;

select random_cno(5000, 0);
select random_cno(10000, 1);
select count(*) from score;
CREATE INDEX SCORE_IDX1 ON SCORE(sno, cno);
--CREATE INDEX COURSE_IDX1 ON course(cno, module);
