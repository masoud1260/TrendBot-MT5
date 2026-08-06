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

   // مرحله بعد:
   // 1- خواندن ADX
   // 2- تشخیص روند
   // 3- تشخیص رنج
   // 4- پیدا کردن پولبک

}
