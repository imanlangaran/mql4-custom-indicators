//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Averages Convergence/Divergence"
#property strict


//--- indicator settings
#property  indicator_separate_window
#property indicator_minimum    -10
#property indicator_maximum    110
#property  indicator_buffers 2
#property  indicator_color1  LightSeaGreen
#property  indicator_color2  Red


#property indicator_level1     20.0
#property indicator_level2     50.0
#property indicator_level3     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- indicator parameters
input int InpKPeriod=5; // K Period
input int InpDPeriod=3; // D Period
input int InpSlowing=3; // Slowing

input bool indicatorLines = true; //indicator Lines
input bool indicatorArrows = true; //indicator Arrows
//--- indicator buffers
double ExtMainBuffer[];
double ExtSignalBuffer[];
//--- right input parameters flag
int draw_begin1=0;
int draw_begin2=0;

int indicatorIndex;
string short_name;

bool SHOW = true;

bool SHOWDOWN = false;
bool SHOWHIGH = false;

#define EXTERMOMS 4

int highsI[EXTERMOMS];
int lowsI[EXTERMOMS];

int cntHighs = 0;
int cntLows = 0;

bool firstChecked = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits+1);
//--- drawing settings
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, ExtMainBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, ExtSignalBuffer);
//--- indicator buffers mapping
//--- name for DataWindow and indicator subwindow label
   short_name="Sto Diver("+IntegerToString(InpKPeriod)+","+IntegerToString(InpDPeriod)+","+IntegerToString(InpSlowing)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Signal");
   
   
   draw_begin1=InpKPeriod+InpSlowing;
   draw_begin2=draw_begin1+InpDPeriod;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);
//--- check for input parameters

   
   indicatorIndex = WindowFind(short_name);
   
   
   ObjectsDeleteAll(indicatorIndex , OBJ_TREND);
   ObjectsDeleteAll(indicatorIndex , OBJ_ARROW);
   
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
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++){
      
      ExtMainBuffer[i] = iStochastic(Symbol(),PERIOD_CURRENT,InpKPeriod,InpDPeriod,InpSlowing,MODE_SMA,0,MODE_MAIN,i);
      ExtSignalBuffer[i] = iStochastic(Symbol(),PERIOD_CURRENT,InpKPeriod,InpDPeriod,InpSlowing,MODE_SMA,0,MODE_SIGNAL,i);
      
      if(limit == 1){
      
         if(ExtMainBuffer[3] > ExtMainBuffer[1] &&
            ExtMainBuffer[3] > ExtMainBuffer[2] &&
            ExtMainBuffer[3] > ExtMainBuffer[4] &&
            ExtMainBuffer[3] > ExtMainBuffer[5] &&
            highsI[0] != 3){
               
               shiftHighs();
               highsI[0] = 3;
               
               int j0 = 0;
            
               int iohp0 = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,5,highsI[j0]-2);
               
               for(int j1 = j0+1 ; j1 < EXTERMOMS ; j1++){
                  
                  int iohp1 = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,5,highsI[j1]-2);
                  
                  if(ExtMainBuffer[highsI[j0]] > ExtMainBuffer[highsI[j1]] &&
                     high[iohp0] < high[iohp1] &&
                     iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,iohp1 - iohp0 + 3,iohp0) == iohp1){ // hiden in highs
                        
                        if(indicatorLines){
                           string n = string(indicatorIndex) + "hidenhighline" + string(Time[highsI[j0]]);
                           if(!(ObjectFind(n)>=0))
                           {
                              ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[highsI[j0]], ExtMainBuffer[highsI[j0]], Time[highsI[j1]], ExtMainBuffer[highsI[j1]]);
                              ObjectSet(n, OBJPROP_RAY, false);
                              ObjectSet(n, OBJPROP_COLOR, clrRed);
                              ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_HIDDEN,false);
                           }
                        }
                        
                        if(indicatorArrows){
                           string n = string(indicatorIndex) + "hidenhigharrow" + string(Time[highsI[j0]]);
                           if(!(ObjectFind(n)>=0)){
                              ObjectDelete(0,n);
                              ObjectCreate(0,n, OBJ_ARROW,indicatorIndex,Time[highsI[j0]],ExtMainBuffer[highsI[j0]]);
                              ObjectSetInteger(0,n, OBJPROP_ARROWCODE,234);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_COLOR,clrRed);
                              ObjectSet(n,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
                              ObjectSetInteger(0,n, OBJPROP_WIDTH,0);
                           }
                        }
                        break;
                        
                     }
                     else if(ExtMainBuffer[highsI[j0]] < ExtMainBuffer[highsI[j1]] &&
                           high[iohp0] > high[iohp1] &&
                           iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,iohp1 - iohp0 + 3,iohp0) == iohp0){ // diver in highs
                           
                           if(indicatorLines){
                              string n = string(indicatorIndex) + "diverhighline" + string(Time[highsI[j0]]);
                              if(!(ObjectFind(n)>=0))
                              {
                                 ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[highsI[j0]], ExtMainBuffer[highsI[j0]], Time[highsI[j1]], ExtMainBuffer[highsI[j1]]);
                                 ObjectSet(n, OBJPROP_RAY, false);
                                 ObjectSet(n, OBJPROP_COLOR, clrRed);
                                 ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_HIDDEN,false);
                              }
                           }
                           
                           if(indicatorArrows){
                              string n = string(indicatorIndex) + "diverhigharrow" + string(Time[highsI[j0]]);
                              if(!(ObjectFind(n)>=0)){
                                 ObjectDelete(0,n);
                                 ObjectCreate(0,n, OBJ_ARROW,indicatorIndex,Time[highsI[j0]],ExtMainBuffer[highsI[j0]]);
                                 ObjectSetInteger(0,n, OBJPROP_ARROWCODE,234);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_COLOR,clrRed);
                                 ObjectSet(n,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
                                 ObjectSetInteger(0,n, OBJPROP_WIDTH,0);
                              }
                           }
                           break;
                     }
                     else if(ExtMainBuffer[highsI[j0]] < ExtMainBuffer[highsI[j1]] &&
                            high[iohp0] < high[iohp1]){
                              
                              break;
                     }
               }
               
         }
         else if(ExtMainBuffer[3] < ExtMainBuffer[1] &&
                 ExtMainBuffer[3] < ExtMainBuffer[2] &&
                 ExtMainBuffer[3] < ExtMainBuffer[4] &&
                 ExtMainBuffer[3] < ExtMainBuffer[5] &&
                 lowsI[0] != 3){
               
               shiftLows();
               lowsI[0] = 3;
               
               int j0 = 0;
            
               int iolp0 = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,5,lowsI[j0]-2);
               
               for(int j1 = j0+1 ; j1 < EXTERMOMS ; j1++){
                  
                  int iolp1 = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,5,lowsI[j1]-2);
                  
                  if(ExtMainBuffer[lowsI[j0]] < ExtMainBuffer[lowsI[j1]] &&
                     low[iolp0] > low[iolp1] &&
                     iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,iolp1 - iolp0 + 3,iolp0) == iolp1){ // hiden in lows
                        
                        if(indicatorLines){
                           string n = string(indicatorIndex) + "hidenlowline" + string(Time[lowsI[j0]]);
                           if(!(ObjectFind(n)>=0))
                           {
                              ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[lowsI[j0]], ExtMainBuffer[lowsI[j0]], Time[lowsI[j1]], ExtMainBuffer[lowsI[j1]]);
                              ObjectSet(n, OBJPROP_RAY, false);
                              ObjectSet(n, OBJPROP_COLOR, clrGreen);
                              ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_HIDDEN,false);
                           }
                        }
                        
                        if(indicatorArrows){
                           string n = string(indicatorIndex) + "hidenlowarrow" + string(Time[lowsI[j0]]);
                           if(!(ObjectFind(n)>=0)){
                              ObjectDelete(0,n);
                              ObjectCreate(0,n, OBJ_ARROW,indicatorIndex,Time[lowsI[j0]],ExtMainBuffer[lowsI[j0]]);
                              ObjectSetInteger(0,n, OBJPROP_ARROWCODE,233);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_COLOR,clrGreen);
                              ObjectSet(n,OBJPROP_ANCHOR,ANCHOR_TOP);
                              ObjectSetInteger(0,n, OBJPROP_WIDTH,0);
                           }
                        }
                        break;
                        
                     }
                     else if(ExtMainBuffer[lowsI[j0]] > ExtMainBuffer[lowsI[j1]] &&
                           low[iolp0] < low[iolp1] &&
                           iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,iolp1 - iolp0 + 3,iolp0) == iolp0){ // diver in lows
                           
                           if(indicatorLines){
                              string n = string(indicatorIndex) + "diverlowline" + string(Time[lowsI[j0]]);
                              if(!(ObjectFind(n)>=0))
                              {
                                 ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[lowsI[j0]], ExtMainBuffer[lowsI[j0]], Time[lowsI[j1]], ExtMainBuffer[lowsI[j1]]);
                                 ObjectSet(n, OBJPROP_RAY, false);
                                 ObjectSet(n, OBJPROP_COLOR, clrGreen);
                                 ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_HIDDEN,false);
                              }
                           }
                           
                           if(indicatorArrows){
                              string n = string(indicatorIndex) + "diverlowarrow" + string(Time[lowsI[j0]]);
                              if(!(ObjectFind(n)>=0)){
                                 ObjectDelete(0,n);
                                 ObjectCreate(0,n, OBJ_ARROW,indicatorIndex,Time[lowsI[j0]],ExtMainBuffer[lowsI[j0]]);
                                 ObjectSetInteger(0,n, OBJPROP_ARROWCODE,233);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_COLOR,clrGreen);
                                 ObjectSet(n,OBJPROP_ANCHOR,ANCHOR_TOP);
                                 ObjectSetInteger(0,n, OBJPROP_WIDTH,0);
                              }
                           }
                           
                           break;
                     }
                     else if(ExtMainBuffer[lowsI[j0]] > ExtMainBuffer[lowsI[j1]] &&
                           low[iolp0] > low[iolp1]){
                           
                           break;
                           
                     }
                  
               }
               
            
               
         }
         
      }
      else if(i>4){
         if(ExtMainBuffer[i-2] > ExtMainBuffer[i-3] &&
            ExtMainBuffer[i-2] > ExtMainBuffer[i-4] &&
            ExtMainBuffer[i-2] > ExtMainBuffer[i-1] &&
            ExtMainBuffer[i-2] > ExtMainBuffer[i] &&
            cntHighs != EXTERMOMS){
               
               highsI[cntHighs] = i-2;
               cntHighs++;
            
               
          }
          else if(ExtMainBuffer[i-2] < ExtMainBuffer[i-3] &&
                  ExtMainBuffer[i-2] < ExtMainBuffer[i-4] &&
                  ExtMainBuffer[i-2] < ExtMainBuffer[i-1] &&
                  ExtMainBuffer[i-2] < ExtMainBuffer[i] &&
                  cntLows != EXTERMOMS){
               
               lowsI[cntLows] = i-2;
               cntLows++;
            
               
          }
          else if(cntHighs == EXTERMOMS && cntLows == EXTERMOMS && !firstChecked){
            firstChecked = true;
            
            for(int j0 = 0 ; j0 < EXTERMOMS-1; j0++){
            
               int iohp0 = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,5,highsI[j0]-2);
               
               for(int j1 = j0+1 ; j1 < EXTERMOMS ; j1++){
                  
                  int iohp1 = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,5,highsI[j1]-2);
                  
                  if(ExtMainBuffer[highsI[j0]] > ExtMainBuffer[highsI[j1]] &&
                     high[iohp0] < high[iohp1] &&
                     iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,iohp1 - iohp0 + 3,iohp0) == iohp1){ // hiden in highs
                        
                        if(indicatorLines){
                           string n = string(indicatorIndex) + "hidenhighline" + string(Time[highsI[j0]]);
                           if(!(ObjectFind(n)>=0))
                           {
                              ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[highsI[j0]], ExtMainBuffer[highsI[j0]], Time[highsI[j1]], ExtMainBuffer[highsI[j1]]);
                              ObjectSet(n, OBJPROP_RAY, false);
                              ObjectSet(n, OBJPROP_COLOR, clrRed);
                              ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_HIDDEN,false);
                           }
                        }
                        
                        if(indicatorArrows){
                           string n = string(indicatorIndex) + "hidenhigharrow" + string(Time[highsI[j0]]);
                           if(!(ObjectFind(n)>=0)){
                              ObjectDelete(0,n);
                              ObjectCreate(0,n, OBJ_ARROW,indicatorIndex,Time[highsI[j0]],ExtMainBuffer[highsI[j0]]);
                              ObjectSetInteger(0,n, OBJPROP_ARROWCODE,234);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_COLOR,clrRed);
                              ObjectSet(n,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
                              ObjectSetInteger(0,n, OBJPROP_WIDTH,0);
                           }
                        }
                        break;
                        
                     }
                     else if(ExtMainBuffer[highsI[j0]] < ExtMainBuffer[highsI[j1]] &&
                           high[iohp0] > high[iohp1] &&
                           iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,iohp1 - iohp0 + 3,iohp0) == iohp0){ // diver in highs
                           
                           if(indicatorLines){
                              string n = string(indicatorIndex) + "diverhighline" + string(Time[highsI[j0]]);
                              if(!(ObjectFind(n)>=0))
                              {
                                 ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[highsI[j0]], ExtMainBuffer[highsI[j0]], Time[highsI[j1]], ExtMainBuffer[highsI[j1]]);
                                 ObjectSet(n, OBJPROP_RAY, false);
                                 ObjectSet(n, OBJPROP_COLOR, clrRed);
                                 ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_HIDDEN,false);
                              }
                           }
                           
                           if(indicatorArrows){
                              string n = string(indicatorIndex) + "diverhigharrow" + string(Time[highsI[j0]]);
                              if(!(ObjectFind(n)>=0)){
                                 ObjectDelete(0,n);
                                 ObjectCreate(0,n, OBJ_ARROW,indicatorIndex,Time[highsI[j0]],ExtMainBuffer[highsI[j0]]);
                                 ObjectSetInteger(0,n, OBJPROP_ARROWCODE,234);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_COLOR,clrRed);
                                 ObjectSet(n,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
                                 ObjectSetInteger(0,n, OBJPROP_WIDTH,0);
                              }
                           }
                           break;
                     }
                     else if(ExtMainBuffer[highsI[j0]] < ExtMainBuffer[highsI[j1]] &&
                            high[iohp0] < high[iohp1]){
                              
                              break;
                     }
               }
            }
            //------------------------------------------------------------
            
            
            for(int j0 = 0 ; j0 < EXTERMOMS-1; j0++){
            
               int iolp0 = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,5,lowsI[j0]-2);
               
               for(int j1 = j0+1 ; j1 < EXTERMOMS ; j1++){
                  
                  int iolp1 = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,5,lowsI[j1]-2);
                  
                  if(ExtMainBuffer[lowsI[j0]] < ExtMainBuffer[lowsI[j1]] &&
                     low[iolp0] > low[iolp1] &&
                     iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,iolp1 - iolp0 + 3,iolp0) == iolp1){ // hiden in lows
                        
                        if(indicatorLines){
                           string n = string(indicatorIndex) + "hidenlowline" + string(Time[lowsI[j0]]);
                           if(!(ObjectFind(n)>=0))
                           {
                              ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[lowsI[j0]], ExtMainBuffer[lowsI[j0]], Time[lowsI[j1]], ExtMainBuffer[lowsI[j1]]);
                              ObjectSet(n, OBJPROP_RAY, false);
                              ObjectSet(n, OBJPROP_COLOR, clrGreen);
                              ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_HIDDEN,false);
                           }
                        }
                        
                        if(indicatorArrows){
                           string n = string(indicatorIndex) + "hidenlowarrow" + string(Time[lowsI[j0]]);
                           if(!(ObjectFind(n)>=0)){
                              ObjectDelete(0,n);
                              ObjectCreate(0,n, OBJ_ARROW,indicatorIndex,Time[lowsI[j0]],ExtMainBuffer[lowsI[j0]]);
                              ObjectSetInteger(0,n, OBJPROP_ARROWCODE,233);
                              ObjectSet(n,OBJPROP_SELECTABLE,false);
                              ObjectSet(n,OBJPROP_COLOR,clrGreen);
                              ObjectSet(n,OBJPROP_ANCHOR,ANCHOR_TOP);
                              ObjectSetInteger(0,n, OBJPROP_WIDTH,0);
                           }
                        }
                        break;
                        
                     }
                     else if(ExtMainBuffer[lowsI[j0]] > ExtMainBuffer[lowsI[j1]] &&
                           low[iolp0] < low[iolp1] &&
                           iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,iolp1 - iolp0 + 3,iolp0) == iolp0){ // diver in lows
                           
                           if(indicatorLines){
                              string n = string(indicatorIndex) + "diverlowline" + string(Time[lowsI[j0]]);
                              if(!(ObjectFind(n)>=0))
                              {
                                 ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[lowsI[j0]], ExtMainBuffer[lowsI[j0]], Time[lowsI[j1]], ExtMainBuffer[lowsI[j1]]);
                                 ObjectSet(n, OBJPROP_RAY, false);
                                 ObjectSet(n, OBJPROP_COLOR, clrGreen);
                                 ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_HIDDEN,false);
                              }
                           }
                           
                           if(indicatorArrows){
                              string n = string(indicatorIndex) + "diverlowarrow" + string(Time[lowsI[j0]]);
                              if(!(ObjectFind(n)>=0)){
                                 ObjectDelete(0,n);
                                 ObjectCreate(0,n, OBJ_ARROW,indicatorIndex,Time[lowsI[j0]],ExtMainBuffer[lowsI[j0]]);
                                 ObjectSetInteger(0,n, OBJPROP_ARROWCODE,233);
                                 ObjectSet(n,OBJPROP_SELECTABLE,false);
                                 ObjectSet(n,OBJPROP_COLOR,clrGreen);
                                 ObjectSet(n,OBJPROP_ANCHOR,ANCHOR_TOP);
                                 ObjectSetInteger(0,n, OBJPROP_WIDTH,0);
                              }
                           }
                           
                           break;
                     }
                     
                     else if(ExtMainBuffer[lowsI[j0]] > ExtMainBuffer[lowsI[j1]] &&
                           low[iolp0] > low[iolp1]){
                           
                           break;
                           
                     }
                  
               }
               
            }
            
          }
      }
      
   }
   
   
   
   for(int j1 = 0 ; j1 < EXTERMOMS ; j1++){
      
      int iohp0 = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,3,0); // index of highest price 0
      
      int iohp1 = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,5,highsI[j1]-2); // index of highest price 1
      
      if(ExtMainBuffer[1] > ExtMainBuffer[highsI[j1]] &&
         high[iohp0] < high[iohp1] &&
         iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,iohp1 - iohp0 + 3,iohp0) == iohp1 &&
         ExtMainBuffer[0] < ExtMainBuffer[1] &&
         ExtMainBuffer[1] > ExtMainBuffer[3]){ // hiden in highs
            
            if(indicatorLines){
               string n = string(indicatorIndex) + "hidenhighT" + string(Time[1]);
               if(!(ObjectFind(n)>=0))
               {
                  ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[1], ExtMainBuffer[1], Time[highsI[j1]], ExtMainBuffer[highsI[j1]]);
                  ObjectSet(n, OBJPROP_RAY, false);
                  ObjectSet(n, OBJPROP_COLOR, clrRed);
                  ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                  ObjectSet(n,OBJPROP_SELECTABLE,false);
                  ObjectSet(n,OBJPROP_HIDDEN,false);
               }
            }
            
            SHOWHIGH = true;
            break;
      }
      else if(ExtMainBuffer[1] < ExtMainBuffer[highsI[j1]] &&
               high[iohp0] > high[iohp1] &&
               iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,iohp1 - iohp0 + 3,iohp0) == iohp0 &&
               ExtMainBuffer[0] < ExtMainBuffer[1] &&
               ExtMainBuffer[1] > ExtMainBuffer[3]){ // diver in highs
                     
               if(indicatorLines){
                  string n = string(indicatorIndex) + "diverhighT" + string(Time[1]);
                  if(!(ObjectFind(n)>=0))
                  {
                     ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[1], ExtMainBuffer[1], Time[highsI[j1]], ExtMainBuffer[highsI[j1]]);
                     ObjectSet(n, OBJPROP_RAY, false);
                     ObjectSet(n, OBJPROP_COLOR, clrRed);
                     ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                     ObjectSet(n,OBJPROP_SELECTABLE,false);
                     ObjectSet(n,OBJPROP_HIDDEN,false);
                  }
               }
      
            SHOWHIGH = true;
            break;
      }
      else if(ExtMainBuffer[1] < ExtMainBuffer[highsI[j1]] &&
             high[iohp0] < high[iohp1]){
             
            break;
      }
      
      else {
            ObjectDelete(string(indicatorIndex) + "hidenhighT" + string(Time[1]));
            ObjectDelete(string(indicatorIndex) + "diverhighT" + string(Time[1]));
            SHOWHIGH = false;
               
      }
   }
      
      
   
   for(int j1 = 0 ; j1 < EXTERMOMS ; j1++){
      
      int iolp0 = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,3,0); // index of lowest price 0
      
      int iolp1 = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,5,lowsI[j1]-2); // index of lowest price 1
      
      if(ExtMainBuffer[1] < ExtMainBuffer[lowsI[j1]] &&
         low[iolp0] > low[iolp1] &&
         iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,iolp1 - iolp0 + 3,iolp0) == iolp1 &&
         ExtMainBuffer[0] > ExtMainBuffer[1] &&
         ExtMainBuffer[1] < ExtMainBuffer[3]){ // hiden in lows
            
            if(indicatorLines){
               string n = string(indicatorIndex) + "hidenlowT" + string(Time[1]);
               if(!(ObjectFind(n)>=0))
               {
                  ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[1], ExtMainBuffer[1], Time[lowsI[j1]], ExtMainBuffer[lowsI[j1]]);
                  ObjectSet(n, OBJPROP_RAY, false);
                  ObjectSet(n, OBJPROP_COLOR, clrGreen);
                  ObjectSet(n, OBJPROP_STYLE, STYLE_DOT);
                  ObjectSet(n,OBJPROP_SELECTABLE,false);
                  ObjectSet(n,OBJPROP_HIDDEN,false);
               }
            }
            
            SHOWDOWN = true;
            break;
      }
      else if(ExtMainBuffer[1] > ExtMainBuffer[lowsI[j1]] &&
               low[iolp0] < low[iolp1] &&
               iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,iolp1 - iolp0 + 3,iolp0) == iolp0 &&
               ExtMainBuffer[0] > ExtMainBuffer[1] &&
               ExtMainBuffer[1] < ExtMainBuffer[3]){ // diver in lows
                     
               if(indicatorLines){
                  string n = string(indicatorIndex) + "diverlowT" + string(Time[1]);
                  if(!(ObjectFind(n)>=0))
                  {
                     ObjectCreate(0, n, OBJ_TREND,indicatorIndex, Time[1], ExtMainBuffer[1], Time[lowsI[j1]], ExtMainBuffer[lowsI[j1]]);
                     ObjectSet(n, OBJPROP_RAY, false);
                     ObjectSet(n, OBJPROP_COLOR, clrGreen);
                     ObjectSet(n, OBJPROP_STYLE, STYLE_SOLID);
                     ObjectSet(n,OBJPROP_SELECTABLE,false);
                     ObjectSet(n,OBJPROP_HIDDEN,false);
                  }
               }
      
            SHOWDOWN = true;
            break;
      }
      else if(ExtMainBuffer[1] < ExtMainBuffer[lowsI[j1]] &&
             low[iolp0] < low[iolp1]){
             
            break;
      }
      
      else {
            ObjectDelete(string(indicatorIndex) + "hidenlowT" + string(Time[1]));
            ObjectDelete(string(indicatorIndex) + "diverlowT" + string(Time[1]));
            SHOWDOWN = false;
               
      }
      
      
      
   }
   
   
   //printHighs();
   //printLows();
   
   
   if(!(ObjectFind("downArrow" + short_name)>=0)){
      ObjectDelete(0,"downArrow" + short_name);
      ObjectCreate(0,"downArrow" + short_name, OBJ_ARROW,indicatorIndex,Time[0],10);
      ObjectSetInteger(0,"downArrow" + short_name, OBJPROP_ARROWCODE,228);
      ObjectSet("downArrow" + short_name,OBJPROP_SELECTABLE,false);
      ObjectSet("downArrow" + short_name,OBJPROP_COLOR,clrGreen);
      ObjectSet("downArrow" + short_name,OBJPROP_ANCHOR,ANCHOR_TOP);
      ObjectSetInteger(0,"downArrow" + short_name, OBJPROP_WIDTH,0);
   }
   
   if(!(ObjectFind("upArrow" + short_name)>=0)){
      ObjectDelete(0,"upArrow" + short_name);
      ObjectCreate(0,"upArrow" + short_name, OBJ_ARROW,indicatorIndex,Time[0],90);
      ObjectSetInteger(0,"upArrow" + short_name, OBJPROP_ARROWCODE,230);
      ObjectSet("upArrow" + short_name,OBJPROP_SELECTABLE,false);
      ObjectSet("upArrow" + short_name,OBJPROP_COLOR,clrRed);
      ObjectSet("upArrow" + short_name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSetInteger(0,"upArrow" + short_name, OBJPROP_WIDTH,0);
   }
   
   
   
   if(IsNewCandle()){
      
      ObjectSetInteger(0,"upArrow" + short_name, OBJPROP_TIME,Time[0]);
      ObjectSetInteger(0,"downArrow" + short_name, OBJPROP_TIME,Time[0]);
      
      updateIndexes();
      
      
      ObjectDelete(string(indicatorIndex) + "hidenhighT" + string(Time[2]));
      ObjectDelete(string(indicatorIndex) + "diverhighT" + string(Time[2]));
   
      ObjectDelete(string(indicatorIndex) + "hidenlowT" + string(Time[2]));
      ObjectDelete(string(indicatorIndex) + "diverlowT" + string(Time[2]));
   }
   
   
   
   
   //--------------------------------------------------------------------------------------------------------
   SHOW = !SHOW;
   ObjectSet("downArrow" + short_name,OBJPROP_TIMEFRAMES,((SHOW&&SHOWDOWN) ? OBJ_ALL_PERIODS:OBJ_NO_PERIODS));
   ObjectSet("upArrow" + short_name,OBJPROP_TIMEFRAMES,((SHOW&&SHOWHIGH) ? OBJ_ALL_PERIODS:OBJ_NO_PERIODS));
   
   return(rates_total);
  }
  
  
//+-----------------------------shift highs-------------------------------------+

void shiftHighs(){
   for(int i = EXTERMOMS-2 ; i >= 0 ; i--){
      highsI[i+1] = highsI[i];
   }
}

//+-----------------------------shift lows-------------------------------------+

void shiftLows(){
   for(int i = EXTERMOMS-2 ; i >= 0 ; i--){
      lowsI[i+1] = lowsI[i];
   }
}

//+-----------------------------update indexes-------------------------------------+

void updateIndexes(){
   for(int i = 0 ; i < EXTERMOMS ; i++){
      lowsI[i]++;
      highsI[i]++;
   }
}



//+-----------------------------print-------------------------------------+
void printHighs(){
   
   string s = "highs : ";
   string ss = "highs : ";
   for(int i = 0 ; i < EXTERMOMS ; i++){
      s+= string(Time[highsI[i]]) + " ";
      ss+=string(highsI[i]) + " ";
   }
   
   //Print(s);
   Print(ss);
}

void printLows(){
   
   string s = "lows : ";
   string ss = "lows : ";
   for(int i = 0 ; i < EXTERMOMS ; i++){
      s+= string(Time[lowsI[i]]) + " ";
      ss+=string(lowsI[i]) + " ";
   }
   
   //Print(s);
   Print(ss);
}

//---------------------NewCandleTime--------------------
datetime NewCandleTime=iTime(Symbol(),0,0);
bool IsNewCandle(){
   if(NewCandleTime==iTime(Symbol(),0,0)) return false;
   else{
      NewCandleTime=iTime(Symbol(),0,0);
      return true;
   }
}