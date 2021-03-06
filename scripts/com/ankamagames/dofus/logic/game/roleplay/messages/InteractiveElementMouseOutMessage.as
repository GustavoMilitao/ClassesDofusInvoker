package com.ankamagames.dofus.logic.game.roleplay.messages
{
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.dofus.network.types.game.interactive.InteractiveElement;
   
   public class InteractiveElementMouseOutMessage extends Object implements Message
   {
       
      private var _ie:InteractiveElement;
      
      public function InteractiveElementMouseOutMessage(param1:InteractiveElement)
      {
         super();
         this._ie = param1;
      }
      
      public function get interactiveElement() : InteractiveElement
      {
         return this._ie;
      }
   }
}
