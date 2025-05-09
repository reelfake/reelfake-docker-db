# ReelFake Docker DB

## About this repo
Dockerize postgres db for ReelFake api. This repo provides the db script to generate the database, tables, functions, triggers, etc everything that reelfake api needs. We can spin up the docker container just for learning purpose as well.

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
- rental
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
14. Rental
    - This entity contains the customer rental related information.
    - This entity has customer_id referencing customer, staff_id referencing staff and inventory_id referencing inventory.
    - The rental and customer has 1-to-many relationship i.e. a single customer can have many orders.
    - The rental and staff has 1-to-many relationship i.e. a single staff can process many orders.
    - The rental and inventory has 1-to-many relationship i.e. a single inventory can have many orders.
   
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

## Points to know before starting the container
* In docker compose file, there are two profiles (dev and test)
* These profiles were specifically created for reelfake-api and you can pick any one
* The profile dev will start container with name db-dev and profile test with name db-test

## Downloading sample data for the database
* Since the files are large it cannot be published to git
* The sample data are stored in csv file which can be downloaded from [here](https://pratapreddy15.github.io/reelfake-dbdata-downloader)
* Downlaod and save the .csv files under data folder in the repo

## Creating .env file for docker compose
* Depending on the profile you are using you may need to create .env file
* If you are using dev profile, create dev.env
* If you using test profile, create test.env
* In the created .env file, add **POSTGRES_USER** and **POSTGRES_PASSWORD** variables with the values of your choice

## Spinning up the database
1. Pre-requisites
   1. Latest version of docker is installed
   2. PgAdmin or any database client to connect and query the database
   3. If running on linux, docker compose will need to be installed separately from docker
2. Starting docker container
   1. cd in to the repo directory
   2. Run the docker compose in detached mode (to see the output streaming on terminal remove -d flat)
      ```
      docker compose --profile dev -d
      ```
   3. The above command will start the container with name db-dev
  
## Stopping the container
1. Run below command in the terminal
   ```
   docker compose --profile dev down -v
   ```
2. The above command will delete the volume that was created for the database
3. If you do not need the images, you can delete them with below command (will ask for confirmation)
   ```
   docker image prune -a
   ```
4. To clear the cache that was created while starting the container, run the below command (will ask for confirmation)
   ```
   docker builder prune
   ```
