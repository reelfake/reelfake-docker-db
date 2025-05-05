# ReelFake Docker DB (dockerize postgres db for reelfake api)

## About this repo
reelfake-docker-db provides the db script to generate the database, tables, functions, triggers, etc everything that reelfake api needs. We can spin up the docker container just for learning purpose as well.

## Disclaimer
The idea of the schema, including structure and organizing of tables, are taken from the [dvdrental sample database](https://neon.tech/postgresql/postgresql-getting-started/postgresql-sample-database) from neon.tech.
The movies and actors related data are taken from [tmdb api](https://www.themoviedb.org). I have modified and added new tables, functions and triggers to the dvdrental db schema to suit my side project (reelfake api) need.

## List of tables
- genre
- country
- city
- movie_language
- movie
- actor
- movie_actor
- address
- store
- staff
- customer
- inventory
- dvd_order
- user (this is specific to reelfake api and you may not need this)

## Models
1. Genre
   - This is a genre of the movies like action, drama, thriller, horror, etc.
3. Country
   - This is country that the movie is from. A given movie can have more than 1 origin country. For example, [Speak No Evil](https://www.imdb.com/title/tt27534307).
4. City
   - This entity is a list of cities.
   - Currently, only Australian cities are considered.
5. Movie language
   - This is a list of languages that a movie is in. Usually a movie can belong to many languages but for simplicity a single movie belongs to single lanugage.
   - A single movie belongs to a single language is intentional with the concept that the inventory can have a movie in single language.
6. Movie
   - A single movie instance has many genres (movie table has genre_ids which is array of ids pointing to genre)
   - A single movie instance can belong to many countries (movie table has origin_country_ids which is array of ids pointing to country)
   - A single movie instance belong to a single movie language
7. Actor
   - This has the actors and their detail.
   - This entity has tmdb_id column which is id of the record in the tmdb api. This column is for debugging purpose.
   - This entity also has imdb_id which is the id of the movie on IMDb. The movie need not be on imdb meaning the imdb_id could be null.
   - To visit hte movie on imdb, simply go to https://www.imdb.com/title/{imdb_id}
8. Movie Cast
   - This is a junction table associating actors and movies.
   - This entity has many movies and many actors.
9. Address
   - This entity contains the address record.
   - The address belongs to city i.e. the city_id column in address is referencing id of city table
   - The customer, staff and store has address reference.
10. Store
    - This entity contains the store data.
    - A store and address entities has 1-to-1 relationship.
    - A single store instance belongs to the single address.
    - This entity also has store_manager_id which is the id of the staff who is employed as manager at a given store.
11. Staff
    - This entity contains the staff data.
    - This entity also has store_id column referencing id fo the store.
    - A store and staff entities has 1-to-many relationship.
    - A single store instance has many staff and a single staff instance belongs to a single store.
12. Customer
    - This entity has customer data.
    - This entity also has preferred_store_id referencing store and address_id referecing address.
    - The customer and address has 1-to-1 relationship i.e. a single customer has a single address.
    - The customer and store has 1-to-1 relationship i.e. a single customer has a single preferred store.
13. Inventory
    - This entity contains the inventory record of the movie.
    - This entity has movie_id referencing movie and store_id referencing store.
    - The inventory and movie has 1-to-many relationship i.e. a single movie can have many inventory.
    - The inventory and store has 1-to-many relationship i.e. a single store can have many inventory.
14. DVD Order
    - This entity contains the customer order related information.
    - This entity has customer_id referencing customer, staff_id referencing staff and inventory_id referencing inventory.
    - The order and customer has 1-to-many relationship i.e. a single customer can have many orders.
    - The order and staff has 1-to-many relationship i.e. a single staff can process many orders.
    - The order and inventory has 1-to-many relationship i.e. a single inventory can have many orders.
   
## Entity Relationship Visual
![image](https://github.com/user-attachments/assets/1ff2296c-be39-4559-88fa-0e06d586bf25)

## Indexes
The following tables are indexed:
1. movie
   - title
   - release_date
2. actor
   - actor_name

## Triggers
- The created_at column is current date when a new record is inserted.
- The updated_at column is current date when any record is updated.
- The following tables has triggers for created_at and updated_at:
  - genre, country, movie_language, movie, actor, movie_actor, city, address, store, staff, customer, inventory, dvd_order
