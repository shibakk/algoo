//+------------------------------------------------------------------+
//|                                                      iQuanta.mq4 |
//|                                      Copyright 2018,Trader-Help. |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018,Trader-Help."
#property link      "https://www.trader-help.com"
#property version   "1.00"

#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot GS
#property indicator_label1  "GS"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

string file_name_dt="mqldt.csv"; // file name
string file_name="debt-44.csv"; // file name
int open_flags=FILE_CSV|FILE_ANSI;
int ot_open_flags=FILE_CSV|FILE_ANSI;
ushort delimiter=',';

double gs_buff[];
datetime time_buff[];

double current_number=0;
datetime current_number_date=0;
int n=0;
int g=1;
int ind;

int re=1;
int size=0;
int a;
double last;
double lot;

double         GSBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Resetting the last error code 
    ResetLastError(); 
//--- Downloading a html page from Trader-Help
//--- indicator buffers mapping
   int file_handle=FileOpen(file_name,open_flags,delimiter);
   int file_handle_date=FileOpen(file_name_dt,open_flags,delimiter);
   if(file_handle!=INVALID_HANDLE)
   {
    PrintFormat("Expert advisor is available for initialization.");
    while(!FileIsEnding(file_handle))
      {
       size=re++;
       current_number=StringToDouble(FileReadString(file_handle));
       current_number_date=FileReadDatetime(file_handle_date);      
       ArrayResize(gs_buff,size);
       ArrayResize(time_buff,size);
       time_buff[n]=current_number_date;
       gs_buff[n]=current_number;
       n++;
      }
    FileClose(file_handle);
    PrintFormat("Data is written, %s file is closed",file_name);
   }
   else
   { 
    Print("Error in FileOpen. Error code =",GetLastError());
    return(INIT_FAILED);
   }
//---
//--- bind the array to the indicator buffer with index 0
   
   SetIndexBuffer(0,GSBuffer,INDICATOR_DATA);
   SetIndexEmptyValue(0,0.0); 
//---- set the indicator values that will not be visible on the chart 
   return(INIT_SUCCEEDED);   
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
//--- return value of prev_calculated for next call
   //--- Get the number of bars available for the current symbol and chart period
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(GSBuffer,false); 
//--- the loop for the bars that have not been handled yet 
   for(int i=prev_calculated;i<rates_total;i++) 
     {
      //--- 0 by default 
      GSBuffer[i]=0;
      //--- check if any data still exists 
      if(ind<size) 
        { 
         for(int j=ind;j<size;j++) 
           { 
            //--- if the dates coincide, the value from the file is used
            if(time[i]==time_buff[j]) 
              {
               GSBuffer[i]=gs_buff[j];
               //--- increase the counter
               ind=j+1;
              } 
           } 
        } 
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
