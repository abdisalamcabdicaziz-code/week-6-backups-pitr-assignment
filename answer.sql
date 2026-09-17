-- Step 1: Take and Verify a Logical Backup
-- (Run these commands in your terminal shell, documented here for reference)
-- mkdir -p ~/backups
-- pg_dump -Fc -f ~/backups/bootcamp.dump bootcamp
-- pg_restore --list ~/backups/bootcamp.dump | head
-- createdb bootcamp_check && pg_restore -d bootcamp_check ~/backups/bootcamp.dump

-- Step 2: Enable WAL Archiving & Base Backup Configuration
/*
-- In postgresql.conf:
wal_level = replica
archive_mode = on
archive_command = 'cp %p /home/$USER/backups/wal/%f'
*/

-- (Shell commands reference)
-- mkdir -p ~/backups/wal
-- sudo systemctl restart postgresql
-- pg_basebackup -D ~/backups/base -Ft -z -Xs -P

-- Step 3: Simulate a Disaster and Recover (PITR)
-- SELECT now();   -- Record time before deletion, e.g., '2025-06-01 10:00:00'
-- DELETE FROM students;   -- Simulated disaster

/*
-- Recovery Steps:
1. Stop PostgreSQL
2. Replace data directory with base backup
3. In postgresql.conf set:
   restore_command = 'cp ~/backups/wal/%f %p'
   recovery_target_time = '2025-06-01 10:00:00'
4. Start PostgreSQL
5. Verify recovery:
*/
-- SELECT count(*) FROM students;

-- Step 4: Set Up a Streaming Standby
-- (On the Primary server):
CREATE ROLE replicator
WITH REPLICATION LOGIN PASSWORD 'reppass';

/*
-- In pg_hba.conf:
host replication replicator 127.0.0.1/32 md5
*/

-- (Shell command to build standby):
-- pg_basebackup -h 127.0.0.1 -U replicator -D ~/standby -R -P

-- Step 5: Watch Replication Health
SELECT application_name, state,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;
