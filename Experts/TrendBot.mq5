//+------------------------------------------------------------------+
//|                                                   TrendBot.mq5    |
//|                         TrendBot-MT5 Project                     |
//+------------------------------------------------------------------+

#property copyright "Masoud"
#property version   "0.1"
#property strict

//--- Inputs
input ENUM_TIMEFRAMES TradeTimeframe = PERIOD_M5;

input int ADX_Period = 14;
input double ADX_Minimum = 23;
input int RangeBars = 30;
input int ATR_Period = 14;
input double MaxRangeATR = 1.2;
input double BreakoutBuffer = 2;
input double PullbackPips = 2;
input double EntryOffsetPips = 3;
input double StopOffsetPips = 2;
input double RiskReward = 1.6;
input int EMA_Fast = 50;
input int EMA_Slow = 200;
input bool EnableSignals = true;
input int MajorLookbackBars = 192;
input int SwingStrength = 3;
//--- Handles
int adxHandle;
int emaFastHandle;
int emaSlowHandle;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   adxHandle = iADX(_Symbol, TradeTimeframe, ADX_Period);

   emaFastHandle = iMA(
      _Symbol,
      TradeTimeframe,
      EMA_Fast,
      0,
      MODE_EMA,
      PRICE_CLOSE
   );

   emaSlowHandle = iMA(
      _Symbol,
      TradeTimeframe,
      EMA_Slow,
      0,
      MODE_EMA,
      PRICE_CLOSE
   );


   if(adxHandle == INVALID_HANDLE ||
      emaFastHandle == INVALID_HANDLE ||
      emaSlowHandle == INVALID_HANDLE)
   {
      Print("Indicator initialization failed");
      return INIT_FAILED;
   }


   Print("TrendBot started successfully");

   return INIT_SUCCEEDED;
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool IsMarketRange()
{

   double highPrices[];
   double lowPrices[];
   double atrValue[];


   ArraySetAsSeries(highPrices,true);
   ArraySetAsSeries(lowPrices,true);
   ArraySetAsSeries(atrValue,true);


   CopyHigh(_Symbol,TradeTimeframe,0,RangeBars,highPrices);
   CopyLow(_Symbol,TradeTimeframe,0,RangeBars,lowPrices);


   int atrHandle = iATR(
      _Symbol,
      TradeTimeframe,
      ATR_Period
   );


   CopyBuffer(
      atrHandle,
      0,
      0,
      2,
      atrValue
   );


   double highest = highPrices[ArrayMaximum(highPrices)];
   double lowest  = lowPrices[ArrayMinimum(lowPrices)];


   double rangeSize = highest - lowest;


   if(rangeSize <= atrValue[0] * MaxRangeATR)
   {
      return true;
   }


   return false;

}
int CheckRangeBreakout()
{

   double highs[];
   double lows[];
   double closes[];


   ArraySetAsSeries(highs,true);
   ArraySetAsSeries(lows,true);
   ArraySetAsSeries(closes,true);


   CopyHigh(_Symbol,TradeTimeframe,1,RangeBars,highs);
   CopyLow(_Symbol,TradeTimeframe,1,RangeBars,lows);
   CopyClose(_Symbol,TradeTimeframe,0,3,closes);



   double rangeHigh = highs[ArrayMaximum(highs)];
   double rangeLow  = lows[ArrayMinimum(lows)];



   double lastClose = closes[1];



   // شکست صعودی

   if(lastClose > rangeHigh + BreakoutBuffer * _Point)
   {
      return 1;
   }



   // شکست نزولی

   if(lastClose < rangeLow - BreakoutBuffer * _Point)
   {
      return -1;
   }



   return 0;

}
int CheckCandlePullback()
{

   double highs[3];
   double lows[3];
   double closes[3];


   ArraySetAsSeries(highs,true);
   ArraySetAsSeries(lows,true);
   ArraySetAsSeries(closes,true);


   CopyHigh(_Symbol,TradeTimeframe,0,3,highs);
   CopyLow(_Symbol,TradeTimeframe,0,3,lows);
   CopyClose(_Symbol,TradeTimeframe,0,3,closes);



   double pip = _Point * 10;



   // پولبک خرید
   if(lows[1] <= lows[2] - PullbackPips * pip)
   {
      return 1;
   }



   // پولبک فروش
   if(highs[1] >= highs[2] + PullbackPips * pip)
   {
      return -1;
   }


   return 0;

}

void CreateSignal(int direction)
{

   double highs[3];
   double lows[3];


   ArraySetAsSeries(highs,true);
   ArraySetAsSeries(lows,true);


   CopyHigh(_Symbol,TradeTimeframe,0,3,highs);
   CopyLow(_Symbol,TradeTimeframe,0,3,lows);



   double pip = _Point * 10;



   double entry;
   double stop;
   double take;



   if(direction == 1)
   {

      entry = highs[1] + EntryOffsetPips * pip;

      stop = lows[1] - StopOffsetPips * pip;

      double risk = entry - stop;

      take = entry + risk * RiskReward;
DrawSignal(1,entry,stop,take);
if(!CheckMajorLevel(1,take))
{
   Print("BUY rejected: Major M15 resistance");
   return;
}
      Print(
      "BUY SIGNAL",
      " Entry: ",
      entry,
      " SL: ",
      stop,
      " TP: ",
      take
      );

   }



   if(direction == -1)
   {

      entry = lows[1] - EntryOffsetPips * pip;

      stop = highs[1] + StopOffsetPips * pip;

      double risk = stop - entry;

      take = entry - risk * RiskReward;
DrawSignal(-1,entry,stop,take);
if(!CheckMajorLevel(-1,take))
{
   Print("SELL rejected: Major M15 support");
   return;
}
      Print(
      "SELL SIGNAL",
      " Entry: ",
      entry,
      " SL: ",
      stop,
      " TP: ",
      take
      );

   }

}
void DrawSignal(
   int direction,
   double entry,
   double stop,
   double take
)
{

   string timeName =
   IntegerToString(TimeCurrent());


   string arrowName =
   "SignalArrow_" + timeName;



   datetime signalTime =
   iTime(_Symbol,TradeTimeframe,1);



   if(direction==1)
   {

      ObjectCreate(
         0,
         arrowName,
         OBJ_ARROW,
         0,
         signalTime,
         iLow(_Symbol,TradeTimeframe,1)
      );


      ObjectSetInteger(
         0,
         arrowName,
         OBJPROP_ARROWCODE,
         233
      );

   }



   if(direction==-1)
   {

      ObjectCreate(
         0,
         arrowName,
         OBJ_ARROW,
         0,
         signalTime,
         iHigh(_Symbol,TradeTimeframe,1)
      );


      ObjectSetInteger(
         0,
         arrowName,
         OBJPROP_ARROWCODE,
         234
      );

   }



   // خط ورود

   ObjectCreate(
      0,
      "ENTRY_"+timeName,
      OBJ_HLINE,
      0,
      0,
      entry
   );


   // حد ضرر

   ObjectCreate(
      0,
      "SL_"+timeName,
      OBJ_HLINE,
      0,
      0,
      stop
   );


   // حد سود

   ObjectCreate(
      0,
      "TP_"+timeName,
      OBJ_HLINE,
      0,
      0,
      take
   );

}
double GetMajorHigh()
{

   for(int i=SwingStrength+1; i<MajorLookbackBars-SwingStrength; i++)
   {

      double high=iHigh(_Symbol,PERIOD_M15,i);

      bool valid=true;


      for(int j=1;j<=SwingStrength;j++)
      {

         if(high <= iHigh(_Symbol,PERIOD_M15,i-j) ||
            high <= iHigh(_Symbol,PERIOD_M15,i+j))
         {
            valid=false;
            break;
         }

      }


      if(valid)
         return high;

   }


   return 0;

}



double GetMajorLow()
{

   for(int i=SwingStrength+1; i<MajorLookbackBars-SwingStrength; i++)
   {

      double low=iLow(_Symbol,PERIOD_M15,i);

      bool valid=true;


      for(int j=1;j<=SwingStrength;j++)
      {

         if(low >= iLow(_Symbol,PERIOD_M15,i-j) ||
            low >= iLow(_Symbol,PERIOD_M15,i+j))
         {
            valid=false;
            break;
         }

      }


      if(valid)
         return low;

   }


   return 0;

}
bool CheckMajorLevel(int direction,double take)
{

   double majorHigh = GetMajorHigh();
   double majorLow  = GetMajorLow();



   if(direction==1)
   {

      if(majorHigh>0 && take >= majorHigh)
      {
         return false;
      }

   }



   if(direction==-1)
   {

      if(majorLow>0 && take <= majorLow)
      {
         return false;
      }

   }


   return true;

}
void OnTick()
{

   double adxValue[];
   double emaFast[];
   double emaSlow[];


   ArraySetAsSeries(adxValue,true);
   ArraySetAsSeries(emaFast,true);
   ArraySetAsSeries(emaSlow,true);


   CopyBuffer(adxHandle,0,0,3,adxValue);
   CopyBuffer(emaFastHandle,0,0,3,emaFast);
   CopyBuffer(emaSlowHandle,0,0,3,emaSlow);



   double currentADX = adxValue[0];

   string trend = "NO TREND";
bool ranging = IsMarketRange();
int breakout = CheckRangeBreakout();
int pullback = CheckCandlePullback();
if(EnableSignals)
{

   if(!ranging && breakout==1 && pullback==1 && trend=="BULLISH")
   {
      CreateSignal(1);
   }



   if(!ranging && breakout==-1 && pullback==-1 && trend=="BEARISH")
   {
      CreateSignal(-1);
   }

}
   if(currentADX >= ADX_Minimum)
   {

      if(emaFast[0] > emaSlow[0])
      {
         trend = "BULLISH";
      }

      else if(emaFast[0] < emaSlow[0])
      {
         trend = "BEARISH";
      }

   }


Comment(
"TrendBot\n",
"ADX: ",
DoubleToString(currentADX,2),
"\n",
"Trend: ",
trend,
"\n",
"Range: ",
ranging ? "YES" : "NO"
);
   );

"\nBreakout: ",
breakout==1 ? "BUY BREAK" :
breakout==-1 ? "SELL BREAK" : "NONE"
"\nPullback: ",
pullback==1 ? "BUY PB" :
pullback==-1 ? "SELL PB" : "NONE"
}
