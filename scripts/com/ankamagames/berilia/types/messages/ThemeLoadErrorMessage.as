package com.ankamagames.berilia.types.messages
{
   import com.ankamagames.jerakine.messages.Message;
   
   public class ThemeLoadErrorMessage extends Object implements Message
   {
       
      private var _themeName:String;
      
      public function ThemeLoadErrorMessage(param1:String)
      {
         super();
         this._themeName = param1;
      }
      
      public function get themeName() : String
      {
         return this._themeName;
      }
   }
}
