# IMDB Queries

## Tables used according to each TSV:

| Table Name  | TSV File on S3  |
|---|---|
| title_basics  | title.basics.tsv  |
| title_ratings  | title.ratings.tsv  |
| aka_titles | title.akas.tsv |
| title_crew  | title.crew.tsv  |

> All tables containing arrays must be parsed using the SPLIT() function.<br>
> When a initial table is parsed its name updates to: *(table's_name)_arr*<br>

Example of a initial table being parsed:

CREATE TABLE IF NOT EXISTS title_basics_Arr AS 
    SELECT tconst, 
           titleType, 
           primaryTitle, 
           originalTitle, 
           isAdult, 
           startYear, 
           endYear,
           runtimeMinutes, 
           **split(element_at(genres,1),',') AS genresA** 
    FROM title_basics WITH DATA;

## Queries:

### Query A

~~~~
With seriesAndAge AS( 
SELECT  startYear,
        (endYear - startYear) AS Age,
        COUNT(*) AS countSY
FROM title_basics_arr
WHERE startYear IS NOT NULL AND startYear >= 1960 
AND titleType = 'tvSeries' 
GROUP BY startYear, (endYear - startYear)
ORDER BY startYear limit 100),

totalCountEachYear AS( 
SELECT  startYear,
        COUNT(*) AS totalCount
FROM title_basics_arr
WHERE startYear IS NOT NULL AND startYear >= 1960 
AND titleType = 'tvSeries' 
GROUP BY startYear
ORDER BY startYear)

SELECT  a.startYear, 
        a.Age,
        a.countSY AS Number_of_TVSeries,
        CAST(a.countSY AS DOUBLE)*100/b.totalCount AS Percentage_start_year 
FROM seriesAndAge a
INNER JOIN totalCountEachYear b ON a.startYear = b.startYear
ORDER BY a.startyear, a.Age
LIMIT 10;
~~~~

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2011.46.38.png)

## Query B 
~~~~
-- INSERT INTO title_basics (tconst,titleType ,primaryTitle ,originalTitle ,isAdult ,startYear ,endYear ,runtimeMinutes ,genres) VALUES ('abcdefghi', 'movie', 'Hola', '', False, 1995, 1995, 3, ARRAY[''] );

-- DELETE FROM title_basics WHERE tconst = 'abcdefghi';

-- Data Inconsistency Check. [1 inconsitent row included to check the query]

SELECT  startYear,
        COUNT(*) AS Number_of_movies
FROM title_basics_arr
WHERE startYear IS NOT NULL AND startYear >= 1960
AND titleType = 'movie'
AND (originalTitle IS NULL OR LENGTH(originalTitle)=0)
AND (LENGTH(primaryTitle)>0 OR primaryTitle IS NOT NULL)
GROUP BY startYear 
ORDER BY startYear;
~~~~

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2011.49.57.png)

## Query C
~~~~ 
-- Subquering to check data consistency<br>
SELECT  startYear, 
        COUNT(*) AS Number_of_movies 
FROM title_basics_arr
WHERE tConst IN (   SELECT titleID
                    FROM aka_titles_arr 
                    WHERE LENGTH(title)>0   AND isOriginalTitle=0)
AND startYear >= 1960
AND titleType = 'movie' 
GROUP BY startYear 
ORDER BY startYear;
~~~~ 

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2011.53.46.png)

## Query D

~~~~ 
-- Data Inconsistency Check. [1 inconsitent row included to check the query]<br>
SELECT  startYear, 
        COUNT(startYear) AS Number_of_movies 
FROM title_basics_arr
WHERE endYear IS NOT NULL
AND startYear >= 1960
AND titleType = 'movie' 
GROUP BY startYear 
ORDER BY startYear;
~~~~ 

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2011.55.22.png)

## Query E

~~~~ 
WITH arra AS (
SELECT  startYear, 
        genres1, 
        genres2, 
        runtimeminutes
FROM title_basics_arr
CROSS JOIN UNNEST(genresa) WITH ORDINALITY AS t(genres1, genres2) 
WHERE startYear >= 1960 AND runtimeminutes IS NOT NULL
LIMIT 100
)

SELECT DISTINCT startYear, 
                genres1,
                COUNT(genres1) OVER(PARTITION BY arra.genres1) AS number_of_movies, 
                MIN(runtimeminutes) OVER(PARTITION BY arra.genres1) AS minRT, 
                MAX(runtimeminutes) OVER(PARTITION BY arra.genres1) AS maxRT
FROM arra
ORDER BY startYear
~~~~ 

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2011.56.43.png)

## Query F
~~~~ 
with cte1 as(
select a.startyear as year, 
       a.primarytitle as movie, 
       round(b.averagerating) as rating, 
       count(a.primarytitle) over () as cnt
from title_basics_arr a 
     inner join title_ratings_arr b on a.tconst=b.tconst
where a.titletype = 'movie'
      and a.startyear >= 2015
order by a.startyear
),

cte2 as
(
select distinct cte1.rating as rating, 
       count(cte1.movie) over (partition by cte1.rating order by cte1.rating) as rating_1, 
       cast(cte1.cnt as double) as tot
from cte1
)

select cte2.rating,
       round((cte2.rating_1/cte2.tot),4) as den 
from cte2
order by cte2.rating
~~~~ 

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2011.59.02.png)

## Query G
~~~~ 
with aux1 as (select (case when numvotes >= 1 and numvotes <= 1000 then 1000 when numvotes > 1000 and numvotes <= 2000 then 2000
when numvotes > 2000 and numvotes <= 3000 then 3000
when numvotes > 3000 and numvotes <= 4000 then 4000
when numvotes > 4000 and numvotes <= 5000 then 5000
when numvotes > 5000 and numvotes <= 6000 then 6000
when numvotes > 6000 and numvotes <= 7000 then 7000
when numvotes > 7000 and numvotes <= 8000 then 8000
when numvotes > 8000 and numvotes <= 9000 then 9000
when numvotes > 9000 and numvotes <= 10000 then 10000 else NULL end) as num,
t1.numvotes as numvotes,
count(t1.numvotes) over() as tot
from title_ratings_arr t1 inner join title_basics_arr t2 on t1.tconst = t2.tconst where t2.startyear >=2015),

aux2 as (select distinct aux1.num as range,
cast(aux1.tot as double) as totalVotes,
count(aux1.numvotes) over(partition by aux1.num) as nVotes
from aux1)

select range, round(nVotes/totalVotes,5) from aux2
where range is not null
order by range
~~~~ 

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2012.01.51.png)

## Query H

~~~~
WITH cte1 AS(
SELECT startyear AS year, 
       primarytitle as movie, 
       runtimeminutes as runtime, 
       COUNT(primarytitle) OVER() AS cnt
FROM title_basics_arr
WHERE titletype = 'movie'
AND startyear >= 2015
ORDER BY startyear),
             
cte2 AS (
SELECT DISTINCT cte1.runtime AS rt, 
                CAST(cte1.cnt as DOUBLE) AS total, 
                COUNT(cte1.runtime) OVER(PARTITION BY cte1.runtime) AS runtimeSum
FROM cte1
ORDER BY rt)

SELECT cte2.rt AS runtimeMinutes, 
       ROUND((cte2.runtimeSum/cte2.total),5) AS Density_Total_no_of_movies_in_last_5_yrs
FROM cte2
ORDER BY runtimeMinutes;
~~~~

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2012.16.36.png)

## Query I

~~~~
WITH cte1 AS(SELECT startyear AS year, 
                    primarytitle AS movie, 
                    COUNT(*) OVER() AS cnt
             FROM title_basics_arr
             WHERE titletype = 'movie'
                   AND startyear BETWEEN 2000 AND 2019
             ORDER BY startyear),
             
     cte2 AS(SELECT DISCTINCT cte1.year AS startYear, 
                              CAST(cte1.cnt AS DOUBLE) AS total, 
                              COUNT(cte1.year) OVER(PARTITION BY cte1.year) AS yearSum
                       FROM cte1
                       ORDER BY startYear)
SELECT cte2.startYear AS startYear, 
       ROUND((cte2.yearSum/cte2.total),5) AS Density_Total_no_of_movies_in_last_20_yrs
FROM cte2
ORDER BY startYear;
~~~~

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2012.21.15.png)

## Query J

~~~~
SELECT  tconst AS movie_title_ID, 
        primaryTitle AS movie_title, 
        genresa AS Genres
 FROM title_basics_arr
 WHERE titleType = 'movie' --AND CARDINALITY(genresa) >=5 
 ORDER BY CARDINALITY(genresa) DESC 
 LIMIT 10
~~~~

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2012.23.44.png)

## Query K

~~~~
SELECT  a.tconst, 
        b.primarytitle,
        a.directorsa 
FROM title_crew_arr a
INNER JOIN title_basics b ON a.tconst=b.tconst
ORDER BY CARDINALITY(a.directorsa) DESC
LIMIT 10
~~~~

![image](https://github.com/PabloFdez/auxSQLQeriesSC/blob/master/IMDb/Screenshot%202020-02-10%20at%2012.26.21.png)
