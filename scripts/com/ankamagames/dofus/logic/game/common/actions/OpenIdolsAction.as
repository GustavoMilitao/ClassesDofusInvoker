package com.ankamagames.dofus.logic.game.common.actions
{
   import com.ankamagames.jerakine.handlers.messages.Action;
   
   public class OpenIdolsAction extends Object implements Action
   {
       
      public function OpenIdolsAction()
      {
         super();
      }
      
      public static function create() : OpenIdolsAction
      {
         return new OpenIdolsAction();
      }
   }
}
