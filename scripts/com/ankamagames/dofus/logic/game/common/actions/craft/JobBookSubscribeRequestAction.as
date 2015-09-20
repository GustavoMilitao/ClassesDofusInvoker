package com.ankamagames.dofus.logic.game.common.actions.craft
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class JobBookSubscribeRequestAction extends Object implements Action
   {
       
      public var jobId:uint;
      
      public function JobBookSubscribeRequestAction()
      {
         super();
      }
      
      public static function create(param1:uint) : JobBookSubscribeRequestAction
      {
         var _loc2_:JobBookSubscribeRequestAction = new JobBookSubscribeRequestAction();
         _loc2_.jobId = param1;
         return _loc2_;
      }
   }
}
