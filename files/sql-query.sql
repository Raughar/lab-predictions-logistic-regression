/*With this project I will search and select the features that will help us in the training of a model to predict the films that are more
prone to be rented next month.*/

-- To start, I will select the database that we will use:
USE sakila;

-- Next, I will search the tables to look for the features that are best fitted to be used in the ML model.
SELECT * FROM rental; -- From rental, I will use rental_id and inventory_id to identify the films that are rented, and rental_date to filter the data within the last two months.
SELECT * FROM inventory; -- From inventory, I will use inventory_id and film_id so we can further identify the films.
SELECT * FROM film; -- From film, we will use film_id, rental_rate, length and rating. I don't think the other features will impact the results of the model.
SELECT * FROM film_category; -- I will try to use the category, so we can the check if it is something that impacts on the films rented.
SELECT * FROM category; -- With this information, we can then link the category_id with the name.

/*From all that information, the final features that I will be use are:
  film_id: To identify the film
  rental_duration: To check if the film has been rented for a long time or not
  rental_rate: To check if the prices affect the rental of the movies
  lenght: Also, to check if it affects the rental of a movie.
  rating: To check which ratings are more rented.
  category: Also, to check if it affects the rental.alter
  */

-- The next step will be to check how many times each film has been rented to be used in the model.
SELECT i.film_id, COUNT(*) AS times_rented
FROM rental AS r
JOIN inventory AS i USING (inventory_id)
WHERE r.rental_date BETWEEN '2005-07-01' AND '2005-07-31'
GROUP BY i.film_id;
-- Knowing that the query works, we will use it later.

-- Now I will check the shape of the data that I have chosen for the dataset.
SELECT f.film_id, f.length, f.rating, c.name as category, f.rental_rate, f.rental_duration
FROM film AS f
JOIN film_category AS fc USING (film_id)
JOIN category AS c USING (category_id);

-- To end the SQL part of the project, I will create the query that I will use later on Python to analyze and predict the rentals, while also adding the part to
-- create the binary target value.
SELECT * FROM predict_data;
WITH times_rented AS 
    (SELECT i.film_id, COUNT(*) AS times_rented
    FROM rental AS r
    JOIN inventory AS i USING (inventory_id)
    WHERE r.rental_date BETWEEN '2005-07-01' AND '2005-07-31'
    GROUP BY i.film_id)
SELECT f.film_id, f.length, f.rating, c.name as category, f.rental_rate, f.rental_duration, rc.times_rented,
    CASE 
        WHEN rc.times_rented > AVG(rc.times_rented) OVER () THEN 'High'
        WHEN rc.times_rented <= AVG(rc.times_rented) OVER () THEN 'Low'
        ELSE 'Unknown'
    END AS renting_probability
FROM film AS f
    JOIN film_category AS fc USING (film_id)
    JOIN category AS c USING (category_id)
    JOIN times_rented AS rc USING (film_id)
ORDER BY f.film_id ASC;