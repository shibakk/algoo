//+------------------------------------------------------------------+
//|                                                    SENTIPlat.mq5 |
//|                              Copyright 2018, Kristian Shahbazian |
//|                                      https://www.trader-help.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Import                       |
//+------------------------------------------------------------------+
#import "include\Requests.mqh"
int RequestIndicator(void);
#import "include\Bools.mqh"
bool ConfirmTime();
bool IsExisting();
#import
//+------------------------------------------------------------------+
//| Global Var                    |
//+------------------------------------------------------------------+
datetime tm=TimeCurrent();

string file_name="URL.HTM"; // file name
int open_flags=FILE_CSV|FILE_ANSI;
int size=0;

//--- global variables
input double MaximumRisk = 0.02; // Max risk in %
input double DecreaseFactor = 0.03; // Decrease factor

//--- indicator buffer
double gs_buff[];
double current_number=0;
double last_value=0;
double average_value=0;

//--- integers used in loops
int i=0;
int a=0;

int file_handle=FileOpen(file_name,open_flags);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInIt(void)
  {
   //---
     ResetLastError();
     if(!IsExisting())
       {
        PrintFormat("Don't forget to add the URL to the list of allowed URLs (Main Menu->Tools->Options, tab Expert Advisors");
        PrintFormat("https://gist.githubusercontent.com/shibakk/0286699151490b4b91df035c37d02bdc/raw/8c67f0eb7ac09f875fa1158592977c1496cd6928/US");
        RequestIndicator();
       }
     else if(ConfirmTime())
       {
        PrintFormat("The robot is updating. Please wait.");
        RequestIndicator();
       }
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

void OnTrade(void)
  {
   //--- check the signals

//--- additional checks

//---
  }