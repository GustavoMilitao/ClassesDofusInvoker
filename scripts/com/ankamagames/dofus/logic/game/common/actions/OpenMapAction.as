package com.ankamagames.dofus.logic.game.common.actions
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class OpenMapAction extends Object implements Action
   {
       
      public var conquest:Boolean;
      
      public var pocket:Boolean;
      
      public var ignoreSetting:Boolean;
      
      public var switchingMapUi:Boolean;
      
      public function OpenMapAction()
      {
         super();
      }
      
      public static function create(param1:Boolean = false, param2:Boolean = true, param3:Boolean = false, param4:Boolean = false) : OpenMapAction
      {
         var _loc5_:OpenMapAction = new OpenMapAction();
         _loc5_.ignoreSetting = param1;
         _loc5_.pocket = param2;
         _loc5_.switchingMapUi = param3;
         _loc5_.conquest = param4;
         return _loc5_;
      }
   }
}
