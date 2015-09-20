package com.ankamagames.dofus.logic.game.common.actions.alliance
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class AllianceInvitationAction extends Object implements Action
   {
       
      public var targetId:uint;
      
      public function AllianceInvitationAction()
      {
         super();
      }
      
      public static function create(param1:uint) : AllianceInvitationAction
      {
         var _loc2_:AllianceInvitationAction = new AllianceInvitationAction();
         _loc2_.targetId = param1;
         return _loc2_;
      }
   }
}
