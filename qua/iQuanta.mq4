//+------------------------------------------------------------------+
//|                                                      iQuanta.mq4 |
//|                                      Copyright 2018,Trader-Help. |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018,Trader-Help."
#property link      "https://www.trader-help.com"
#property version   "1.00"

#property strict

#property indicator_buffers 2
#property indicator_plots   0
//--- plot GS
#property indicator_label1  "Quanta Signal"

#property indicator_label2  "Moving Indicator"

string file_name="QuantaI.HTM"; // file name
string file_name_av="QuantaIAverage.HTM"; // file name
string file_name_dt="QuantaDate.HTM";
int open_flags=FILE_CSV|FILE_ANSI;
int ot_open_flags=FILE_CSV|FILE_ANSI;
ushort delimiter=',';

double gs_buff[];
double gs_buff_av[];
datetime time_buff[];

double current_number=0;
double current_number_av=0;
datetime current_number_date=0;
int n=0;
int g=1;
int twot=2;
int m=-1;
int ind;

int re=1;
int size=0;
int a;
double last;
double lot;

double         GSBuffer[];
double         AVBuffer[];
double         AVInvBuffer[];
double         LBuffer[];
double         HBuffer[];
double         Lo[];
double         Hig[];
double         LBBuffer[];
double         UBBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Resetting the last error code 
    ResetLastError(); 
   int file_handle=FileOpen(file_name,open_flags,delimiter);
   int file_handle_av=FileOpen(file_name_av,open_flags,delimiter);
   int file_handle_date=FileOpen(file_name_dt,open_flags,delimiter);
   if(file_handle!=INVALID_HANDLE)
   {
    PrintFormat("Expert advisor is available for initialization.");
    while(!FileIsEnding(file_handle))
      {
       size=re++;
       current_number=StringToDouble(FileReadString(file_handle));
       current_number_av=StringToDouble(FileReadString(file_handle_av));
       current_number_date=FileReadDatetime(file_handle_date);      
       ArrayResize(gs_buff,size);
       ArrayResize(gs_buff_av,size);
       ArrayResize(time_buff,size);
       time_buff[n]=current_number_date;
       Print(time_buff[n]);
       gs_buff[n]=current_number;
       gs_buff_av[n]=current_number_av;
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
   SetIndexBuffer(0,GSBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,AVBuffer,INDICATOR_DATA);
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
//--- return value of prev_calculated for next call
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(gs_buff,false);
   ArraySetAsSeries(gs_buff_av,false);
   ArraySetAsSeries(time_buff,false);
   ArraySetAsSeries(GSBuffer,false);
   ArraySetAsSeries(AVBuffer,false);
//--- double AVBuffer=iMAOnArray(gs_buff,0,length,0,MODE_SMA,index);
//--- Print(AVBuffer);
//---   STDBuffer[i]=iStdDevOnArray(gs_buff,0,5,0,MODE_SMA,j);
//---LBBuffer[i]=iBandsOnArray(gs_buff,0,5,2,0,MODE_LOWER,j);
//---UBBuffer[i]=iBandsOnArray(gs_buff,0,5,2,0,MODE_UPPER,j);
//--- the loop for the bars that have not been handled yet;

//--- Get the number of bars available for the current symbol and chart period
   for(int i=prev_calculated;i<rates_total;i++) 
     {
      //--- 0 by default 
      GSBuffer[i]=0;
      AVBuffer[i]=0;
      //--- check if any data still exists 
      if(ind<size) 
        { 
         for(int j=ind;j<size;j++) 
           {
            //--- if the dates coincide, the value from the file is used
            if(time[i]==time_buff[j])
              {
               GSBuffer[i]=gs_buff[j];
               AVBuffer[i]=gs_buff_av[j];
               Print(time[i]);
               //--- increase the counter
               ind=j+1;
               //---LBuffer[i]+=MathMin(GSBuffer[i],GSBuffer[i+m]);
               //---HBuffer[i]-=MathMax(GSBuffer[i],GSBuffer[i+m]);
               //---Lo[i]-=AVBuffer[i+m];
               //---Hig[i]+=GSBuffer[i+m];
              }
               //---AVInvBuffer[i]=iMAOnArray(HBuffer,0,1,0,MODE_SMA,ind+m);
               //---LBBuffer[i]=iBandsOnArray(GSBuffer,0,1,1.5,0,MODE_LOWER,ind+m);
               //---UBBuffer[i]=iBandsOnArray(GSBuffer,0,1,1.5,0,MODE_UPPER,ind+m);
             }   
           } 
         }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+