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
int                      gs_handle; 

input double MaximumRisk = 0.02; // Max risk in %
input double DecreaseFactor = 3; // Decrease factor

//+------------------------------------------------------------------+ 
//| Enumeration of the methods of handle creation                    | 
//+------------------------------------------------------------------+ 
enum Creation 
  { 
   Call_GS,                   // use GS 
   Call_IndicatorCreate       // use IndicatorCreate 
  }; 
//--- input parameters 
input Creation                      type=Call_GS;                // type of the function  
input int                           ma_period=7;                 // period of ma 
input int                           ma_shift=1;                   // shift
input ENUM_MA_METHOD                ma_method=MODE_SMA;     // type of price 
input string                        symbol=" ";                   // symbol  
input ENUM_TIMEFRAMES               period=PERIOD_CURRENT;        // timeframe
input ENUM_CHART_PROPERTY_DOUBLE    double_values;
input string               keyword="debt";

//--- variable for storing the handle of the iMA indicator 
int    handle; 
//--- variable for storing 
string name=symbol; 
//--- name of the indicator on a chart 
string short_name; 
//--- we will keep the number of values in the GS Average indicator 
int    bars_calculated=0; 
//--- indicator buffers
double         GSBuffer[];
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
//--- indicator buffers mapping
   SetIndexBuffer(0,GSBuffer,INDICATOR_DATA);
//--- set shift 
   PlotIndexSetInteger(0,PLOT_SHIFT,ma_shift);    
//--- determine the symbol the indicator is drawn for   
   name=symbol; 
//--- delete spaces to the right and to the left 
   StringTrimRight(name); 
   StringTrimLeft(name); 
//--- if it results in zero length of the 'name' string 
   if(StringLen(name)==0) 
     { 
      //--- take the symbol of the chart the indicator is attached to 
      name=_Symbol; 
     } 
//--- create handle of the indicator 
   if(type==Call_GS) 
     { 
      //--- fill the structure with parameters of the indicator 
      MqlParam pars[4]; 
      //--- period 
      pars[0].type=TYPE_INT; 
      pars[0].integer_value=ma_period; 
      //--- shift 
      pars[1].type=TYPE_INT; 
      pars[1].integer_value=ma_shift; 
      //--- type of smoothing 
      pars[2].type=TYPE_INT; 
      pars[2].integer_value=ma_method; 
      //--- type of price 
      pars[3].type=TYPE_DOUBLE; 
      pars[3].double_value=last; 
      handle=IndicatorCreate(name,period,IND_MA,4,pars);
     }
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
        //--- tell about the failure and output the error code 
        PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d", 
                    name, 
                    EnumToString(period), 
                    GetLastError()); 
      //--- the indicator is stopped early 
        return(INIT_FAILED);
       }

     //--- show the symbol/timeframe the Moving Average indicator is calculated for 
   short_name=StringFormat("GS(%s/%s, %d, %d, %s, %s)",name,EnumToString(period), 
                           ma_period, ma_shift,EnumToString(ma_method),EnumToString(double_values)); 
   IndicatorSetString(INDICATOR_SHORTNAME,short_name); 
//--- normal initialization of the indicator 
     return(INIT_SUCCEEDED);
   }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   //--- number of values copied from the iMA indicator 
   int values_to_copy; 
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
//--- fill the iMABuffer array with values of the Moving Average indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(GSBuffer,ma_shift,handle,values_to_copy)) return(0); 
//--- form the message 
   string comm=StringFormat("%s ==>  Updated value in the indicator %s: %d", 
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS), 
                            short_name, 
                            values_to_copy); 
//--- display the service message on the chart 
   Comment(comm); 
//--- memorize the number of values in the Moving Average indicator 
   bars_calculated=calculated;  
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
   

//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the MA indicator                  | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &values[],   // indicator buffer of Moving Average values 
                         int shift,          // shift 
                         int ind_handle,     // handle of the iMA indicator 
                         int amount          // number of copied values 
                         ) 
  { 
//--- reset error code 
   ResetLastError(); 
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
//--- everything is fine 
   return(true); 
  }
  
void OnDeinit(const int reason) 
  { 
//--- clear the chart after deleting the indicator 
   Comment(""); 
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
//--- get the current value of the Moving Average indicator
   double lv;
   if(CopyBuffer(lv,0,0,1,current_number)!=1)
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