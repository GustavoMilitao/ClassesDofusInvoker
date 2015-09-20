package com.ankamagames.dofus.network.messages.game.inventory.preset
{
   import com.ankamagames.jerakine.network.NetworkMessage;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.dofus.network.types.game.inventory.preset.IdolsPreset;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import flash.utils.ByteArray;
   import com.ankamagames.jerakine.network.CustomDataWrapper;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   
   [Trusted]
   public class IdolsPresetUpdateMessage extends NetworkMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 6606;
       
      private var _isInitialized:Boolean = false;
      
      public var idolsPreset:IdolsPreset;
      
      public function IdolsPresetUpdateMessage()
      {
         this.idolsPreset = new IdolsPreset();
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 6606;
      }
      
      public function initIdolsPresetUpdateMessage(param1:IdolsPreset = null) : IdolsPresetUpdateMessage
      {
         this.idolsPreset = param1;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         this.idolsPreset = new IdolsPreset();
         this._isInitialized = false;
      }
      
      override public function pack(param1:ICustomDataOutput) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         this.serialize(new CustomDataWrapper(_loc2_));
         writePacket(param1,this.getMessageId(),_loc2_);
      }
      
      override public function unpack(param1:ICustomDataInput, param2:uint) : void
      {
         this.deserialize(param1);
      }
      
      public function serialize(param1:ICustomDataOutput) : void
      {
         this.serializeAs_IdolsPresetUpdateMessage(param1);
      }
      
      public function serializeAs_IdolsPresetUpdateMessage(param1:ICustomDataOutput) : void
      {
         this.idolsPreset.serializeAs_IdolsPreset(param1);
      }
      
      public function deserialize(param1:ICustomDataInput) : void
      {
         this.deserializeAs_IdolsPresetUpdateMessage(param1);
      }
      
      public function deserializeAs_IdolsPresetUpdateMessage(param1:ICustomDataInput) : void
      {
         this.idolsPreset = new IdolsPreset();
         this.idolsPreset.deserialize(param1);
      }
   }
}
