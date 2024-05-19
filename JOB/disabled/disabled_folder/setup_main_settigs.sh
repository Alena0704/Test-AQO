INSTDIR=/home/a.rybakina/postgrespro_job/tmp_install/bin
export PGDATA=/home/a.rybakina/postgres_data9

#rm $PGDATA/postgresql.conf
echo "shared_buffers = 5GB" >> $PGDATA/postgresql.conf
echo "work_mem = 128MB" >> $PGDATA/postgresql.conf
echo "wal_buffers = 16MB" >> $PGDATA/postgresql.conf
echo "max_wal_size = 16GB" >> $PGDATA/postgresql.conf
echo "min_wal_size = 4GB" >> $PGDATA/postgresql.conf

echo "effective_cache_size = 15GB" >> $PGDATA/postgresql.conf
echo "default_statistics_target = 500" >> $PGDATA/postgresql.conf

echo "random_page_cost = 1.5" >> $PGDATA/postgresql.conf
echo "seq_page_cost = 1.5" >> $PGDATA/postgresql.conf
echo "cpu_tuple_cost=0.01" >> $PGDATA/postgresql.conf
echo "cpu_operator_cost=0.0025" >> $PGDATA/postgresql.conf
echo "cpu_index_tuple_cost=0.005" >> $PGDATA/postgresql.conf
#echo "maintenance_work_mem = 2GB" >> $PGDATA/postgresql.conf
#echo "max_worker_processes = 8" >> $PGDATA/postgresql.conf
#echo "max_parallel_workers_per_gather = 8" >> $PGDATA/postgresql.conf
#echo "max_parallel_maintenance_workers = 8" >> $PGDATA/postgresql.conf
#echo "max_parallel_workers = 8" >> $PGDATA/postgresql.conf
echo "autovacuum = 'off'" >> $PGDATA/postgresql.conf
echo "parallel_setup_cost = 1.0" >> $PGDATA/postgresql.conf
echo "parallel_tuple_cost = 0.00001" >> $PGDATA/postgresql.conf
echo "min_parallel_table_scan_size = 4" >> $PGDATA/postgresql.conf
echo "min_parallel_index_scan_size = 4" >> $PGDATA/postgresql.conf
echo "max_parallel_workers_per_gather = 4" >> $PGDATA/postgresql.conf
echo "max_parallel_maintenance_workers = 4" >> $PGDATA/postgresql.conf	# taken from max_parallel_workers
echo "max_parallel_workers = 4" >> $PGDATA/postgresql.conf		# maximum number of max_worker_processes that
echo "from_collapse_limit = 8" >> $PGDATA/postgresql.conf
echo "join_collapse_limit = 8" >> $PGDATA/postgresql.conf
# AQO preferences
#echo "shared_preload_libraries = 'aqo, pg_stat_statements'" >> $PGDATA/postgresql.conf
echo "aqo.mode = 'disabled'" >> $PGDATA/postgresql.conf
#echo "aqo.join_threshold = 8" >> $PGDATA/postgresql.conf
echo "aqo.join_threshold = 3" >> $PGDATA/postgresql.conf
#echo "aqo.min_neighbors_for_predicting=5" >> $PGDATA/postgresql.conf
#, 5, 6, 9
#echo "aqo.predict_with_few_neighbors = false" >> $PGDATA/postgresql.conf
echo "aqo.force_collect_stat = 'off'" >> $PGDATA/postgresql.conf
echo "aqo.fs_max_items = 10000" >> $PGDATA/postgresql.conf
echo "aqo.fss_max_items = 20000" >> $PGDATA/postgresql.conf
