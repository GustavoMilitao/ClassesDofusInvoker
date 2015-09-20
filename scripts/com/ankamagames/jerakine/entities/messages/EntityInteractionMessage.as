package com.ankamagames.jerakine.entities.messages
{
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.jerakine.entities.interfaces.IInteractive;
   
   public class EntityInteractionMessage extends Object implements Message
   {
       
      private var _entity:IInteractive;
      
      public function EntityInteractionMessage(param1:IInteractive)
      {
         super();
         this._entity = param1;
      }
      
      public function get entity() : IInteractive
      {
         return this._entity;
      }
   }
}
