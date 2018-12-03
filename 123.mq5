//+------------------------------------------------------------------+
//|                                                          .mq5 |
//|                                      Copyright 2018, Trader-Help |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Trader-Help"
#property link      "https://www.trader-help.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot GS
#property indicator_label1  "GS"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
input ENUM_CHART_PROPERTY_DOUBLE    double_values;

double                   GSBuff[]; 

string file_name="debt-49.csv"; // file name
string file_name_dt="debt-49-dates.csv"; // file name
int open_flags=FILE_CSV|FILE_ANSI;
ushort delimiter=',';

double gs_buff[];
datetime time_buff[];

double current_number=0;
datetime current_number_date;
int n=0;
int g=1;
int ind;



int re=1;
int size=0;
int a;
double last;
double lot;
//--- indicator buffers
double         GSBuffer[];
int            handlee;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
    string cookie=NULL,headers; 
    char   post[],result[]; 
    string url_ind="https://trader-help.com/mt4/SentimentTrader-Wealth-Indicator.csv";
    string url_date="https://trader-help.com/mt4/SentimentTrader-Wealth-Indicator.csv"; 
//--- To enable access to the server, you should add URL "https://trader-help.com" 
//--- to the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"): 
//--- Resetting the last error code 
    ResetLastError(); 
//--- Downloading a html page from Trader-Help
    int res_ind=WebRequest("GET",url_ind,cookie,NULL,500,post,0,result,headers);
    int res_date=WebRequest("GET",url_date,cookie,NULL,500,post,0,result,headers);
    if(res_ind && res_date==-1) 
     { 
       Print("Error in WebRequest. Error code  =",GetLastError()); 
       //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
       MessageBox("Add the address to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
      } 
    else 
      { 
       if(res_ind && res_date==200) 
         {
         //--- Successful download 
          PrintFormat("The file has been successfully downloaded, File size %d byte.",ArraySize(result)); 
          //PrintFormat("Server headers: %s",headers); 
         //--- Saving the data to a file 
          int filehandle=FileOpen(file_name,FILE_WRITE|FILE_BIN); 
          if(filehandle!=INVALID_HANDLE) 
            {
            //--- Saving the contents of the result[] array to a file 
             FileWriteArray(filehandle,result,0,ArraySize(result)); 
             //--- Closing the file 
             FileClose(filehandle);
            }
          } 
         else
           { 
            PrintFormat("Downloading '%s' failed, error code %d",url_ind,res_ind);
            Print("Error in FileOpen. Error code =",GetLastError()); 
           }
       }
//--- indicator buffers mapping
   int file_handle=FileOpen(file_name,open_flags,delimiter);
   int file_handle_date=FileOpen(file_name_dt,open_flags,delimiter);
   if(file_handle && file_handle_date!=INVALID_HANDLE)
   {
    PrintFormat("Expert advisor is available for initialization.");
    while(!FileIsEnding(file_handle))
      {
       size=re++;
       current_number=StringToDouble(FileReadString(file_handle));
       current_number_date=FileReadDatetime(file_handle_date);      
       ArrayResize(gs_buff,size);
       ArrayResize(time_buff,size);
       gs_buff[n]=current_number;
       time_buff[n]=current_number_date;
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
   SetIndexBuffer(0,GSBuff,INDICATOR_DATA); 
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
//--- the loop for the bars that have not been handled yet 
   for(int i=prev_calculated;i<rates_total;i++) 
     { 
      //--- 0 by default 
      GSBuff[i]=0; 
      //--- check if any data still exists 
      if(ind<size) 
        { 
         for(int j=ind;j<size;j++) 
           { 
            //--- if the dates coincide, the value from the file is used 
            if(time[i]==time_buff[j]) 
              {
               GSBuff[i]=gs_buff[j]; 
               //--- increase the counter 
               ind=j+1; 
               break; 
              } 
           } 
        } 
     } 
   return(rates_total);
  }
//+------------------------------------------------------------------+
