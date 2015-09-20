package com.ankamagames.dofus.types.characteristicContextual
{
   import flash.display.Sprite;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.berilia.types.event.BeriliaEvent;
   
   public class CharacteristicContextual extends Sprite
   {
       
      private var _referedEntity:IEntity;
      
      public var gameContext:uint;
      
      public function CharacteristicContextual()
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      public function get referedEntity() : IEntity
      {
         return this._referedEntity;
      }
      
      public function set referedEntity(param1:IEntity) : void
      {
         this._referedEntity = param1;
      }
      
      public function remove() : void
      {
         dispatchEvent(new BeriliaEvent(BeriliaEvent.REMOVE_COMPONENT));
      }
   }
}
