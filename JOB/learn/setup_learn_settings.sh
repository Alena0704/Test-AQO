INSTDIR=/home/a.rybakina/postgrespro/tmp_install/bin
export PGDATA=/home/a.rybakina/postgres_data9
# AQO specific settings
$INSTDIR/psql -d postgres -c "ALTER SYSTEM SET aqo.mode = 'learn'"
$INSTDIR/psql -d postgres -c "ALTER SYSTEM SET aqo.force_collect_stat = 'on'"
$INSTDIR/psql -d postgres -c "ALTER SYSTEM SET aqo.show_details = 'on'"
$INSTDIR/psql -d postgres -c "ALTER SYSTEM SET aqo.show_hash = 'on'"
#$INSTDIR/psql -c "ALTER SYSTEM SET aqo.join_threshold = 4"
#$INSTDIR/psql -c "ALTER SYSTEM SET aqo.wide_search = 'off'"

# pg_stat_statements
#$INSTDIR/psql -d test_db -c "ALTER SYSTEM SET pg_stat_statements.track = 'all'"
#$INSTDIR/psql -d test_db -c "ALTER SYSTEM SET pg_stat_statements.track_planning = 'on'"
#$INSTDIR/psql -d test_db -c "ALTER SYSTEM SET min_parallel_table_scan_size = 1"
#$INSTDIR/psql -d test_db -c "ALTER SYSTEM SET min_parallel_index_scan_size = 1"
#$INSTDIR/psql -d test_db -c "ALTER SYSTEM SET max_parallel_workers_per_gather = 1"
#$INSTDIR/psql -d test_db -c "ALTER SYSTEM SET max_parallel_maintenance_workers = 1"	# taken from max_parallel_workers
echo "max_parallel_workers = 1" >> $PGDATA/postgresql.conf		# maximum number of max_worker_processes that
$INSTDIR/psql -d postgres -c "SELECT pg_reload_conf();"
