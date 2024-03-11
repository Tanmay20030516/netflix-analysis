select *
from netflix


select show_id, COUNT(*)
from netflix
group by show_id
order by show_id desc


/* count the num of NULLS for each column */
select 
	count(case when show_id is null then 1 end) as show_id_null_count,
	count(case when type is null then 1 end) as type_null_count,
	count(case when title is null then 1 end) as title_null_count,
	count(case when director is null then 1 end) as director_null_count,
	count(case when cast is null then 1 end) as cast_null_count,
	count(case when country is null then 1 end) as country_null_count,
	count(case when date_added is null then 1 end) as date_added_null_count,
	count(case when release_year is null then 1 end) as release_year_null_count,
	count(case when rating is null then 1 end) as rating_null_count,
	count(case when duration is null then 1 end) as duration_null_count,
	count(case when listed_in is null then 1 end) as listed_in_null_count,
	count(case when description is null then 1 end) as description_null_count
from netflix


/* trying to correlate directors with cast */
with cte as -- common table expression
(
select title, CONCAT(director, '<===>', cast) as director_cast
from netflix
where director is null
)
select director_cast, COUNT(*) as count
from cte
group by director_cast
having COUNT(*) > 1
order by COUNT(*) desc


/* set director as Not Given where both director and cast is NULL */
update netflix
set director = 'Not Given'
where director is null and cast is null
/* this manual filling will take a lot of time */
update netflix
set director = 'Raghav Subbu'
where title ='Kota Factory'
/* let us set all NULL directors as "Not Given" */
update netflix
set director = 'Not Given'
where director is null


/* delete rows where ever there are nulls for columns "date_added", "rating" & "duration" (small number of nulls, can be safely dropped) */
delete from netflix
where show_id
in (select show_id from netflix where rating is NULL)
delete from netflix
where show_id
in (select show_id from netflix where duration is NULL)
delete from netflix
where show_id
in (select show_id from netflix where date_added is NULL)


/* we do not need "cast" and "description" */
alter table netflix
drop column cast
alter table netflix
drop column description


/* let us deal with nulls from the column "country" */
/* set NULL country as "Not Given" */
select 
	count(case when show_id is null then 1 end) as show_id_null_count,
	count(case when type is null then 1 end) as type_null_count,
	count(case when title is null then 1 end) as title_null_count,
	count(case when director is null then 1 end) as director_null_count,
	count(case when country is null then 1 end) as country_null_count,
	count(case when date_added is null then 1 end) as date_added_null_count,
	count(case when release_year is null then 1 end) as release_year_null_count,
	count(case when rating is null then 1 end) as rating_null_count,
	count(case when duration is null then 1 end) as duration_null_count,
	count(case when listed_in is null then 1 end) as listed_in_null_count
from netflix

select coalesce(country, 'Not Given') -- used to fill NULL values with 'Not Given' or any other place holder
from netflix
where country is null

update netflix
set country = 'Not Given'
where country is null


/* process the "country" column */
select distinct country
from netflix

select *
from netflix
where country = ', France, Algeria'  -- show_id = s366
select *
from netflix
where country = ', South Korea'  -- show_id = s194

update netflix
set country = 'France, Algeria'
where show_id = 's366'
update netflix
set country = 'South Korea'
where show_id = 's194'

alter table netflix
add country1 varchar(100)
/* selecting the first country as the main country of the movie */
select substring(country,1, (case when charindex(',',country) = 0 then len(country) else charindex(',',country)-1 end)) as countryy
from netflix

update netflix
set country1 = substring(country,1, (case when charindex(',',country) = 0 then len(country) else charindex(',',country)-1 end))

select distinct country1
from netflix

alter table netflix
drop column country

EXEC sp_rename 'netflix.country1', 'country', 'COLUMN'

select distinct country -- name updated
from netflix

/*
DATA CLEANING IS DONE, LET US EXPORT THE DATASET INTO EXCEL FOR VISUALIZATIONS
*/