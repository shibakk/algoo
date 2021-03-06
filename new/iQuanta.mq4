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
#property indicator_buffers 9
#property indicator_plots   9
//--- plot GS
#property indicator_label1  "Quanta Data"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_DASHDOTDOT
#property indicator_width1  1

#property indicator_label2  "Moving Indicator"
#property indicator_type2   DRAW_SECTION
#property indicator_color2  clrWhiteSmoke
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Price Low"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  Green
#property indicator_style3  0
#property indicator_width3  3

#property indicator_label4  "Price High"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrTomato
#property indicator_style4  0
#property indicator_width4  4

#property indicator_label5  "BB Lower Band"
#property indicator_type5   DRAW_NONE
#property indicator_color5  clrSnow
#property indicator_color5  clrBisque
#property indicator_style5  STYLE_DASHDOTDOT
#property indicator_width5  3

#property indicator_label6  "BB Upper Band"
#property indicator_type6   DRAW_NONE
#property indicator_color6  clrSnow
#property indicator_style6  STYLE_DASHDOTDOT
#property indicator_width6  3

#property indicator_label7  "Low"
#property indicator_type7   DRAW_HISTOGRAM
#property indicator_color7  Red
#property indicator_style7  0
#property indicator_width7  3

#property indicator_label8  "High"
#property indicator_type8   DRAW_HISTOGRAM
#property indicator_color8  clrGreen
#property indicator_style8  0
#property indicator_width3  4

#property indicator_label9  "Moving Inverted Indicator"
#property indicator_type9   DRAW_NONE
#property indicator_color9  Green
#property indicator_style9  STYLE_SOLID
#property indicator_width9  2

string file_name_av="debt-average.csv"; // file name
string file_name="debt.csv"; // file name
string file_name_dt="date.csv";
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
//--- bind the array to the indicators | Total = 6 |
   SetIndexBuffer(0,GSBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,AVBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,HBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,LBBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,UBBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,Lo,INDICATOR_DATA);
   SetIndexBuffer(7,Hig,INDICATOR_DATA);
   SetIndexBuffer(8,AVInvBuffer,INDICATOR_DATA);

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
   ArraySetAsSeries(GSBuffer,false);
   ArraySetAsSeries(AVBuffer,true);
   ArraySetAsSeries(AVInvBuffer,false);
   ArraySetAsSeries(LBuffer,false);
   ArraySetAsSeries(HBuffer,false);
   ArraySetAsSeries(LBBuffer,false);
   ArraySetAsSeries(UBBuffer,false);
   ArraySetAsSeries(Lo,false);
   ArraySetAsSeries(Hig,false);
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
               Print(AVBuffer[i]);
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