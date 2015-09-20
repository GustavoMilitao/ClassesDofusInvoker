package com.ankamagames.dofus.logic.common.managers
{
   import flash.filesystem.File;
   
   public class HyperlinkSystem extends Object
   {
       
      public function HyperlinkSystem()
      {
         super();
      }
      
      public static function open(param1:String) : void
      {
         var _loc2_:File = new File(param1);
         _loc2_.openWithDefaultApplication();
      }
   }
}
