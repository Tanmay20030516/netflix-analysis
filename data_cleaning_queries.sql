--View dataset
SELECT *
FROM netflix

--The show_id column is unique id for dataset, therefore let's check for duplicates
SELECT show_id, COUNT(*)
FROM netflix
GROUP BY show_id
ORDER BY show_id DESC
/* No duplicates */

--Check null values across columns
SELECT COUNT(*) FILTER (WHERE show_id IS NULL) AS show_id_nulls,
       COUNT(*) FILTER (WHERE type IS NULL) AS type_nulls,
       COUNT(*) FILTER (WHERE title IS NULL) AS title_nulls,
       COUNT(*) FILTER (WHERE director IS NULL) AS director_nulls,
       COUNT(*) FILTER (WHERE movie_cast IS NULL) AS movie_cast_nulls,
       COUNT(*) FILTER (WHERE country IS NULL) AS country_nulls,
       COUNT(*) FILTER (WHERE date_added IS NULL) AS date_added_nulls,
       COUNT(*) FILTER (WHERE release_year IS NULL) AS release_year_nulls,
       COUNT(*) FILTER (WHERE rating IS NULL) AS rating_nulls,
       COUNT(*) FILTER (WHERE duration IS NULL) AS duration_nulls,
       COUNT(*) FILTER (WHERE listed_in IS NULL) AS listed_in_nulls,
       COUNT(*) FILTER (WHERE description IS NULL) AS description_nulls
FROM netflix
/* not dropping Directors rows where they are null as their number is high */

WITH cte AS -- common table expression
(
SELECT title, CONCAT(director, '<===>', movie_cast) AS director_cast
FROM netflix
)
SELECT director_cast, COUNT(*) AS count
FROM cte
GROUP BY director_cast
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC

UPDATE netflix
SET director = 'Alastair Fothergill'
WHERE movie_cast = 'David Attenborough'
AND director IS NULL
/* Repeat this step to populate the rest of the director nulls;
Populate the rest of the NULL in director as "Not Given" */
UPDATE netflix
SET director = 'Not Given'
WHERE director IS NULL

--Populate the country using the director column
SELECT COALESCE(nt.country,nt2.country)
FROM netflix  AS nt
JOIN netflix AS nt2
ON nt.director = nt2.director
AND nt.show_id <> nt2.show_id
WHERE nt.country IS NULL;
UPDATE netflix
SET country = nt2.country
FROM netflix AS nt2
WHERE netflix.director = nt2.director and netflix.show_id <> nt2.show_id
AND netflix.country IS NULL

SELECT director, country, date_added
FROM netflix
WHERE country IS NULL

--Populate the rest of the NULL in director as "Not Given"
UPDATE netflix
SET country = 'Not Given'
WHERE country IS NULL

-- delete rows where ever there are nulls for columns "date_added", "rating" & "duration" (small number of nulls, can be safely dropped)
SELECT show_id, rating
FROM netflix
WHERE date_added IS NULL

DELETE FROM netflix
WHERE show_id
IN (SELECT show_id FROM netflix WHERE rating IS NULL)

DELETE FROM netflix
WHERE show_id
IN (SELECT show_id FROM netflix WHERE duration IS NULL)

/* check again if any nulls left by running the query from line 13-25 */


-- dropping "movie_cast" and "description" column, coz they seem unnecessary
ALTER TABLE netflix
DROP COLUMN movie_cast
DROP COLUMN description


-- keeping 1st country as original country of the movie/tv show
SELECT *,
       SPLIT_PART(country,',',1) AS countryy,
       SPLIT_PART(country,',',2),
       SPLIT_PART(country,',',4),
       SPLIT_PART(country,',',5),
       SPLIT_PART(country,',',6),
       SPLIT_PART(country,',',7),
       SPLIT_PART(country,',',8),
       SPLIT_PART(country,',',9),
       SPLIT_PART(country,',',10)
FROM netflix
ALTER TABLE netflix
ADD country1 varchar(500)
UPDATE netflix
SET country1 = SPLIT_PART(country, ',', 1)
--Delete column
ALTER TABLE netflix
DROP COLUMN country

-- rename the column country1 to country
-- ALTER TABLE netflix
-- RENAME COLUMN country1 TO country




