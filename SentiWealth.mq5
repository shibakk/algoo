//+------------------------------------------------------------------+
//|                                                  SentiWealth.mq5 |
//|                              Copyright 2018, Kristian Shahbazian |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Kristian Shahbazian"
#property link      "https://www.trader-help.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Global Var                    |
//+------------------------------------------------------------------+
datetime tm=TimeCurrent();

string file_name="debt.csv"; // file name
int open_flags=FILE_CSV|FILE_ANSI;
int size=0;

//--- indicator buffer
double gs_buff[];
double buff[];
double current_number=0;
double last_value=0;
double average_value=0;

//--- integers used in loops
int i=0;
int a=0;

int OnInit()
  {
   //---
     ResetLastError();
     int file_handle=FileOpen(file_name,open_flags);
     if(file_handle!=INVALID_HANDLE)
       {
        PrintFormat("Expert advisor is available for initialization.");
        size=(int)StringToDouble(FileReadString(file_handle));
        while(!FileIsEnding(file_handle))
          {
           ArrayResize(gs_buff,size);
           current_number=StringToDouble(FileReadString(file_handle));
           gs_buff[i]=current_number;
           i++;
           Print(i);
          }
        Print(gs_buff[8]);
        FileClose(file_handle);
        PrintFormat("Data is written, %s file is closed",file_name);
        //--- close the file
       }
     else
       {
        PrintFormat("FAILED TO OPEN %s FILE, Error code = %d",file_name,GetLastError());
        PrintFormat("Please contact customer support at www.trader-help.com");
        return(INIT_FAILED);
       }
//---
     return(INIT_SUCCEEDED);
   }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }

//+------------------------------------------------------------------+

void OnTrade(void)
  {
   //--- check the signals

//--- additional checks

//---
  }
//---

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
