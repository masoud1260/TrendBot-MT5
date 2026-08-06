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
