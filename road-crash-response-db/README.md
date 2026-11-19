# Road crash response database (PostgreSQL)

A database that reacts the moment a road crash is reported. Three triggers on `roadcrashcases` handle dispatch:

| Trigger | When | What it does |
| --- | --- | --- |
| `assign_case_trigger` | every crash | Assigns the nearest traffic police officer, using great-circle distance (`earthdistance`) |
| `book_emergency_room_trigger` | severity `red` | Books the nearest hospital with enough free emergency rooms for everyone involved, and reserves the rooms |
| `notify_on_crash` | severity `yellow` or `red` | Notifies the vehicle's insurer, owner and driver |

Data model: users (drivers, owners, police officers, witnesses), vehicles, insurers, hospitals, police posts, crash cases, assignments, emergency room bookings and notifications, with foreign keys and enum types for roles, severity and status.

## Run it

```bash
createdb crash_response
psql crash_response -f schema.sql   # tables, enum types, functions, triggers
psql crash_response -f seed.sql     # sample data (fictional people)
psql crash_response -f tests.sql    # integration tests; changes are rolled back
```

`tests.sql` reports a severe crash and checks that the right officer and hospital were chosen, the rooms were reserved and the notification was sent. It also checks that a minor crash does not book a hospital, and that the system degrades safely when every hospital is full.

## Fixes made while documenting it

- The emergency-room function called `earch_distance` (a typo), so it crashed whenever the nearest-hospital search found nothing. Its fallback search could also never succeed, because it repeated the first query with an extra filter. When no hospital has capacity, it now records the case as unassigned for manual dispatch and raises a warning.
- The hospital row is locked (`FOR UPDATE`) during booking, so two simultaneous crashes cannot overbook the same hospital.
- Functions now set `search_path = public`, so they behave the same whatever the caller's settings.
