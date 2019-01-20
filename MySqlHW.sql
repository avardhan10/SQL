USE sakila;


#1a. Display the first and last names of all actors FROM the table actor. 
SELECT first_name, last_name
FROM actor;


#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS `Actor Name`
FROM actor;



#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
#What is one query would you USE to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';


#2b. Find all actors whose last name contain the letters GEN:
SELECT * 
FROM actor
WHERE last_name like '%gen%';


#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name 
FROM actor
WHERE last_name like '%li%'
ORDER BY last_name, first_name;


#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and USE the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD COLUMN description BLOB(50) NULL AFTER first_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor 
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, COUNT(last_name) AS 'name_count'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT DISTINCT last_name, COUNT(last_name) AS 'name_count'
FROM actor
GROUP BY last_name 
HAVING name_count >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

SET SQL_SAFE_UPDATES=0;
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you USE to re-create it?
-- *Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
DESCRIBE sakila.address;

-- 6a. USE JOIN to display the first and last names, as well as the address, of each staff member. USE the tables staff and address:
SELECT stff.first_name, stff.last_name, addy.address
FROM staff stff LEFT JOIN address addy ON stff.address_id = addy.address_id;

-- 6b. USE JOIN to display the total amount rung up by each staff member in August of 2005. USE tables staff and payment.
SELECT stff.first_name, stff.last_name, SUM(pyment.amount) AS 'TOTAL'
FROM staff stff LEFT JOIN payment pyment ON stff.staff_id = pyment.staff_id
GROUP BY stff.first_name, stff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. USE tables film_actor and film. USE inner join.
SELECT f.title, COUNT(a.actor_id) AS 'TOTAL'
FROM film f LEFT JOIN film_actor a ON f.film_id = a.film_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) FROM film WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT ctmer.first_name, ctmer.last_name, SUM(pyment.amount) AS 'TOTAL'
FROM customer ctmer LEFT JOIN payment pyment ON ctmer.customer_id = pyment.customer_id
GROUP BY ctmer.first_name, ctmer.last_name
ORDER BY ctmer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. USE subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id=(SELECT language_id FROM language WHERE name='English');

-- 7b. USE subqueries to display all actors who appear in the film Alone Trip
SELECT first_name, last_name
FROM actor
WHERE actor_id
	IN (SELECT actor_id FROM film_actor WHERE film_id 
	IN (SELECT film_id FROM film WHERE title='ALONE TRIP'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. USE joins to retrieve this information.
SELECT first_name, last_name, email 
FROM customer cust
JOIN address addy ON (cust.address_id = addy.address_id)
JOIN city cit ON (addy.city_id=cit.city_id)
JOIN country cntry ON (cit.country_id=cntry.country_id);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN (SELECT 
		film_id FROM film_category WHERE
		category_id IN (SELECT category_id FROM category WHERE name = 'Family'));
        
-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(f.film_id) AS 'Count_of_Rented_Movies'
FROM  film f
JOIN inventory i ON (f.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
GROUP BY title ORDER BY Count_of_Rented_Movies DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(pyment.amount) 
FROM payment pyment
JOIN staff s ON (pyment.staff_id=s.staff_id)
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store s
JOIN address addy ON (s.address_id=addy.address_id)
JOIN city c ON (addy.city_id=c.city_id)
JOIN country ctry ON (c.country_id=ctry.country_id);

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to USE the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS "Top Five", SUM(pymnt.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment pymnt ON (r.rental_id=pymnt.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. USE the solution FROM the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT name, SUM(pymnt.amount) AS gross_revenue
FROM category cat
INNER JOIN film_category fc ON (fc.category_id = cat.category_id)
INNER JOIN inventory i ON (i.film_id = fc.film_id)
INNER JOIN rental r ON (r.inventory_id = i.inventory_id)
RIGHT JOIN payment pymnt ON (pymnt.rental_id = r.rental_id)
GROUP BY name ORDER BY gross_revenue DESC
LIMIT 5;
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
