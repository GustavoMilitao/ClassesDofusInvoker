package com.ankamagames.dofus.logic.game.common.actions.bid
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class BidSwitchToBuyerModeAction extends Object implements Action
   {
       
      public function BidSwitchToBuyerModeAction()
      {
         super();
      }
      
      public static function create() : BidSwitchToBuyerModeAction
      {
         var _loc1_:BidSwitchToBuyerModeAction = new BidSwitchToBuyerModeAction();
         return _loc1_;
      }
   }
}
