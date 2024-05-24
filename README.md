# This repository contains materials which were used for AQO testing

# Content of repository:
0. [What AQO is](#what-AQO-is)
   0. [Description and you can find it](#description-and-you-can-find-it)
   1. [Extra links about AQO](#extra-links-about-aqo)
1. [Database about students](#database-about-students)
    0. [Database description](#database-description)
    1. [Analyze data from database](#analyze-data-from-database)
    2. [Interesting query issue](#interesting-query-issue)
2. [AQO tests on JOB database](#aqo-tests-on-JOB-database)
    0. [How to prepare database](#how-to-prepare-database)
    1. [Extra links about AQO](#extra-links-about-AQO)
    2. [How to run JOB test](#how-to-run-JOB-to-test-AQO)
    3. [How analyze AQO test](#how-analyze-AQO-test)


# What AQO is
## Description and you sources
Adaptive query optimization is the extension of standard PostgreSQL cost-based query optimizer. Its basic principle is to use query execution statistics for improving cardinality estimation. Experimental evaluation shows that this improvement sometimes provides optimal perfomance.
The installation of [AQO](https://github.com/postgrespro/aqo) is described [here](https://github.com/postgrespro/aqo).
## Extra links about AQO
To know about [AQO](https://github.com/postgrespro/aqo), you can read articles, documentation and see presentations from these sources:
- [AQO documentation](https://postgrespro.ru/docs/postgrespro/16/aqo?lang=en)
- [Oleg Ivanov, Sergey Bartunov :Adaptive Cardinality Estimation](https://arxiv.org/pdf/1711.08330)
- [Oleg Ivanov: Adaptive query optimization in PostgreSQL](https://www.pgcon.org/2017/schedule/attachments/450_pgcon2017_aqo.pdf)
- [Oleg Ivanov, Yerzhaisang Taskali: Adaptive query optimization in PostgreSQL](https://archive.fosdem.org/2021/schedule/event/postgres_query_optimization/)

AQO links (Russian version):
- [Павел Толмачев: AQO — адаптивная оптимизация запросов в PostgreSQL](https://habr.com/ru/companies/postgrespro/articles/508766/)
- [Олег Иванов: Применение машинного обучения для увеличения производительности PostgreSQL](https://habr.com/ru/companies/postgrespro/articles/273199/)
- [Олег Иванов: Адаптивная оптимизация запросов](https://postgrespro.ru/media/2016/11/25/olegivanov.pdf)
- [Андрей Лепихов: Постгрессовый планнер с памятью](https://pgconf.ru/talk/1589166)
- [Алена Рыбакина: Адаптивная оптимизация запросов в PostgreSQL](https://pgconf.ru/talk/1589142)

# Database about students
## Database description
Database consists of four tables:
Students' table contains information about students - names, genders, learning groups.
Teachers' table contains information about teachers (name and gender) who teach the courses.
Course table describes courses. It contains the ID information of one specific teacher their assigned course.
Scores table collects information about students course grades/marks and analytics for essays (word count) and whether students have a course before an exam.
See the database schema link bellow:
<img alt="Database schema about students" src="some pictures/database_schema.png" />

Note: you can restore dump_students.sql dump using command:
```
pg_dump -d postgres > 'dump_students2.sql'
```
You can generate own data for experiments using database_students.sql script.
Note, if you run it you can generate 100 teachers, 10 courses, 3000 students and 15000 data for score table. You can use below commands to generate more data (instead of N you set how many data you want to generate):

To generate students:
```
insert into student (sno, gen, sgroup) select id, CASE WHEN random()<0.25 THEN 'Female' ELSE 'Male' END,
			       CASE
			       WHEN random()>=0.89 THEN 'ClassE'
			       WHEN random()>=0.79 THEN 'ClassB'
			       WHEN random()>=0.58 THEN 'ClassA'
			       WHEN random()>=0.32 THEN 'ClassD'
			       ELSE 'ClassC'
			       END as sgroup
from generate_series(1,N) id;

update student set sname = random_string(gen);
```
To generate teachers:
```
insert into teacher (tno, gen) select id, CASE WHEN random()<0.5 THEN 'Female' ELSE 'Male' END from generate_series(1,N) id;
update teacher set tname = random_string(gen);
```
To generate courses:
```
select select_random_course(N);
```
To generate score data:
```
select random_cno(N, 0);
select random_cno(N, 1);
```
The second parameter is about having preparation course students or not.
## Analyze data from database
Anyway, you'll likely have nonuniform distribution. There are some my analytical research about database.
1. The result short analysis with pandas profilling.
To do it I prepared csv file with collected all important information about student academic performance through this script:
```
psql -d postgres -c "\copy (select degree, essay_text_len, clevel, gen, sgroup, test_preparation from student, course, score where score.cno = course.cno and student.sno = score.sno) to '/home/alena/score.csv' DELIMITER ',' CSV HEADER"
```
After that I ran pandas profilling to analyse data. There are analytical results.
Breaf analytical information:
<img alt="Breaf analytical information" src="some pictures/breaf information.png" />
As you see on the picture above I had 30000 data at all and 4800 among of them was dublicate.

There are data distribution between degree, essay_text_len and test_preparation columns by gender:
<img alt="Data distribution between degree, essay_text_len and test_preparation" src="some pictures/data_distribution1.png" />

There are data distribution between degree, essay_text_len and test_preparation columns by groups:

### Degree column
Degree column has nonuniform distribution, where we have a lot of values between 40 and 90 degree.
<img alt="Distribution of degree column" src="some pictures/degree.png" />
There are some more statistical information about this column (MCV):
<img alt="Statistic info about degree column" src="some pictures/degree_statistics.png" />
MCV statistics of degree column:
<img alt="MCV statistics of degree column" src="some pictures/degree_mcv.png" />
Extreme MCV statistics of degree column:
<img alt="Extreme MCV statistics of degree column" src="some pictures/degree_extrem_mcv.png" />
<img alt="Extreme MCV statistics of degree column" src="some pictures/degree_extrem_mcv1.png" />

The most interesting distribution of this column by groups:
Degree distribution for Group A:
<img alt="Degree distribution for Group A" src="some pictures/degree_groupA.png" />
Degree distribution for Group B:
<img alt="Degree distribution for Group B" src="some pictures/degree_groupB.png" />
Degree distribution for Group C:
<img alt="Degree distribution for Group C" src="some pictures/degree_groupC.png" />
Degree distribution for Group D:
<img alt="Degree distribution for Group D" src="some pictures/degree_groupD.png" />
Degree distribution for Group E:
<img alt="Degree distribution for Group E" src="some pictures/degree_groupE.png" />

### The length of letters of essay (essay_text_len column)
It also have nonuniform distribution, where we have a lot of students who didn't write essay.
<img alt="Distribution of essay_text_len column" src="some pictures/essay_text_len.png" />
There are some more statistical information about this column (MCV):
Statistic info about essay_text_len column:
<img alt="Statistic info about essay_text_len column" src="some pictures/essay_text_len_statistics.png" />
MCV statistics of essay_text_len column:
<img alt="MCV statistics of essay_text_len column" src="some pictures/essay_text_len_mcv.png" />
Extreme MCV statistics of essay_text_len column:
<img alt="Extreme MCV statistics of essay_text_len column" src="some pictures/essay_text_len_extreme_mcv.png" />
<img alt="Extreme MCV statistics of essay_text_len column" src="some pictures/essay_text_len_extreme_mcv1.png" />

It looks exciting to observe the distribution of the number of letters in the essay for some groups:
Distribution of number of letter of essay for Group E:
<img alt="Distribution of number of letter of essay for Group E" src="some pictures/len_text_groupE.png" />
Distribution of number of letter of essay for Group D:
<img alt="Distribution of number of letter of essay for Group D" src="some pictures/len_text_groupD.png" />
Distribution of number of letter of essay for Group C:
<img alt="Distribution of number of letter of essay for Group C" src="some pictures/len_text_groupC.png" />
Distribution of number of letter of essay for Group B:
<img alt="Distribution of number of letter of essay for Group B" src="some pictures/len_text_groupB.png" />
Distribution of number of letter of essay for Group A:
<img alt="Distribution of number of letter of essay for Group A" src="some pictures/len_text_groupA.png" />

### The mark about having preparation course students before taking exam
As we see about 80% of them have it.
<img alt="Students had a preparation course" src="some pictures/test_preparation.png" />

### Groups of students
As you see from picture bellow, we have more students from 'A' and 'B' classes, but less from 'E' class.
<img alt="Statistical information about groups" src="some pictures/groups.png" />
<img alt="Statistical information about groups" src="some pictures/representative_info_about_group.png" />

Here are statistic information how much data columns have by groups:
<img alt="Statistic information how much data columns have by groups" src="some pictures/some pictures/distribution columns by groups.png" />

If you wanna install pandas profilling you can read about it [there](https://www.geeksforgeeks.org/how-to-install-pandas-profiling-on-linux/)

### Corellation between data

I saw high corellation between degree and test_preparation columns (0.73) and highest one between essay_text_len and degree (1.0):
<img alt="Corellation between data" src="some pictures/corellation.png" />

Corellation analysis for group A:
<img alt="Corellation between data for group A" src="some pictures/corellation_groupA.png" />

Corellation analysis for group B:
<img alt="Corellation between data for group B" src="some pictures/corellation_groupB.png" />

Corellation analysis for group C:
<img alt="Corellation between data for group C" src="some pictures/corellation_groupC.png" />

Corellation analysis for group D:
<img alt="Corellation between data for group D" src="some pictures/corellation_groupD.png" />

Corellation analysis for group E:
<img alt="Corellation between data for group E" src="some pictures/corellation_groupE.png" />

I use such script to check it:
```
corr = df_copy.corr()
mask = np.zeros_like(corr)
mask[np.triu_indices_from(mask)] = True
with sns.axes_style("white"):
    f, ax = plt.subplots(figsize=(8, 8))
    ax = sns.heatmap(corr,mask=mask,square=True,linewidths=.8,cmap="autumn",annot=True)
```

All script analysis is in database_analyzes.ipynb

# AQO tests on JOB database

## How to prepare database
This repository is a fork of the [project](https://github.com/gregrahn/join-order-benchmark). Here we unite queries and data in one place. Main goal of this repository is simplifying of the deploy process.

Large tables divided into chunks each less than 100 MB.

Repository contains some scripts for quick deploy & run of the benchmark:

schema.sql - creates the data schema.
copy.sql - copies data from csv files into the tables. Uses datadir variable to make absolute paths to csv files. Use psql -v to define it.
parts.sql - script which splitted the tables. Just for future reusage.
job - a template script for quick launch of the benchmark.
Example below shows export procedure of all tables:
```
psql -f ~/join-order-benchmark/schema.sql
psql -f ~/join-order-benchmark/fkindexes.sql
psql -vdatadir="'/home/user/jo-bench'" -f ~/jo-bench/copy.sql
NB! Deploying tested on database with C-locale.
```
Please note that you should specify the absolute path to the data files when using the 'copy' functions, otherwise you may catch the error that the files were not found.

## How to test the AQO
### disabled mode
To test AQO with JOB you should gather statistics with (disabled)[https://postgrespro.ru/docs/postgrespro/14/aqo#AQO-CONFIGURATION] mode. To do it you should adjust your database applying gucs:
```
aqo.mode = 'disabled'
aqo.force_collect_stat = 'on'
```
force_collect_stat allows you to gather statistic and store it in aqo_query_stats in any modes. You can use it to consider planning and execution time and also an avarage of error of cardinality to see is ot better to use AQO for queries or not.

I used 15 iterations for disabled mode to estimate the average planning and execution time for every query. But I also gathered statistic from 'Explain' description of query and use both options to analyze AQO working on JOB database.

I used the script:
```
for (( i=1; i<=disabled_iters; i++ ))
do
  for file in $QUERY_DIR/queries/*.sql
  do
    short_file=$(basename "$file")
    echo -n "EXPLAIN (ANALYZE, VERBOSE, FORMAT JSON) " > test.sql
    cat $file >> test.sql
    result=$(psql -d postgres -f test.sql)

    query_hash=$(echo $result | grep -Eo '"Query Identifier": [+-]?[0-9]*' | grep -Eo '[+-]?[0-9]*')
    exec_time=$(echo $result | sed -n 's/.*"Execution Time": \([0-9]*\.[0-9]*\).*/\1/p')
    plan_time=$(echo $result | sed -n 's/.*"Planning Time": \([0-9]*\.[0-9]*\).*/\1/p')

    echo -n "EXPLAIN " > test.sql
    cat $file >> test.sql
    result=$(psql -d postgres -f test.sql)

    echo -e "$i,$short_file,$exec_time,$plan_time,$query_hash" >> $file_output
    echo -e "$i,$short_file,$exec_time,$plan_time,$query_hash"
  done
done

psql -d postgres -c "\copy (select * from aqo_query_stat) to '${mode}_aqo_query_stat.csv' DELIMITER ',' CSV HEADER"
```
### learn mode
What you should do to [learn](https://postgrespro.ru/docs/postgrespro/14/aqo#AQO-CONFIGURATION) queries on JOB database is to change GUC's mode to learn and repeat the script above. During learning, you should disabled parallel workers to better and speed up the results of learning.
I applyed such gucs:
```
min_parallel_table_scan_size = 1
min_parallel_index_scan_size = 1
max_parallel_workers_per_gather = 1
max_parallel_maintenance_workers = 1
```
I needed 15 iterations to see the minimal cardinalty error, but initially I set 22 iterations.

In addition, you can see an error cardinality after every learning iteration and notice is there a convergence in cardinality in queries or not. Use this command to realize it:
```
psql -d postgres -c "SELECT error AS error_aqo FROM aqo_cardinality_error(true)"
```
### controlled mode
Last stage is running AQO in [controlled](https://postgrespro.ru/docs/postgrespro/14/aqo#AQO-CONFIGURATION) or frozen mode. The main difference between them is collect new queries or not to AQO data to learn it. For known queiries planner uses cardinality information stored in AQO. I applyed GUC:
```
aqo.mode = 'controlled'
```
And I returned parallel working there, applyed GUCs like:
```
min_parallel_table_scan_size = 1
min_parallel_index_scan_size = 1
max_parallel_workers_per_gather = 1
max_parallel_maintenance_workers = 1
```

You can see my test results in JOB folder for three modes: disabled, frozen and learn. Files like "1_report.csv" or "frozen_1_report.csv" ("learn_1_report") contain execution, planning time and query hash of queries. Files like "setup_learn_settings.sh" contain settings that I applyed on every stage of AQO testing. Files aqo_job_disabled, aqo_job_forced and aqo_job_learn consist of test script that I described before.

You should pay attention on paths set in script, particulary the values of variables enumerated bellow:
INSTDIR - the path where install folder with "bin" is located
QUERY_DIR - the path where JOB queries are
folder_output - the catalog where you store test results.

## How analyze AQO test
To compare statistic of working planner with and without AQO, first of all, you should consider an error of cardinality on every iteration of learning.
To be noted, an cardinality error will be descreassing only for learning process, in disabled and controlled it will be changing slightly.
If query are learnable, an error will be dropping and in the last itration it will even reach 0.
In learning mode, planning and execution time might be unstable because planner tries to generate new optimal plan again after using new information about cardinality.

The graphics [there](https://github.com/Alena0704/Test-AQO/blob/main/Cardinality%20error.html) show how an error of cardinality is falling during 22 iteration when queries were learning.

As I mentioned before, during learning, planner will probably regenerate the plan of execution query, so planning time will be more.

See the picture with the planning and execution time for every query [there](https://github.com/Alena0704/Test-AQO/blob/main/Execution%20and%20planning%20time%20during%20learning%20AQO.html)

The next thing, that you should consider is time of execution query. If with AQO planner built better plan than it was, the execution time must be less.

See the difference between execution time with and without used AQO for every query [there](https://github.com/Alena0704/Test-AQO/blob/main/Execution%20Time%20between%20with%20and%20without%20AQO.html)

I used analytic information from aqo_query_stats copied the results within query:
```
psql -d postgres -c "\copy (select * from aqo_query_stat) to 'aqo_query_stat.csv' DELIMITER ',' CSV HEADER"
```
So, after preprocessing (I used code bellow and my owned functions), I got the presentative view of data for analysis:
```
import functions
from preprocess_dataframe import get_preprocess_dataframe

df_query_stat=pd.read_csv('/home/alena/Test-AQO/JOB/disabled/aqo_query_stat.csv')
    lst_stat_columns = ['execution_time_with_aqo', 'execution_time_without_aqo',
       'planning_time_with_aqo', 'planning_time_without_aqo',
       'cardinality_error_with_aqo', 'cardinality_error_without_aqo']
lst_stat_cut = [1, 1, 1, 1, 1, 1]
df_query_stat = get_preprocess_dataframe(df_query_stat, lst_stat_columns, lst_stat_cut)
```
I got the table looking like that:
<img alt="aqo_query_stats" src="some pictures/aqo_query_stats.png" />

For processing files with analytical information (like learn_1_report.csv) and file with cardinality error (like I use learn_aqo_query_err_1.csv) I used script bellow:
```
df_ex_pl_time = pd.DataFrame()
df_ex_pl_time_orig = pd.DataFrame()
df_query_err=pd.DataFrame()

filename_basics=glob.glob("{}/*_report.csv".format(path_folder, mode))

for file in filename_basics:
    df_list = list(pd.read_csv(file) for file in filename_basics)
    if len(df_list)>1:
        df_list = []
        for file in filename_basics:
            df=pd.read_csv(file)
            df['Query hash'] = df['Query hash'].astype(str)
            df_list.append(df)
        df_ex_pl_time = pd.concat(df_list, ignore_index=True)
    else:
        df_ex_pl_time = df_list[0]

#report
df_ex_pl_time = df_ex_pl_time.fillna(0)
df_ex_pl_time = df_ex_pl_time.rename(columns = {'Plan time': 'plan_time',
                                        'Query Number':'query_number',
                                        'Query Name':'query_name',
                                        'Execution Time':'execution_time',
                                        'Query hash':'query_hash'})
df_ex_pl_time['query_hash'] = df_ex_pl_time['query_hash'].astype(str)
df_ex_pl_time['plan_time'] = df_ex_pl_time['plan_time'].astype(float)
df_ex_pl_time_orig=df_ex_pl_time.copy()


filename_basics=glob.glob("{}/*_err*.csv".format(path_folder, mode))
lst=[]
df_list=[]
def f(lst,k,l):
    lst_temp=[k]*l
    lst = lst+lst_temp
df_list = list(pd.read_csv(file) for file in filename_basics)
if len(df_list)>1:
    df_query_err = pd.concat(df_list, ignore_index=True)
else:
    df_query_err = df_list[0]
df_query_err['id'] = df_query_err['id'].astype(str)
df_query_err['errdelta'] = df_query_err['errdelta'].astype(float)
```

To assign what query names are determinated to query hash I used script:
```
dict_hash = {}
for i in df_ex_pl_time.itertuples(index=False):
    if i.query_hash in dict_hash:
        dict_hash[str(i.query_hash)].append(i.query_name)
    else:
        dict_hash[i.query_hash] = []
        dict_hash[str(i.query_hash)].append(i.query_name)
df_temp=pd.DataFrame(dict_hash.items())
df_temp.columns=['queryid', 'query_name']
df_temp['queryid'] = df_temp['queryid'].astype(str)
#print(df_query_stat.columns)
df_query_err=df_query_err.merge(df_temp,left_on='id', right_on='queryid')
df_query_err['query_name'] = df_query_err['query_name'].astype(str)
df_query_err=df_query_err.drop(columns=['queryid'])
df_query_stat['queryid'] = df_query_stat['queryid'].astype(int)
df_query_stat=df_query_stat.merge(df_temp, how='left', on='queryid')
```

Note, you need to collect information from explained queries to realize it.

Code for drawing graphics mentioned before:
```
fig = make_subplots(rows=11, cols=11, subplot_titles=name_query)
for it, i in enumerate(name_query):
    df_temp=learn_df_query_err[learn_df_query_err['query_name']==name_query[it]]
    df_temp2=stats[stats['query_name']==name_query[it]]['cardinality_error_without_aqo_split'].to_list()
    if len(df_temp2)==0:
        fig.add_trace(go.Scatter(name='cardinality_error', x = ox,
                         y = [2]*22, line = dict(color= 'black', dash='dash')),
              row=(it//11)+1, col=(it%11)+1)
    else:
        fig.add_trace(go.Scatter(name='cardinality_error', x = ox,
                         y = [df_temp2[0][0]]*22, line = dict(color= 'black', dash='dash')),
              row=(it//11)+1, col=(it%11)+1)
    fig.add_trace(go.Scatter(name='cardinality_error', x = ox,
                         y = df_temp['errdelta_learn'].to_list()[:22], line = dict(color= 'red', dash='dot')),
              row=(it//11)+1, col=(it%11)+1)
    fig.update_layout(legend_orientation="h",
                  legend=dict(x=.5, xanchor="center"),
                   title_text="Error of cardinality")
    fig.update_xaxes(title_text="Iterations", row=(it//11)+1, col=(it%11)+1)
    fig.update_yaxes(title_text="Cardinality Error", row=(it//11)+1, col=(it%11)+1)
fig.update_layout(width=4000, height = 4200)
upload_pics(fig, '{}/{}_folder{}'.format(main_path, 'learn',cycle_test), 'Difference cardinality')
os.rename('temp-plot.html', '{}_learn_Difference cardinality.html'.format(cycle_test))
fig.show()
```

So, the benefits of using AQO under withut it you can see [there](https://github.com/Alena0704/Test-AQO/blob/main/final_graphic_exec_time_diff.html) or below:

<img alt="The difference between Execution time with and without AQO" src="some pictures/benefits from AQO1.png" />

The code to make the graphic:
```
stackData = {
    "last execution time with aqo":lst_execution_time_with_aqo,
    "last execution time without aqo": lst_execution_time_without_aqo,
    # Use differece
    "labels": name_query2
}


fig3 = go.Figure(
    data=[
        go.Bar(
            name="frozen execution time",
            x=stackData["labels"],
            y=stackData["last execution time with aqo"],
            offsetgroup=0,
            marker_color = '#800080'
        ),
        go.Bar(
            name="disabled execution time",
            x=stackData["labels"],
            y=stackData["last execution time without aqo"],
            offsetgroup=1,
            marker_color = '#ff4d00'
        )
    ],
    layout=go.Layout(
        title="Execution time with and without AQO",
        yaxis_title="Execution time",
        xaxis_title="queries",
        width=1400, height = 800, font=dict(
        family="Courier New, monospace",
        size=16,
        color="RebeccaPurple"
    ),
        yaxis=dict(range=[0, 20]),
                 legend=dict(
    orientation = 'h', xanchor = "center", x = 0.5, y= 1)
    )
)
upload_pics(fig3, '{}/{}_folder{}'.format(main_path, 'learn',cycle_test), 'Stack')
fig3.show()
```

Evaluate the benefits as the ratio Execution time of query without AQO by Execution time with it:
<img alt="The ratio between execution time without and with using AQO" src="some pictures/benefits from AQO2.png" />

Code to build it:
```
fig3 = go.Figure(
    data=[
        go.Scatter(name = 'Relative execution time', x = name_query2, y= [(b) / (m)-1 for b,m in zip(lst_execution_time_without_aqo, lst_execution_time_with_aqo)], line = dict(color= 'black', dash='solid')),
        go.Scatter(name = 'No better no worse (1)', x = name_query2, y= [1]*len(name_query2), line = dict(color= 'red', dash='dash')),
        go.Scatter(name = 'Better in 4 times (4)', x = name_query2, y= [4]*len(name_query2), line = dict(color= 'red', dash='dash')),
    go.Scatter(name = 'Worse (0)', x = name_query2, y= [0.01]*len(name_query2), line = dict(color = '#800080', dash='dash'))],
layout=go.Layout(
        title="The ratio between execution time without and with using AQO",
        yaxis_title="Relative execution time",
        xaxis_title="queries",
        width=1400, height = 800, font=dict(
        family="Courier New, monospace",
        size=16,
        color="Black"),
    yaxis=dict(range=[-1, 10]),legend=dict(orientation = 'h', xanchor = "center", x = 0.5, y= 1)
    ),
)
fig3.update_traces(texttemplate='%{text:.2s}', textposition='top center')
upload_pics(fig3, '{}/{}_folder{}'.format(main_path, 'learn',cycle_test), 'Stack')
fig3.show()
```
