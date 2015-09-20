package com.ankamagames.dofus.logic.game.common.actions
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class CloseIdolsAction extends Object implements Action
   {
       
      public function CloseIdolsAction()
      {
         super();
      }
      
      public static function create() : CloseIdolsAction
      {
         return new CloseIdolsAction();
      }
   }
}
