package com.ankamagames.dofus.network.types.game.idol
{
   import com.ankamagames.jerakine.network.INetworkType;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   
   [Trusted]
   public class PartyIdol extends Idol implements INetworkType
   {
      
      public static const protocolId:uint = 490;
       
      public var ownersIds:Vector.<int>;
      
      public function PartyIdol()
      {
         this.ownersIds = new Vector.<int>();
         super();
      }
      
      override public function getTypeId() : uint
      {
         return 490;
      }
      
      public function initPartyIdol(param1:uint = 0, param2:uint = 0, param3:uint = 0, param4:Vector.<int> = null) : PartyIdol
      {
         super.initIdol(param1,param2,param3);
         this.ownersIds = param4;
         return this;
      }
      
      override public function reset() : void
      {
         super.reset();
         this.ownersIds = new Vector.<int>();
      }
      
      override public function serialize(param1:ICustomDataOutput) : void
      {
         this.serializeAs_PartyIdol(param1);
      }
      
      public function serializeAs_PartyIdol(param1:ICustomDataOutput) : void
      {
         super.serializeAs_Idol(param1);
         param1.writeShort(this.ownersIds.length);
         var _loc2_:uint = 0;
         while(_loc2_ < this.ownersIds.length)
         {
            param1.writeInt(this.ownersIds[_loc2_]);
            _loc2_++;
         }
      }
      
      override public function deserialize(param1:ICustomDataInput) : void
      {
         this.deserializeAs_PartyIdol(param1);
      }
      
      public function deserializeAs_PartyIdol(param1:ICustomDataInput) : void
      {
         var _loc4_:* = 0;
         super.deserialize(param1);
         var _loc2_:uint = param1.readUnsignedShort();
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = param1.readInt();
            this.ownersIds.push(_loc4_);
            _loc3_++;
         }
      }
   }
}
