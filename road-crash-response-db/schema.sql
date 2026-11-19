--
-- PostgreSQL database dump
--

\restrict X0rsHOILZGxuWx5ydvp9XjwbO3LzyOoyadMIJg0X7oNNffckZ4puavW1V8wlzFU

-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: arcemmergencie; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA arcemmergencie;


--
-- Name: cube; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- Name: earthdistance; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;


--
-- Name: EXTENSION earthdistance; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION earthdistance IS 'calculate great-circle distances on the surface of the Earth';


--
-- Name: availability_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.availability_status AS ENUM (
    'available',
    'occupied'
);


--
-- Name: severity_types; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.severity_types AS ENUM (
    'red',
    'yellow',
    'green'
);


--
-- Name: status_types; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.status_types AS ENUM (
    'open',
    'closed'
);


--
-- Name: valid_roles; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.valid_roles AS ENUM (
    'driver',
    'owner',
    'police_officer',
    'witness'
);


--
-- Name: assign_case_to_nearest_police(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_case_to_nearest_police() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
    nearest_officer_id INT;
BEGIN
    -- Find the nearest police officer using earthdistance extension
    SELECT u.user_id INTO nearest_officer_id
    FROM users u
    JOIN policeposts p ON u.user_id = p.trafficpolice_id
    ORDER BY earth_distance(ll_to_earth(NEW.latitude,NEW.longitude),ll_to_earth(p.latitude,p.longitude))
    LIMIT 1;

    -- Update the "assignedcases" table with the case ID and police officer ID
    INSERT INTO assignedcases (crash_id, police_id)
    VALUES (NEW.crash_id, nearest_officer_id);

    RETURN NEW;
END;

$$;


--
-- Name: book_emergency_room(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.book_emergency_room() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
    nearest_hospital_id integer;
BEGIN
    -- nearest hospital with enough rooms
    SELECT hospital_id INTO nearest_hospital_id
    FROM public.hospitals h
    WHERE h.available_rooms >= NEW.number_of_people
    ORDER BY public.earth_distance(public.ll_to_earth(NEW.latitude, NEW.longitude),
                                   public.ll_to_earth(h.latitude, h.longitude))
    LIMIT 1
    FOR UPDATE;  -- lock the row so two simultaneous crashes cannot overbook it

    IF nearest_hospital_id IS NULL THEN
        -- none free: leave unassigned
        RAISE WARNING 'No emergency room capacity for crash %', NEW.crash_id;
        INSERT INTO public.emergencyrooms (crash_id, hospital_id) VALUES (NEW.crash_id, NULL);
        RETURN NEW;
    END IF;

    UPDATE public.hospitals
    SET available_rooms = available_rooms - NEW.number_of_people
    WHERE hospital_id = nearest_hospital_id;

    INSERT INTO public.emergencyrooms (crash_id, hospital_id) VALUES (NEW.crash_id, nearest_hospital_id);
    RETURN NEW;
END;
$$;


--
-- Name: send_crash_notification(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.send_crash_notification() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
DECLARE
    ownerID INTEGER;
    driverID INTEGER;
	insurerID INTEGER;
BEGIN
    -- Get owner and driver information
    SELECT owner_id, driver_id,insurer_id
    INTO ownerID, driverID,insurerID
    FROM vehicles
    WHERE vehicle_id = NEW.vehicle_id;

    -- Check the severity code of the newly inserted crash case
    IF NEW.severitycode IN ('yellow', 'red') THEN
        INSERT INTO notifications (insurer_id, vehicle_id, severitycode, owner_id, driver_id)
        VALUES (insurerID, NEW.vehicle_id, NEW.severitycode, ownerID, driverID);
    END IF;

    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assignedcases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignedcases (
    crash_id integer,
    police_id integer,
    assignement_id integer NOT NULL
);


--
-- Name: assignedcases_assignement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignedcases_assignement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignedcases_assignement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignedcases_assignement_id_seq OWNED BY public.assignedcases.assignement_id;


--
-- Name: emergencyrooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emergencyrooms (
    hospital_id integer,
    crash_id integer
);


--
-- Name: hospitals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hospitals (
    hospital_id integer NOT NULL,
    _name character varying(255),
    latitude double precision,
    longitude double precision,
    available_rooms integer
);


--
-- Name: hospitals_hospital_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hospitals_hospital_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hospitals_hospital_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hospitals_hospital_id_seq OWNED BY public.hospitals.hospital_id;


--
-- Name: insurers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insurers (
    insurer_id integer NOT NULL,
    _name character varying(255),
    address character varying(255),
    contact character varying(10)
);


--
-- Name: insurers_insurer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.insurers_insurer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: insurers_insurer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.insurers_insurer_id_seq OWNED BY public.insurers.insurer_id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    notification_id integer NOT NULL,
    insurer_id integer,
    vehicle_id integer,
    driver_id integer,
    owner_id integer,
    severitycode public.severity_types
);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_notification_id_seq OWNED BY public.notifications.notification_id;


--
-- Name: policeposts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.policeposts (
    post_id integer NOT NULL,
    _name character varying(255),
    trafficpolice_id integer,
    latitude double precision,
    longitude double precision
);


--
-- Name: policeposts_post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.policeposts_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: policeposts_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.policeposts_post_id_seq OWNED BY public.policeposts.post_id;


--
-- Name: roadcrashcases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roadcrashcases (
    crash_id integer NOT NULL,
    reporter_id integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    severitycode public.severity_types NOT NULL,
    status public.status_types,
    latitude double precision,
    longitude double precision,
    number_of_people integer,
    vehicle_id integer
);


--
-- Name: roadcrashcases_crash_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roadcrashcases_crash_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roadcrashcases_crash_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roadcrashcases_crash_id_seq OWNED BY public.roadcrashcases.crash_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(255),
    email character varying(255),
    user_role public.valid_roles NOT NULL
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    vehicle_id integer NOT NULL,
    model character varying(255),
    plate_number character varying(255),
    driver_id integer,
    owner_id integer,
    insurer_id integer,
    make character varying(255)
);


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicles_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicles_vehicle_id_seq OWNED BY public.vehicles.vehicle_id;


--
-- Name: assignedcases assignement_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignedcases ALTER COLUMN assignement_id SET DEFAULT nextval('public.assignedcases_assignement_id_seq'::regclass);


--
-- Name: hospitals hospital_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hospitals ALTER COLUMN hospital_id SET DEFAULT nextval('public.hospitals_hospital_id_seq'::regclass);


--
-- Name: insurers insurer_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insurers ALTER COLUMN insurer_id SET DEFAULT nextval('public.insurers_insurer_id_seq'::regclass);


--
-- Name: notifications notification_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.notifications_notification_id_seq'::regclass);


--
-- Name: policeposts post_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policeposts ALTER COLUMN post_id SET DEFAULT nextval('public.policeposts_post_id_seq'::regclass);


--
-- Name: roadcrashcases crash_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roadcrashcases ALTER COLUMN crash_id SET DEFAULT nextval('public.roadcrashcases_crash_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: vehicles vehicle_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicles_vehicle_id_seq'::regclass);


--
-- Name: assignedcases assignedcases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignedcases
    ADD CONSTRAINT assignedcases_pkey PRIMARY KEY (assignement_id);


--
-- Name: hospitals hospitals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hospitals
    ADD CONSTRAINT hospitals_pkey PRIMARY KEY (hospital_id);


--
-- Name: insurers insurers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insurers
    ADD CONSTRAINT insurers_pkey PRIMARY KEY (insurer_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: policeposts policeposts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policeposts
    ADD CONSTRAINT policeposts_pkey PRIMARY KEY (post_id);


--
-- Name: roadcrashcases roadcrashcases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roadcrashcases
    ADD CONSTRAINT roadcrashcases_pkey PRIMARY KEY (crash_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: roadcrashcases assign_case_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER assign_case_trigger AFTER INSERT ON public.roadcrashcases FOR EACH ROW EXECUTE FUNCTION public.assign_case_to_nearest_police();


--
-- Name: roadcrashcases book_emergency_room_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER book_emergency_room_trigger AFTER INSERT ON public.roadcrashcases FOR EACH ROW WHEN ((new.severitycode = 'red'::public.severity_types)) EXECUTE FUNCTION public.book_emergency_room();


--
-- Name: roadcrashcases notify_on_crash; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER notify_on_crash AFTER INSERT ON public.roadcrashcases FOR EACH ROW EXECUTE FUNCTION public.send_crash_notification();


--
-- Name: assignedcases assignedcases_crash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignedcases
    ADD CONSTRAINT assignedcases_crash_id_fkey FOREIGN KEY (crash_id) REFERENCES public.roadcrashcases(crash_id);


--
-- Name: assignedcases assignedcases_police_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignedcases
    ADD CONSTRAINT assignedcases_police_id_fkey FOREIGN KEY (police_id) REFERENCES public.users(user_id);


--
-- Name: emergencyrooms emergencyrooms_crash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emergencyrooms
    ADD CONSTRAINT emergencyrooms_crash_id_fkey FOREIGN KEY (crash_id) REFERENCES public.roadcrashcases(crash_id);


--
-- Name: emergencyrooms emergencyrooms_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emergencyrooms
    ADD CONSTRAINT emergencyrooms_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id);


--
-- Name: notifications notifications_insurer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_insurer_id_fkey FOREIGN KEY (insurer_id) REFERENCES public.insurers(insurer_id);


--
-- Name: notifications notifications_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: policeposts policeposts_trafficpolice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policeposts
    ADD CONSTRAINT policeposts_trafficpolice_id_fkey FOREIGN KEY (trafficpolice_id) REFERENCES public.users(user_id);


--
-- Name: roadcrashcases roadcrashcases_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roadcrashcases
    ADD CONSTRAINT roadcrashcases_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.users(user_id);


--
-- Name: roadcrashcases roadcrashcases_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roadcrashcases
    ADD CONSTRAINT roadcrashcases_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);


--
-- Name: vehicles vehicles_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.users(user_id);


--
-- Name: vehicles vehicles_insurer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_insurer_id_fkey FOREIGN KEY (insurer_id) REFERENCES public.insurers(insurer_id);


--
-- Name: vehicles vehicles_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(user_id);


--
-- PostgreSQL database dump complete
--

\unrestrict X0rsHOILZGxuWx5ydvp9XjwbO3LzyOoyadMIJg0X7oNNffckZ4puavW1V8wlzFU

