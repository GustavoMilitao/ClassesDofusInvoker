package com.ankamagames.dofus.network.messages.game.context.roleplay.fight.arena
{
   import com.ankamagames.jerakine.network.NetworkMessage;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import flash.utils.ByteArray;
   import com.ankamagames.jerakine.network.CustomDataWrapper;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   
   [Trusted]
   public class GameRolePlayArenaUpdatePlayerInfosMessage extends NetworkMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 6301;
       
      private var _isInitialized:Boolean = false;
      
      public var rank:uint = 0;
      
      public var bestDailyRank:uint = 0;
      
      public var bestRank:uint = 0;
      
      public var victoryCount:uint = 0;
      
      public var arenaFightcount:uint = 0;
      
      public function GameRolePlayArenaUpdatePlayerInfosMessage()
      {
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 6301;
      }
      
      public function initGameRolePlayArenaUpdatePlayerInfosMessage(param1:uint = 0, param2:uint = 0, param3:uint = 0, param4:uint = 0, param5:uint = 0) : GameRolePlayArenaUpdatePlayerInfosMessage
      {
         this.rank = param1;
         this.bestDailyRank = param2;
         this.bestRank = param3;
         this.victoryCount = param4;
         this.arenaFightcount = param5;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         this.rank = 0;
         this.bestDailyRank = 0;
         this.bestRank = 0;
         this.victoryCount = 0;
         this.arenaFightcount = 0;
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
         this.serializeAs_GameRolePlayArenaUpdatePlayerInfosMessage(param1);
      }
      
      public function serializeAs_GameRolePlayArenaUpdatePlayerInfosMessage(param1:ICustomDataOutput) : void
      {
         if(this.rank < 0 || this.rank > 2300)
         {
            throw new Error("Forbidden value (" + this.rank + ") on element rank.");
         }
         param1.writeVarShort(this.rank);
         if(this.bestDailyRank < 0 || this.bestDailyRank > 2300)
         {
            throw new Error("Forbidden value (" + this.bestDailyRank + ") on element bestDailyRank.");
         }
         param1.writeVarShort(this.bestDailyRank);
         if(this.bestRank < 0 || this.bestRank > 2300)
         {
            throw new Error("Forbidden value (" + this.bestRank + ") on element bestRank.");
         }
         param1.writeVarShort(this.bestRank);
         if(this.victoryCount < 0)
         {
            throw new Error("Forbidden value (" + this.victoryCount + ") on element victoryCount.");
         }
         param1.writeVarShort(this.victoryCount);
         if(this.arenaFightcount < 0)
         {
            throw new Error("Forbidden value (" + this.arenaFightcount + ") on element arenaFightcount.");
         }
         param1.writeVarShort(this.arenaFightcount);
      }
      
      public function deserialize(param1:ICustomDataInput) : void
      {
         this.deserializeAs_GameRolePlayArenaUpdatePlayerInfosMessage(param1);
      }
      
      public function deserializeAs_GameRolePlayArenaUpdatePlayerInfosMessage(param1:ICustomDataInput) : void
      {
         this.rank = param1.readVarUhShort();
         if(this.rank < 0 || this.rank > 2300)
         {
            throw new Error("Forbidden value (" + this.rank + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.rank.");
         }
         this.bestDailyRank = param1.readVarUhShort();
         if(this.bestDailyRank < 0 || this.bestDailyRank > 2300)
         {
            throw new Error("Forbidden value (" + this.bestDailyRank + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.bestDailyRank.");
         }
         this.bestRank = param1.readVarUhShort();
         if(this.bestRank < 0 || this.bestRank > 2300)
         {
            throw new Error("Forbidden value (" + this.bestRank + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.bestRank.");
         }
         this.victoryCount = param1.readVarUhShort();
         if(this.victoryCount < 0)
         {
            throw new Error("Forbidden value (" + this.victoryCount + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.victoryCount.");
         }
         this.arenaFightcount = param1.readVarUhShort();
         if(this.arenaFightcount < 0)
         {
            throw new Error("Forbidden value (" + this.arenaFightcount + ") on element of GameRolePlayArenaUpdatePlayerInfosMessage.arenaFightcount.");
         }
      }
   }
}
