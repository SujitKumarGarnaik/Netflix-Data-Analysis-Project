CREATE DATABASE NETFLIX;
use NETFLIX;

---15 Bussiness Problem
--1.Count the number of Movies vs TV Shows
SELECT 
  type,
  count(*) as total_content
FROM netflix
group by type;

--2. Find the most common rating for movies and TV shows
select type,rating
from(
select type,
rating,
count(*) as count_no_time,
rank()over (partition by type order by count(*) desc)as ranking
from netflix
group by type,rating) as t1
where ranking=1;

--3. List all movies released in a specific year (e.g., 2020)
select *
from netflix
where type='Movie' and release_year=2020;
--4. Find the top 5 countries with the most content on Netflix
select top 5 
       TRIM(value) AS country, 
       COUNT(*) AS content_count
from netflix
cross apply STRING_SPLIT(netflix.country, ',')
group by TRIM(value)
order by content_count DESC;
--5. Identify the longest movie or TV show duration
select  * 
from netflix
where type='Movie' and
duration=(select max(duration) from netflix);
--6. Find content added in the last 5 years
select * 
from netflix
where convert(date,date_added,103)>= dateadd(year,-5,getdate());
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select *
from netflix
where director like '%RajiV Chilaka%' ;
--8. List all TV shows with more than 5 seasons
select *
from netflix
where type ='TV Show'
AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;
--9 Count the number of content items in each genre
select genre,count(*) as content_count
from(
     select trim(value) as genre
	 from netflix
	 cross apply string_split(listed_in,',')
	 ) as a
group by genre;
--10. Find each year and the average number of content release by indian on netflix return the top 5 with highest avg content  release

WITH ContentByYear AS (
    SELECT 
        release_year,
        COUNT(*) AS content_count
    FROM netflix
    WHERE country LIKE '%India%'
    GROUP BY release_year
),
AverageContentByYear AS (
    SELECT
        release_year,
		AVG(content_count) AS yearly_content,
        CAST(AVG(content_count) AS DECIMAL(5, 1)) AS avg_content_count
    FROM ContentByYear
    GROUP BY release_year
)
SELECT TOP 5
    release_year,
	yearly_content,
    avg_content_count
FROM AverageContentByYear
ORDER BY avg_content_count DESC;
--11. List all movies that are documentaries
select *
from netflix
where listed_in like '%Documentaries%';
--12. Find all content without a director
select *
from netflix
where director is null;
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years! 
select *
from netflix
where cast like'%Salman Khan%'
and release_year >= year(getdate())-10;
--14. Find the top 10 actors who have appeared in the highest number of movies produced in india
with ActorMovieCount as (
    select
        trim(value) as actor_name
    from netflix
    cross apply string_split(cast, ',')
    where country like '%India%'
),
ActorCount as (
    select
        actor_name,
        count(*) as movie_count
    from ActorMovieCount
    group by actor_name
)
select top 10
    actor_name,
    movie_count
from ActorCount
order by movie_count DESC;
--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in
--the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
select
    category,
    count(*) AS item_count
from(
    select
        case
        when description LIKE '%kill%' 
			 OR
			 description LIKE '%violence%' THEN 'Bad'
             else 'Good'
        end as category
    from netflix
) as categorized_content
group by category;
--16 Count how many times each actor appears across all movies and TV shows and list the top 5 actors with the highest counts.
WITH ActorList AS (
    SELECT 
        TRIM(value) AS actor_name
    FROM netflix
    CROSS APPLY STRING_SPLIT(cast, ',')
)
SELECT 
actor_name,
    COUNT(*) AS appearance_count
FROM ActorList
GROUP BY actor_name
ORDER BY appearance_count DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;
--17.List the top 2 countries with the highest number of content items, similar to finding the top countries with the most content.
SELECT country, COUNT(*) AS content_count
FROM netflix
GROUP BY country
ORDER BY content_count DESC
OFFSET 0 ROWS FETCH NEXT 2 ROWS ONLY;

--18.Find the top 10 longest movies based on their duration.
select title as Movie_name,duration
from netflix
where type='Movie'
order by cast(left(duration,charindex(' ',duration)-1)as int)desc
offset 0 rows fetch next 10 rows only;

--19.Identify the most recently added content to Netflix based on the date_added column.
select top 1 *
from netflix
order by date_added desc;

--20.Count how many movies or TV shows each director has contributed to.
select director,count(*)as Content_Count
from netflix
where director is not null
group by director
order by Content_Count desc;

--21 Analyze the description field to find the most frequently occurring keywords for top 5 keywords
WITH KeywordCount AS (
    SELECT value AS keyword
    FROM netflix
    CROSS APPLY STRING_SPLIT(description, ' ')
)
SELECT TOP 5 keyword, COUNT(*) AS frequency
FROM KeywordCount
GROUP BY keyword
ORDER BY frequency DESC;
