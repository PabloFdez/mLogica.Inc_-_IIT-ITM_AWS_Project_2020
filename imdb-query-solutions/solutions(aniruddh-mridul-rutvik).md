# IMDB Query Solutions 

## Creating new tables with correct Array columns

### name_basics_new

CREATE TABLE IF NOT EXISTS name_basics_new as ( 
  select 
  nconst, 
  primaryname, 
  birthyear, 
  deathyear, 
  split(element_at(primaryprofession,1),',') as primaryprofession,
  split(element_at(knownfortitles,1),',') as knownfortitles
  from name_basics)

### title_basics_new

CREATE TABLE IF NOT EXISTS title_basics_new as ( 
  select 
  tconst, 
  titletype, 
  primarytitle, 
  originaltitle, 
  isadult, 
  startyear, 
  endyear, 
  runtimeminutes, 
  split(element_at(genres,1),',') as genre
  from title_basics)

### title_akas_new

CREATE TABLE IF NOT EXISTS title_akas_new as ( 
  select 
  titleid, 
  ordering, 
  title, 
  region,
  language,
  split(element_at(types,1),',') as types,
  split(element_at(attributes,1),',') as attributes,
  isoriginaltitle
  from title_akas)

### title_crew_new

CREATE TABLE IF NOT EXISTS title_crew_new as ( 
  select 
  tconst, 
  split(element_at(directors,1),',') as directors, 
  split(element_at(writers,1),',') as writers
  from title_crew)

## Query A

with t2
   AS
(select startyear , (endyear - startyear) as age, count(startyear) as count    
from title_basics_new
where startyear between 1960 and 2019
and endyear between 1960 and 2019 
group by startyear ,  (endyear - startyear)
order by startyear asc),
t1
as 
(select startyear, count(startyear) as count2
from title_basics_new where titletype = 'tvEpisode'
group by startyear)

select a.startyear, a.age, a.count as Number_of_TVSeries, cast(a.count as double)*100/b.count2 as percentage_start_year
from t2 a 
inner join t1 b
on a.startyear = b.startyear
order by a.startyear

![image](https://user-images.githubusercontent.com/46951312/74114733-5b196500-4b71-11ea-9c58-e20181f8b44f.png)

## Query B 

select a.startYear, count(a.startYear) as Number_of_movies from title_basics_new a
inner join  
title_akas_new b
on a.tconst = b.titleId
where a.startYear >=1960
and a.titleType = 'movie'
and b.isOriginalTitle = 0
group by a.startyear
order by a.startyear asc;

![image](https://user-images.githubusercontent.com/46951312/74114931-52755e80-4b72-11ea-9693-b9c0a390521b.png)

## Query C

select a.startYear, count(distinct(b.titleId)) as Number_of_movies from title_basics_new a
inner join  
title_akas_new b
on a.tconst = b.titleId
where a.startYear >=1960
and a.titletype = 'movie'
and b.isOriginalTitle = 0
group by a.startyear
order by a.startyear asc;

![image](https://user-images.githubusercontent.com/46951312/74115077-f959fa80-4b72-11ea-8954-d9690a34cbb1.png)

## Query D

select startyear, count(startyear) as Number_of_movies
from title_basics_new
where startyear>= 1960
and titletype = 'movie'
and endyear is not null
group by startyear
order by startyear asc;

![image](https://user-images.githubusercontent.com/46951312/74115235-be0bfb80-4b73-11ea-9bc3-68b8ce47e804.png)

## Query E

select startyear, genre_1, min(runtimeminutes) as min_runtime, max(runtimeminutes) as max_runtime from title_basics_new
CROSS JOIN UNNEST(genre) AS t(genre_1) 
where startyear >= 1960 and titletype = 'movie' 
group by startyear, genre_1 
order by startyear asc;

![image](https://user-images.githubusercontent.com/46951312/74115475-0841ac80-4b75-11ea-809c-f2b5706bc56b.png)

## Query F

create table if not exists ratings_in_each_year_1
as 
select round(title_ratings.averagerating,0) as ratings, count(title_ratings.averagerating) as count
from title_ratings
inner join title_basics_new 
on title_ratings.tconst= title_basics_new.tconst
where title_basics_new.titletype = 'movie'
and title_basics_new.startyear >=2015 and title_basics_new.startyear<=2019
group by round(title_ratings.averagerating,0)
order by round(title_ratings.averagerating,0) asc;

SELECT a.ratings, cast(a.count as double)/b.sum_count as density
FROM ratings_in_each_year_1 a
CROSS JOIN
(
    SELECT SUM(count) as sum_count FROM ratings_in_each_year_1
) b

![image](https://user-images.githubusercontent.com/46951312/74116098-9d45a500-4b77-11ea-8895-59ffdcc48075.png)

## Query G

with cte1
as
(select
case when numvotes >=1 and numvotes <=100000 then 100000
when numvotes >100000 and numvotes<=200000 then 200000
when numvotes >200000 and numvotes<=300000 then 300000
when numvotes >300000 and numvotes<=400000 then 400000
when numvotes >400000 and numvotes<=500000 then 500000
when numvotes >500000 and numvotes<=600000 then 600000
when numvotes >600000 and numvotes<=700000 then 700000
when numvotes >700000 and numvotes<=800000 then 800000
when numvotes >800000 and numvotes<=900000 then 900000
when numvotes >900000 and numvotes<=1000000 then 1000000
when numvotes >1000000 and numvotes<=1100000 then 1100000
when numvotes >1100000 and numvotes<=1200000 then 1200000
when numvotes >1200000 and numvotes<=1300000 then 1300000
when numvotes >1300000 and numvotes<=1400000 then 1400000
when numvotes >1400000 and numvotes<=1500000 then 1500000
when numvotes >1500000 and numvotes<=1600000 then 1600000
when numvotes >1600000 and numvotes<=1700000 then 1700000
when numvotes >1700000 and numvotes<=1800000 then 1800000
when numvotes >1800000 and numvotes<=1900000 then 1900000
when numvotes >1900000 and numvotes<=2000000 then 2000000
when numvotes >2000000 and numvotes<=2100000 then 2100000
when numvotes >2100000 and numvotes<=2200000 then 2200000
else NULL end as num,
t2.primarytitle, 
count(t2.primarytitle) over () as cnt
from title_ratings t1 inner join title_basics_new t2
on t1.tconst = t2.tconst
where t2.startyear >=2015 and t2.startyear <= 2019
and t2.titletype = 'movie')
, grouped_num_1 as
(select distinct t1.num as range, 
count(t1.primarytitle) over (partition by t1.num) as num_count,
cast(t1.cnt as double) as tot
from cte1 t1
)

select t.range,
(t.num_count/t.tot) as density
from grouped_num_1 t
order by t.range

![image](https://user-images.githubusercontent.com/46951312/74126342-4fdc2e80-4b9d-11ea-98b6-07c6b6f0b810.png)

## Query H

create table if not exists runtimeminutes_in_each_year
as
select runtimeminutes, count(runtimeminutes) as count_of_movies from title_basics_new
where titletype = 'movie'
and startyear >=2015 and startyear <= 2019
group by runtimeminutes
order by runtimeminutes asc;

select runtimeminutes, cast(a.count_of_movies as double)/b.total_sum_of_movies as density
from runtimeminutes_in_each_year a
CROSS JOIN
(
select sum(count_of_movies) as total_sum_of_movies from runtimeminutes_in_each_year
) b

![image](https://user-images.githubusercontent.com/46951312/74124852-4ea90280-4b99-11ea-8a50-3ddbf34d0b5e.png)

## Query I

create table if not exists movies_in_each_year
as
select startyear, count(startyear) as count_of_movies from title_basics_new
where titletype = 'movie'
and startyear >=2000 and startyear <= 2019
group by startyear
order by startyear asc;

select startyear, cast(a.count_of_movies as double)/b.total_sum_of_movies as density
from movies_in_each_year a
CROSS JOIN
(
select sum(count_of_movies) as total_sum_of_movies from movies_in_each_year
) b

![image](https://user-images.githubusercontent.com/46951312/74126662-2374e200-4b9e-11ea-9d59-7af74ce8fd6c.png)

## Query J

select row_number() over (order by cardinality(genre) desc) Rank, Movie_title_id, Movie_title,  genre from
(select a.tconst as Movie_title_id, a.primarytitle as Movie_title, a.genre from 
title_basics_new a
inner join title_ratings b
on a.tconst = b.tconst
where b.averagerating > 5.0
and a.titletype = 'movie')

![image](https://user-images.githubusercontent.com/46951312/74128633-38a03f80-4ba3-11ea-9aae-d37697ce137c.png)

## Query K

select row_number() over (order by cardinality(directors) desc) Rank, Movie_title_id, Movie_title,  directors from
(select a.tconst as Movie_title_id, b.primarytitle as Movie_title, a.directors from 
title_crew_new a
inner join title_basics_new b
on a.tconst = b.tconst
inner join title_ratings c
on a.tconst = c.tconst
where c.averagerating > 5.0
and b.titletype = 'movie')

![image](https://user-images.githubusercontent.com/46951312/74128429-c62f5f80-4ba2-11ea-8f90-2f6e98ce00d9.png)
