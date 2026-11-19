--
-- PostgreSQL database dump
--

\restrict zAzEeesKbZnI0RLaBm0a6ureOP93ggb8jAlrRN5IwgQDjtEUHNwOCXzl6Glpc0G

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
-- Data for Name: insurers; Type: TABLE DATA; Schema: public; Owner: -
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE public.insurers DISABLE TRIGGER ALL;

INSERT INTO public.insurers VALUES (1, 'sanilam', ' gasabo', '0125468');
INSERT INTO public.insurers VALUES (2, 'uap ', 'nyarugenge', '0125487');
INSERT INTO public.insurers VALUES (3, 'soras', ' kicukiro', '0124563');
INSERT INTO public.insurers VALUES (4, 'old mutual', ' gasabo', '0124587');
INSERT INTO public.insurers VALUES (5, 'rdf', 'kicukiro', '0125879');


ALTER TABLE public.insurers ENABLE TRIGGER ALL;

--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

ALTER TABLE public.users DISABLE TRIGGER ALL;

INSERT INTO public.users VALUES (1, 'John Doe', 'johndoe@john.com', 'owner');
INSERT INTO public.users VALUES (2, 'Alice Smith', 'alicesmith@alic.com', 'driver');
INSERT INTO public.users VALUES (3, 'GEICO gary', 'geicogary@gmal.com', 'owner');
INSERT INTO public.users VALUES (4, 'Stacy Funny', 'stacyfunny@brat.fr', 'police_officer');
INSERT INTO public.users VALUES (5, 'Bob Johnson', 'bobbyjohnny@bobs.com', 'police_officer');
INSERT INTO public.users VALUES (6, 'John Drak', 'ex1@police.rw', 'police_officer');
INSERT INTO public.users VALUES (7, 'Alik Smitten', 'ex2@police.rw', 'police_officer');
INSERT INTO public.users VALUES (8, 'Gren Sheen', 'ex3@police.rw', 'police_officer');
INSERT INTO public.users VALUES (9, 'Sun Pak', 'ex4@police.rw', 'police_officer');
INSERT INTO public.users VALUES (10, 'Brent Keizer', 'ex5@police.rw', 'police_officer');


ALTER TABLE public.users ENABLE TRIGGER ALL;

--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: -
--

ALTER TABLE public.vehicles DISABLE TRIGGER ALL;

INSERT INTO public.vehicles VALUES (7, 'F-150', 'REA41F', 4, 2, 1, 'Ford ');
INSERT INTO public.vehicles VALUES (8, ' Civic', 'RGDNULL4', 3, 4, 5, 'Honda');
INSERT INTO public.vehicles VALUES (9, ' Malibu', 'RAD34H', 5, 1, 2, 'Chevrolet');
INSERT INTO public.vehicles VALUES (10, ' Altima', 'RAC42H', 1, 5, 1, 'Nissan');
INSERT INTO public.vehicles VALUES (11, 'camry', 'rac45154G', 8, 4, 2, 'toyota');
INSERT INTO public.vehicles VALUES (12, 'camry', 'rac45154G', 8, 4, 2, 'toyota');
INSERT INTO public.vehicles VALUES (6, ' Camry', 'RAD34G', 2, 3, 2, 'Toyota');


ALTER TABLE public.vehicles ENABLE TRIGGER ALL;

--
-- Data for Name: roadcrashcases; Type: TABLE DATA; Schema: public; Owner: -
--

ALTER TABLE public.roadcrashcases DISABLE TRIGGER ALL;

INSERT INTO public.roadcrashcases VALUES (38, 3, '2006-11-12 00:00:00', 'yellow', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (46, 1, '2023-10-01 09:30:00', 'yellow', 'open', 23.626696156281064, -56.64978409266227, NULL, 6);
INSERT INTO public.roadcrashcases VALUES (47, 1, '2023-10-01 09:30:00', 'yellow', 'open', 23.626696156281064, -56.64978409266227, NULL, 6);
INSERT INTO public.roadcrashcases VALUES (49, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, NULL, 6);
INSERT INTO public.roadcrashcases VALUES (50, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, NULL, 6);
INSERT INTO public.roadcrashcases VALUES (53, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, NULL, 6);
INSERT INTO public.roadcrashcases VALUES (54, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, 7, 6);
INSERT INTO public.roadcrashcases VALUES (55, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, 7, 6);
INSERT INTO public.roadcrashcases VALUES (1, 1, '2023-10-01 09:30:00', 'red', 'open', 23.626696156281064, -56.64978409266227, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (2, 2, '2023-10-02 15:45:00', 'yellow', 'open', 27.28021384139904, -55.18686995535448, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (3, 1, '2023-10-03 08:15:00', 'green', 'closed', 21.33626681636666, -35.9415465300321, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (4, 5, '2023-10-04 14:00:00', 'red', 'open', 26.613714256794747, -59.652828066443426, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (5, 4, '2023-10-05 11:20:00', 'yellow', 'closed', 30.51334637628596, -34.72088629271743, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (56, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, 7, 6);
INSERT INTO public.roadcrashcases VALUES (57, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, 7, 6);
INSERT INTO public.roadcrashcases VALUES (58, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, 7, 6);
INSERT INTO public.roadcrashcases VALUES (59, 1, '2023-10-01 09:30:00', 'green', 'open', 23.626696156281064, -56.64978409266227, 7, 6);
INSERT INTO public.roadcrashcases VALUES (61, 1, '2023-10-01 09:30:00', 'red', 'open', 23.626696156281064, -56.64978409266227, 7, 6);
INSERT INTO public.roadcrashcases VALUES (25, 3, '2016-11-12 00:00:00', 'yellow', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (26, 4, '2019-11-11 00:00:00', 'yellow', 'open', 21.7128, -72.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (27, 3, '2006-11-12 00:00:00', 'yellow', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (28, 3, '2006-11-12 00:00:00', 'yellow', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (29, 3, '2006-11-12 00:00:00', 'yellow', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (30, 3, '2006-11-12 00:00:00', 'red', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (31, 3, '2006-11-12 00:00:00', 'red', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (32, 3, '2006-11-12 00:00:00', 'red', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (33, 3, '2006-11-12 00:00:00', 'red', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (34, 3, '2006-11-12 00:00:00', 'red', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (35, 3, '2006-11-12 00:00:00', 'red', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (36, 3, '2006-11-12 00:00:00', 'red', 'open', 42.7128, -62.006, NULL, NULL);
INSERT INTO public.roadcrashcases VALUES (37, 3, '2006-11-12 00:00:00', 'red', 'open', 42.7128, -62.006, NULL, NULL);


ALTER TABLE public.roadcrashcases ENABLE TRIGGER ALL;

--
-- Data for Name: assignedcases; Type: TABLE DATA; Schema: public; Owner: -
--

ALTER TABLE public.assignedcases DISABLE TRIGGER ALL;



ALTER TABLE public.assignedcases ENABLE TRIGGER ALL;

--
-- Data for Name: hospitals; Type: TABLE DATA; Schema: public; Owner: -
--

ALTER TABLE public.hospitals DISABLE TRIGGER ALL;

INSERT INTO public.hospitals VALUES (1, 'City Hospital', 15.172748986656268, -130.6447361218345, 6);
INSERT INTO public.hospitals VALUES (2, 'County Hospital', 26.10620405904701, -99.2003091809878, 3);
INSERT INTO public.hospitals VALUES (3, 'Community Hospital', 32.679823353625046, -131.20320667227742, 0);
INSERT INTO public.hospitals VALUES (4, 'Metro Hospital', 10.607168268023033, -155.9331313665661, 8);
INSERT INTO public.hospitals VALUES (5, 'Regional Hospital', 37.59332326168746, -132.93129556132354, 2);


ALTER TABLE public.hospitals ENABLE TRIGGER ALL;

--
-- Data for Name: emergencyrooms; Type: TABLE DATA; Schema: public; Owner: -
--

ALTER TABLE public.emergencyrooms DISABLE TRIGGER ALL;



ALTER TABLE public.emergencyrooms ENABLE TRIGGER ALL;

--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

ALTER TABLE public.notifications DISABLE TRIGGER ALL;



ALTER TABLE public.notifications ENABLE TRIGGER ALL;

--
-- Data for Name: policeposts; Type: TABLE DATA; Schema: public; Owner: -
--

ALTER TABLE public.policeposts DISABLE TRIGGER ALL;

INSERT INTO public.policeposts VALUES (5, 'cranh', 10, 40.6532, -75.3832);
INSERT INTO public.policeposts VALUES (4, 'freshet', 9, 49.5074, -7.3832);
INSERT INTO public.policeposts VALUES (3, 'north', 8, 39.8781, -60.3832);
INSERT INTO public.policeposts VALUES (2, 'crans', 7, 34.0522, -89.3832);
INSERT INTO public.policeposts VALUES (1, 'bramt', 6, 41.7128, -53.3832);


ALTER TABLE public.policeposts ENABLE TRIGGER ALL;

--
-- Name: assignedcases_assignement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.assignedcases_assignement_id_seq', 9, true);


--
-- Name: hospitals_hospital_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hospitals_hospital_id_seq', 5, true);


--
-- Name: insurers_insurer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.insurers_insurer_id_seq', 5, true);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_notification_id_seq', 12, true);


--
-- Name: policeposts_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.policeposts_post_id_seq', 5, true);


--
-- Name: roadcrashcases_crash_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roadcrashcases_crash_id_seq', 61, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 10, true);


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehicles_vehicle_id_seq', 12, true);


--
-- PostgreSQL database dump complete
--

\unrestrict zAzEeesKbZnI0RLaBm0a6ureOP93ggb8jAlrRN5IwgQDjtEUHNwOCXzl6Glpc0G

