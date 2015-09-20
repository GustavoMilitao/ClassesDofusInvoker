package com.ankamagames.dofus.uiApi
{
   import com.ankamagames.berilia.interfaces.IApi;
   import com.ankamagames.berilia.types.data.UiModule;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayEntitiesFrame;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayInteractivesFrame;
   import com.ankamagames.dofus.logic.game.common.frames.SpellInventoryManagementFrame;
   import com.ankamagames.dofus.logic.game.common.frames.EmoticonFrame;
   import com.ankamagames.dofus.logic.game.roleplay.frames.ZaapFrame;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.dofus.logic.game.roleplay.managers.RoleplayManager;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayContextFrame;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayNamedActorInformations;
   import flash.utils.Dictionary;
   import com.ankamagames.jerakine.sequencer.SerialSequencer;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayNpcInformations;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.tiphon.sequence.PlayAnimationStep;
   import com.ankamagames.jerakine.interfaces.IRectangle;
   import com.ankamagames.jerakine.entities.interfaces.IDisplayable;
   import com.ankamagames.dofus.internalDatacenter.communication.ChatBubble;
   import com.ankamagames.berilia.managers.TooltipManager;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.berilia.types.LocationEnum;
   import com.ankamagames.berilia.enums.StrataEnum;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   
   [InstanciedApi]
   public class RoleplayApi extends Object implements IApi
   {
       
      private var _module:UiModule;
      
      protected var _log:Logger;
      
      public function RoleplayApi()
      {
         this._log = Log.getLogger(getQualifiedClassName(RoleplayApi));
         super();
      }
      
      private function get roleplayEntitiesFrame() : RoleplayEntitiesFrame
      {
         return Kernel.getWorker().getFrame(RoleplayEntitiesFrame) as RoleplayEntitiesFrame;
      }
      
      private function get roleplayInteractivesFrame() : RoleplayInteractivesFrame
      {
         return Kernel.getWorker().getFrame(RoleplayInteractivesFrame) as RoleplayInteractivesFrame;
      }
      
      private function get spellInventoryManagementFrame() : SpellInventoryManagementFrame
      {
         return Kernel.getWorker().getFrame(SpellInventoryManagementFrame) as SpellInventoryManagementFrame;
      }
      
      private function get roleplayEmoticonFrame() : EmoticonFrame
      {
         return Kernel.getWorker().getFrame(EmoticonFrame) as EmoticonFrame;
      }
      
      private function get zaapFrame() : ZaapFrame
      {
         return Kernel.getWorker().getFrame(ZaapFrame) as ZaapFrame;
      }
      
      [ApiData(name="module")]
      public function set module(param1:UiModule) : void
      {
         this._module = param1;
      }
      
      [Trusted]
      public function destroy() : void
      {
         this._module = null;
      }
      
      [Untrusted]
      public function getTotalFightOnCurrentMap() : uint
      {
         return this.roleplayEntitiesFrame.fightNumber;
      }
      
      [Untrusted]
      public function getSpellToForgetList() : Array
      {
         var _loc2_:SpellWrapper = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in PlayedCharacterManager.getInstance().spellsInventory)
         {
            if(_loc2_.spellLevel > 1)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      [Untrusted]
      public function getEmotesList() : Array
      {
         var _loc1_:Array = this.roleplayEmoticonFrame.emotesList;
         return _loc1_;
      }
      
      [Untrusted]
      public function getUsableEmotesList() : Array
      {
         return this.roleplayEmoticonFrame.emotes;
      }
      
      [Untrusted]
      public function getSpawnMap() : uint
      {
         return this.zaapFrame.spawnMapId;
      }
      
      [Trusted]
      public function getEntitiesOnCell(param1:int) : Array
      {
         return EntitiesManager.getInstance().getEntitiesOnCell(param1);
      }
      
      [Trusted]
      public function getPlayersIdOnCurrentMap() : Array
      {
         return this.roleplayEntitiesFrame.playersId;
      }
      
      [Trusted]
      public function getPlayerIsInCurrentMap(param1:int) : Boolean
      {
         return this.roleplayEntitiesFrame.playersId.indexOf(param1) != -1;
      }
      
      [Trusted]
      public function isUsingInteractive() : Boolean
      {
         if(!this.roleplayInteractivesFrame)
         {
            return false;
         }
         return this.roleplayInteractivesFrame.usingInteractive;
      }
      
      [Untrusted]
      public function getFight(param1:int) : Object
      {
         return this.roleplayEntitiesFrame.fights[param1];
      }
      
      [Trusted]
      public function putEntityOnTop(param1:AnimatedCharacter) : void
      {
         RoleplayManager.getInstance().putEntityOnTop(param1);
      }
      
      [Untrusted]
      public function getEntityInfos(param1:Object) : Object
      {
         var _loc2_:RoleplayContextFrame = Kernel.getWorker().getFrame(RoleplayContextFrame) as RoleplayContextFrame;
         return _loc2_.entitiesFrame.getEntityInfos(param1.id);
      }
      
      [Untrusted]
      public function getEntityByName(param1:String) : Object
      {
         var _loc3_:IEntity = null;
         var _loc4_:GameRolePlayNamedActorInformations = null;
         var _loc2_:RoleplayContextFrame = Kernel.getWorker().getFrame(RoleplayContextFrame) as RoleplayContextFrame;
         for each(_loc3_ in EntitiesManager.getInstance().entities)
         {
            _loc4_ = _loc2_.entitiesFrame.getEntityInfos(_loc3_.id) as GameRolePlayNamedActorInformations;
            if(_loc4_ && param1 == _loc4_.name)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      [Trusted]
      public function switchButtonWrappers(param1:Object, param2:Object) : void
      {
         var _loc3_:int = param2.position;
         var _loc4_:int = param1.position;
         param2.setPosition(_loc4_);
         param1.setPosition(_loc3_);
      }
      
      [Trusted]
      public function setButtonWrapperActivation(param1:Object, param2:Boolean) : void
      {
         param1.active = param2;
      }
      
      [Trusted]
      public function playEntityAnimation(param1:int, param2:String) : void
      {
         var _loc3_:RoleplayEntitiesFrame = null;
         var _loc4_:Dictionary = null;
         var _loc5_:Object = null;
         var _loc6_:AnimatedCharacter = null;
         var _loc7_:SerialSequencer = null;
         try
         {
            _loc3_ = Kernel.getWorker().getFrame(RoleplayEntitiesFrame) as RoleplayEntitiesFrame;
            _loc4_ = _loc3_.getEntitiesDictionnary();
            if(_loc4_.length <= 0)
            {
               return;
            }
            for each(_loc5_ in _loc4_)
            {
               if(_loc5_ is GameRolePlayNpcInformations && _loc5_.npcId == param1)
               {
                  _loc6_ = DofusEntities.getEntity(GameRolePlayNpcInformations(_loc5_).contextualId) as AnimatedCharacter;
                  _loc7_ = new SerialSequencer();
                  _loc7_.addStep(new PlayAnimationStep(_loc6_,param2));
                  _loc7_.start();
               }
            }
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      [Untrusted]
      public function showNpcBubble(param1:int, param2:String) : void
      {
         var _loc5_:IRectangle = null;
         var _loc6_:Object = null;
         var _loc7_:IDisplayable = null;
         var _loc8_:ChatBubble = null;
         var _loc3_:RoleplayEntitiesFrame = Kernel.getWorker().getFrame(RoleplayEntitiesFrame) as RoleplayEntitiesFrame;
         var _loc4_:Dictionary = _loc3_.getEntitiesDictionnary();
         if(_loc4_.length <= 0)
         {
            return;
         }
         for each(_loc6_ in _loc4_)
         {
            if(_loc6_ is GameRolePlayNpcInformations && _loc6_.npcId == param1)
            {
               _loc7_ = DofusEntities.getEntity(GameRolePlayNpcInformations(_loc6_).contextualId) as IDisplayable;
               _loc5_ = _loc7_.absoluteBounds;
               _loc8_ = new ChatBubble(param2);
               TooltipManager.show(_loc8_,_loc5_,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),true,"npcBubble" + param1,LocationEnum.POINT_BOTTOMLEFT,LocationEnum.POINT_TOPRIGHT,0,true,null,null,null,null,false,StrataEnum.STRATA_WORLD);
               return;
            }
         }
      }
   }
}
