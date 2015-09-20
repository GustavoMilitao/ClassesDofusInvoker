package com.ankamagames.dofus.logic.game.approach.actions
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class GiftAssignAllRequestAction extends Object implements Action
   {
       
      public var characterId:uint;
      
      public function GiftAssignAllRequestAction()
      {
         super();
      }
      
      public static function create(param1:uint) : GiftAssignAllRequestAction
      {
         var _loc2_:GiftAssignAllRequestAction = new GiftAssignAllRequestAction();
         _loc2_.characterId = param1;
         return _loc2_;
      }
   }
}
