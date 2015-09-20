package com.ankamagames.dofus.logic.game.common.frames
{
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.dofus.network.messages.game.idol.IdolPartyRegisterRequestMessage;
   import com.ankamagames.dofus.datacenter.idols.Idol;
   import com.ankamagames.dofus.internalDatacenter.items.IdolsPresetWrapper;
   import com.ankamagames.dofus.logic.game.common.actions.IdolSelectRequestAction;
   import com.ankamagames.dofus.network.messages.game.idol.IdolSelectRequestMessage;
   import com.ankamagames.dofus.logic.game.common.actions.IdolsPresetUseAction;
   import com.ankamagames.dofus.logic.game.common.actions.IdolsPresetSaveAction;
   import com.ankamagames.dofus.network.messages.game.inventory.preset.IdolsPresetSaveMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.preset.IdolsPresetSaveResultMessage;
   import com.ankamagames.dofus.logic.game.common.actions.IdolsPresetDeleteAction;
   import com.ankamagames.dofus.network.messages.game.inventory.preset.IdolsPresetDeleteMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.preset.IdolsPresetDeleteResultMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.preset.IdolsPresetUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.idol.IdolListMessage;
   import com.ankamagames.dofus.network.messages.game.idol.IdolSelectErrorMessage;
   import com.ankamagames.dofus.network.messages.game.idol.IdolSelectedMessage;
   import com.ankamagames.dofus.network.messages.game.idol.IdolPartyRefreshMessage;
   import com.ankamagames.dofus.network.messages.game.idol.IdolPartyLostMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.items.ObjectAddedMessage;
   import com.ankamagames.dofus.network.messages.game.inventory.items.ObjectDeletedMessage;
   import com.ankamagames.dofus.internalDatacenter.items.ItemWrapper;
   import com.ankamagames.dofus.logic.game.common.managers.InventoryManager;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.dofus.network.enums.PresetSaveResultEnum;
   import com.ankamagames.dofus.network.enums.PresetDeleteResultEnum;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.dofus.logic.game.common.actions.OpenIdolsAction;
   import com.ankamagames.dofus.logic.game.common.actions.CloseIdolsAction;
   import com.ankamagames.dofus.misc.lists.ChatHookList;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.dofus.network.enums.ChatActivableChannelsEnum;
   import com.ankamagames.dofus.logic.game.common.managers.TimeManager;
   import com.ankamagames.jerakine.types.enums.Priority;
   
   public class IdolsFrame extends Object implements Frame
   {
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(IdolsFrame));
      
      private static const TYPE_IDOLS_PRESET_WRAPPER:int = 5;
       
      private var _openIdols:Boolean;
      
      private var _shortcutReplaced:Boolean;
      
      private var _presetToUse:int = -1;
      
      private var _equippingPreset:Boolean;
      
      private var _numPresetIdolsToEquip:int;
      
      private var _partyPreset:Boolean;
      
      private var _equipPresetForParty:Boolean;
      
      public function IdolsFrame()
      {
         super();
      }
      
      public function pushed() : Boolean
      {
         return true;
      }
      
      public function pulled() : Boolean
      {
         return true;
      }
      
      public function process(param1:Message) : Boolean
      {
         var _loc2_:IdolPartyRegisterRequestMessage = null;
         var _loc3_:Idol = null;
         var _loc5_:* = 0;
         var _loc6_:IdolsPresetWrapper = null;
         var _loc7_:IdolSelectRequestAction = null;
         var _loc8_:IdolSelectRequestMessage = null;
         var _loc9_:IdolsPresetUseAction = null;
         var _loc10_:IdolsPresetSaveAction = null;
         var _loc11_:IdolsPresetSaveMessage = null;
         var _loc12_:IdolsPresetSaveResultMessage = null;
         var _loc13_:IdolsPresetDeleteAction = null;
         var _loc14_:IdolsPresetDeleteMessage = null;
         var _loc15_:IdolsPresetDeleteResultMessage = null;
         var _loc16_:IdolsPresetUpdateMessage = null;
         var _loc17_:IdolListMessage = null;
         var _loc18_:* = 0;
         var _loc19_:uint = 0;
         var _loc20_:uint = 0;
         var _loc21_:Object = null;
         var _loc22_:IdolSelectErrorMessage = null;
         var _loc23_:IdolSelectedMessage = null;
         var _loc24_:Vector.<uint> = null;
         var _loc25_:IdolPartyRefreshMessage = null;
         var _loc26_:IdolPartyLostMessage = null;
         var _loc27_:ObjectAddedMessage = null;
         var _loc28_:ObjectDeletedMessage = null;
         var _loc29_:ItemWrapper = null;
         var _loc30_:* = 0;
         var _loc4_:InventoryManager = InventoryManager.getInstance();
         switch(true)
         {
            case param1 is OpenIdolsAction:
               this._openIdols = true;
               _loc2_ = new IdolPartyRegisterRequestMessage();
               _loc2_.initIdolPartyRegisterRequestMessage(true);
               ConnectionsHandler.getConnection().send(_loc2_);
               return true;
            case param1 is CloseIdolsAction:
               _loc2_ = new IdolPartyRegisterRequestMessage();
               _loc2_.initIdolPartyRegisterRequestMessage(false);
               ConnectionsHandler.getConnection().send(_loc2_);
               return true;
            case param1 is IdolSelectRequestAction:
               _loc7_ = param1 as IdolSelectRequestAction;
               _loc8_ = new IdolSelectRequestMessage();
               _loc8_.initIdolSelectRequestMessage(_loc7_.idolId,_loc7_.activate,_loc7_.party);
               ConnectionsHandler.getConnection().send(_loc8_);
               return true;
            case param1 is IdolsPresetUseAction:
               _loc9_ = param1 as IdolsPresetUseAction;
               this._presetToUse = _loc9_.presetId;
               this.usePreset(this._presetToUse,false);
               return true;
            case param1 is IdolsPresetSaveAction:
               _loc10_ = param1 as IdolsPresetSaveAction;
               _loc11_ = new IdolsPresetSaveMessage();
               _loc11_.initIdolsPresetSaveMessage(_loc10_.presetId,_loc10_.iconId);
               ConnectionsHandler.getConnection().send(_loc11_);
               return true;
            case param1 is IdolsPresetSaveResultMessage:
               _loc12_ = param1 as IdolsPresetSaveResultMessage;
               if(_loc12_.code != PresetSaveResultEnum.PRESET_SAVE_OK)
               {
               }
               return true;
            case param1 is IdolsPresetDeleteAction:
               _loc13_ = param1 as IdolsPresetDeleteAction;
               _loc14_ = new IdolsPresetDeleteMessage();
               _loc14_.initIdolsPresetDeleteMessage(_loc13_.presetId);
               ConnectionsHandler.getConnection().send(_loc14_);
               return true;
            case param1 is IdolsPresetDeleteResultMessage:
               _loc15_ = param1 as IdolsPresetDeleteResultMessage;
               if(_loc15_.code == PresetDeleteResultEnum.PRESET_DEL_OK)
               {
                  for each(_loc6_ in PlayedCharacterManager.getInstance().idolsPresets)
                  {
                     if(_loc6_.id == _loc15_.presetId)
                     {
                        _loc30_ = PlayedCharacterManager.getInstance().idolsPresets.indexOf(_loc6_);
                        break;
                     }
                  }
                  PlayedCharacterManager.getInstance().idolsPresets.splice(_loc30_,1);
                  KernelEventsManager.getInstance().processCallback(HookList.IdolsPresetDelete,_loc15_.presetId);
               }
               return true;
            case param1 is IdolsPresetUpdateMessage:
               _loc16_ = param1 as IdolsPresetUpdateMessage;
               _loc6_ = IdolsPresetWrapper.create(_loc16_.idolsPreset.presetId,_loc16_.idolsPreset.symbolId,_loc16_.idolsPreset.idolId);
               PlayedCharacterManager.getInstance().idolsPresets.push(_loc6_);
               KernelEventsManager.getInstance().processCallback(HookList.IdolsPresetSaved,_loc6_);
               return true;
            case param1 is IdolListMessage:
               _loc17_ = param1 as IdolListMessage;
               PlayedCharacterManager.getInstance().soloIdols.length = 0;
               _loc19_ = _loc17_.chosenIdols.length;
               _loc18_ = 0;
               while(_loc18_ < _loc19_)
               {
                  PlayedCharacterManager.getInstance().soloIdols.push(_loc17_.chosenIdols[_loc18_]);
                  _loc18_++;
               }
               PlayedCharacterManager.getInstance().partyIdols.length = 0;
               _loc20_ = _loc17_.partyChosenIdols.length;
               _loc18_ = 0;
               while(_loc18_ < _loc20_)
               {
                  PlayedCharacterManager.getInstance().partyIdols.push(_loc17_.partyChosenIdols[_loc18_]);
                  _loc18_++;
               }
               _loc21_ = new Object();
               _loc21_.chosenIdols = _loc17_.chosenIdols;
               _loc21_.partyChosenIdols = _loc17_.partyChosenIdols;
               _loc21_.partyIdols = _loc17_.partyIdols;
               _loc21_.presets = PlayedCharacterManager.getInstance().idolsPresets;
               if(this._openIdols && !Berilia.getInstance().getUi("idolsTab"))
               {
                  KernelEventsManager.getInstance().processCallback(HookList.OpenBook,"idolsTab",_loc21_);
               }
               else
               {
                  KernelEventsManager.getInstance().processCallback(HookList.IdolsList,_loc21_.chosenIdols,_loc21_.partyChosenIdols,_loc21_.partyIdols);
               }
               this._openIdols = false;
               return true;
            case param1 is IdolSelectErrorMessage:
               _loc22_ = param1 as IdolSelectErrorMessage;
               KernelEventsManager.getInstance().processCallback(HookList.IdolSelectError,_loc22_.reason,_loc22_.idolId,_loc22_.activate,_loc22_.party);
               if(this._equippingPreset)
               {
                  this._numPresetIdolsToEquip--;
                  if(this._numPresetIdolsToEquip == 0)
                  {
                     this.usePresetEnd();
                  }
               }
               return true;
            case param1 is IdolSelectedMessage:
               _loc23_ = param1 as IdolSelectedMessage;
               if(!_loc23_.party)
               {
                  if(!_loc23_.activate)
                  {
                     _loc5_ = PlayedCharacterManager.getInstance().soloIdols.indexOf(_loc23_.idolId);
                     if(_loc5_ != -1)
                     {
                        PlayedCharacterManager.getInstance().soloIdols.splice(_loc5_,1);
                     }
                  }
                  else
                  {
                     PlayedCharacterManager.getInstance().soloIdols.push(_loc23_.idolId);
                  }
               }
               else if(!_loc23_.activate)
               {
                  _loc5_ = PlayedCharacterManager.getInstance().partyIdols.indexOf(_loc23_.idolId);
                  if(_loc5_ != -1)
                  {
                     PlayedCharacterManager.getInstance().partyIdols.splice(_loc5_,1);
                  }
               }
               else
               {
                  PlayedCharacterManager.getInstance().partyIdols.push(_loc23_.idolId);
               }
               KernelEventsManager.getInstance().processCallback(HookList.IdolSelected,_loc23_.idolId,_loc23_.activate,_loc23_.party);
               _loc24_ = !this._partyPreset?PlayedCharacterManager.getInstance().soloIdols:PlayedCharacterManager.getInstance().partyIdols;
               if(this._presetToUse != -1 && !this._equippingPreset && _loc24_.length == 0)
               {
                  this._equippingPreset = true;
                  this.equipPreset(this._presetToUse,this._partyPreset);
               }
               if(this._equippingPreset)
               {
                  this._numPresetIdolsToEquip--;
                  if(this._numPresetIdolsToEquip == 0)
                  {
                     this.usePresetEnd();
                  }
               }
               return true;
            case param1 is IdolPartyRefreshMessage:
               _loc25_ = param1 as IdolPartyRefreshMessage;
               KernelEventsManager.getInstance().processCallback(HookList.IdolPartyRefresh,_loc25_.partyIdol);
               return true;
            case param1 is IdolPartyLostMessage:
               _loc26_ = param1 as IdolPartyLostMessage;
               KernelEventsManager.getInstance().processCallback(HookList.IdolPartyLost,_loc26_.idolId);
               return true;
            case param1 is ObjectAddedMessage:
               _loc27_ = param1 as ObjectAddedMessage;
               _loc3_ = Idol.getIdolByItemId(_loc27_.object.objectGID);
               if(_loc3_)
               {
                  KernelEventsManager.getInstance().processCallback(HookList.IdolAdded,_loc3_.id);
               }
               return false;
            case param1 is ObjectDeletedMessage:
               _loc28_ = param1 as ObjectDeletedMessage;
               _loc29_ = InventoryManager.getInstance().inventory.getItem(_loc28_.objectUID);
               _loc3_ = Idol.getIdolByItemId(_loc29_.objectGID);
               if(_loc3_)
               {
                  _loc5_ = PlayedCharacterManager.getInstance().soloIdols.indexOf(_loc3_.id);
                  if(_loc5_ != -1)
                  {
                     PlayedCharacterManager.getInstance().soloIdols.splice(_loc5_,1);
                  }
                  KernelEventsManager.getInstance().processCallback(HookList.IdolRemoved,_loc3_.id);
               }
               return false;
            default:
               return false;
         }
      }
      
      private function usePreset(param1:uint, param2:Boolean) : void
      {
         var _loc4_:uint = 0;
         var _loc5_:IdolSelectRequestMessage = null;
         this._partyPreset = param2;
         var _loc3_:Vector.<uint> = !param2?PlayedCharacterManager.getInstance().soloIdols:PlayedCharacterManager.getInstance().partyIdols;
         if(_loc3_.length == 0)
         {
            this._equippingPreset = true;
            this.equipPreset(this._presetToUse,param2);
         }
         else
         {
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = new IdolSelectRequestMessage();
               _loc5_.initIdolSelectRequestMessage(_loc4_,false,param2);
               ConnectionsHandler.getConnection().send(_loc5_);
            }
         }
      }
      
      private function usePresetEnd() : void
      {
         this._equippingPreset = false;
         KernelEventsManager.getInstance().processCallback(HookList.IdolsPresetEquipped,this._presetToUse);
         if(PlayedCharacterManager.getInstance().isPartyLeader)
         {
            if(!this._equipPresetForParty)
            {
               this._equipPresetForParty = true;
               this.usePreset(this._presetToUse,true);
            }
            else
            {
               this._equipPresetForParty = false;
               this._presetToUse = -1;
            }
         }
         else
         {
            this._presetToUse = -1;
         }
      }
      
      private function equipPreset(param1:uint, param2:Boolean) : void
      {
         var _loc3_:Vector.<uint> = null;
         var _loc4_:uint = 0;
         var _loc5_:IdolsPresetWrapper = null;
         var _loc6_:IdolSelectRequestMessage = null;
         for each(_loc5_ in PlayedCharacterManager.getInstance().idolsPresets)
         {
            if(_loc5_.id == param1)
            {
               _loc3_ = _loc5_.idolsIds;
               break;
            }
         }
         this._numPresetIdolsToEquip = _loc3_.length;
         if(this._numPresetIdolsToEquip > 0)
         {
            for each(_loc4_ in _loc3_)
            {
               _loc6_ = new IdolSelectRequestMessage();
               _loc6_.initIdolSelectRequestMessage(_loc4_,true,param2);
               ConnectionsHandler.getConnection().send(_loc6_);
            }
         }
         else
         {
            this.usePresetEnd();
         }
         if(!PlayedCharacterManager.getInstance().isPartyLeader || param2)
         {
            KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,I18n.getUiText("ui.idol.preset.inUse",[param1 + 1]),ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp());
         }
      }
      
      public function get priority() : int
      {
         return Priority.HIGH;
      }
   }
}
