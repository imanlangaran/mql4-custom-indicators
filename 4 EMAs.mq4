//+------------------------------------------------------------------+
//|                                       Custom Moving Averages.mq4 |
//|                   Copyright 2005-2015, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2015, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Average"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_color2 Blue
#property indicator_color3 Yellow
#property indicator_color4 Green
#property indicator_style1 STYLE_DOT
#property indicator_width4 2

//#property indicator_label2 "val2"

//--- indicator parameters
input int            InpMAPeriod1=15;        // Period1
input int            InpMAPeriod2=30;        // Period2
input int            InpMAPeriod3=60;        // Period3
input int            InpMAPeriod4=240;        // Period4
input ENUM_TIMEFRAMES InpTime = PERIOD_CURRENT; // TimeFrame

//--- indicator buffer
double ExtLineBuffer1[];
double ExtLineBuffer2[];
double ExtLineBuffer3[];
double ExtLineBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- indicator short name
   /*switch(InpMAMethod)
     {
      case MODE_SMA  : short_name="SMA(";                break;
      case MODE_EMA  : short_name="EMA(";  draw_begin=0; break;
      case MODE_SMMA : short_name="SMMA(";               break;
      case MODE_LWMA : short_name="LWMA(";               break;
      default :        return(INIT_FAILED);
     }*/
   //IndicatorShortName("EMA("+string(InpMAPeriod1)+","+string(InpMAPeriod2)+","+string(InpMAPeriod3)+","+string(InpMAPeriod4)+")");
   IndicatorDigits(Digits);
//--- check for input
   if(InpMAPeriod1<2 || InpMAPeriod2<2 || InpMAPeriod3<2 || InpMAPeriod4<2)
      return(INIT_FAILED);
//--- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexDrawBegin(0,0);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtLineBuffer1);
   SetIndexBuffer(1,ExtLineBuffer2);
   SetIndexBuffer(2,ExtLineBuffer3);
   SetIndexBuffer(3,ExtLineBuffer4);
   SetIndexLabel(0,"EMA("+string(InpMAPeriod1)+")");
   SetIndexLabel(1,"EMA("+string(InpMAPeriod2)+")");
   SetIndexLabel(2,"EMA("+string(InpMAPeriod3)+")");
   SetIndexLabel(3,"EMA("+string(InpMAPeriod4)+")");
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|  Moving Average                                                  |
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
//--- check for bars count
   /*if(rates_total<InpMAPeriod1-1 || InpMAPeriod1<2 || rates_total<InpMAPeriod2-1 || InpMAPeriod2<2 || rates_total<InpMAPeriod3-1 || InpMAPeriod3<2 || rates_total<InpMAPeriod4-1 || InpMAPeriod4<2)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtLineBuffer1,false);
   ArraySetAsSeries(ExtLineBuffer2,false);
   ArraySetAsSeries(ExtLineBuffer3,false);
   ArraySetAsSeries(ExtLineBuffer4,false);
   ArraySetAsSeries(close,false);
//--- first calculation or number of bars was changed
   if(prev_calculated==0){
      ArrayInitialize(ExtLineBuffer1,0);
      ArrayInitialize(ExtLineBuffer2,0);
      ArrayInitialize(ExtLineBuffer3,0);
      ArrayInitialize(ExtLineBuffer4,0);
   }*/
//--- calculation
   //CalculateEMA(rates_total,prev_calculated,close);
   
   
   int i,limit;
   
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
      
      
   
   for(i=0; i<limit; i++){
      
      ExtLineBuffer1[i] = iMA(Symbol(),InpTime,InpMAPeriod1,0,MODE_EMA,PRICE_MEDIAN,i);
      ExtLineBuffer2[i] = iMA(Symbol(),InpTime,InpMAPeriod2,0,MODE_EMA,PRICE_MEDIAN,i);
      ExtLineBuffer3[i] = iMA(Symbol(),InpTime,InpMAPeriod3,0,MODE_EMA,PRICE_MEDIAN,i);
      ExtLineBuffer4[i] = iMA(Symbol(),InpTime,InpMAPeriod4,0,MODE_EMA,PRICE_MEDIAN,i);

      
   }
   
   //Print(iBarShift(Symbol(),InpTime,iTime(Symbol(),PERIOD_CURRENT,14)) + "");
   
   
   
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  exponential moving average                                      |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,const double &price[])
  {
   int    i,limit;
   double SmoothFactor=2.0/(1.0+InpMAPeriod1);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=InpMAPeriod1;
      ExtLineBuffer1[0]=price[0];
      for(i=1; i<limit; i++)
         ExtLineBuffer1[i]=price[i]*SmoothFactor+ExtLineBuffer1[i-1]*(1.0-SmoothFactor);
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(i=limit; i<rates_total && !IsStopped(); i++)
      ExtLineBuffer1[i]=price[i]*SmoothFactor+ExtLineBuffer1[i-1]*(1.0-SmoothFactor);
//---
  }
//+------------------------------------------------------------------+
