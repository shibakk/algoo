//+------------------------------------------------------------------+
//|                                                   Quanta.mq4.mq4 |
//|                                      Copyright 2018,Trader-Help. |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018,Trader-Help."
#property link      "https://www.trader-help.com"
#property version   "1.00"

#property strict

int tot=0;
int inc=1;

input int    MovingPeriod  =1;
//+------------------------------------------------------------------+
//| Expert global vars                                               |
//+------------------------------------------------------------------+
int n=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
//---
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }

//+------------------------------------------------------------------+
//| Dybanuc Trade Size Optimization                                  |
//+------------------------------------------------------------------+
void CheckForClose(void)
  {
   double sun;
   double av;
   double average[5];
//--- go trading only for first tiks of new bar
   if(DayOfWeek()==0)
     {
      sun=iCustom(NULL,PERIOD_D1,"iQuanta",false,0,0);
     }
   if(DayOfWeek()!=0)
     {
      av+=iCustom(NULL,PERIOD_D1,"iQuanta",false,0,0);
      tot++;
      Print(av);
     }
   
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(Open[1]>sun && Close[1]<sun)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(Open[1]<sun && Close[1]>sun)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
     }
 }
  
void OnTick()
  {
//--- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false)
      return;
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForClose();
//---
  }