//+------------------------------------------------------------------+
//|                                                   Quanta.mq4.mq4 |
//|                                      Copyright 2018,Trader-Help. |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018,Trader-Help."
#property link      "https://www.trader-help.com"
#property version   "1.00"

#property strict
#property tester_indicator "iQuanta"
#property tester_file "QuantaI.HTM"
#property tester_file "QuantaIAverage.HTM"
#property tester_file "QuantaDate.HTM"

#define MAGICMA  20131111

//--- Inputs
input double Lots           =0.1;
input double MaximumRisk    =0.02;
input double DecreaseFactor =3;

string iAddress="https://trader-help.com/mt4/";

datetime allowed_until = D'2019.01.27 00:00'; 
                             
int password_status = -1;

void CallForI(void)
  {
   string cookie=NULL,headers; 
   char post[],result[]; 
   int res; 
//--- to enable access to the server, you should add URL "https://www.google.com/finance" 
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"): 
   string indic="https://trader-help.com/mt4/debt.csv"; 
//--- Reset the last error code 
   ResetLastError(); 
//--- Loading a html page from Google Finance 
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection 
   res=WebRequest("GET",indic,cookie,NULL,timeout,post,0,result,headers);
//--- Checking errors 
   if(res==-1) 
     { 
      //---Print("Error in WebRequest. Error code  =",GetLastError()); 
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
      MessageBox("Make sure to allow WebRequest for listed URLs. Tools->Options->Expert Advisors","Error",MB_ICONINFORMATION);
      MessageBox("Add the address '"+iAddress+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);    
     } 
   else 
     { 
      //--- Load successfully 
      //---PrintFormat("No Errors, Quanta Should be Working"); 
      //--- Save the data to a file 
      int filehandle=FileOpen("QuantaI.HTM",FILE_WRITE|FILE_BIN); 
      //--- Checking errors 
      if(filehandle!=INVALID_HANDLE) 
        { 
         //--- Save the contents of the result[] array to a file 
         FileWriteArray(filehandle,result,0,ArraySize(result)); 
         //--- Close the file 
         FileClose(filehandle); 
        } 
      else Print("Please, DO NOT STOP Quanta"); 
     } 
  }

void CallForIAverage(void)
  {
   string cookie=NULL,headers; 
   char post[],result[]; 
   int res; 
//--- to enable access to the server, you should add URL "https://www.google.com/finance" 
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"): 
   string indic_av="https://trader-help.com/mt4/debt-average.csv"; 
//--- Reset the last error code 
   ResetLastError(); 
//--- Loading a html page from Google Finance 
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection 
   res=WebRequest("GET",indic_av,cookie,NULL,timeout,post,0,result,headers);
//--- Checking errors 
   if(res==-1) 
     { 
      Print("Error in WebRequest. Error code  =",GetLastError()); 
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
     } 
   else 
     { 
      //--- Load successfully 
      //---PrintFormat("No Errors, Quanta Should be Working"); 
      //--- Save the data to a file 
      int filehandleav=FileOpen("QuantaIAverage.HTM",FILE_WRITE|FILE_BIN); 
      //--- Checking errors 
      if(filehandleav!=INVALID_HANDLE) 
        { 
         //--- Save the contents of the result[] array to a file 
         FileWriteArray(filehandleav,result,0,ArraySize(result)); 
         //--- Close the file 
         FileClose(filehandleav); 
        } 
      //---else Print("Please, DO NOT STOP Quanta"); 
     } 
  }

void CallForIDate(void)
  {
   string cookie=NULL,headers; 
   char post[],result[]; 
   int res; 
//--- to enable access to the server, you should add URL "https://www.google.com/finance" 
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"): 
   string indic_dt="https://trader-help.com/mt4/debt-date.csv"; 
//--- Reset the last error code 
   ResetLastError(); 
//--- Loading a html page from Google Finance 
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection 
   res=WebRequest("GET",indic_dt,cookie,NULL,timeout,post,0,result,headers);
//--- Checking errors 
   if(res==-1) 
     { 
      //---Print("Error in WebRequest. Error code  =",GetLastError()); 
     } 
   else 
     { 
      //--- Load successfully 
      //---PrintFormat("No Errors, Quanta Should be Working"); 
      //--- Save the data to a file 
      int filehandledt=FileOpen("QuantaDate.HTM",FILE_WRITE|FILE_BIN); 
      //--- Checking errors 
      if(filehandledt!=INVALID_HANDLE) 
        { 
         //--- Save the contents of the result[] array to a file 
         FileWriteArray(filehandledt,result,0,ArraySize(result)); 
         //--- Close the file 
         FileClose(filehandledt); 
        } 
      //---else Print("Please, DO NOT STOP Quanta"); 
     } 
  }

int OnInit()
  {
  //---
   //---printf("This EA is valid until %s", TimeToString(allowed_until, TIME_DATE|TIME_MINUTES));
   datetime now = TimeCurrent();
   
   if (now < allowed_until) 
         Print("EA time limit verified, EA init time : " + TimeToString(now, TIME_DATE|TIME_MINUTES));
//---
   return(0);
   //---CallForIDate();
   //---CallForI();
   //---CallForIAverage();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
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
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/100.0,1);
//--- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
           {
            Print("Error in history!");
            break;
           }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
            continue;
         //---
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- return lot size
   if(lot<0.1) lot=0.1;
   return(lot);
  }

//-------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   double ind;
   double ind_av;
   double vask = MarketInfo(NULL,MODE_ASK);
   double tkprofit = vask * 1.1;
   double tkloss = vask * 0.90;
//--- go trading only for first tiks of new bar
   ind=iCustom(NULL,0,"iQuanta",false,0,0);
   ind_av=iCustom(NULL,0,"iQuanta",false,1,0);
   int    res;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- sell conditions
   if(ind>ind_av)
     {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",0,0,Red);
      return;
     }
//--- buy conditions
   if(ind<ind_av)
     {
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",0,0,Blue);
      return;
     }
//---
  }

void CheckForClose()
  {
   double ind;
   double ind_av;
   double vask    = MarketInfo(NULL,MODE_ASK);
   //--- go trading only for first tiks of new bar
   ind=iCustom(NULL,0,"iQuanta",false,0,0);
   ind_av=iCustom(NULL,0,"iQuanta",false,1,0);
   //---
   if(Volume[0]>1) return;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(ind<ind_av)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(ind>ind_av)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
     }
 }
  
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   if (TimeCurrent() < allowed_until) 
     {        
      //--- check for history and trading
      if(Bars<100 || IsTradeAllowed()==false)
         return;
      //---printf("This EA is valid until %s", TimeToString(allowed_until, TIME_DATE|TIME_MINUTES));
      CallForIDate();
      CallForI();
      CallForIAverage();
      //--- calculate open orders by current symbol
      if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
      else                                    CheckForClose();
     }
   else Print("EA expired."); 
  }