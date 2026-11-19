-- Integration test for the crash-response triggers. Run on a fresh database
-- after schema.sql and seed.sql. Everything runs in a transaction and is rolled back.

BEGIN;
SET search_path TO public;

DO $$
DECLARE
    crash integer;
    officer integer;
    expected_officer integer;
    hospital integer;
    expected_hospital integer;
    rooms_before integer;
    rooms_after integer;
    notified integer;
    v1 integer;
    v2 integer;
    v3 integer;
BEGIN
    SELECT min(vehicle_id) INTO v1 FROM vehicles;
    SELECT min(vehicle_id) INTO v2 FROM vehicles WHERE vehicle_id > v1;
    SELECT min(vehicle_id) INTO v3 FROM vehicles WHERE vehicle_id > v2;

    -- The nearest hospital with room for 2 people and the nearest police post to the crash site.
    SELECT hospital_id, available_rooms INTO expected_hospital, rooms_before
    FROM hospitals WHERE available_rooms >= 2
    ORDER BY earth_distance(ll_to_earth(10.6, -155.9), ll_to_earth(latitude, longitude)) LIMIT 1;
    SELECT trafficpolice_id INTO expected_officer
    FROM policeposts
    ORDER BY earth_distance(ll_to_earth(10.6, -155.9), ll_to_earth(latitude, longitude)) LIMIT 1;

    -- A severe ("red") crash with 2 people, reported near Metro Hospital.
    INSERT INTO roadcrashcases (reporter_id, "time", severitycode, status, latitude, longitude, number_of_people, vehicle_id)
    VALUES (1, now(), 'red', 'open', 10.6, -155.9, 2, v1)
    RETURNING crash_id INTO crash;

    SELECT police_id INTO officer FROM assignedcases WHERE crash_id = crash;
    ASSERT officer = expected_officer, format('police: got %s, expected %s', officer, expected_officer);

    SELECT hospital_id INTO hospital FROM emergencyrooms WHERE crash_id = crash;
    ASSERT hospital = expected_hospital, format('hospital: got %s, expected %s', hospital, expected_hospital);

    SELECT available_rooms INTO rooms_after FROM hospitals WHERE hospital_id = expected_hospital;
    ASSERT rooms_after = rooms_before - 2, 'emergency rooms were not reserved';

    SELECT count(*) INTO notified FROM notifications WHERE vehicle_id = v1 AND severitycode = 'red';
    ASSERT notified >= 1, 'insurer, owner and driver were not notified';

    -- A minor ("green") crash: police assigned, but no hospital booking and no insurer alert.
    INSERT INTO roadcrashcases (reporter_id, "time", severitycode, status, latitude, longitude, number_of_people, vehicle_id)
    VALUES (1, now(), 'green', 'open', 10.6, -155.9, 1, v2)
    RETURNING crash_id INTO crash;
    ASSERT EXISTS (SELECT 1 FROM assignedcases WHERE crash_id = crash), 'green crash not assigned';
    ASSERT NOT EXISTS (SELECT 1 FROM emergencyrooms WHERE crash_id = crash), 'green crash booked a room';

    -- When no hospital has capacity, the case is recorded as unassigned instead of failing.
    UPDATE hospitals SET available_rooms = 0;
    INSERT INTO roadcrashcases (reporter_id, "time", severitycode, status, latitude, longitude, number_of_people, vehicle_id)
    VALUES (1, now(), 'red', 'open', 10.6, -155.9, 3, v3)
    RETURNING crash_id INTO crash;
    ASSERT (SELECT hospital_id FROM emergencyrooms WHERE crash_id = crash) IS NULL, 'expected unassigned booking';

    RAISE NOTICE 'All crash-response trigger tests passed';
END $$;

ROLLBACK;
