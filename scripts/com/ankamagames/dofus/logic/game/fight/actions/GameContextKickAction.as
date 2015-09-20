package com.ankamagames.dofus.logic.game.fight.actions
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class GameContextKickAction extends Object implements Action
   {
       
      public var targetId:uint;
      
      public function GameContextKickAction()
      {
         super();
      }
      
      public static function create(param1:uint) : GameContextKickAction
      {
         var _loc2_:GameContextKickAction = new GameContextKickAction();
         _loc2_.targetId = param1;
         return _loc2_;
      }
   }
}
