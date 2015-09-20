package com.ankamagames.dofus.logic.game.common.frames
{
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayNamedActorInformations;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayContextFrame;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayEntitiesFrame;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayMovementFrame;
   import com.ankamagames.dofus.network.types.game.data.items.ObjectItem;
   import com.ankamagames.dofus.logic.game.common.managers.InventoryManager;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeRequestedTradeMessage;
   import com.ankamagames.dofus.logic.game.common.actions.LeaveDialogAction;
   import com.ankamagames.dofus.network.enums.ExchangeTypeEnum;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.misc.lists.ExchangeHookList;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeStartOkNpcTradeMessage;
   import com.ankamagames.dofus.datacenter.npcs.Npc;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayNpcInformations;
   import com.ankamagames.dofus.misc.EntityLookAdapter;
   import com.ankamagames.tiphon.types.look.TiphonEntityLook;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeStartOkRunesTradeMessage;
   import com.ankamagames.dofus.misc.lists.CraftHookList;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeStartOkRecycleTradeMessage;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeStartedWithStorageMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeStartedMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.storage.StorageInventoryContentMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.storage.StorageObjectUpdateMessage;
   import com.ankamagames.dofus.internalDatacenter.items.ItemWrapper;
   import com.ankamagames.dofus.network.messages.game.inventory.storage.StorageObjectRemoveMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.storage.StorageObjectsUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.storage.StorageObjectsRemoveMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.storage.StorageKamasUpdateMessage;
   import com.ankamagames.dofus.logic.game.common.actions.exchange.ExchangeObjectMoveKamaAction;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeObjectMoveKamaMessage;
   import com.ankamagames.dofus.logic.game.common.actions.exchange.ExchangeObjectTransfertAllToInvAction;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeObjectTransfertAllToInvMessage;
   import com.ankamagames.dofus.logic.game.common.actions.exchange.ExchangeObjectTransfertListToInvAction;
   import com.ankamagames.dofus.logic.game.common.actions.exchange.ExchangeObjectTransfertListWithQuantityToInvAction;
   import com.ankamagames.dofus.logic.game.common.actions.exchange.ExchangeObjectTransfertExistingToInvAction;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeObjectTransfertExistingToInvMessage;
   import com.ankamagames.dofus.logic.game.common.actions.exchange.ExchangeObjectTransfertAllFromInvAction;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeObjectTransfertAllFromInvMessage;
   import com.ankamagames.dofus.logic.game.common.actions.exchange.ExchangeObjectTransfertListFromInvAction;
   import com.ankamagames.dofus.logic.game.common.actions.exchange.ExchangeObjectTransfertExistingFromInvAction;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeObjectTransfertExistingFromInvMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeStartOkNpcShopMessage;
   import com.ankamagames.dofus.network.types.game.context.GameContextActorInformations;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.RecycleResultMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeLeaveMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeStartedWithPodsMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeObjectTransfertListToInvMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeObjectTransfertListWithQuantityToInvMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeObjectTransfertListFromInvMessage;
   import com.ankamagames.dofus.network.types.game.data.items.ObjectItemToSellInNpcShop;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.InventoryHookList;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.dofus.network.ProtocolConstantsEnum;
   import com.ankamagames.dofus.misc.lists.ChatHookList;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.dofus.network.enums.ChatActivableChannelsEnum;
   import com.ankamagames.dofus.logic.game.common.managers.TimeManager;
   import com.ankamagames.dofus.logic.common.actions.ChangeWorldInteractionAction;
   import com.ankamagames.dofus.datacenter.items.criterion.GroupItemCriterion;
   import com.ankamagames.dofus.network.messages.game.dialog.LeaveDialogRequestMessage;
   import com.ankamagames.dofus.network.enums.DialogTypeEnum;
   import com.ankamagames.dofus.logic.game.roleplay.actions.LeaveDialogRequestAction;
   
   public class ExchangeManagementFrame extends Object implements Frame
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(ExchangeManagementFrame));
       
      private var _priority:int = 0;
      
      private var _sourceInformations:GameRolePlayNamedActorInformations;
      
      private var _targetInformations:GameRolePlayNamedActorInformations;
      
      private var _meReady:Boolean = false;
      
      private var _youReady:Boolean = false;
      
      private var _exchangeInventory:Array;
      
      private var _success:Boolean;
      
      public function ExchangeManagementFrame()
      {
         super();
      }
      
      public function get priority() : int
      {
         return this._priority;
      }
      
      public function set priority(param1:int) : void
      {
         this._priority = param1;
      }
      
      private function get roleplayContextFrame() : RoleplayContextFrame
      {
         return Kernel.getWorker().getFrame(RoleplayContextFrame) as RoleplayContextFrame;
      }
      
      private function get roleplayEntitiesFrame() : RoleplayEntitiesFrame
      {
         return Kernel.getWorker().getFrame(RoleplayEntitiesFrame) as RoleplayEntitiesFrame;
      }
      
      private function get roleplayMovementFrame() : RoleplayMovementFrame
      {
         return Kernel.getWorker().getFrame(RoleplayMovementFrame) as RoleplayMovementFrame;
      }
      
      public function initMountStock(param1:Vector.<ObjectItem>) : void
      {
         InventoryManager.getInstance().bankInventory.initializeFromObjectItems(param1);
         InventoryManager.getInstance().bankInventory.releaseHooks();
      }
      
      public function processExchangeRequestedTradeMessage(param1:ExchangeRequestedTradeMessage) : void
      {
         var _loc4_:SocialFrame = null;
         var _loc5_:LeaveDialogAction = null;
         if(param1.exchangeType != ExchangeTypeEnum.PLAYER_TRADE)
         {
            return;
         }
         this._sourceInformations = this.roleplayEntitiesFrame.getEntityInfos(param1.source) as GameRolePlayNamedActorInformations;
         this._targetInformations = this.roleplayEntitiesFrame.getEntityInfos(param1.target) as GameRolePlayNamedActorInformations;
         var _loc2_:String = this._sourceInformations.name;
         var _loc3_:String = this._targetInformations.name;
         if(param1.source == PlayedCharacterManager.getInstance().id)
         {
            this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeRequestCharacterFromMe,_loc2_,_loc3_);
         }
         else
         {
            _loc4_ = Kernel.getWorker().getFrame(SocialFrame) as SocialFrame;
            if(_loc4_ && _loc4_.isIgnored(_loc2_))
            {
               _loc5_ = new LeaveDialogAction();
               Kernel.getWorker().process(_loc5_);
               return;
            }
            this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeRequestCharacterToMe,_loc3_,_loc2_);
         }
      }
      
      public function processExchangeStartOkNpcTradeMessage(param1:ExchangeStartOkNpcTradeMessage) : void
      {
         var _loc2_:String = PlayedCharacterManager.getInstance().infos.name;
         var _loc3_:int = this.roleplayEntitiesFrame.getEntityInfos(param1.npcId).contextualId;
         var _loc4_:Npc = Npc.getNpcById(_loc3_);
         var _loc5_:String = Npc.getNpcById((this.roleplayEntitiesFrame.getEntityInfos(param1.npcId) as GameRolePlayNpcInformations).npcId).name;
         var _loc6_:TiphonEntityLook = EntityLookAdapter.getRiderLook(PlayedCharacterManager.getInstance().infos.entityLook);
         var _loc7_:TiphonEntityLook = EntityLookAdapter.getRiderLook(this.roleplayContextFrame.entitiesFrame.getEntityInfos(param1.npcId).look);
         var _loc8_:ExchangeStartOkNpcTradeMessage = param1 as ExchangeStartOkNpcTradeMessage;
         PlayedCharacterManager.getInstance().isInExchange = true;
         this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStartOkNpcTrade,_loc8_.npcId,_loc2_,_loc5_,_loc6_,_loc7_);
         this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStartedType,ExchangeTypeEnum.NPC_TRADE);
      }
      
      public function processExchangeStartOkRunesTradeMessage(param1:ExchangeStartOkRunesTradeMessage) : void
      {
         var _loc2_:ExchangeStartOkRunesTradeMessage = param1 as ExchangeStartOkRunesTradeMessage;
         PlayedCharacterManager.getInstance().isInExchange = true;
         this._kernelEventsManager.processCallback(CraftHookList.ExchangeStartOkRunesTrade);
         this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStartedType,ExchangeTypeEnum.RUNES_TRADE);
      }
      
      public function processExchangeStartOkRecycleTradeMessage(param1:ExchangeStartOkRecycleTradeMessage) : void
      {
         var _loc2_:ExchangeStartOkRecycleTradeMessage = param1 as ExchangeStartOkRecycleTradeMessage;
         PlayedCharacterManager.getInstance().isInExchange = true;
         this._kernelEventsManager.processCallback(CraftHookList.ExchangeStartOkRecycleTrade,_loc2_.percentToPlayer,_loc2_.percentToPrism);
         this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStartedType,ExchangeTypeEnum.RECYCLE_TRADE);
      }
      
      public function process(param1:Message) : Boolean
      {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc4_:ExchangeStartedWithStorageMessage = null;
         var _loc5_:CommonExchangeManagementFrame = null;
         var _loc6_:* = 0;
         var _loc7_:ExchangeStartedMessage = null;
         var _loc8_:CommonExchangeManagementFrame = null;
         var _loc9_:StorageInventoryContentMessage = null;
         var _loc10_:StorageObjectUpdateMessage = null;
         var _loc11_:ObjectItem = null;
         var _loc12_:ItemWrapper = null;
         var _loc13_:StorageObjectRemoveMessage = null;
         var _loc14_:StorageObjectsUpdateMessage = null;
         var _loc15_:StorageObjectsRemoveMessage = null;
         var _loc16_:StorageKamasUpdateMessage = null;
         var _loc17_:ExchangeObjectMoveKamaAction = null;
         var _loc18_:ExchangeObjectMoveKamaMessage = null;
         var _loc19_:ExchangeObjectTransfertAllToInvAction = null;
         var _loc20_:ExchangeObjectTransfertAllToInvMessage = null;
         var _loc21_:ExchangeObjectTransfertListToInvAction = null;
         var _loc22_:ExchangeObjectTransfertListWithQuantityToInvAction = null;
         var _loc23_:ExchangeObjectTransfertExistingToInvAction = null;
         var _loc24_:ExchangeObjectTransfertExistingToInvMessage = null;
         var _loc25_:ExchangeObjectTransfertAllFromInvAction = null;
         var _loc26_:ExchangeObjectTransfertAllFromInvMessage = null;
         var _loc27_:ExchangeObjectTransfertListFromInvAction = null;
         var _loc28_:ExchangeObjectTransfertExistingFromInvAction = null;
         var _loc29_:ExchangeObjectTransfertExistingFromInvMessage = null;
         var _loc30_:ExchangeStartOkNpcShopMessage = null;
         var _loc31_:GameContextActorInformations = null;
         var _loc32_:TiphonEntityLook = null;
         var _loc33_:Array = null;
         var _loc34_:ExchangeStartOkRunesTradeMessage = null;
         var _loc35_:ExchangeStartOkRecycleTradeMessage = null;
         var _loc36_:RecycleResultMessage = null;
         var _loc37_:ExchangeLeaveMessage = null;
         var _loc38_:String = null;
         var _loc39_:String = null;
         var _loc40_:TiphonEntityLook = null;
         var _loc41_:TiphonEntityLook = null;
         var _loc42_:ExchangeStartedWithPodsMessage = null;
         var _loc43_:* = 0;
         var _loc44_:* = 0;
         var _loc45_:* = 0;
         var _loc46_:* = 0;
         var _loc47_:* = 0;
         var _loc48_:ObjectItem = null;
         var _loc49_:ObjectItem = null;
         var _loc50_:ItemWrapper = null;
         var _loc51_:uint = 0;
         var _loc52_:ExchangeObjectTransfertListToInvMessage = null;
         var _loc53_:ExchangeObjectTransfertListWithQuantityToInvMessage = null;
         var _loc54_:ExchangeObjectTransfertListFromInvMessage = null;
         var _loc55_:ObjectItemToSellInNpcShop = null;
         var _loc56_:ItemWrapper = null;
         switch(true)
         {
            case param1 is ExchangeStartedWithStorageMessage:
               _loc4_ = param1 as ExchangeStartedWithStorageMessage;
               PlayedCharacterManager.getInstance().isInExchange = true;
               _loc5_ = Kernel.getWorker().getFrame(CommonExchangeManagementFrame) as CommonExchangeManagementFrame;
               if(_loc5_)
               {
                  _loc5_.resetEchangeSequence();
               }
               _loc6_ = _loc4_.storageMaxSlot;
               this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeBankStartedWithStorage,ExchangeTypeEnum.STORAGE,_loc6_);
               return false;
            case param1 is ExchangeStartedMessage:
               _loc7_ = param1 as ExchangeStartedMessage;
               PlayedCharacterManager.getInstance().isInExchange = true;
               _loc8_ = Kernel.getWorker().getFrame(CommonExchangeManagementFrame) as CommonExchangeManagementFrame;
               if(_loc8_)
               {
                  _loc8_.resetEchangeSequence();
               }
               switch(_loc7_.exchangeType)
               {
                  case ExchangeTypeEnum.PLAYER_TRADE:
                     _loc38_ = this._sourceInformations.name;
                     _loc39_ = this._targetInformations.name;
                     _loc40_ = EntityLookAdapter.getRiderLook(this._sourceInformations.look);
                     _loc41_ = EntityLookAdapter.getRiderLook(this._targetInformations.look);
                     if(_loc7_.getMessageId() == ExchangeStartedWithPodsMessage.protocolId)
                     {
                        _loc42_ = param1 as ExchangeStartedWithPodsMessage;
                     }
                     _loc43_ = -1;
                     _loc44_ = -1;
                     _loc45_ = -1;
                     _loc46_ = -1;
                     if(_loc42_ != null)
                     {
                        if(_loc42_.firstCharacterId == this._sourceInformations.contextualId)
                        {
                           _loc43_ = _loc42_.firstCharacterCurrentWeight;
                           _loc44_ = _loc42_.secondCharacterCurrentWeight;
                           _loc45_ = _loc42_.firstCharacterMaxWeight;
                           _loc46_ = _loc42_.secondCharacterMaxWeight;
                        }
                        else
                        {
                           _loc44_ = _loc42_.firstCharacterCurrentWeight;
                           _loc43_ = _loc42_.secondCharacterCurrentWeight;
                           _loc46_ = _loc42_.firstCharacterMaxWeight;
                           _loc45_ = _loc42_.secondCharacterMaxWeight;
                        }
                     }
                     if(PlayedCharacterManager.getInstance().id == _loc42_.firstCharacterId)
                     {
                        _loc47_ = _loc42_.secondCharacterId;
                     }
                     else
                     {
                        _loc47_ = _loc42_.firstCharacterId;
                     }
                     this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStarted,_loc38_,_loc39_,_loc40_,_loc41_,_loc43_,_loc44_,_loc45_,_loc46_,_loc47_);
                     this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStartedType,_loc7_.exchangeType);
                     return true;
                  case ExchangeTypeEnum.STORAGE:
                     this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStartedType,_loc7_.exchangeType);
                     return true;
                  case ExchangeTypeEnum.TAXCOLLECTOR:
                     this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStartedType,_loc7_.exchangeType);
                     return true;
                  default:
                     return true;
               }
            case param1 is StorageInventoryContentMessage:
               _loc9_ = param1 as StorageInventoryContentMessage;
               InventoryManager.getInstance().bankInventory.kamas = _loc9_.kamas;
               InventoryManager.getInstance().bankInventory.initializeFromObjectItems(_loc9_.objects);
               InventoryManager.getInstance().bankInventory.releaseHooks();
               return true;
            case param1 is StorageObjectUpdateMessage:
               _loc10_ = param1 as StorageObjectUpdateMessage;
               _loc11_ = _loc10_.object;
               _loc12_ = ItemWrapper.create(_loc11_.position,_loc11_.objectUID,_loc11_.objectGID,_loc11_.quantity,_loc11_.effects);
               InventoryManager.getInstance().bankInventory.modifyItem(_loc12_);
               InventoryManager.getInstance().bankInventory.releaseHooks();
               return true;
            case param1 is StorageObjectRemoveMessage:
               _loc13_ = param1 as StorageObjectRemoveMessage;
               InventoryManager.getInstance().bankInventory.removeItem(_loc13_.objectUID);
               InventoryManager.getInstance().bankInventory.releaseHooks();
               return true;
            case param1 is StorageObjectsUpdateMessage:
               _loc14_ = param1 as StorageObjectsUpdateMessage;
               for each(_loc49_ in _loc14_.objectList)
               {
                  _loc50_ = ItemWrapper.create(_loc49_.position,_loc49_.objectUID,_loc49_.objectGID,_loc49_.quantity,_loc49_.effects);
                  InventoryManager.getInstance().bankInventory.modifyItem(_loc50_);
               }
               InventoryManager.getInstance().bankInventory.releaseHooks();
               return true;
            case param1 is StorageObjectsRemoveMessage:
               _loc15_ = param1 as StorageObjectsRemoveMessage;
               for each(_loc51_ in _loc15_.objectUIDList)
               {
                  InventoryManager.getInstance().bankInventory.removeItem(_loc51_);
               }
               InventoryManager.getInstance().bankInventory.releaseHooks();
               return true;
            case param1 is StorageKamasUpdateMessage:
               _loc16_ = param1 as StorageKamasUpdateMessage;
               InventoryManager.getInstance().bankInventory.kamas = _loc16_.kamasTotal;
               KernelEventsManager.getInstance().processCallback(InventoryHookList.StorageKamasUpdate,_loc16_.kamasTotal);
               return true;
            case param1 is ExchangeObjectMoveKamaAction:
               _loc17_ = param1 as ExchangeObjectMoveKamaAction;
               _loc18_ = new ExchangeObjectMoveKamaMessage();
               _loc18_.initExchangeObjectMoveKamaMessage(_loc17_.kamas);
               ConnectionsHandler.getConnection().send(_loc18_);
               return true;
            case param1 is ExchangeObjectTransfertAllToInvAction:
               _loc19_ = param1 as ExchangeObjectTransfertAllToInvAction;
               _loc20_ = new ExchangeObjectTransfertAllToInvMessage();
               _loc20_.initExchangeObjectTransfertAllToInvMessage();
               ConnectionsHandler.getConnection().send(_loc20_);
               return true;
            case param1 is ExchangeObjectTransfertListToInvAction:
               _loc21_ = param1 as ExchangeObjectTransfertListToInvAction;
               if(_loc21_.ids.length > ProtocolConstantsEnum.MAX_OBJ_COUNT_BY_XFERT)
               {
                  KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,I18n.getUiText("ui.exchange.partialTransfert"),ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp());
               }
               if(_loc21_.ids.length >= ProtocolConstantsEnum.MIN_OBJ_COUNT_BY_XFERT)
               {
                  _loc52_ = new ExchangeObjectTransfertListToInvMessage();
                  _loc52_.initExchangeObjectTransfertListToInvMessage(_loc21_.ids.slice(0,ProtocolConstantsEnum.MAX_OBJ_COUNT_BY_XFERT));
                  ConnectionsHandler.getConnection().send(_loc52_);
               }
               return true;
            case param1 is ExchangeObjectTransfertListWithQuantityToInvAction:
               _loc22_ = param1 as ExchangeObjectTransfertListWithQuantityToInvAction;
               if(_loc22_.ids.length > ProtocolConstantsEnum.MAX_OBJ_COUNT_BY_XFERT / 2)
               {
                  KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,I18n.getUiText("ui.exchange.partialTransfert"),ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp());
               }
               if(_loc22_.ids.length >= ProtocolConstantsEnum.MIN_OBJ_COUNT_BY_XFERT && _loc22_.ids.length == _loc22_.qtys.length)
               {
                  _loc53_ = new ExchangeObjectTransfertListWithQuantityToInvMessage();
                  _loc53_.initExchangeObjectTransfertListWithQuantityToInvMessage(_loc22_.ids.slice(0,ProtocolConstantsEnum.MAX_OBJ_COUNT_BY_XFERT / 2),_loc22_.qtys.slice(0,ProtocolConstantsEnum.MAX_OBJ_COUNT_BY_XFERT / 2));
                  ConnectionsHandler.getConnection().send(_loc53_);
               }
               return true;
            case param1 is ExchangeObjectTransfertExistingToInvAction:
               _loc23_ = param1 as ExchangeObjectTransfertExistingToInvAction;
               _loc24_ = new ExchangeObjectTransfertExistingToInvMessage();
               _loc24_.initExchangeObjectTransfertExistingToInvMessage();
               ConnectionsHandler.getConnection().send(_loc24_);
               return true;
            case param1 is ExchangeObjectTransfertAllFromInvAction:
               _loc25_ = param1 as ExchangeObjectTransfertAllFromInvAction;
               _loc26_ = new ExchangeObjectTransfertAllFromInvMessage();
               _loc26_.initExchangeObjectTransfertAllFromInvMessage();
               ConnectionsHandler.getConnection().send(_loc26_);
               return true;
            case param1 is ExchangeObjectTransfertListFromInvAction:
               _loc27_ = param1 as ExchangeObjectTransfertListFromInvAction;
               if(_loc27_.ids.length > ProtocolConstantsEnum.MAX_OBJ_COUNT_BY_XFERT)
               {
                  KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,I18n.getUiText("ui.exchange.partialTransfert"),ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp());
               }
               if(_loc27_.ids.length >= ProtocolConstantsEnum.MIN_OBJ_COUNT_BY_XFERT)
               {
                  _loc54_ = new ExchangeObjectTransfertListFromInvMessage();
                  _loc54_.initExchangeObjectTransfertListFromInvMessage(_loc27_.ids.slice(0,ProtocolConstantsEnum.MAX_OBJ_COUNT_BY_XFERT));
                  ConnectionsHandler.getConnection().send(_loc54_);
               }
               return true;
            case param1 is ExchangeObjectTransfertExistingFromInvAction:
               _loc28_ = param1 as ExchangeObjectTransfertExistingFromInvAction;
               _loc29_ = new ExchangeObjectTransfertExistingFromInvMessage();
               _loc29_.initExchangeObjectTransfertExistingFromInvMessage();
               ConnectionsHandler.getConnection().send(_loc29_);
               return true;
            case param1 is ExchangeStartOkNpcShopMessage:
               _loc30_ = param1 as ExchangeStartOkNpcShopMessage;
               PlayedCharacterManager.getInstance().isInExchange = true;
               Kernel.getWorker().process(ChangeWorldInteractionAction.create(false,true));
               _loc31_ = this.roleplayContextFrame.entitiesFrame.getEntityInfos(_loc30_.npcSellerId);
               _loc32_ = EntityLookAdapter.getRiderLook(_loc31_.look);
               _loc33_ = new Array();
               for each(_loc55_ in _loc30_.objectsInfos)
               {
                  _loc56_ = ItemWrapper.create(63,0,_loc55_.objectGID,0,_loc55_.effects,false);
                  _loc33_.push({
                     "item":_loc56_,
                     "price":_loc55_.objectPrice,
                     "criterion":new GroupItemCriterion(_loc55_.buyCriterion)
                  });
               }
               this._kernelEventsManager.processCallback(ExchangeHookList.ExchangeStartOkNpcShop,_loc30_.npcSellerId,_loc33_,_loc32_,_loc30_.tokenId);
               return true;
            case param1 is ExchangeStartOkRunesTradeMessage:
               _loc34_ = param1 as ExchangeStartOkRunesTradeMessage;
               PlayedCharacterManager.getInstance().isInExchange = true;
               KernelEventsManager.getInstance().processCallback(CraftHookList.ExchangeStartOkRunesTrade);
               return true;
            case param1 is ExchangeStartOkRecycleTradeMessage:
               _loc35_ = param1 as ExchangeStartOkRecycleTradeMessage;
               PlayedCharacterManager.getInstance().isInExchange = true;
               KernelEventsManager.getInstance().processCallback(CraftHookList.ExchangeStartOkRecycleTrade,_loc35_.percentToPlayer,_loc35_.percentToPrism);
               return true;
            case param1 is RecycleResultMessage:
               _loc36_ = param1 as RecycleResultMessage;
               KernelEventsManager.getInstance().processCallback(CraftHookList.RecycleResult,_loc36_.nuggetsForPlayer,_loc36_.nuggetsForPrism);
               KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,I18n.getUiText("ui.recycle.resultDetailed",[_loc36_.nuggetsForPlayer,_loc36_.nuggetsForPrism]),ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp());
               return true;
            case param1 is LeaveDialogRequestAction:
               ConnectionsHandler.getConnection().send(new LeaveDialogRequestMessage());
               return true;
            case param1 is ExchangeLeaveMessage:
               _loc37_ = param1 as ExchangeLeaveMessage;
               if(_loc37_.dialogType == DialogTypeEnum.DIALOG_EXCHANGE)
               {
                  PlayedCharacterManager.getInstance().isInExchange = false;
                  this._success = _loc37_.success;
                  Kernel.getWorker().removeFrame(this);
               }
               return true;
            default:
               return false;
         }
      }
      
      private function proceedExchange() : void
      {
      }
      
      public function pushed() : Boolean
      {
         this._success = false;
         return true;
      }
      
      public function pulled() : Boolean
      {
         if(Kernel.getWorker().contains(CommonExchangeManagementFrame))
         {
            Kernel.getWorker().removeFrame(Kernel.getWorker().getFrame(CommonExchangeManagementFrame));
         }
         KernelEventsManager.getInstance().processCallback(ExchangeHookList.ExchangeLeave,this._success);
         this._exchangeInventory = null;
         return true;
      }
      
      private function get _kernelEventsManager() : KernelEventsManager
      {
         return KernelEventsManager.getInstance();
      }
   }
}
