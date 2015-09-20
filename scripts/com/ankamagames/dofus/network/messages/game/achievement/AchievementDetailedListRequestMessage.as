package com.ankamagames.dofus.network.messages.game.achievement
{
   import com.ankamagames.jerakine.network.NetworkMessage;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import flash.utils.ByteArray;
   import com.ankamagames.jerakine.network.CustomDataWrapper;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   
   [Trusted]
   public class AchievementDetailedListRequestMessage extends NetworkMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 6357;
       
      private var _isInitialized:Boolean = false;
      
      public var categoryId:uint = 0;
      
      public function AchievementDetailedListRequestMessage()
      {
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 6357;
      }
      
      public function initAchievementDetailedListRequestMessage(param1:uint = 0) : AchievementDetailedListRequestMessage
      {
         this.categoryId = param1;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         this.categoryId = 0;
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
         this.serializeAs_AchievementDetailedListRequestMessage(param1);
      }
      
      public function serializeAs_AchievementDetailedListRequestMessage(param1:ICustomDataOutput) : void
      {
         if(this.categoryId < 0)
         {
            throw new Error("Forbidden value (" + this.categoryId + ") on element categoryId.");
         }
         param1.writeVarShort(this.categoryId);
      }
      
      public function deserialize(param1:ICustomDataInput) : void
      {
         this.deserializeAs_AchievementDetailedListRequestMessage(param1);
      }
      
      public function deserializeAs_AchievementDetailedListRequestMessage(param1:ICustomDataInput) : void
      {
         this.categoryId = param1.readVarUhShort();
         if(this.categoryId < 0)
         {
            throw new Error("Forbidden value (" + this.categoryId + ") on element of AchievementDetailedListRequestMessage.categoryId.");
         }
      }
   }
}
