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
1. Movie (table is movie)
   - A single movie instance has many genres (movie table has genre_ids which is array of ids pointing to genre)
   - A single movie instance can belong to many countries (movie table has origin_country_ids which is array of ids pointing to country)
   - A single movie instance belong to a single movie language
2. Movie Cast (table is movie_actor)
   - This is a junction table binding actors with the movie.
   - A single movie_actor instance belongs to movie and actor
   - This entity has many movies and many actors.
