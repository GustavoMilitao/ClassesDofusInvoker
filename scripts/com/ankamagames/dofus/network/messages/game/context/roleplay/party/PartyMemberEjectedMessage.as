package com.ankamagames.dofus.network.messages.game.context.roleplay.party
{
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import flash.utils.ByteArray;
   import com.ankamagames.jerakine.network.CustomDataWrapper;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   
   [Trusted]
   public class PartyMemberEjectedMessage extends PartyMemberRemoveMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 6252;
       
      private var _isInitialized:Boolean = false;
      
      public var kickerId:uint = 0;
      
      public function PartyMemberEjectedMessage()
      {
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return super.isInitialized && this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 6252;
      }
      
      public function initPartyMemberEjectedMessage(param1:uint = 0, param2:uint = 0, param3:uint = 0) : PartyMemberEjectedMessage
      {
         super.initPartyMemberRemoveMessage(param1,param2);
         this.kickerId = param3;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         super.reset();
         this.kickerId = 0;
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
      
      override public function serialize(param1:ICustomDataOutput) : void
      {
         this.serializeAs_PartyMemberEjectedMessage(param1);
      }
      
      public function serializeAs_PartyMemberEjectedMessage(param1:ICustomDataOutput) : void
      {
         super.serializeAs_PartyMemberRemoveMessage(param1);
         if(this.kickerId < 0)
         {
            throw new Error("Forbidden value (" + this.kickerId + ") on element kickerId.");
         }
         param1.writeVarInt(this.kickerId);
      }
      
      override public function deserialize(param1:ICustomDataInput) : void
      {
         this.deserializeAs_PartyMemberEjectedMessage(param1);
      }
      
      public function deserializeAs_PartyMemberEjectedMessage(param1:ICustomDataInput) : void
      {
         super.deserialize(param1);
         this.kickerId = param1.readVarUhInt();
         if(this.kickerId < 0)
         {
            throw new Error("Forbidden value (" + this.kickerId + ") on element of PartyMemberEjectedMessage.kickerId.");
         }
      }
   }
}