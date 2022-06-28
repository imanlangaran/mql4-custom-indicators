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
#property  indicator_buffers 4
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_width1  1


#property  indicator_color3  Red
#property  indicator_color4  Green

#property  indicator_width3  1
#property  indicator_width4  1

input bool indicatorLines = true; // Indicator Lines
input bool indicatorArrows = true; // Indicator Arrows

input bool sendEmail = false; // Send Email
input bool sendNotification = false; // Send Notification
input bool soundAlert = false; //Sound Alert

//--- indicator parameters
input int InpFastEMA=12;   // Fast EMA Period
input int InpSlowEMA=26;   // Slow EMA Period
input int InpSignalSMA=9;  // Signal SMA Period


//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
double    highBuffer[];
double    lowBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;



#define maxHighs 50
#define maxLows maxHighs

#define EXTERMOMS 3




int highs[maxHighs][2] = {0};
int highCounter = 0;
int lows[maxLows][2] = {0};
int lowCounter = 0;



int indicatorIndex;
bool SHOW = false;
bool SHOWDOWN = true;
bool SHOWHIGH = true;
datetime lastNotif;
/*
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
   if (id == CHARTEVENT_CHART_CHANGE){
      
      double t = pnt;
      pnt = 15*((ChartGetDouble(0,CHART_FIXED_MAX,indicatorIndex)-ChartGetDouble(0,CHART_FIXED_MIN,indicatorIndex))/100);
      
      if(MathAbs(t - pnt)>pnt){
         
         RefreshRates();
         
      }
      
   }
  }*/


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
   
   
   
   SetIndexBuffer(2,highBuffer);
   SetIndexBuffer(3,lowBuffer);
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,234);
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,233);
   
//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD-V3("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   
   indicatorIndex = WindowFind("MACD-V3("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+")");
   
   
   ObjectsDeleteAll(indicatorIndex , OBJ_TREND);
   ObjectsDeleteAll(indicatorIndex , OBJ_ARROW);
   
   
   
   
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"high");
   SetIndexLabel(3,"low");
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
         ExtMacdBuffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
         
         if(i >= 8){
            
            if(ExtMacdBuffer[i-3] > ExtMacdBuffer[i-4] && 
               ExtMacdBuffer[i-3] > ExtMacdBuffer[i-5] && 
               ExtMacdBuffer[i-4] > ExtMacdBuffer[i-6] && 
               ExtMacdBuffer[i-4] > ExtMacdBuffer[i-7] && 
               ExtMacdBuffer[i-3] > ExtMacdBuffer[i-2] && 
               ExtMacdBuffer[i-3] > ExtMacdBuffer[i-1] && 
               ExtMacdBuffer[i-3] > ExtMacdBuffer[i] ){
                  
                  //if (indicatorArrows) highBuffer[i-3] = ExtMacdBuffer[i-3] + calculatePoint();
                  
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
            
                  //if (indicatorArrows) lowBuffer[i-3] = ExtMacdBuffer[i-3] - calculatePoint();
                  
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
   
   
   
   //--------------------------------------------------------------------------------------------------------
   if(!(ObjectFind("downArrowFor"+string(indicatorIndex))>=0)){
      ObjectDelete(0,"downArrowFor"+string(indicatorIndex));
      ObjectCreate(0,"downArrowFor"+string(indicatorIndex), OBJ_ARROW,indicatorIndex,Time[0],ChartGetDouble(0,CHART_FIXED_MIN,indicatorIndex)/2);
      ObjectSetInteger(0,"downArrowFor"+string(indicatorIndex), OBJPROP_ARROWCODE,228);
      ObjectSet("downArrowFor"+string(indicatorIndex),OBJPROP_SELECTABLE,false);
      ObjectSet("downArrowFor"+string(indicatorIndex),OBJPROP_COLOR,clrGreen);
      ObjectSet("downArrowFor"+string(indicatorIndex),OBJPROP_ANCHOR,ANCHOR_TOP);
      //ObjectSetDouble(0,"downArrowFor"+string(indicatorIndex),OBJPROP_PRICE,ChartGetDouble(0,CHART_FIXED_MIN,indicatorIndex)/2);
   }
   if(!(ObjectFind("upArrowFor"+string(indicatorIndex))>=0)){
      ObjectDelete(0,"upArrowFor"+string(indicatorIndex));
      ObjectCreate(0,"upArrowFor"+string(indicatorIndex), OBJ_ARROW,indicatorIndex,Time[0],ChartGetDouble(0,CHART_FIXED_MAX,indicatorIndex)/2);
      ObjectSetInteger(0,"upArrowFor"+string(indicatorIndex), OBJPROP_ARROWCODE,230);
      ObjectSet("upArrowFor"+string(indicatorIndex),OBJPROP_SELECTABLE,false);
      ObjectSet("upArrowFor"+string(indicatorIndex),OBJPROP_COLOR,clrRed);
      ObjectSet("upArrowFor"+string(indicatorIndex),OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      //ObjectSetDouble(0,"downArrowFor"+string(indicatorIndex),OBJPROP_PRICE,ChartGetDouble(0,CHART_FIXED_MIN,indicatorIndex)/2);
   }
   
   //--------------------------------------------------------------------------------------------------------
   if(IsNewCandle()){
      updateIndexes();
      ObjectSetInteger(0,"downArrowFor"+string(indicatorIndex), OBJPROP_TIME,Time[0]);
      ObjectSetDouble(0,"downArrowFor"+string(indicatorIndex),OBJPROP_PRICE,MathMin((ChartGetDouble(0,CHART_FIXED_MIN,indicatorIndex))/2,ExtMacdBuffer[0]-calculatePoint()));
      
      ObjectSetInteger(0,"upArrowFor"+string(indicatorIndex), OBJPROP_TIME,Time[0]);
      ObjectSetDouble(0,"upArrowFor"+string(indicatorIndex),OBJPROP_PRICE,MathMax((ChartGetDouble(0,CHART_FIXED_MAX,indicatorIndex))/2,ExtMacdBuffer[0]+calculatePoint()));
      

      ObjectDelete(string(indicatorIndex) + "hidenhighT" + string(Time[2]));
      ObjectDelete(string(indicatorIndex) + "diverhighT" + string(Time[2]));
   
      ObjectDelete(string(indicatorIndex) + "hidenlowT" + string(Time[2]));
      ObjectDelete(string(indicatorIndex) + "diverlowT" + string(Time[2]));
   }
   
   
   //--------------------------------------------------------------------------------------------------------
   
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
               
                                    
                  if(indicatorLines){
                     string n = string(indicatorIndex) + "diverhigh" + string(Time[highs[j0][0]]);
                     if(!(ObjectFind(n)>=0))
                     {
                        ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[highs[j0][0]], ExtMacdBuffer[highs[j0][0]], Time[highs[j1][0]], ExtMacdBuffer[highs[j1][0]]);
                        ObjectSet(n, OBJPROP_RAY, false);
                        ObjectSet(n, OBJPROP_COLOR, clrRed);
                        ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                        ObjectSet(n,OBJPROP_SELECTABLE,false);
                        ObjectSet(n,OBJPROP_HIDDEN,false);
                     }
                  }
                  
                  if(indicatorArrows) highBuffer[highs[j0][0]] = ExtMacdBuffer[highs[j0][0]] + calculatePoint();
               
               
               
               break;
            }
            else if(high[iohp0] < high[iohp1] &&
                    ExtMacdBuffer[highs[j0][0]] > ExtMacdBuffer[highs[j1][0]] &&
                    iHighest(NULL,0,MODE_HIGH,iohp1 - iohp0 + 1 , iohp0) == iohp1){ // Hiden in Highs
                    
               
                        if(indicatorLines){
                           string n = string(indicatorIndex) + "hidenhigh" + string(Time[highs[j0][0]]);
                           if(!(ObjectFind(n)>=0))
                           {
                              ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[highs[j0][0]], ExtMacdBuffer[highs[j0][0]], Time[highs[j1][0]], ExtMacdBuffer[highs[j1][0]]);
                              ObjectSet(n, OBJPROP_RAY, false);
                              ObjectSet(n, OBJPROP_COLOR, clrRed);
                              ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_HIDDEN,false);
                           }
                        }
                        
                        if(indicatorArrows) highBuffer[highs[j0][0]] = ExtMacdBuffer[highs[j0][0]] + calculatePoint();
                     
                     
               
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
               
               
               
                  if(indicatorLines){
                     string n = string(indicatorIndex) + "diverlow" + string(Time[lows[j0][0]]);
                     if(!(ObjectFind(n)>=0))
                     {
                        ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[lows[j0][0]], ExtMacdBuffer[lows[j0][0]], Time[lows[j1][0]], ExtMacdBuffer[lows[j1][0]]);
                        ObjectSet(n, OBJPROP_RAY, false);
                        ObjectSet(n, OBJPROP_COLOR, clrGreen);
                        ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                        ObjectSet(n,OBJPROP_SELECTABLE,false);
                        ObjectSet(n,OBJPROP_HIDDEN,false);
                     }
                  }
                  
                  if(indicatorArrows) lowBuffer[lows[j0][0]] = ExtMacdBuffer[lows[j0][0]] - calculatePoint();
                  
               
               
               break;
               
            }
            else if(low[iolp0] > low[iolp1] &&
                    ExtMacdBuffer[lows[j0][0]] < ExtMacdBuffer[lows[j1][0]] &&
                    iLowest(NULL,0,MODE_LOW,iolp1 - iolp0 + 1 , iolp0) == iolp1){ // Hiden in lows
                    
                    
               
                           if(indicatorLines){
                              string n = string(indicatorIndex) + "hidenlow" + string(Time[lows[j0][0]]);
                              if(!(ObjectFind(n)>=0))
                              {
                                 ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[lows[j0][0]], ExtMacdBuffer[lows[j0][0]], Time[lows[j1][0]], ExtMacdBuffer[lows[j1][0]]);
                                 ObjectSet(n, OBJPROP_RAY, false);
                                 ObjectSet(n, OBJPROP_COLOR, clrGreen);
                                 ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_HIDDEN,false);
                              }
                           }
                           
                           if(indicatorArrows) lowBuffer[lows[j0][0]] = ExtMacdBuffer[lows[j0][0]] - calculatePoint();
                     
               
               break;
            }
         }
      }
   }
   
   
   
   //--------------------------------------------------------------------------------------------------------
   for(int j1 = 0 ; j1 < EXTERMOMS ; j1++){
            if(j1 == maxHighs) break;
            
            int iohp1 = iHighest(NULL,0,MODE_HIGH,8,highs[j1][0]-4); //index of highest price 1
            
            int iohp0 = iHighest(NULL,0,MODE_HIGH,4,0); //index of highest price 0
            
   
            if(high[iohp0] > high[iohp1] &&
               ExtMacdBuffer[0] < ExtMacdBuffer[highs[j1][0]] &&
               iHighest(NULL,0,MODE_HIGH,iohp1 + 1 - iohp0 , iohp0) == iohp0 &&
               ExtMacdBuffer[0] < ExtMacdBuffer[1]  &&
               ExtMacdBuffer[1] > ExtMacdBuffer[3]){   //Divergence in Highs
               
                  
                  if(indicatorLines){
                     string n = string(indicatorIndex) + "diverhighT" + string(Time[1]);
                     if(!(ObjectFind(n)>=0))
                     {
                        ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[1], ExtMacdBuffer[1], Time[highs[j1][0]], ExtMacdBuffer[highs[j1][0]]);
                        ObjectSet(n, OBJPROP_RAY, false);
                        ObjectSet(n, OBJPROP_COLOR, clrRed);
                        ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                        ObjectSet(n,OBJPROP_SELECTABLE,false);
                        ObjectSet(n,OBJPROP_HIDDEN,false);
                     }
                  }
                                       
                  SHOWHIGH = true;
                  
                  if(lastNotif == time[1]) lastNotif = time[0];
                  if(lastNotif != time[0]){
                     lastNotif = time[0];
                     notify(Symbol() + "," + getPeriodInString() +  " : \n" + "Diver - High - " + string(time[0]));
                  }
               
               
               
               
               
               break;
            }
            else if(high[iohp0] < high[iohp1] &&
                 ExtMacdBuffer[0] > ExtMacdBuffer[highs[j1][0]] &&
                 iHighest(NULL,0,MODE_HIGH,iohp1 + 1 - iohp0 , iohp0) == iohp1 &&
                 ExtMacdBuffer[0] < ExtMacdBuffer[1]  &&
                 ExtMacdBuffer[1] > ExtMacdBuffer[3]){ // Hiden in Highs
                 
                 
                 
                       
                     if(indicatorLines){
                        string n = string(indicatorIndex) + "hidenhighT" + string(Time[1]);
                        if(!(ObjectFind(n)>=0))
                        {
                           ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[1], ExtMacdBuffer[1], Time[highs[j1][0]], ExtMacdBuffer[highs[j1][0]]);
                           ObjectSet(n, OBJPROP_RAY, false);
                           ObjectSet(n, OBJPROP_COLOR, clrRed);
                           ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                           ObjectSet(n,OBJPROP_SELECTABLE,false);
                           ObjectSet(n,OBJPROP_HIDDEN,false);
                        }
                     }
                     
                     SHOWHIGH = true;
                     
                     if(lastNotif == time[1]) lastNotif = time[0];
                     if(lastNotif != time[0]){
                        lastNotif = time[0];
                        notify(Symbol() + "," + getPeriodInString() +  " : \n" + "Hiden - High - " + string(time[0]));
                     }
                 
               
               break;
            }
             else{
               ObjectDelete(string(indicatorIndex) + "hidenhighT" + string(Time[1]));
               ObjectDelete(string(indicatorIndex) + "diverhighT" + string(Time[1]));
               SHOWHIGH = false;
             }
         }
         
         
         
         
         
         
   for(int j1 = 0 ; j1 < EXTERMOMS ; j1++){
      if(j1 == maxLows) break;
      
      int iolp1 = iLowest(NULL,0,MODE_LOW,8,lows[j1][0]-4); //index of lowest price 1
            
      int iolp0 = iLowest(NULL,0,MODE_LOW,4,0); //index of lowest price 0
      
      if(low[iolp0] < low[iolp1] &&
         ExtMacdBuffer[0] > ExtMacdBuffer[lows[j1][0]] &&
         iLowest(NULL,0,MODE_LOW,iolp1 + 1 - iolp0 , iolp0) == iolp0 &&
         ExtMacdBuffer[0] > ExtMacdBuffer[1]  &&
         ExtMacdBuffer[1] < ExtMacdBuffer[3]){ // Divergence in Lows
         
         
         
            if(indicatorLines){
               string n = string(indicatorIndex) + "diverlowT" + string(Time[1]);
               if(!(ObjectFind(n)>=0))
               {
                  ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[1], ExtMacdBuffer[1], Time[lows[j1][0]], ExtMacdBuffer[lows[j1][0]]);
                  ObjectSet(n, OBJPROP_RAY, false);
                  ObjectSet(n, OBJPROP_COLOR, clrGreen);
                  ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet(n,OBJPROP_SELECTABLE,false);
                  ObjectSet(n,OBJPROP_HIDDEN,false);
               }
            }
            
            SHOWDOWN = true;
            
            if(lastNotif == time[1]) lastNotif = time[0];
            if(lastNotif != time[0]){
               lastNotif = time[0];
               notify(Symbol() + "," + getPeriodInString() +  " : \n" + "Diver - Lows - " + string(time[0]));
            }
            
         
         
         break;
         
      }
      else if(low[iolp0] > low[iolp1] &&
           ExtMacdBuffer[0] < ExtMacdBuffer[lows[j1][0]] &&
           iLowest(NULL,0,MODE_LOW,iolp1  + 1 - iolp0 , iolp0) == iolp1 &&
           ExtMacdBuffer[0] > ExtMacdBuffer[1]  &&
           ExtMacdBuffer[1] < ExtMacdBuffer[3]){ // Hiden in lows
           
            
           
           
              if(indicatorLines){
                     string n = string(indicatorIndex) + "hidenlowT" + string(Time[1]);
                     if(!(ObjectFind(n)>=0))
                     {
                        ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[1], ExtMacdBuffer[1], Time[lows[j1][0]], ExtMacdBuffer[lows[j1][0]]);
                        ObjectSet(n, OBJPROP_RAY, false);
                        ObjectSet(n, OBJPROP_COLOR, clrGreen);
                        ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                        ObjectSet(n,OBJPROP_SELECTABLE,false);
                        ObjectSet(n,OBJPROP_HIDDEN,false);
                     }
                  }
               
               SHOWDOWN = true;
               
               if(lastNotif == time[1]) lastNotif = time[0];
               if(lastNotif != time[0]){
                  lastNotif = time[0];
                  notify(Symbol() + "," + getPeriodInString() + " : \n" + "Hiden - Lows - " + string(time[0]));
               }
            
         
            break;
      }
      else{
         ObjectDelete(string(indicatorIndex) + "hidenlowT" + string(Time[1]));
         ObjectDelete(string(indicatorIndex) + "diverlowT" + string(Time[1]));
         SHOWDOWN = false;
      }
   }
   
     
     
     
     
    
   
   
   
   
   //--------------------------------------------------------------------------------------------------------
   SHOW = !SHOW;
   ObjectSet("downArrowFor"+string(indicatorIndex),OBJPROP_TIMEFRAMES,((SHOW&&SHOWDOWN) ? OBJ_ALL_PERIODS:OBJ_NO_PERIODS));
   ObjectSet("upArrowFor"+string(indicatorIndex),OBJPROP_TIMEFRAMES,((SHOW&&SHOWHIGH) ? OBJ_ALL_PERIODS:OBJ_NO_PERIODS));
   
   //--------------------------------------------------------------------------------------------------------
   
   
//--- signal line counted in the 2-nd buffer
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
//--- done
   
   
   
   
   
   return(rates_total);
  }
//+------------------------------------------------------------------+


void notify(string text){
   
   //Print(text);
   
   if(sendEmail){
      SendMail("ALERT",text);
   }
   if(sendNotification){
      SendNotification(text);
   }
   if(soundAlert){
      Alert(text);
   }
   
}


 string getPeriodInString(){
   int p = Period();
   string res = "";
   switch(p)
     {
      case 1 :
        res = "M1";
        break;
      case 5 :
        res = "M5";
        break;
      case 15 :
        res = "M15";
        break;
      case 30 :
        res = "M30";
        break;
      case 60 :
        res = "H1";
        break;
      case 240 :
        res = "H4";
        break;
      default:
        break;
     }
     
     return res;
 }




void shiftHighs(){
   for(int i = maxHighs-2 ; i >= 0 ; i-- ){
      highs[i+1][0] = highs[i][0];
      highs[i+1][1] = highs[i][1];
   }
}

void shiftLows(){
   for(int i = maxLows-2 ; i >= 0 ; i-- ){
      lows[i+1][0] = lows[i][0];
      lows[i+1][1] = lows[i][1];
   }
}



void updateIndexes(){
   for(int i = 0 ; i < maxHighs ; i++){
      highs[i][0]++;
      lows[i][0]++;
   }
}



void prnth(){
   string s = "h0 ";
   for(int i = 0 ; i < maxHighs ; i++){
      s = s+ string(highs[i][0]) + "-";
   }
   Print(s);
   /*s = "h1 ";
   for(int i = 0 ; i < maxHighs ; i++){
      s = s+ highs[i][1] + "-";
   }
   Print(s);*/
}


void prntl(){
   string s = "l0 ";
   for(int i = 0 ; i < maxLows ; i++){
      s = s+ string(lows[i][0]) + "-";
   }
   Print(s);
}


double calculatePoint(){
   
   return 8*(ChartGetDouble(0,CHART_FIXED_MAX,indicatorIndex)-ChartGetDouble(0,CHART_FIXED_MIN,indicatorIndex))/100;
   
}




/*void drlns(){
   
   for (int i = 0 ; i < maxHighs-3 ; i++){
      
      string n = "high" + Time[highs[i][0]];
      if(!(ObjectFind(n)>=0))
      {
         ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[highs[i][0]], ExtMacdBuffer[highs[i][0]], Time[highs[i+1][0]], ExtMacdBuffer[highs[i+1][0]]);
         ObjectSet(n, OBJPROP_RAY, false);
         ObjectSet(n, OBJPROP_COLOR, clrRed);
         ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
       }
      
   }  
   
}*/


//---------------------NewCandleTime--------------------
datetime NewCandleTime=iTime(Symbol(),0,0);
bool IsNewCandle(){
   if(NewCandleTime==iTime(Symbol(),0,0)) return false;
   else{
      NewCandleTime=iTime(Symbol(),0,0);
      return true;
   }
}
