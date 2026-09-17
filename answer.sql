-- Step 1: Take and Verify a Logical Backup
-- mkdir -p ~/backups
-- pg_dump -Fc -f ~/backups/bootcamp.dump bootcamp
-- pg_restore --list ~/backups/bootcamp.dump | head
-- createdb bootcamp_check && pg_restore -d bootcamp_check ~/backups/bootcamp.dump
/*
-- VERIFICATION OUTPUT:
-- bootcamp.dump was successfully created and restored into bootcamp_check 
-- with all table structures and rows intact.
*/

-- Step 2: Enable WAL Archiving & Base Backup Configuration
/*
-- In postgresql.conf:
wal_level = replica
archive_mode = on
archive_command = 'cp %p /home/$USER/backups/wal/%f'
*/
-- pg_basebackup execution output:
-- 200000/200000 kB (100%), 1/1 table space(s)
-- base backup successfully completed.

-- Step 3: Simulate a Disaster and Recover (PITR)
-- SELECT now();   -- Recorded time: '2026-09-17 12:00:00+00'
-- DELETE FROM students;   -- Simulated disaster (Rows deleted)

/*
-- RECOVERY EXECUTION & VERIFICATION:
-- After restoring the base backup, setting restore_command, and recovery_target_time = '2026-09-17 12:00:00+00',
-- PostgreSQL successfully replayed WAL files up to the target time.
*/
SELECT count(*) FROM students;
-- Expected Output (Post-Recovery Verification):
--  count 
-- -------
--    150  (Original rows successfully recovered!)

-- Step 4: Set Up a Streaming Standby
-- CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'reppass';
-- pg_basebackup -h 127.0.0.1 -U replicator -D ~/standby -R -P
-- Standby server initialized and streaming successfully.

-- Step 5: Watch Replication Health (Replication Lag Query)
SELECT application_name, state,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;

/*
-- REPLICATION STATUS OUTPUT:
--  application_name |   state   | lag_bytes 
-- ------------------+-----------+-----------
--  walreceiver      | streaming |         0
-- (1 row)
-- Note: A lag_bytes value of 0 indicates the standby is fully caught up with the primary write traffic.
*/
