PGDMP         1        	    	    {            autoRTC    15.4    15.4 Y    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16867    autoRTC    DATABASE     }   CREATE DATABASE "autoRTC" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_Rwanda.1252';
    DROP DATABASE "autoRTC";
                postgres    false                        2615    17158    arcemmergencie    SCHEMA        CREATE SCHEMA arcemmergencie;
    DROP SCHEMA arcemmergencie;
                postgres    false                        3079    17178    cube 	   EXTENSION     8   CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;
    DROP EXTENSION cube;
                   false            �           0    0    EXTENSION cube    COMMENT     E   COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';
                        false    2                        3079    17267    earthdistance 	   EXTENSION     A   CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;
    DROP EXTENSION earthdistance;
                   false    2            �           0    0    EXTENSION earthdistance    COMMENT     f   COMMENT ON EXTENSION earthdistance IS 'calculate great-circle distances on the surface of the Earth';
                        false    3            �           1247    17370    availability_status    TYPE     T   CREATE TYPE public.availability_status AS ENUM (
    'available',
    'occupied'
);
 &   DROP TYPE public.availability_status;
       public          postgres    false            �           1247    16915    severity_types    TYPE     T   CREATE TYPE public.severity_types AS ENUM (
    'red',
    'yellow',
    'green'
);
 !   DROP TYPE public.severity_types;
       public          postgres    false            �           1247    16922    status_types    TYPE     F   CREATE TYPE public.status_types AS ENUM (
    'open',
    'closed'
);
    DROP TYPE public.status_types;
       public          postgres    false            �           1247    16897    valid_roles    TYPE     k   CREATE TYPE public.valid_roles AS ENUM (
    'driver',
    'owner',
    'police_officer',
    'witness'
);
    DROP TYPE public.valid_roles;
       public          postgres    false            '           1255    17406    assign_case_to_nearest_police()    FUNCTION     �  CREATE FUNCTION public.assign_case_to_nearest_police() RETURNS trigger
    LANGUAGE plpgsql
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
 6   DROP FUNCTION public.assign_case_to_nearest_police();
       public          postgres    false            (           1255    17415    book_emergency_room()    FUNCTION     �  CREATE FUNCTION public.book_emergency_room() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    nearest_hospital_id INT;
BEGIN
    -- Find the nearest hospital with available emergency rooms considering the number of people involved
    SELECT hospital_id INTO nearest_hospital_id
    FROM hospitals h
    WHERE available_rooms >= NEW.number_of_people
    AND available_rooms > 0
    ORDER BY earth_distance(ll_to_earth(NEW.latitude,NEW.longitude),ll_to_earth(h.latitude,h.longitude))
    LIMIT 1;

    -- If no available rooms found at the nearest hospital, look within 10 km
    IF nearest_hospital_id IS NULL THEN
        SELECT hospital_id INTO nearest_hospital_id
        FROM hospitals hs
        WHERE available_rooms >= NEW.number_of_people
        AND available_rooms > 0
        AND earch_distance(ll_to_earth(NEW.latitude,NEW.longitude),ll_to_earth(hs.latitude,hs.longitude)) > 10
        ORDER BY earth_distance(ll_to_earth(NEW.latitude,NEW.longitude),ll_to_earth(hs.latitude,hs.longitude))
        LIMIT 1;
    END IF;

    -- Update the hospital's available room count
    UPDATE hospitals
    SET available_rooms = available_rooms - NEW.number_of_people
    WHERE hospital_id = nearest_hospital_id;

    -- Insert the booking information into the EmergencyRoomBookings table
    INSERT INTO emergencyrooms (crash_id, hospital_id)
    VALUES (NEW.crash_id, nearest_hospital_id);

    RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.book_emergency_room();
       public          postgres    false            &           1255    17386    send_crash_notification()    FUNCTION     �  CREATE FUNCTION public.send_crash_notification() RETURNS trigger
    LANGUAGE plpgsql
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
 0   DROP FUNCTION public.send_crash_notification();
       public          postgres    false            �            1259    17293    assignedcases    TABLE     x   CREATE TABLE public.assignedcases (
    crash_id integer,
    police_id integer,
    assignement_id integer NOT NULL
);
 !   DROP TABLE public.assignedcases;
       public         heap    postgres    false            �            1259    17398     assignedcases_assignement_id_seq    SEQUENCE     �   CREATE SEQUENCE public.assignedcases_assignement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.assignedcases_assignement_id_seq;
       public          postgres    false    232            �           0    0     assignedcases_assignement_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.assignedcases_assignement_id_seq OWNED BY public.assignedcases.assignement_id;
          public          postgres    false    233            �            1259    17050    emergencyrooms    TABLE     V   CREATE TABLE public.emergencyrooms (
    hospital_id integer,
    crash_id integer
);
 "   DROP TABLE public.emergencyrooms;
       public         heap    postgres    false            �            1259    17029 	   hospitals    TABLE     �   CREATE TABLE public.hospitals (
    hospital_id integer NOT NULL,
    _name character varying(255),
    latitude double precision,
    longitude double precision,
    available_rooms integer
);
    DROP TABLE public.hospitals;
       public         heap    postgres    false            �            1259    17028    hospitals_hospital_id_seq    SEQUENCE     �   CREATE SEQUENCE public.hospitals_hospital_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.hospitals_hospital_id_seq;
       public          postgres    false    226            �           0    0    hospitals_hospital_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.hospitals_hospital_id_seq OWNED BY public.hospitals.hospital_id;
          public          postgres    false    225            �            1259    16991    insurers    TABLE     �   CREATE TABLE public.insurers (
    insurer_id integer NOT NULL,
    _name character varying(255),
    address character varying(255),
    contact character varying(10)
);
    DROP TABLE public.insurers;
       public         heap    postgres    false            �            1259    16990    insurers_insurer_id_seq    SEQUENCE     �   CREATE SEQUENCE public.insurers_insurer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.insurers_insurer_id_seq;
       public          postgres    false    222            �           0    0    insurers_insurer_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.insurers_insurer_id_seq OWNED BY public.insurers.insurer_id;
          public          postgres    false    221            �            1259    17135    notifications    TABLE     �   CREATE TABLE public.notifications (
    notification_id integer NOT NULL,
    insurer_id integer,
    vehicle_id integer,
    driver_id integer,
    owner_id integer,
    severitycode public.severity_types
);
 !   DROP TABLE public.notifications;
       public         heap    postgres    false    914            �            1259    17134 !   notifications_notification_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.notifications_notification_id_seq;
       public          postgres    false    231            �           0    0 !   notifications_notification_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.notifications_notification_id_seq OWNED BY public.notifications.notification_id;
          public          postgres    false    230            �            1259    17111    policeposts    TABLE     �   CREATE TABLE public.policeposts (
    post_id integer NOT NULL,
    _name character varying(255),
    trafficpolice_id integer,
    latitude double precision,
    longitude double precision
);
    DROP TABLE public.policeposts;
       public         heap    postgres    false            �            1259    17110    policeposts_post_id_seq    SEQUENCE     �   CREATE SEQUENCE public.policeposts_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.policeposts_post_id_seq;
       public          postgres    false    229            �           0    0    policeposts_post_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.policeposts_post_id_seq OWNED BY public.policeposts.post_id;
          public          postgres    false    228            �            1259    16928    roadcrashcases    TABLE     _  CREATE TABLE public.roadcrashcases (
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
 "   DROP TABLE public.roadcrashcases;
       public         heap    postgres    false    917    914            �            1259    16927    roadcrashcases_crash_id_seq    SEQUENCE     �   CREATE SEQUENCE public.roadcrashcases_crash_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.roadcrashcases_crash_id_seq;
       public          postgres    false    220            �           0    0    roadcrashcases_crash_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.roadcrashcases_crash_id_seq OWNED BY public.roadcrashcases.crash_id;
          public          postgres    false    219            �            1259    16906    users    TABLE     �   CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(255),
    email character varying(255),
    user_role public.valid_roles NOT NULL
);
    DROP TABLE public.users;
       public         heap    postgres    false    908            �            1259    16905    users_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.users_user_id_seq;
       public          postgres    false    218            �           0    0    users_user_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;
          public          postgres    false    217            �            1259    17000    vehicles    TABLE     �   CREATE TABLE public.vehicles (
    vehicle_id integer NOT NULL,
    model character varying(255),
    plate_number character varying(255),
    driver_id integer,
    owner_id integer,
    insurer_id integer,
    make character varying(255)
);
    DROP TABLE public.vehicles;
       public         heap    postgres    false            �            1259    16999    vehicles_vehicle_id_seq    SEQUENCE     �   CREATE SEQUENCE public.vehicles_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.vehicles_vehicle_id_seq;
       public          postgres    false    224            �           0    0    vehicles_vehicle_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.vehicles_vehicle_id_seq OWNED BY public.vehicles.vehicle_id;
          public          postgres    false    223            �           2604    17399    assignedcases assignement_id    DEFAULT     �   ALTER TABLE ONLY public.assignedcases ALTER COLUMN assignement_id SET DEFAULT nextval('public.assignedcases_assignement_id_seq'::regclass);
 K   ALTER TABLE public.assignedcases ALTER COLUMN assignement_id DROP DEFAULT;
       public          postgres    false    233    232            �           2604    17032    hospitals hospital_id    DEFAULT     ~   ALTER TABLE ONLY public.hospitals ALTER COLUMN hospital_id SET DEFAULT nextval('public.hospitals_hospital_id_seq'::regclass);
 D   ALTER TABLE public.hospitals ALTER COLUMN hospital_id DROP DEFAULT;
       public          postgres    false    226    225    226            �           2604    16994    insurers insurer_id    DEFAULT     z   ALTER TABLE ONLY public.insurers ALTER COLUMN insurer_id SET DEFAULT nextval('public.insurers_insurer_id_seq'::regclass);
 B   ALTER TABLE public.insurers ALTER COLUMN insurer_id DROP DEFAULT;
       public          postgres    false    222    221    222            �           2604    17138    notifications notification_id    DEFAULT     �   ALTER TABLE ONLY public.notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.notifications_notification_id_seq'::regclass);
 L   ALTER TABLE public.notifications ALTER COLUMN notification_id DROP DEFAULT;
       public          postgres    false    230    231    231            �           2604    17114    policeposts post_id    DEFAULT     z   ALTER TABLE ONLY public.policeposts ALTER COLUMN post_id SET DEFAULT nextval('public.policeposts_post_id_seq'::regclass);
 B   ALTER TABLE public.policeposts ALTER COLUMN post_id DROP DEFAULT;
       public          postgres    false    228    229    229            �           2604    16931    roadcrashcases crash_id    DEFAULT     �   ALTER TABLE ONLY public.roadcrashcases ALTER COLUMN crash_id SET DEFAULT nextval('public.roadcrashcases_crash_id_seq'::regclass);
 F   ALTER TABLE public.roadcrashcases ALTER COLUMN crash_id DROP DEFAULT;
       public          postgres    false    219    220    220            �           2604    16909    users user_id    DEFAULT     n   ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);
 <   ALTER TABLE public.users ALTER COLUMN user_id DROP DEFAULT;
       public          postgres    false    218    217    218            �           2604    17003    vehicles vehicle_id    DEFAULT     z   ALTER TABLE ONLY public.vehicles ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicles_vehicle_id_seq'::regclass);
 B   ALTER TABLE public.vehicles ALTER COLUMN vehicle_id DROP DEFAULT;
       public          postgres    false    224    223    224            �          0    17293    assignedcases 
   TABLE DATA           L   COPY public.assignedcases (crash_id, police_id, assignement_id) FROM stdin;
    public          postgres    false    232   �u       �          0    17050    emergencyrooms 
   TABLE DATA           ?   COPY public.emergencyrooms (hospital_id, crash_id) FROM stdin;
    public          postgres    false    227   �u       �          0    17029 	   hospitals 
   TABLE DATA           ]   COPY public.hospitals (hospital_id, _name, latitude, longitude, available_rooms) FROM stdin;
    public          postgres    false    226   �u       �          0    16991    insurers 
   TABLE DATA           G   COPY public.insurers (insurer_id, _name, address, contact) FROM stdin;
    public          postgres    false    222   �v       �          0    17135    notifications 
   TABLE DATA           s   COPY public.notifications (notification_id, insurer_id, vehicle_id, driver_id, owner_id, severitycode) FROM stdin;
    public          postgres    false    231   w       �          0    17111    policeposts 
   TABLE DATA           \   COPY public.policeposts (post_id, _name, trafficpolice_id, latitude, longitude) FROM stdin;
    public          postgres    false    229   +w       �          0    16928    roadcrashcases 
   TABLE DATA           �   COPY public.roadcrashcases (crash_id, reporter_id, "time", severitycode, status, latitude, longitude, number_of_people, vehicle_id) FROM stdin;
    public          postgres    false    220   �w       �          0    16906    users 
   TABLE DATA           D   COPY public.users (user_id, username, email, user_role) FROM stdin;
    public          postgres    false    218   &y       �          0    17000    vehicles 
   TABLE DATA           j   COPY public.vehicles (vehicle_id, model, plate_number, driver_id, owner_id, insurer_id, make) FROM stdin;
    public          postgres    false    224   z       �           0    0     assignedcases_assignement_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.assignedcases_assignement_id_seq', 9, true);
          public          postgres    false    233            �           0    0    hospitals_hospital_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.hospitals_hospital_id_seq', 5, true);
          public          postgres    false    225            �           0    0    insurers_insurer_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.insurers_insurer_id_seq', 5, true);
          public          postgres    false    221            �           0    0 !   notifications_notification_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.notifications_notification_id_seq', 12, true);
          public          postgres    false    230            �           0    0    policeposts_post_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.policeposts_post_id_seq', 5, true);
          public          postgres    false    228            �           0    0    roadcrashcases_crash_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.roadcrashcases_crash_id_seq', 61, true);
          public          postgres    false    219            �           0    0    users_user_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.users_user_id_seq', 10, true);
          public          postgres    false    217            �           0    0    vehicles_vehicle_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.vehicles_vehicle_id_seq', 12, true);
          public          postgres    false    223            �           2606    17401     assignedcases assignedcases_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.assignedcases
    ADD CONSTRAINT assignedcases_pkey PRIMARY KEY (assignement_id);
 J   ALTER TABLE ONLY public.assignedcases DROP CONSTRAINT assignedcases_pkey;
       public            postgres    false    232            �           2606    17034    hospitals hospitals_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.hospitals
    ADD CONSTRAINT hospitals_pkey PRIMARY KEY (hospital_id);
 B   ALTER TABLE ONLY public.hospitals DROP CONSTRAINT hospitals_pkey;
       public            postgres    false    226            �           2606    16998    insurers insurers_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.insurers
    ADD CONSTRAINT insurers_pkey PRIMARY KEY (insurer_id);
 @   ALTER TABLE ONLY public.insurers DROP CONSTRAINT insurers_pkey;
       public            postgres    false    222            �           2606    17142     notifications notifications_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);
 J   ALTER TABLE ONLY public.notifications DROP CONSTRAINT notifications_pkey;
       public            postgres    false    231            �           2606    17116    policeposts policeposts_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.policeposts
    ADD CONSTRAINT policeposts_pkey PRIMARY KEY (post_id);
 F   ALTER TABLE ONLY public.policeposts DROP CONSTRAINT policeposts_pkey;
       public            postgres    false    229            �           2606    16933 "   roadcrashcases roadcrashcases_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.roadcrashcases
    ADD CONSTRAINT roadcrashcases_pkey PRIMARY KEY (crash_id);
 L   ALTER TABLE ONLY public.roadcrashcases DROP CONSTRAINT roadcrashcases_pkey;
       public            postgres    false    220            �           2606    16913    users users_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    218            �           2606    17007    vehicles vehicles_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);
 @   ALTER TABLE ONLY public.vehicles DROP CONSTRAINT vehicles_pkey;
       public            postgres    false    224                       2620    17407 "   roadcrashcases assign_case_trigger    TRIGGER     �   CREATE TRIGGER assign_case_trigger AFTER INSERT ON public.roadcrashcases FOR EACH ROW EXECUTE FUNCTION public.assign_case_to_nearest_police();
 ;   DROP TRIGGER assign_case_trigger ON public.roadcrashcases;
       public          postgres    false    220    295                       2620    17416 *   roadcrashcases book_emergency_room_trigger    TRIGGER     �   CREATE TRIGGER book_emergency_room_trigger AFTER INSERT ON public.roadcrashcases FOR EACH ROW WHEN ((new.severitycode = 'red'::public.severity_types)) EXECUTE FUNCTION public.book_emergency_room();
 C   DROP TRIGGER book_emergency_room_trigger ON public.roadcrashcases;
       public          postgres    false    220    914    220    296                       2620    17387    roadcrashcases notify_on_crash    TRIGGER     �   CREATE TRIGGER notify_on_crash AFTER INSERT ON public.roadcrashcases FOR EACH ROW EXECUTE FUNCTION public.send_crash_notification();
 7   DROP TRIGGER notify_on_crash ON public.roadcrashcases;
       public          postgres    false    294    220            
           2606    17299 )   assignedcases assignedcases_crash_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignedcases
    ADD CONSTRAINT assignedcases_crash_id_fkey FOREIGN KEY (crash_id) REFERENCES public.roadcrashcases(crash_id);
 S   ALTER TABLE ONLY public.assignedcases DROP CONSTRAINT assignedcases_crash_id_fkey;
       public          postgres    false    3315    232    220                       2606    17304 *   assignedcases assignedcases_police_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignedcases
    ADD CONSTRAINT assignedcases_police_id_fkey FOREIGN KEY (police_id) REFERENCES public.users(user_id);
 T   ALTER TABLE ONLY public.assignedcases DROP CONSTRAINT assignedcases_police_id_fkey;
       public          postgres    false    232    3313    218                       2606    17408 +   emergencyrooms emergencyrooms_crash_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.emergencyrooms
    ADD CONSTRAINT emergencyrooms_crash_id_fkey FOREIGN KEY (crash_id) REFERENCES public.roadcrashcases(crash_id);
 U   ALTER TABLE ONLY public.emergencyrooms DROP CONSTRAINT emergencyrooms_crash_id_fkey;
       public          postgres    false    220    227    3315                       2606    17056 .   emergencyrooms emergencyrooms_hospital_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.emergencyrooms
    ADD CONSTRAINT emergencyrooms_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospitals(hospital_id);
 X   ALTER TABLE ONLY public.emergencyrooms DROP CONSTRAINT emergencyrooms_hospital_id_fkey;
       public          postgres    false    226    3321    227                       2606    17148 +   notifications notifications_insurer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_insurer_id_fkey FOREIGN KEY (insurer_id) REFERENCES public.insurers(insurer_id);
 U   ALTER TABLE ONLY public.notifications DROP CONSTRAINT notifications_insurer_id_fkey;
       public          postgres    false    222    231    3317            	           2606    17388 +   notifications notifications_vehicle_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);
 U   ALTER TABLE ONLY public.notifications DROP CONSTRAINT notifications_vehicle_id_fkey;
       public          postgres    false    224    3319    231                       2606    17310 -   policeposts policeposts_trafficpolice_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.policeposts
    ADD CONSTRAINT policeposts_trafficpolice_id_fkey FOREIGN KEY (trafficpolice_id) REFERENCES public.users(user_id);
 W   ALTER TABLE ONLY public.policeposts DROP CONSTRAINT policeposts_trafficpolice_id_fkey;
       public          postgres    false    3313    218    229                        2606    16934 .   roadcrashcases roadcrashcases_reporter_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.roadcrashcases
    ADD CONSTRAINT roadcrashcases_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.users(user_id);
 X   ALTER TABLE ONLY public.roadcrashcases DROP CONSTRAINT roadcrashcases_reporter_id_fkey;
       public          postgres    false    218    3313    220                       2606    17376 -   roadcrashcases roadcrashcases_vehicle_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.roadcrashcases
    ADD CONSTRAINT roadcrashcases_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id);
 W   ALTER TABLE ONLY public.roadcrashcases DROP CONSTRAINT roadcrashcases_vehicle_id_fkey;
       public          postgres    false    220    224    3319                       2606    17013     vehicles vehicles_driver_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.users(user_id);
 J   ALTER TABLE ONLY public.vehicles DROP CONSTRAINT vehicles_driver_id_fkey;
       public          postgres    false    224    3313    218                       2606    17023 !   vehicles vehicles_insurer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_insurer_id_fkey FOREIGN KEY (insurer_id) REFERENCES public.insurers(insurer_id);
 K   ALTER TABLE ONLY public.vehicles DROP CONSTRAINT vehicles_insurer_id_fkey;
       public          postgres    false    224    3317    222                       2606    17018    vehicles vehicles_owner_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(user_id);
 I   ALTER TABLE ONLY public.vehicles DROP CONSTRAINT vehicles_owner_id_fkey;
       public          postgres    false    218    3313    224            �      x������ � �      �      x������ � �      �   �   x�U��nA���)�Y��]RRR\U'%�����}�\��|󍅎��xy]���t!�.��1G�b�A�{���@��S4�q���$���'[��a�f�)���Aڴ���~�'U��9��p�xJ�`G$�i nFo��{�ͭe���2�U�t�S�
��B���~�\��鲳f��AU�R*��Q���Go���`E�      �   m   x�M�I� ��u�)8�q ���i'BD0�z�n�э���U���y>�,g�"ʪ6�������Į��o�;j�c���Yv��MېF�:�'쿇��� -��^"� C�%M      �      x������ � �      �   l   x�%�1� ��s,�66w�V�X�J���Q�����]9AU�hJ�\������i����e��;f���yF�iQ��7,��<��Eﱝ��rqD�E/
!� ���      �   o  x���MN�0F��)r[�oO�	���ME,��.-�*��Ȼ�=�8�8\���f�����p8~����%��TB4Juk�=�5��(qD��3��7(q22sC5*&!�%�E��+�܄6I����۾���)���X����fӑ6ܐ���쳦��2�Qћ��D��;4�&,V�]�U��uW_�g(������^�$Ḽ�V�Y���2 ^f"誓�<Mk��-�Bj�%��G�dJ��l&�B�	� �Mgą~Ĺ:���,ƹ��z�NR&(��)c��F�/%[�g+CmÆ��lP����t�bǍ[���~B�o����Wh���Aލ2l�?G��a'G�wr��i'g��Vp��vi��/SH�      �   �   x�u�MO�0��ί�/��>����6�zEBI�ak�܌Q~=q��&��G���v	��}O�	v�FjQSt
�j�_��z;���ގ�g�]?�=���-���L��ÿ�T�֣�Can�c���d�5M*���"��ȁ8rn�e�ܐ��&.�^b��*�o��ӹx%���cCrg��5l��:��|ڼ���K^����X�Ĩ��#'y9-�J�]V�=      �   �   x�}ν�@�z�)xw��
� �ٜ@�%�%�I��{bo��7��#���%�C #7�� Ջn�Y}�*�ػDi�N��U��F�d�(=�/��~�f�q� ��O�"*�3��g53Z5�V�B�Nۼ3�q�8������|�!�w��cOD�K5�     