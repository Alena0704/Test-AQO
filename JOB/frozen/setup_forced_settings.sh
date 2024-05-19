INSTDIR=/home/a.rybakina/postgrespro/tmp_install/bin
export PGDATA=/home/a.rybakina/postgres_data9
# AQO specific settings
$INSTDIR/psql -d postgres -c "ALTER SYSTEM SET aqo.mode = 'frozen'"
$INSTDIR/psql -d postgres -c "ALTER SYSTEM SET aqo.force_collect_stat = 'on'"
$INSTDIR/psql -d postgres -c "ALTER SYSTEM SET aqo.show_details = 'on'"
$INSTDIR/psql -d postgres -c "ALTER SYSTEM SET aqo.show_hash = 'on'"

# pg_stat_statements
#$INSTDIR/psql -d test_db -c "ALTER SYSTEM SET pg_stat_statements.track = 'all'"
#$INSTDIR/psql -d test_db -c "ALTER SYSTEM SET pg_stat_statements.track_planning = 'on'"
#echo "min_parallel_table_scan_size = 4" >> $PGDATA/postgresql.conf
#echo "min_parallel_index_scan_size = 4" >> $PGDATA/postgresql.conf
echo "max_parallel_workers_per_gather = 4" >> $PGDATA/postgresql.conf
echo "max_parallel_maintenance_workers = 4" >> $PGDATA/postgresql.conf	# taken from max_parallel_workers
echo "max_parallel_workers = 4" >> $PGDATA/postgresql.conf		# maximum number of max_worker_processes that
$INSTDIR/psql -d postgres -c "SELECT pg_reload_conf();"
