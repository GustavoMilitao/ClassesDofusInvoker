package com.ankamagames.dofus.uiApi
{
   import com.ankamagames.berilia.interfaces.IApi;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.dofus.logic.connection.frames.ServerSelectionFrame;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.network.types.connection.GameServerInformations;
   import com.ankamagames.dofus.logic.connection.managers.GuestModeManager;
   import com.ankamagames.dofus.logic.game.approach.frames.GameServerApproachFrame;
   import com.ankamagames.dofus.logic.common.managers.PlayerManager;
   import com.ankamagames.dofus.datacenter.servers.Server;
   import com.ankamagames.dofus.BuildInfos;
   import com.ankamagames.dofus.network.enums.BuildTypeEnum;
   import com.ankamagames.dofus.network.enums.ServerStatusEnum;
   
   [InstanciedApi]
   [Trusted]
   public class ConnectionApi extends Object implements IApi
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(ConnectionApi));
       
      public function ConnectionApi()
      {
         super();
      }
      
      private function get serverSelectionFrame() : ServerSelectionFrame
      {
         return Kernel.getWorker().getFrame(ServerSelectionFrame) as ServerSelectionFrame;
      }
      
      [Untrusted]
      public function getUsedServers() : Vector.<GameServerInformations>
      {
         return this.serverSelectionFrame.usedServers;
      }
      
      [Untrusted]
      public function getServers() : Vector.<GameServerInformations>
      {
         return this.serverSelectionFrame.servers;
      }
      
      [Untrusted]
      public function getAvailableSlotsByServerType() : Array
      {
         return this.serverSelectionFrame.availableSlotsByServerType;
      }
      
      [Untrusted]
      public function hasGuestAccount() : Boolean
      {
         return GuestModeManager.getInstance().hasGuestAccount();
      }
      
      [Untrusted]
      public function isCharacterWaitingForChange(param1:int) : Boolean
      {
         var _loc2_:GameServerApproachFrame = Kernel.getWorker().getFrame(GameServerApproachFrame) as GameServerApproachFrame;
         if(_loc2_)
         {
            return _loc2_.isCharacterWaitingForChange(param1);
         }
         return false;
      }
      
      [Untrusted]
      public function allowAutoConnectCharacter(param1:Boolean) : void
      {
         PlayerManager.getInstance().allowAutoConnectCharacter = param1;
         PlayerManager.getInstance().autoConnectOfASpecificCharacterId = -1;
      }
      
      [Untrusted]
      public function getAutoChosenServer(param1:int) : GameServerInformations
      {
         var _loc5_:Server = null;
         var _loc6_:GameServerInformations = null;
         var _loc7_:* = 0;
         var _loc8_:GameServerInformations = null;
         var _loc9_:Object = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:int = PlayerManager.getInstance().communityId;
         for each(_loc6_ in this.serverSelectionFrame.servers)
         {
            _loc5_ = Server.getServerById(_loc6_.id);
            if(_loc5_)
            {
               if((_loc5_.communityId == _loc4_ || _loc5_.communityId == 2 || _loc4_ == 2 && _loc5_.communityId == 1) && _loc5_.gameTypeId == param1 && _loc6_.charactersCount < _loc6_.charactersSlots)
               {
                  _loc3_.push(_loc6_);
               }
            }
         }
         _loc3_.sortOn("completion",Array.NUMERIC);
         if(_loc3_.length > 0)
         {
            _loc7_ = -1;
            for each(_loc8_ in _loc3_)
            {
               if(BuildInfos.BUILD_TYPE == BuildTypeEnum.RELEASE && _loc8_.id == 36 && _loc8_.status == ServerStatusEnum.ONLINE)
               {
                  return _loc8_;
               }
               _loc9_ = Server.getServerById(_loc8_.id);
               if(_loc8_.status == ServerStatusEnum.ONLINE && _loc7_ == -1)
               {
                  _loc7_ = _loc8_.completion;
               }
               if(_loc7_ != -1 && _loc9_.population.id == _loc7_ && _loc8_.status == ServerStatusEnum.ONLINE)
               {
                  if(BuildInfos.BUILD_TYPE != BuildTypeEnum.RELEASE || _loc9_.name.indexOf("Test") == -1)
                  {
                     _loc2_.push(_loc8_);
                  }
               }
            }
            if(_loc2_.length > 0)
            {
               return _loc2_[Math.floor(Math.random() * _loc2_.length)];
            }
         }
         return null;
      }
   }
}
