//+------------------------------------------------------------------+
//|                                                     stoTest1.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrRed
#property indicator_color2 clrGreen
#property indicator_color3 clrAqua
#property indicator_color4 clrAqua

input int space = 20;

double mark_upside[];
double mark_downside[];
double hiden_upside[];
double hiden_downside[];


bool isFirstHigh = true;
bool isFirstLow = true;

const int HIGH = 5;
const int LOW = 6;
int lastOne;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
      SetIndexBuffer(0, mark_upside);
      SetIndexBuffer(1, mark_downside);
      SetIndexBuffer(2, hiden_upside);
      SetIndexBuffer(3, hiden_downside);
      SetIndexStyle(0, DRAW_ARROW);
      SetIndexStyle(1, DRAW_ARROW);
      SetIndexStyle(2, DRAW_ARROW);
      SetIndexStyle(3, DRAW_ARROW);
      SetIndexArrow(0,SYMBOL_ARROWDOWN);
      SetIndexArrow(1,SYMBOL_ARROWUP);
      SetIndexArrow(2,SYMBOL_ARROWDOWN);
      SetIndexArrow(3,SYMBOL_ARROWUP);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
      
/*    
      if(Volume[0] <= 1)
      {
         if(iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 2) > iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1) &&
            iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 2) > iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 3))
            {
               Print("top : " + (Minute() - 2));
               mark_upside[2] = high[2] + space * Point;
            }
          else if(iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 2) < iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1) &&
            iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 2) < iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 3))
            {
               Print("bottom : " + (Minute() - 2));
               mark_downside[2] = low[2] - space * Point;
            }
      }
*/
//      Print(rates_total, " - ", prev_calculated);
      for(int i = rates_total - prev_calculated - 1 ; i >= 0 ; i--){
         
         if(iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3) > iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+1) &&
            iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3) > iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+2) &&
            iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3) > iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+4) &&
            iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3) > iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+5))
            {
               //top
               mark_upside[i+3] = high[i+3] + space * Point;
//               Print(time[i+2], "-mark up i+2 : ", i+2, " : ", mark_upside[i+2], "-mark up i+3 : ", i+3, " : ", mark_upside[i+3]);
               
               if(isFirstHigh){
                  isFirstHigh = false;
               } else {
               
                  int last_high = 0;
                  for(int j = i+4 ; ; j++){
                     if(mark_upside[j] != 2147483647.0){
                        //Print(j);
                        last_high = j;
                        break;
                     }
                     else if(j == rates_total) 
                     { 
                        break;
                     }
                  }
                  
                  if(last_high != 0){
                     if(iMA(Symbol(), PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_MEDIAN, last_high) > iMA(Symbol(), PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_MEDIAN, i+3) &&
                        iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, last_high) < iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3)){
                           hiden_upside[i+3] = high[i+3] + (space+20) * Point;
                           /*Print(time[i+2], " - ",last_high," ",i+2,
                           "j iMA: ", NormalizeDouble(iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_MEDIAN, last_high), Digits+1),"  ",
                           "i+2 iMA: ", NormalizeDouble(iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_MEDIAN, i+2), Digits+1));*/
                        }
                  }
                  
               }
            }
          else if(iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3) < iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+1) &&
                  iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3) < iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+2) &&
                  iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3) < iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+4) &&
                  iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3) < iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+5))
            {
               //bottom
               mark_downside[i+3] = low[i+3] - space * Point;
               
               if(isFirstLow){
                  isFirstLow = false;
               } else {
                  int last_low = 0;
                  for(int j = i+4 ; ; j++){
                     if(mark_downside[j] != 2147483647.0){
                        //Print(j);
                        last_low = j;
                        break;
                     }
                     else if(j == rates_total) 
                     { 
                        break;
                     }
                  }
                  
                  if(last_low != 0){
                     if(iMA(Symbol(), PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_MEDIAN, last_low) < iMA(Symbol(), PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_MEDIAN, i+3) &&
                        iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, last_low) > iStochastic(Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i+3)){
                           hiden_downside[i+3] = low[i+3] - (space+20) * Point;
                           /*Print(time[i+2], " - ",last_low," ",i+2,
                           "j iMA: ", NormalizeDouble(iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_MEDIAN, last_low), Digits+1),"  ",
                           "i+2 iMA: ", NormalizeDouble(iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_MEDIAN, i+2), Digits+1));*/
                        }
                  }
                  
               }
            }
         
      }
            
//      mark_downside[1] = Low[1] - 50 * Point;

//      int bars=Bars(Symbol(),0); 
//      Print("Bars = ",bars,", rates_total = ",rates_total,",  prev_calculated = ",prev_calculated); 
//      Print("time[0] = ",time[0]," time[rates_total-1] = ",time[rates_total-1]); 

  
  
  return(rates_total);
  }
//+------------------------------------------------------------------+
