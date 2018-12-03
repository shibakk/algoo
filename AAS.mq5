//+------------------------------------------------------------------+
//|                                                          AAS.mq5 |
//|                                      Copyright 2018, Trader-Help |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Trader-Help"
#property link      "https://www.trader-help.com"
#property version   "1.00"
#property tester_indicator "123"
#property tester_file "debt-49.csv"
#property tester_file "debt-49-dates.csv"
#include <Trade\Trade.mqh>

input double MaximumRisk = 0.35; // Max risk in %

int                      ExtHandle=0;

int n=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//---
//---
   double mowq[];
   Print(ExtHandle=iCustom(_Symbol,_Period,"123"));
   CopyBuffer(ExtHandle,0,1,1,mowq);
   Print(mowq[0]);
   if(ExtHandle==INVALID_HANDLE)
     {
      printf("Error creating MA indicator");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
//---
   if(PositionSelect(_Symbol))
      CheckForClose();
   else
      CheckForOpen();
//---
  }
//+------------------------------------------------------------------+

void CheckForOpen(void)
  {
   MqlRates rt[2];
//--- copy the price values
   if(CopyRates(_Symbol,_Period,0,2,rt)!=2)
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }
//--- Trade only on the first tick of the new bar
   if(rt[1].tick_volume>1)
      return;
//--- Get the current value of the Moving Average indicator 
   double   cv[1];
   if(CopyBuffer(ExtHandle,0,1,1,cv)!=1)
     {
      Print("CopyBuffer from indicator failed, no data");
      return;
     }
//--- Get the current value of the Moving Average indicator 
   double   wv[1];
   if(CopyBuffer(ExtHandle,0,2,1,wv)!=1)
     {
      Print("CopyBuffer from indicator failed, no data");
      return;
     }
//---    for(int a=1;a>7;a++)
//---      {
//---       average=wv[n+a]/6;
//---      }
//--- check the signals
   ENUM_ORDER_TYPE signal=WRONG_VALUE;
   if(cv[0]>wv[0])
      signal=ORDER_TYPE_SELL;    // sell condition
   else
     {
      if(cv[0]<wv[0])
         signal=ORDER_TYPE_BUY;  // buy condition
     }
//--- additional checks
   if(signal!=WRONG_VALUE)
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
         if(Bars(NULL,0)>1)
           {
            CTrade trade;
            trade.PositionOpen(_Symbol,signal,TradeSizeOptimized(),
                               SymbolInfoDouble(_Symbol,signal==ORDER_TYPE_SELL ? SYMBOL_BID:SYMBOL_ASK),
                               0,0);
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForClose(void)
  {
   MqlRates rt[2];
//--- Copy price values
   if(CopyRates(_Symbol,_Period,0,2,rt)!=2)
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }
//--- Trade only on the first tick o the new bar
   if(rt[1].tick_volume>1)
      return;
//--- Get the current value of the Moving Average indicator 
   double   cv[1];
   if(CopyBuffer(ExtHandle,0,1,1,cv)!=1)
     {
      Print("CopyBuffer from indicator failed, no data");
      return;
     }
//--- Get the current value of the Moving Average indicator
   double wv[];
   if(CopyBuffer(ExtHandle,0,2,1,wv)!=1)
     {
      Print("CopyBuffer from indicator failed, no data");
      return;
     }
//--- get the type of the position selected earlier using PositionSelect()
   bool signal=false;
   long type=PositionGetInteger(POSITION_TYPE);

   if(type==(long)POSITION_TYPE_BUY && cv[0]<wv[0])
      signal=true;
   if(type==(long)POSITION_TYPE_SELL && cv[0]>wv[0])
      signal=true;
//--- additional checks
   if(signal)
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
         if(Bars(_Symbol,_Period)>100)
           {
            CTrade trade;
            trade.PositionClose(_Symbol,3);
           }
//---
  }
//+------------------------------------------------------------------+
