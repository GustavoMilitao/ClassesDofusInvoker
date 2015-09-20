package com.ankamagames.berilia.types.template
{
   public class TemplateVar extends Object
   {
       
      public var name:String;
      
      public var value:String;
      
      public function TemplateVar(param1:String)
      {
         super();
         this.name = param1;
      }
      
      public function clone() : TemplateVar
      {
         var _loc1_:TemplateVar = new TemplateVar(this.name);
         _loc1_.value = this.value;
         return _loc1_;
      }
   }
}
