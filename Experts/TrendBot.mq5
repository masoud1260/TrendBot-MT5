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
      trend
   );


}
