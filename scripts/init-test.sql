CREATE DATABASE reelfake_db_test WITH TEMPLATE = template0 ENCODING = 'UTF8';

ALTER DATABASE reelfake_db_test OWNER TO postgres;

\connect reelfake_db_test

SET TIME ZONE 'UTC';
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', 'public', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

-- CREATE EXTENSIONS
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE OR REPLACE FUNCTION public.set_updated_at()
	RETURNS TRIGGER
	AS
$$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

CREATE OR REPLACE FUNCTION public.set_created_at()
	RETURNS TRIGGER
	AS
$$
BEGIN
    NEW.created_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

ALTER FUNCTION public.set_created_at() OWNER TO postgres;

CREATE TYPE public.RENTAL_TYPE AS ENUM ('in-store', 'online');

CREATE TABLE public.genre (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    genre_name CHARACTER VARYING(25) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.genre OWNER TO postgres;

CREATE TABLE public.country (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    country_name citext NOT NULL,
    iso_country_code CHARACTER VARYING(2) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.country OWNER TO postgres;

CREATE TABLE public.city (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    city_name citext NOT NULL,
    state_name citext NOT NULL,
    country_id SMALLINT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.city OWNER TO postgres;

CREATE TABLE public.movie_language (
	id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	language_name CHARACTER VARYING(60) not null,
	iso_language_code CHARACTER VARYING(2) UNIQUE not null,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
	updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() not null
);

ALTER TABLE public.movie_language OWNER TO postgres;

CREATE TABLE public.movie (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tmdb_id INT UNIQUE NOT NULL,
    imdb_id CHARACTER VARYING(60) UNIQUE DEFAULT NULL,
    title citext NOT NULL,
    original_title CHARACTER VARYING(255) NOT NULL,
    overview TEXT,
    runtime SMALLINT,
    release_date DATE NOT NULL,
    genre_ids INT[] NOT NULL,
    origin_country_ids INT[] NOT NULL,
    language_id SMALLINT NOT NULL,
    movie_status CHARACTER VARYING(20) NOT NULL,
    popularity REAL NOT NULL,
    budget BIGINT NOT NULL,
    revenue BIGINT NOT NULL,
    rating_average REAL NOT NULL,
    rating_count INT NOT NULL,
    poster_url CHARACTER VARYING(90),
    rental_rate NUMERIC(4,2) DEFAULT 20.00 NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.movie OWNER TO postgres;

CREATE TABLE public.actor (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tmdb_id INT UNIQUE NOT NULL,
    imdb_id CHARACTER VARYING(60) UNIQUE DEFAULT NULL,
    actor_name citext NOT NULL,
    biography TEXT,
    birthday DATE DEFAULT NULL,
    deathday DATE DEFAULT NULL,
    place_of_birth TEXT DEFAULT NULL,
    popularity REAL DEFAULT NULL,
    profile_picture_url CHARACTER VARYING(90) DEFAULT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.actor OWNER TO postgres;

CREATE TABLE public.movie_actor (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    movie_id INT,
    actor_id INT,
    character_name TEXT,
    cast_order SMALLINT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    UNIQUE(movie_id, actor_id, character_name)
);

ALTER TABLE public.movie_actor OWNER TO postgres;

CREATE TABLE public.address (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address_line citext NOT NULL,
    city_id int NOT NULL,
    postal_code citext NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.address OWNER TO postgres;

CREATE TABLE public.store (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    store_manager_id INT UNIQUE DEFAULT NULL,
    address_id SMALLINT NOT NULL,
    phone_number CHARACTER VARYING(30) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.store OWNER TO postgres;

CREATE TABLE public.staff (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    first_name CHARACTER VARYING(45) NOT NULL,
    last_name CHARACTER VARYING(45) NOT NULL,
    email CHARACTER VARYING(50),
    address_id SMALLINT NOT NULL,
    store_id INT DEFAULT NULL,
    active BOOLEAN DEFAULT true NOT NULL,
    phone_number CHARACTER VARYING(30) NOT NULL,
    avatar TEXT DEFAULT NULL,
    user_password CHARACTER VARYING(120) DEFAULT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.staff OWNER TO postgres;

CREATE TABLE public.customer (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    first_name CHARACTER VARYING(45) NOT NULL,
    last_name CHARACTER VARYING(45) NOT NULL,
    email CHARACTER VARYING(50),
    address_id INT NOT NULL,
    preferred_store_id INT DEFAULT NULL,
    active boolean DEFAULT true NOT NULL,
    phone_number CHARACTER VARYING(30) NOT NULL,
    avatar CHARACTER VARYING(120),
    registered_on DATE DEFAULT ('now'::text)::date NOT NULL,
    user_password CHARACTER VARYING(120) DEFAULT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.customer OWNER TO postgres;

CREATE TABLE public.inventory (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    movie_id INT NOT NULL,
    store_id INT NOT NULL,
    stock_count INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.inventory OWNER TO postgres;

CREATE TABLE public.rental (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    inventory_id INT NOT NULL,
    customer_id INT NOT NULL,
    staff_id INT DEFAULT NULL,
    rental_start_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    rental_end_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    return_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
    rental_duration INT GENERATED ALWAYS AS (rental_end_date::date - rental_start_date::date) STORED,
    delayed_by_days INT DEFAULT NULL,
    amount_paid NUMERIC(5,2) NOT NULL,
    discount_amount NUMERIC(5,2) DEFAULT 0.00 CHECK(discount_amount BETWEEN 0.00 AND 100.00),
    payment_date timestamp without time zone NOT NULL,
    rental_type RENTAL_TYPE NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.rental OWNER TO postgres;

CREATE TABLE public.user (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    first_name CHARACTER VARYING(45) NOT NULL,
    last_name CHARACTER VARYING(45) NOT NULL,
    customer_id INT DEFAULT NULL,
    staff_id INT DEFAULT NULL,
    store_manager_id INT DEFAULT NULL,
    email CHARACTER VARYING(150) NOT NULL,
    user_password CHARACTER VARYING(60) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL
);

ALTER TABLE public.user OWNER TO postgres;

-- ADD FOREIGN KEYS

ALTER TABLE ONLY public.movie
    ADD CONSTRAINT fk_movie_language_id FOREIGN KEY (language_id) REFERENCES public.movie_language ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.movie_actor
    ADD CONSTRAINT fk_movie_actor_actor_id FOREIGN KEY (actor_id) REFERENCES public.actor(id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_movie_actor_movie_id FOREIGN KEY (movie_id) REFERENCES public.movie(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public.city
    ADD CONSTRAINT fk_city_country_id FOREIGN KEY (country_id) REFERENCES public.country(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.address
    ADD CONSTRAINT fk_address_city_id FOREIGN KEY (city_id) REFERENCES public.city(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.store
    ADD CONSTRAINT fk_store_manager_id FOREIGN KEY (store_manager_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_store_address_id FOREIGN KEY (address_id) REFERENCES public.address(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT fk_customer_address_id FOREIGN KEY (address_id) REFERENCES public.address(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_customer_pref_store_id FOREIGN KEY (preferred_store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT fk_inventory_movie_id FOREIGN KEY (movie_id) REFERENCES public.movie(id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_inventory_store_id FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public.rental
    ADD CONSTRAINT fk_rental_inventory_id FOREIGN KEY (inventory_id) REFERENCES public.inventory(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_rental_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_rental_staff_id FOREIGN KEY (staff_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.user
    ADD CONSTRAINT fk_user_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_user_staff_id FOREIGN KEY (staff_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_user_store_manager_id FOREIGN KEY (store_manager_id) REFERENCES public.staff(id)  ON UPDATE CASCADE ON DELETE RESTRICT;

-- INDEXES
CREATE INDEX idx_movie_title ON public.movie(title);
CREATE INDEX idx_movie_release_date ON public.movie(release_date);
CREATE INDEX idx_movie_actor_actor_id ON public.movie_actor(actor_id);
CREATE INDEX idx_movie_actor_movie_id ON public.movie_actor(movie_id);
CREATE INDEX idx_actor_name ON public.actor(actor_name);
CREATE INDEX idx_address_line ON public.address(address_line);
CREATE INDEX idx_postal_code ON public.address(postal_code);
CREATE INDEX idx_city_name ON public.city(city_name);
CREATE INDEX idx_state_name ON public.city(state_name);
CREATE INDEX idx_country_name ON public.country(country_name);

-- TRIGGERS

-- Updated at
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.genre FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.country FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.movie_language FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.movie FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.actor FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.movie_actor FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.city FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.address FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.store FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.staff FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.customer FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.inventory FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
CREATE TRIGGER last_updated_trigger BEFORE UPDATE ON public.rental FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- Created at
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.genre FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.country FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.movie_language FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.movie FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.actor FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.movie_actor FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.city FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.address FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.store FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.staff FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.customer FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.inventory FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();
CREATE TRIGGER created_at_trigger BEFORE INSERT ON public.rental FOR EACH ROW EXECUTE PROCEDURE public.set_created_at();

-- LOAD DATA

COPY public.genre(genre_name) FROM '/docker-entrypoint-initdb.d/genres.csv' DELIMITERS ',' CSV header;
COPY public.movie_language(language_name, iso_language_code) FROM '/docker-entrypoint-initdb.d/languages.csv' DELIMITERS ',' CSV header;
COPY public.country(country_name, iso_country_code) FROM '/docker-entrypoint-initdb.d/countries.csv' DELIMITERS ',' CSV header;
COPY public.city(city_name, state_name, country_id) FROM '/docker-entrypoint-initdb.d/cities.csv' DELIMITERS ',' CSV header;
COPY public.movie(tmdb_id, imdb_id, title, original_title, overview, runtime, release_date, genre_ids, origin_country_ids, language_id, movie_status, popularity, budget, revenue, rating_average, rating_count, poster_url) FROM '/docker-entrypoint-initdb.d/movies.csv' DELIMITERS ',' CSV header;
COPY public.actor(tmdb_id, imdb_id, actor_name, biography, birthday, deathday, place_of_birth, popularity, profile_picture_url) FROM '/docker-entrypoint-initdb.d/actors.csv' DELIMITERS ',' CSV header;
COPY public.movie_actor(movie_id, actor_id, character_name, cast_order) FROM '/docker-entrypoint-initdb.d/movie_actors.csv' DELIMITERS ',' CSV header;
COPY public.address(address_line, city_id, postal_code) FROM '/docker-entrypoint-initdb.d/addresses.csv' DELIMITERS ',' CSV header;
COPY public.staff(first_name, last_name, email, address_id, store_id, active, phone_number, avatar, user_password) FROM '/docker-entrypoint-initdb.d/staff.csv' DELIMITERS ',' CSV header;
COPY public.store(store_manager_id, address_id, phone_number) FROM '/docker-entrypoint-initdb.d/stores.csv' DELIMITERS ',' CSV header;
COPY public.customer(first_name, last_name, email, address_id, preferred_store_id, active, phone_number, avatar, registered_on, user_password) FROM '/docker-entrypoint-initdb.d/customers.csv' DELIMITERS ',' CSV header;
COPY public.inventory(movie_id, store_id, stock_count) FROM '/docker-entrypoint-initdb.d/inventory.csv' DELIMITERS ',' CSV header;
COPY public.rental(customer_id, staff_id, inventory_id, rental_start_date, rental_end_date, return_date, delayed_by_days, amount_paid, discount_amount, payment_date, rental_type) FROM '/docker-entrypoint-initdb.d/rentals.csv' DELIMITERS ',' CSV header;

-- Set foreign keys for staff table

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_staff_address_id FOREIGN KEY (address_id) REFERENCES public.address(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    ADD CONSTRAINT fk_staff_store_id FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE RESTRICT;