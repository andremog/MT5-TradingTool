#property copyright "Copyright 2018, FX4BTC"
#property link      "https://github.com/fx4btc"
#property version "1.00" 

/*
   April 2020
   - make for buy and sell logic
*/

input string PLEASE_ADJUST_STATEGY = "------------------------------------";
input int    MA_PERIOD_A               = 50;
input ENUM_MA_METHOD MA_TYPE           = MODE_EMA;
input ENUM_APPLIED_PRICE MA_DATA_TYPE  = PRICE_MEDIAN;
input double MA_DEVIATION              = 2.0;
input int MA_BAR_SHIFT                 = 0;

datetime lasttime;


// within lower band

// within higher band

// below low band

// above high high band

// within bands

 enum ENUM_AVAILABLE_LOGIC
  {
   WITHIN_LOWER_BAND = 1,
   WITHIN_HIGHER_BAND = 2,
   BELOW_LOW_BAND = 3,
   ABOVE_HIGH_BAND = 4,
   WITHIN_BANDS =5,
   NO_BANDS =6
  };


string Select_Logic(int scan){

  
   switch(scan)
     {
      case 0:
         return("DEFAULT STRATEGY");
      case WITHIN_LOWER_BAND:
         return("WITHIN_LOWER_BAND");        
      case WITHIN_HIGHER_BAND:
         return("WITHIN_HIGHER_BAND");         
      case BELOW_LOW_BAND:
         return("BELOW_LOW_BAND");  
      case ABOVE_HIGH_BAND:
         return("ABOVE_HIGH_BAND");  
      case WITHIN_BANDS:
         return("WITHIN_BANDS");  
      case NO_BANDS:
         return("NO_BANDS"); 
     }
    
    return("SELECT A STRATEGY");
    
}


// Indicators
int    MA_handle_1;                // handle of the indicator iMA
int    STD_handle_1;               // handle of the indicator iMA
double BBUp[],BBLow[],BBMidle[];   // dynamic arrays for numerical values of Bollinger Bands
double StdDevBuffer[];             // dynamic arrays for numerical values of stddev
string market_name ="";

/*
 Place this function within the OnInit()
*/

bool init_Indicators(string what_market){
   // grab the market symbol from init function for later use in indicator logic
   market_name = what_market;
 
   MA_handle_1=  iBands(what_market,PERIOD_CURRENT,MA_PERIOD_A,MA_BAR_SHIFT ,MA_DEVIATION,MA_DATA_TYPE);
   
   //handle=iStdDev(name,period,                     ma_period,ma_shift,ma_method,applied_price); 
   STD_handle_1=  iStdDev(what_market,PERIOD_CURRENT,MA_PERIOD_A,MA_BAR_SHIFT,MA_TYPE,MA_DATA_TYPE);
 
   //--- report if there was an error in object creation
   if(MA_handle_1<0 )
      {
      Print("The creation of iMA has failed: MA_handle=",INVALID_HANDLE);
      Print("Runtime error = ",GetLastError());
      //--- forced program termination
      return(false);
      }
      
   //--- report if there was an error in object creation
   if(STD_handle_1<0 )
      {
      Print("The creation of iSTD has failed: STD_handle=",INVALID_HANDLE);
      Print("Runtime error = ",GetLastError());
      //--- forced program termination
      return(false);
      }
 
   // everything is ok
   return(true);
}


string get_signal(int strategy, double dBid_Price){
   // use the logic 
  
   //--- do we have enough bars to work with
   int Mybars=Bars(market_name,0);
   if(Mybars<MA_PERIOD_A) // if total bars is less than 60 bars
     {
      Print("We have less than enough bars on the chart, Robot will wait for more bars before deciding on what to do next");
      return("NONE");
     }
    
   CopyBuffer(MA_handle_1,0,0,MA_PERIOD_A,BBMidle);
   CopyBuffer(MA_handle_1,1,0,MA_PERIOD_A,BBUp);
   CopyBuffer(MA_handle_1,2,0,MA_PERIOD_A,BBLow);
     
   // the indicator arrays
   ArraySetAsSeries(BBUp,true);
   ArraySetAsSeries(BBLow,true);
   ArraySetAsSeries(BBMidle,true);
   //--- Copy the new values of our indicators to buffers (arrays) using the handle
   // 0 = middle
   // 1 = upper
   // 2 = lower
      // start index (0)
      // count how many values to store in the buffer (3)
            
            
   // Different logic ( strategies)
   /*
   WITHIN_LOWER_BAND = 1,
   WITHIN_HIGHER_BAND = 2,
   BELOW_LOW_BAND = 3,
   ABOVE_HIGH_BAND = 4,
   WITHIN_BANDS =5
   NO_BANDS = 6
   */
   
    // Default strategy? 
   // If the user does not select a strategy , then use the original logic
   if(strategy == 0){
    if(dBid_Price >= BBLow[1] && dBid_Price < BBMidle[1] ){
      return("SIGNAL");
     }
   } 
   
   if(strategy == 1){
     if(dBid_Price > BBLow[1] && dBid_Price < BBMidle[1] ){
      return("SIGNAL");
     }
   }
   
   if(strategy == 2){
     if(dBid_Price < BBUp[1] && dBid_Price > BBMidle[1] && BBMidle[1]> BBMidle[2] && BBMidle[2] > BBMidle[3] ){
      return("SIGNAL");
     }
   }  
   
   if(strategy == 3){
     if(dBid_Price < BBLow[1] ){
      return("SIGNAL");
     }
   }  
   
   if(strategy == 4){
     if(dBid_Price > BBUp[1] && BBMidle[1]> BBMidle[2] && BBMidle[2] > BBMidle[3] ){
      return("SIGNAL");
     }
   }  
   
   if(strategy == 5){
     if(dBid_Price >= BBLow[1] && dBid_Price <= BBUp[1] ){
      return("SIGNAL");
     }
   }  
   if(strategy == 6){
      return("SIGNAL");
   }  
       
   // No signal
   return("NONE");
}

double get_ma_deviation(){

   CopyBuffer(MA_handle_1,0,0, MA_PERIOD_A, BBMidle);
   CopyBuffer(MA_handle_1,1,0, MA_PERIOD_A, BBUp);
   CopyBuffer(MA_handle_1,2,0, MA_PERIOD_A, BBLow);
   
   ArraySetAsSeries(BBUp,true);
   ArraySetAsSeries(BBLow,true);
   ArraySetAsSeries(BBMidle,true);
   
   double width = BBUp[1] - BBLow[1];
   
   return(width);
}


string get_standard_deviation(double dBid_Price){
   // use the logic 
   
   int Mybars=Bars(market_name,0);
   if(Mybars<MA_PERIOD_A) // if total bars is less than 60 bars
     {
      Print("We have less than enough bars on the chart, Robot will wait for more bars before deciding on what to do next");
      return("NONE");
     }
     /*
     // To be used for getting recent/latest price quotes
         MqlTick Latest_Price; // Structure to get the latest prices      
         SymbolInfoTick(market_name ,Latest_Price); // Assign current prices to structure 
      
      // The BID price.
         static double dBid_Price; 
      
      // The ASK price.
         static double dAsk_Price; 
      
         dBid_Price = Latest_Price.bid;  // Current Bid price.
         dAsk_Price = Latest_Price.ask;  // Current Ask price.
     */
   CopyBuffer(STD_handle_1,0,0,MA_PERIOD_A,StdDevBuffer);
   /*
   handle_          ,// indicator handle 
      0,             // indicator buffer number 
      index,         // start position 
      1,             // amount to copy 
      StdDev         // target array to copy
   */
  
     
   // the indicator arrays
   ArraySetAsSeries(StdDevBuffer,true);
  
           
    string decision = "";       
    if( StdDevBuffer[1] > StdDevBuffer[2] && StdDevBuffer[2] > StdDevBuffer[3] ){
      // std increasing
      decision = "up";
    }
    if( StdDevBuffer[1] < StdDevBuffer[2] && StdDevBuffer[2] < StdDevBuffer[3] ){
      // std decreasing
      decision = "down";
    }
   
    if(decision == ""){
      decision = "flat";
    }
   
   return(decision);
}


double get_standard_deviation_price(){
   // use the logic 
   
   int Mybars=Bars(market_name,0);
   if(Mybars<MA_PERIOD_A) // if total bars is less than 60 bars
     {
      Print("We have less than enough bars on the chart, Robot will wait for more bars before deciding on what to do next");
     }
    
   CopyBuffer(STD_handle_1,0,0,MA_PERIOD_A,StdDevBuffer);
   /*
   handle_          ,// indicator handle 
      0,             // indicator buffer number 
      index,         // start position 
      1,             // amount to copy 
      StdDev         // target array to copy
   */
  
     
   // the indicator arrays
   ArraySetAsSeries(StdDevBuffer,true);
  
           
   double normalize = NormalizeDouble(StdDevBuffer[1],8) ;
   return(normalize);
}