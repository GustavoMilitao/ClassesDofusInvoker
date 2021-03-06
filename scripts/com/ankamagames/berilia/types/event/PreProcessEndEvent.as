package com.ankamagames.berilia.types.event
{
   import flash.events.Event;
   import com.ankamagames.berilia.uiRender.XmlPreProcessor;
   
   public class PreProcessEndEvent extends Event
   {
      
      public static const PRE_PROCESS_END:String = "pre_process_end";
       
      private var _preprocessor:XmlPreProcessor;
      
      public function PreProcessEndEvent(param1:XmlPreProcessor)
      {
         super(PRE_PROCESS_END,false,false);
         this._preprocessor = param1;
      }
      
      public function get preprocessor() : XmlPreProcessor
      {
         return this._preprocessor;
      }
   }
}
