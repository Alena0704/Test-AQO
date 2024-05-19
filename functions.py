import pandas as pd
import numpy as np

def get_text_query(query_hash):
    ind = df_texts[df_texts['query_hash']==query_hash].index[0]
    arr = df_texts['query_text_edit'].loc[ind].split('\n')
    str_ = ''
    for i in arr:
        str_+=i
    return str_

def get_dict(df, key_column, concat_column):
    dict_queries = {}
    for i in df_data.itertuples(index=False):
        if i.fsspace_hash in dict_queries.keys():
            dict_queries[i.fsspace_hash]+=i.features_split
        else:
            dict_queries[i.fsspace_hash] = []
            dict_queries[i.fsspace_hash].append(i.features_split)
    for i in dict_queries.keys():
        dict_queries[i] = dict_queries[i][0]
    return dict_queries

def get_elements(elem):
    ln = len(elem)-1
    try:
        if elem[ln]=='}':
            elem = elem[:-1]
        if elem[0] == '{':
            elem = elem[1:]
        return float(elem)
    except:
        return 0

def preprocess(df, column_name, cut=1):
    df['{}'.format(column_name)] = df['{}'.format(column_name)].str[cut:-cut]
    df['{}'.format(column_name)] = df['{}'.format(column_name)].astype(str)
    df.insert(1, "{}_split".format('{}'.format(column_name)), '')
    #print(column_name)
    for k,i in enumerate(df['{}'.format(column_name)]):
        df['{}_split'.format('{}'.format(column_name))].loc[k] = list(map(get_elements,i.split(',')))
    df = df.drop('{}'.format(column_name),axis = 1)
    return df

def sum_errors(df, column, mode):
    lst = []
    for k,i in enumerate(df.itertuples(index=False)):
        a = np.array(df[column].loc[k])
        if mode=='with':
            lst.append(a.sum()/i.executions_with_aqo)
        else:
            lst.append(a.sum()/i.executions_without_aqo)
    df[column] = lst
    return df

def last_errors(df, column, new_column):
    lst = []
    for k,i in enumerate(df.itertuples(index=False)):
        a = np.array(df[column].loc[k])
        lst.append(a[-1])
    df[new_column] = lst
    return df

def del_column(df, column_name):
    df = df.drop('{}'.format(column_name),axis = 1)
    return df

def rename_column(df, column_old_name, column_new_name):
    df.rename(columns={"{}".format(column_old_name): "{}".format(column_new_name)})
    return df
def column_to_string(df, column):
    df[column] = df[column].astype(str)
    return df
def get_df(path_folder, file_name, mode, times):
    df = pd.DataFrame()
    if mode == 'disabled':
        lst_files = os. listdir(path_folder)

        dfs = []
        for filename in lst_files:
            dfs.append(pd.read_csv('{}/{}'.format(path_folder, filename)))
        # Concatenate all data into one DataFrame
        df = pd.concat(dfs, ignore_index=True)
    else:
        df = pd.read_csv('{}/{}'.format(path_folder,file_name))

    df = df.fillna(0)
    df=df.rename(columns={'+':'plus', 'Plan time': 'plan_time'})
    df = df.rename(columns = {'Query Number':'query_number', 'Query Name':'query_name', 'Execution Time':'execution_time', 'Query hash':'query_hash'})
    lst_data = []
    for i in df.itertuples(index=False):
        a = 0.
        if i.plan_time==0:
            a = i.plus
        else:
            a = i.plan_time
        lst_data.append([i.query_number, i.query_name, i.execution_time, i.query_hash, a])
    df = pd.DataFrame(lst_data, columns = ['query_number', 'query_name', 'execution_time', 'query_hash', 'plan_time'])
    df['query_number'] = df['query_number'].astype(int)
    df['query_hash'] = df['query_hash'].astype(str)
    df['plan_time'] = df['plan_time'].astype(float)
    if mode == 'disabled':
        lst_data = []
        dict_query = {}
        for i in df.itertuples(index=False):
            if i.query_name in dict_query:
                dict_query[i.query_name][1] += i.execution_time
                dict_query[i.query_name][3] += i.plan_time
            else:
                dict_query[i.query_name] = [i.query_name, i.execution_time, i.query_hash, i.plan_time]
        df = pd.DataFrame(dict_query.values(), columns = ['query_name', 'execution_time', 'query_hash', 'plan_time'])
        df['exec_time_avg'] = df['execution_time']/times
        df['plan_time_avg'] = df['plan_time']/times
    lst_data = []
    for i in df.itertuples(index=False):
        lst_data.append(re.findall(r'-?\d+',i.query_hash))
    lst_data1 = []
    for i in lst_data:
        lst_data1.append(i[0])
    df['query_hash'] = lst_data1
    return df