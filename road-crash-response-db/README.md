# Road crash response database (PostgreSQL)

When a crash is reported, triggers on `roadcrashcases` handle dispatch:

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

`tests.sql` checks officer and hospital assignment, room booking, notifications, minor crashes and the case where all hospitals are full.

## Notes

- If no hospital has free rooms, the case is left unassigned for manual dispatch.
- The hospital row is locked during booking so two crashes can't overbook it.
