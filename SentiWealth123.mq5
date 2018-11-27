//+------------------------------------------------------------------+
//|                                                  SentiWealth.mq5 |
//|                              Copyright 2018, Kristian Shahbazian |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Kristian Shahbazian"
#property link      "https://www.trader-help.com"
#property version   "1.00"

#property tester_file "debt.csv"

#include <Trade\Trade.mqh>

//--- indicator buffers 
double                   GSBuffer[]; 
int                      gs_handle; 

input double MaximumRisk = 0.02; // Max risk in %
input double DecreaseFactor = 3; // Decrease factor


//+------------------------------------------------------------------+
//| Global Var                    |
//+------------------------------------------------------------------+
string file_name="debt.csv"; // file name
int open_flags=FILE_CSV|FILE_ANSI;
ushort delimiter=',';

int size=0;

//--- indicator buffer
double gs_buff[];
datetime gs_buff_dt[];
double current_number=0;
datetime current_number_date;
double last;
datetime last_date;
double average;

//--- integers used in loops
int n=0;
int re=1;
int a=-1;
int v=0;
int d=0;

//--- indicator buffers
double         NumerationBuffer[];
int GS_handle;
int OnInit()
  {
     SetIndexBuffer(0,NumberationBuffer,INDICATOR_DATA)
     GS_handle=iCustom(_Symbol,_Period,
     ArraySetAsSeries(NumerationBuffer,true);
     GS
   //---
     ResetLastError();
     int file_handle=FileOpen(file_name,open_flags,delimiter);
     int file_handle_dt=FileOpen("date.csv",open_flags,delimiter);
     if(file_handle!=INVALID_HANDLE)
       {
        PrintFormat("Expert advisor is available for initialization.");
        while(!FileIsEnding(file_handle))
          {
           size=re++;
           current_number=StringToDouble(FileReadString(file_handle));
           current_number_date=FileReadDatetime(file_handle_dt);
           ArrayResize(gs_buff,re);
           ArrayResize(gs_buff_dt,re);
           gs_buff[n]=current_number;
           gs_buff_dt[d]=current_number_date;
           Print(gs_buff_dt[d]);
           n++;
           d++;
          }
        //---last_value=gs_buff[a-1];
        //---Print(last_value);
        last=gs_buff[n-1];
        for(a=-2;a>-9;a--)
          {
           average=gs_buff[n+a]/7;
          }
        last_date=gs_buff_dt[n-1];
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

     ArraySetAsSeries(gs_buff,true);
     return(INIT_SUCCEEDED);
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
//---  we'll store the time of the current zero bar opening
   static datetime currentBarTimeOpen=0;
    //--- number of values copied from the iMA indicator 
   int values_to_copy; 
//--- revert access to array time[] - do it like in timeseries
   ArraySetAsSeries(time,true);
//--- If time of zero bar differs from the stored one
   if(currentBarTimeOpen!=time[0])
     {
     //--- enumerate all bars from the current to the chart depth
      for(int i=rates_total-1;i>=0;i--) NumerationBuffer[i]=i;
      currentBarTimeOpen=time[0];
     }
//--- determine the number of values calculated in the indicator 
   int calculated=BarsCalculated(handle); 
   if(calculated<=0) 
     { 
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError()); 
      return(0); 
     } 
//--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1) 
     { 
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated>rates_total) values_to_copy=rates_total; 
      else                       values_to_copy=calculated; 
     } 
   else 
     { 
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1; 
     } 
//--- return value of prev_calculated for next call
   return(rates_total);
  }

void OnTick(void)
   {
//---
    if(PositionSelect(_Symbol))
       BuyOrSell();
//---
   }

double TradeSizeOptimized(void)
   {
   double price=0.0;
   double margin=0.0;
//--- Calculate the lot size
   if(!SymbolInfoDouble(_Symbol,SYMBOL_ASK,price))
      return(0.0);
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,1.0,price,margin))
      return(0.0);
   if(margin<=0.0)
      return(0.0);
      
   double lot=NormalizeDouble(AccountInfoDouble(ACCOUNT_FREEMARGIN)*MaximumRisk/margin,2);
//--- Calculate the length of the series of consecutive trades
   if(DecreaseFactor>0)
      {
      //--- request the entire trading history
      HistorySelect(0,TimeCurrent());
      //--
      int orders=HistoryDealsTotal(); // the total number of deals
      int losses=0; // the number of loss deals in the series
      
      for(int i=orders-1;i>=0;i--)
         {
         ulong ticket=HistoryDealGetTicket(i);
         if(ticket==0)
            {
            Print("HistoryDealGetTicket failed, no trade history");
            break;
            }
         //---checking deal signal
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol)
            continue;
         //---checking the profit
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         if(profit>0.0)
            break;
         if(profit<0.0)
            losses++;
         }
      //---
      if(losses>1)
         NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
      }
//--- normalizing and checking the allowed values of the trade volume
   double stepvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   lot=stepvol*NormalizeDouble(lot/stepvol,0);
   
   double minvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(lot<minvol)
      lot=minvol;
      
   double maxvol=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(lot>maxvol)
      lot=maxvol;
//--- terunt the value of the trade volume
   return(lot);
   }
   

void BuyOrSell(void)
  {
   MqlRates rt[3];
//--- Copy price values
   if(CopyRates(_Symbol,_Period,0,2,rt)!=2)
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }
//--- Trade only on the first tick of the new bar
   if(rt[1].tick_volume>1)
      return;
/
//--- get the current value of the Moving Average indicator
   if(CopyBuffer(last,1,0,1,gs_buff)!=1)
     {
      Print("CopyBuffer from iMA failed, no data");
      return;
     }
//--- check the signals
   ENUM_ORDER_TYPE signal=WRONG_VALUE;

   if(cv[1]>av[0])
      signal=ORDER_TYPE_SELL;    // sell condition
   else
     {
      if(cv[1]<av[0])
         signal=ORDER_TYPE_BUY;  // buy condition
     }
//--- additional checks
   if(signal!=WRONG_VALUE)
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
         if(Bars(_Symbol,_Period)>100)
           {
            CTrade trade;
            trade.PositionOpen(_Symbol,signal,TradeSizeOptimized(),
                               SymbolInfoDouble(_Symbol,signal==ORDER_TYPE_SELL ? SYMBOL_BID:SYMBOL_ASK),
                               0,0);
           }
//---
  }