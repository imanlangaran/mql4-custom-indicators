//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Averages Convergence/Divergence"
#property strict

#include <MovingAverages.mqh>

//--- indicator settings

#property indicator_level1     0
#property indicator_levelcolor Silver
#property indicator_levelstyle STYLE_DOT




#property  indicator_separate_window
#property  indicator_buffers 6
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_color3  Red
#property  indicator_color4  Red
#property  indicator_color5  Green
#property  indicator_color6  Green
#property  indicator_width3  1
#property  indicator_width4  1
#property  indicator_width5  1
#property  indicator_width6  1
//--- indicator parameters
/*
input int InpFastEMA=12;   // Fast EMA Period
input int InpSlowEMA=26;   // Slow EMA Period
input int InpSignalSMA=9;  // Signal SMA Period
*/


int InpFastEMA=12;   // Fast EMA Period
int InpSlowEMA=26;   // Slow EMA Period
int InpSignalSMA=9;  // Signal SMA Period


//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;


//signal buffers
double    highDiver[];
double    highHiden[];
double    lowDiver[];
double    lowHiden[];




//parameters
int indicatorIndex;


#define maxHighs 50
#define maxLows maxHighs
#define EXTERMOMS 3


int highCounter = 0;
int lowCounter = 0;
int highs[maxHighs][2] = {0};
int lows[maxLows][2] = {0};


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,InpSignalSMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
   
   SetIndexBuffer(2,highDiver);
   SetIndexBuffer(3,highHiden);
   SetIndexBuffer(4,lowDiver);
   SetIndexBuffer(5,lowHiden);
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexStyle(5,DRAW_ARROW);
   
   SetIndexArrow(2,242);
   SetIndexArrow(3,226);
   SetIndexArrow(4,241);
   SetIndexArrow(5,225);
   
   
   ObjectsDeleteAll(0 , OBJ_TREND);
   ObjectsDeleteAll(0 , OBJ_ARROW);
   
   
   
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")div");
   indicatorIndex = WindowFind("MACD("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")div");
   
   
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"highDiver");
   SetIndexLabel(3,"highHiden");
   SetIndexLabel(4,"lowDiver");
   SetIndexLabel(5,"lowHiden");
//--- check for input parameters
   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<=1 || InpFastEMA>=InpSlowEMA)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
   int i,limit;
//---
   if(rates_total<=InpSignalSMA || !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++){
      ExtMacdBuffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)- iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
      
      if(i >= 8){
            
            if(ExtMacdBuffer[i-3] > ExtMacdBuffer[i-4] && 
               ExtMacdBuffer[i-3] > ExtMacdBuffer[i-5] && 
               ExtMacdBuffer[i-4] > ExtMacdBuffer[i-6] && 
               ExtMacdBuffer[i-4] > ExtMacdBuffer[i-7] && 
               ExtMacdBuffer[i-3] > ExtMacdBuffer[i-2] && 
               ExtMacdBuffer[i-3] > ExtMacdBuffer[i-1] && 
               ExtMacdBuffer[i-3] > ExtMacdBuffer[i] ){
               
                  
                  
                  if (highCounter!=maxHighs){
                     highs[highCounter][0] = i-3;
                     highs[highCounter][1] = 0;
                     highCounter++;
                     //highBuffer[i-3] = ExtMacdBuffer[i-3] + pnt;
                  }
                  
              }
              if(ExtMacdBuffer[i-3] < ExtMacdBuffer[i-4] && 
                 ExtMacdBuffer[i-3] < ExtMacdBuffer[i-5] && 
                 ExtMacdBuffer[i-4] < ExtMacdBuffer[i-6] && 
                 ExtMacdBuffer[i-4] < ExtMacdBuffer[i-7] && 
                 ExtMacdBuffer[i-3] < ExtMacdBuffer[i-2] && 
                 ExtMacdBuffer[i-3] < ExtMacdBuffer[i-1] && 
                 ExtMacdBuffer[i-3] < ExtMacdBuffer[i] ){
                 
                    
                  
                  if (lowCounter!=maxLows){
                     lows[lowCounter][0] = i-3;
                     lows[lowCounter][1] = 0;
                     lowCounter++;
                     //lowBuffer[i-3] = ExtMacdBuffer[i-3] - pnt;
                  }
                  
              }
            
         }
         else if(limit == 1){
            
            if(ExtMacdBuffer[5] > ExtMacdBuffer[4] && 
               ExtMacdBuffer[5] > ExtMacdBuffer[3] && 
               ExtMacdBuffer[4] > ExtMacdBuffer[2] && 
               ExtMacdBuffer[4] > ExtMacdBuffer[1] && 
               ExtMacdBuffer[5] > ExtMacdBuffer[6] && 
               ExtMacdBuffer[5] > ExtMacdBuffer[7] && 
               ExtMacdBuffer[5] > ExtMacdBuffer[8] &&
               highs[0][0] != 5){
                  
                  //Print("new high");
                  shiftHighs();
                  highs[0][0] = 5;
                  highs[0][1] = 0;
                  //if (indicatorArrows) highBuffer[5] = ExtMacdBuffer[5] + calculatePoint();
                  
             }
             
               if(ExtMacdBuffer[5] < ExtMacdBuffer[4] && 
                  ExtMacdBuffer[5] < ExtMacdBuffer[3] && 
                  ExtMacdBuffer[4] < ExtMacdBuffer[2] && 
                  ExtMacdBuffer[4] < ExtMacdBuffer[1] && 
                  ExtMacdBuffer[5] < ExtMacdBuffer[6] && 
                  ExtMacdBuffer[5] < ExtMacdBuffer[7] && 
                  ExtMacdBuffer[5] < ExtMacdBuffer[8] &&
                  lows[0][0] != 5){
                     
                     //Print("new low");
                     shiftLows();
                     lows[0][0] = 5;
                     lows[0][1] = 0;
                     //if (indicatorArrows) lowBuffer[5] = ExtMacdBuffer[5] - calculatePoint();
                     
                }
                
            
         }
      }






    for(int j0 = 0 ; j0 < maxHighs-1; j0++){
      
      if(highs[j0][1] == 0){
         highs[j0][1] = 1;
         
         int iohp0 = iHighest(NULL,0,MODE_HIGH,8,highs[j0][0]-4); //index of highest price 0
         
         for(int j1 = j0+1 ; j1 < j0+EXTERMOMS ; j1++){
            if(j1 == maxHighs) break;
            
            int iohp1 = iHighest(NULL,0,MODE_HIGH,8,highs[j1][0]-4); //index of highest price 1
            
            if(high[iohp0] > high[iohp1] &&
               ExtMacdBuffer[highs[j0][0]] < ExtMacdBuffer[highs[j1][0]] &&
               iHighest(NULL,0,MODE_HIGH,iohp1 - iohp0 + 1 , iohp0) == iohp0){   //Divergence in Highs
               
               highDiver[highs[j0][0]] = ExtMacdBuffer[highs[j0][0]];
                                  
                  //if(indicatorLines){
                     string n = string(indicatorIndex) + "diverhigh" + string(Time[highs[j0][0]]);
                     if(!(ObjectFind(n)>=0))
                     {
                        ObjectCreate(0, n, OBJ_TREND,0, Time[iohp0], high[iohp0], Time[iohp1], high[iohp1]);
                        ObjectSet(n, OBJPROP_RAY, false);
                        ObjectSet(n, OBJPROP_COLOR, clrRed);
                        ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                        ObjectSet(n,OBJPROP_SELECTABLE,false);
                        ObjectSet(n,OBJPROP_HIDDEN,true);
                     }
                  //}
                  
                  //if(indicatorArrows) highBuffer[highs[j0][0]] = ExtMacdBuffer[highs[j0][0]] + calculatePoint();
               
               
               
               break;
            }
            else if(high[iohp0] < high[iohp1] &&
                    ExtMacdBuffer[highs[j0][0]] > ExtMacdBuffer[highs[j1][0]] &&
                    iHighest(NULL,0,MODE_HIGH,iohp1 - iohp0 + 1 , iohp0) == iohp1){ // Hiden in Highs
                    
                    highHiden[highs[j0][0]] = ExtMacdBuffer[highs[j0][0]];
               
                        //if(indicatorLines){
                           string n = string(indicatorIndex) + "hidenhigh" + string(Time[highs[j0][0]]);
                           if(!(ObjectFind(n)>=0))
                           {
                              ObjectCreate(0, n, OBJ_TREND,0, Time[iohp0], high[iohp0], Time[iohp1], high[iohp1]);
                              ObjectSet(n, OBJPROP_RAY, false);
                              ObjectSet(n, OBJPROP_COLOR, clrRed);
                              ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_HIDDEN,true);
                           }
                        //}
                        
                        //if(indicatorArrows) highBuffer[highs[j0][0]] = ExtMacdBuffer[highs[j0][0]] + calculatePoint();
                     
                     
               
               break;
            }
         }
      }
      
      
      if(lows[j0][1] == 0){
         lows[j0][1] = 1;
         
         int iolp0 = iLowest(NULL,0,MODE_LOW,8,lows[j0][0]-4); //index of lowest price 0
         
         for(int j1 = j0+1 ; j1 < j0+EXTERMOMS ; j1++){
            if(j1 == maxLows) break;
            
            int iolp1 = iLowest(NULL,0,MODE_LOW,8,lows[j1][0]-4); //index of lowest price 1
            
            if(low[iolp0] < low[iolp1] &&
               ExtMacdBuffer[lows[j0][0]] > ExtMacdBuffer[lows[j1][0]] &&
               iLowest(NULL,0,MODE_LOW,iolp1 - iolp0 + 1 , iolp0) == iolp0){ // Divergence in Lows
               
               lowDiver[lows[j0][0]] = ExtMacdBuffer[lows[j0][0]];
               
                  //if(indicatorLines){
                     string n = string(indicatorIndex) + "diverlow" + string(Time[lows[j0][0]]);
                     if(!(ObjectFind(n)>=0))
                     {
                        ObjectCreate(0, n, OBJ_TREND,0, Time[iolp0], low[iolp0], Time[iolp1], low[iolp1]);
                        ObjectSet(n, OBJPROP_RAY, false);
                        ObjectSet(n, OBJPROP_COLOR, clrGreen);
                        ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                        ObjectSet(n,OBJPROP_SELECTABLE,false);
                        ObjectSet(n,OBJPROP_HIDDEN,true);
                     }
                  //}
                  
                  //if(indicatorArrows) lowBuffer[lows[j0][0]] = ExtMacdBuffer[lows[j0][0]] - calculatePoint();
                  
               
               
               break;
               
            }
            else if(low[iolp0] > low[iolp1] &&
                    ExtMacdBuffer[lows[j0][0]] < ExtMacdBuffer[lows[j1][0]] &&
                    iLowest(NULL,0,MODE_LOW,iolp1 - iolp0 + 1 , iolp0) == iolp1){ // Hiden in lows
                    
                    lowHiden[lows[j0][0]] = ExtMacdBuffer[lows[j0][0]];
                     
                    
               
                           //if(indicatorLines){
                              string n = string(indicatorIndex) + "hidenlow" + string(Time[lows[j0][0]]);
                              if(!(ObjectFind(n)>=0))
                              {
                                 ObjectCreate(0, n, OBJ_TREND,0, Time[iolp0], low[iolp0], Time[iolp1], low[iolp1]);
                                 ObjectSet(n, OBJPROP_RAY, false);
                                 ObjectSet(n, OBJPROP_COLOR, clrGreen);
                                 ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_HIDDEN,true);
                              }
                           //}
                           
                           //if(indicatorArrows) lowBuffer[lows[j0][0]] = ExtMacdBuffer[lows[j0][0]] - calculatePoint();
                     
               
               break;
            }
         }
      }
   }
   






//--- signal line counted in the 2-nd buffer
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+