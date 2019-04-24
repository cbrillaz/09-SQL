-- 1a Display the first and last names of all actors from the table actor.
use sakila;
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
use sakila;
select concat(first_name,' ', last_name) AS actor_name 
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
use sakila;
select actor_id, first_name, last_name from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
use sakila;
select * from actor
where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
use sakila;
select actor_id, first_name, last_name from actor
where last_name like "%LI%"
order by 3, 2;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
use sakila;
select country_id, country, last_update from country
where country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
use sakila;
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
use sakila;
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
use sakila;
select last_name, Count(*) AS last_name_count
from  actor
group by 1
order by 2 DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
use sakila;
create view name_count as
select last_name, Count(*) AS last_name_count
from  actor
group by 1;

select actor.last_name, name_count.last_name_count from actor
inner join name_count on actor.last_name = name_count.last_name
where last_name_count > 1
order by 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
use sakila;
update actor
set first_name = "HARPO" where actor_id = "172";

select * from actor
where actor_id = "172";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
use sakila;
update actor
set first_name = "GROUCHO" where first_name = "HARPO";

select * from actor
where first_name = "GROUCHO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
use sakila;
show create table address; 

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
use sakila;
select s.first_name, s.last_name, a.address, a.address2 from staff s 
join address a on a.address_id = s.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
use sakila;
select s.staff_id, s.first_name, s.last_name, sum(p.amount) As total_amount
from staff s
join payment p on p.staff_id = s.staff_id 
group by 1;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
use sakila;
select f.film_id, f.title, Count(*) AS actor_count
from film f 
inner join film_actor fa on fa.film_id = f.film_id
group by 1
order by 3 DESC;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
use sakila;
select count(*) AS film_count
from inventory i
inner join film f on f.film_id = i.film_id
where f.title = "Hunchback Impossible"; 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
use sakila;
create view total_paid as
select customer_id, SUM(amount) AS total_paid
from payment
group by 1;

select c.first_name, c.last_name, t.total_paid 
from customer c 
join total_paid t on c.customer_id = t.customer_id
order by 2;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
use sakila;
select f.film_id, f.title
from film f
join language l on f.language_id = l.language_id
where l.name = "English"  AND (f.title like "Q%" OR f.title like "K%");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
use sakila;
select first_name, last_name
from actor a
WHERE a.actor_id IN
(
  SELECT actor_id
  FROM film_actor fa
  WHERE fa.film_id IN
  (
  SELECT film_id
  FROM film f
  WHERE f.title = 'ALONE TRIP'
  )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
use sakila;
create view customer_addr as
select c.first_name, c.last_name, c.email, a.city_id
from customer c 
inner join address a on c.address_id = a.address_id;

use sakila;
create view customer_city as
select d.first_name, d.last_name, d.email, e.country_id from customer_addr d
inner join city e on d.city_id = e.city_id;

use sakila;
select f.first_name, f.last_name, f.email, g.country from customer_city f
inner join country g on f.country_id = g.country_id
where g.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
use sakila;
create view family_films as
select b.film_id, a.name from category a
inner join film_category b on a.category_id = b.category_id
where a.name = 'Family';

select f.title as movie_title, m.name as category_name
from family_films m
inner join film f on m.film_id = f.film_id
order by 1;

-- 7e. Display the most frequently rented movies in descending order.
use sakila;
create view rental_count as
select inventory_id, count(rental_id) as rental_count from rental
group by inventory_id
order by 2 DESC;

use sakila;
create view rental_join as
select i.film_id, r.inventory_id, r.rental_count from rental_count r 
join inventory i on r.inventory_id = i.inventory_id
order by 1;

select f.title, SUM(r.rental_count) AS total_rentals 
from film f
join rental_join r on f.film_id = r.film_id
group by 1
order by 2 DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
use sakila;
select c.store_id, SUM(p.amount) as total_store_amount from customer c
inner join payment p on c.customer_id = p.customer_id
group by 1
order by 2 DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.
use sakila;
create view store_view as
select s.store_id, a.city_id from address a
inner join store s on a.address_id = s.address_id;

use sakila;
create view store_view2 as 
select s.store_id, c.city, c.country_id from city c
inner join store_view s on c.city_id = s.city_id;

select s.store_id, s.city, c.country from country c
inner join store_view2 s on c.country_id = s.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
use sakila;
create view view_1 as
select c.name, f.film_id from film_category f
inner join category c on f.category_id = c.category_id;

create view view_2 as
select a.name, a.film_id, i.inventory_id from inventory i
join view_1 a on i.film_id = a.film_id;

create view view_3 as
select a.name, a.film_id, a.inventory_id, r.rental_id from rental r
join view_2 a on r.inventory_id = a.inventory_id;

select a.name as genre, SUM(p.amount) as Gross_revenue from payment p
join view_3 a on p.rental_id = a.rental_id
group by 1
order by 2 DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
use sakila;
create view top_5_genres as
select a.name as genre, SUM(p.amount) as Gross_revenue from payment p
join view_3 a on p.rental_id = a.rental_id
group by 1
order by 2 DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_5_genres

