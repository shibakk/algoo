from collections import Counter
from datetime import datetime
from newsapi import NewsApiClient
import numpy as np
import pandas as pd
import scipy as sp
from sklearn.preprocessing import MinMaxScaler

def save_news_from_source():
    qword = 'United States' and 'debt'
    sources = 'financial-times'
    newsAPI = NewsApiClient(api_key='48b2efb7dbf9480b84f66a0b6837cc46')
    sources = newsAPI.get_everything(q=qword,
                                     sources='financial-times',
                                     sort_by='relevancy',
                                     page_size=100)
    df = pd.DataFrame.from_dict(sources)
    df = pd.concat([df.drop(['articles'], axis=1), df['articles'].apply(pd.Series)], axis=1)
    dftime = df['publishedAt']
    dfref = []
    for each in dftime:
        dfref.append(each[:10])
    dfref.sort(key=lambda date: datetime.strptime(date, '%Y-%m-%d'))
    date = pd.to_datetime(dfref, format='%Y/%m/%d')
    inaday = dict(Counter(date))
    df = pd.DataFrame.from_dict(inaday, orient='index', columns=['Counted'])
    countall = df['Counted'].sum()
    df.to_csv('debtUK.csv')
    print(countall, df)

def organize_dataframe():
    dfnews = pd.read_csv('debtUS.csv', names=['Date', 'Count'])
    dfnews.set_index('Date', drop=True, inplace=True)
    dfnews = dfnews[1:]
    dftrends = pd.read_csv('US.csv', names=['Date', 'Trends'])
    dftrends.set_index('Date', drop=True, inplace=True)
    dftrends = dftrends[1:]
    df = pd.DataFrame(index=dftrends.index)
    df['trend'] = dftrends['Trends']
    df['news'] = dfnews['Count']
    df['news'].fillna(0, inplace=True)
    scaler = MinMaxScaler()
    scaled = scaler.fit_transform(df)
    dfscaled = pd.DataFrame(scaled, columns=['trends', 'news'], index=df.index)
    dfscaled['trends'].to_csv('optimalUS.csv')

def forex():
    df1 = pd.read_csv('optimalUS.csv', names=['Date','Debt'])
    df2 = pd.read_csv('optimalUK.csv', names=['Date','Debt'])
    df3 = pd.DataFrame()
    df3['US'] = df1['Debt']
    df3['UK'] = df2['Debt']
    scaler = MinMaxScaler()
    scaled = scaler.fit_transform(df3)
    dfscaled = pd.DataFrame(scaled, columns=['US', 'UK'], index=df1.index)
    dfscaled.to_csv('debtscaled.csv')
    print(dfscaled)
forex()