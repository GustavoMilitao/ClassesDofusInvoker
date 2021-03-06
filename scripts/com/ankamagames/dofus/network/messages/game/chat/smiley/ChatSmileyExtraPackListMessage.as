package com.ankamagames.dofus.network.messages.game.chat.smiley
{
   import com.ankamagames.jerakine.network.NetworkMessage;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import flash.utils.ByteArray;
   import com.ankamagames.jerakine.network.CustomDataWrapper;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   
   [Trusted]
   public class ChatSmileyExtraPackListMessage extends NetworkMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 6596;
       
      private var _isInitialized:Boolean = false;
      
      public var packIds:Vector.<uint>;
      
      public function ChatSmileyExtraPackListMessage()
      {
         this.packIds = new Vector.<uint>();
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 6596;
      }
      
      public function initChatSmileyExtraPackListMessage(param1:Vector.<uint> = null) : ChatSmileyExtraPackListMessage
      {
         this.packIds = param1;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         this.packIds = new Vector.<uint>();
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
         this.serializeAs_ChatSmileyExtraPackListMessage(param1);
      }
      
      public function serializeAs_ChatSmileyExtraPackListMessage(param1:ICustomDataOutput) : void
      {
         param1.writeShort(this.packIds.length);
         var _loc2_:uint = 0;
         while(_loc2_ < this.packIds.length)
         {
            if(this.packIds[_loc2_] < 0)
            {
               throw new Error("Forbidden value (" + this.packIds[_loc2_] + ") on element 1 (starting at 1) of packIds.");
            }
            param1.writeByte(this.packIds[_loc2_]);
            _loc2_++;
         }
      }
      
      public function deserialize(param1:ICustomDataInput) : void
      {
         this.deserializeAs_ChatSmileyExtraPackListMessage(param1);
      }
      
      public function deserializeAs_ChatSmileyExtraPackListMessage(param1:ICustomDataInput) : void
      {
         var _loc4_:uint = 0;
         var _loc2_:uint = param1.readUnsignedShort();
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = param1.readByte();
            if(_loc4_ < 0)
            {
               throw new Error("Forbidden value (" + _loc4_ + ") on elements of packIds.");
            }
            this.packIds.push(_loc4_);
            _loc3_++;
         }
      }
   }
}
