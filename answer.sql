-- Step 1: Logical Backup reference commands
-- Note: pg_dump and pg_restore are executed via shell terminal.

-- Step 2 & 3: WAL Archiving and Recovery Setup Reference
-- Config settings for postgresql.conf:
-- wal_level = replica
-- archive_mode = on
-- archive_command = 'cp %p /home/postgres/backups/wal/%f'
-- restore_command = 'cp /home/postgres/backups/wal/%f %p'

-- Step 4: Set Up a Streaming Standby (Executable SQL)
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'reppass';

-- Step 5: Watch Replication Health (Executable SQL Query)
SELECT application_name, state,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;
