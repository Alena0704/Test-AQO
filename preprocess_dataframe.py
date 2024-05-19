import pandas as pd
import numpy as np
import functions

class Dataframe_preprocess:
    def __init__(self, df_in, column_list_in, cut_list_in = 1):
        self.df = df_in
        self.column_list = column_list_in
        self.cut_list = cut_list_in
        
    def preprocess_columns(self):
        for column, cut in zip(self.column_list, self.cut_list):
            self.df = functions.preprocess(self.df, column, cut)
        return self.df
    
def get_preprocess_dataframe(df, column_list, cut_list):
    dataframe_new = Dataframe_preprocess(df, column_list, cut_list)
    dataframe_new = dataframe_new.preprocess_columns()
    return dataframe_new
    