package com.ankamagames.dofus.logic.game.fight.frames
{
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.filters.GlowFilter;
   import flash.filters.ColorMatrixFilter;
   import com.ankamagames.jerakine.utils.memory.WeakReference;
   import flash.utils.Timer;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import flash.utils.Dictionary;
   import com.ankamagames.dofus.network.types.game.context.roleplay.party.NamedPartyTeam;
   import com.ankamagames.dofus.network.types.game.idol.Idol;
   import com.ankamagames.jerakine.types.enums.Priority;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.frames.PartyManagementFrame;
   import com.ankamagames.atouin.Atouin;
   import flash.events.TimerEvent;
   import com.ankamagames.dofus.logic.game.roleplay.frames.MonstersInfoFrame;
   import com.ankamagames.jerakine.managers.OptionManager;
   import com.ankamagames.jerakine.types.events.PropertyChangeEvent;
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.berilia.types.event.UiUnloadEvent;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightCompanionInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightTaxCollectorInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterNamedInformations;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.dofus.datacenter.monsters.Companion;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.dofus.datacenter.npcs.TaxCollectorFirstname;
   import com.ankamagames.dofus.datacenter.npcs.TaxCollectorName;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMutantInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightCharacterInformations;
   import com.ankamagames.dofus.internalDatacenter.fight.ChallengeWrapper;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightStartingMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.CurrentMapMessage;
   import com.ankamagames.dofus.internalDatacenter.world.WorldPointWrapper;
   import flash.utils.ByteArray;
   import com.ankamagames.dofus.network.messages.game.context.GameContextReadyMessage;
   import com.ankamagames.atouin.messages.MapsLoadingCompleteMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightResumeMessage;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightResumeSlaveInfo;
   import com.ankamagames.dofus.logic.game.fight.managers.CurrentPlayedFighterManager;
   import com.ankamagames.dofus.logic.game.fight.types.SpellCastInFightManager;
   import com.ankamagames.dofus.logic.game.fight.types.CastingSpell;
   import com.ankamagames.dofus.network.types.game.action.fight.FightDispellableEffectExtendedInformations;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightUpdateTeamMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightSpectateMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightSpectatorJoinMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightJoinMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightCarryCharacterMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightStartMessage;
   import com.ankamagames.atouin.messages.CellOverMessage;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.dofus.logic.game.fight.managers.MarkedCellsManager;
   import com.ankamagames.dofus.logic.game.fight.types.MarkInstance;
   import com.ankamagames.atouin.messages.CellOutMessage;
   import com.ankamagames.jerakine.entities.messages.EntityMouseOverMessage;
   import com.ankamagames.jerakine.entities.messages.EntityMouseOutMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightLeaveMessage;
   import com.ankamagames.dofus.logic.game.fight.actions.TimelineEntityOverAction;
   import com.ankamagames.dofus.logic.game.fight.actions.TimelineEntityOutAction;
   import com.ankamagames.dofus.logic.game.fight.actions.TogglePointCellAction;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightEndMessage;
   import com.ankamagames.dofus.logic.game.fight.actions.ChallengeTargetsListRequestAction;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeTargetsListRequestMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeTargetsListMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeInfoMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeTargetUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.challenge.ChallengeResultMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.MapObstacleUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightNoSpellCastMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightResumeWithSlavesMessage;
   import com.ankamagames.dofus.logic.game.fight.types.BasicBuff;
   import com.ankamagames.dofus.types.entities.Glyph;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.dofus.logic.game.common.messages.FightEndingMessage;
   import com.ankamagames.dofus.internalDatacenter.fight.FightResultEntryWrapper;
   import com.ankamagames.dofus.network.types.game.context.fight.FightResultListEntry;
   import com.ankamagames.dofus.network.types.game.context.roleplay.party.NamedPartyTeamWithOutcome;
   import com.ankamagames.dofus.internalDatacenter.items.ItemWrapper;
   import com.ankamagames.dofus.network.types.game.interactive.MapObstacle;
   import com.ankamagames.dofus.datacenter.spells.SpellLevel;
   import com.ankamagames.berilia.managers.TooltipManager;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.dofus.logic.game.fight.fightEvents.FightEventsHelper;
   import com.ankamagames.dofus.kernel.sound.SoundManager;
   import com.ankamagames.dofus.kernel.sound.enum.UISoundEnum;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.dofus.logic.game.fight.managers.TacticModeManager;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.hurlant.util.Hex;
   import com.ankamagames.dofus.misc.lists.FightHookList;
   import com.ankamagames.atouin.managers.*;
   import com.ankamagames.atouin.renderers.*;
   import com.ankamagames.atouin.types.*;
   import com.ankamagames.jerakine.entities.interfaces.*;
   import com.ankamagames.dofus.datacenter.spells.Spell;
   import com.ankamagames.dofus.logic.game.fight.managers.BuffManager;
   import com.ankamagames.dofus.network.enums.TeamEnum;
   import com.ankamagames.dofus.logic.game.fight.types.StatBuff;
   import com.ankamagames.dofus.network.enums.GameActionMarkTypeEnum;
   import com.ankamagames.dofus.logic.game.fight.managers.LinkedCellsManager;
   import com.ankamagames.dofus.logic.game.fight.types.FightEventEnum;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.berilia.managers.SecureCenter;
   import com.ankamagames.dofus.network.types.game.context.fight.FightResultPlayerListEntry;
   import com.ankamagames.dofus.network.types.game.context.fight.FightResultTaxCollectorListEntry;
   import com.ankamagames.dofus.network.types.game.context.fight.FightResultFighterListEntry;
   import com.ankamagames.dofus.network.enums.FightOutcomeEnum;
   import com.ankamagames.dofus.misc.lists.TriggerHookList;
   import com.ankamagames.dofus.logic.game.common.managers.SpeakingItemManager;
   import com.ankamagames.dofus.logic.common.managers.HyperlinkShowCellManager;
   import com.ankamagames.dofus.network.enums.MapObstacleStateEnum;
   import com.ankamagames.dofus.uiApi.PlayedCharacterApi;
   import com.ankamagames.atouin.messages.MapLoadedMessage;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.dofus.network.messages.game.context.GameContextDestroyMessage;
   import com.ankamagames.dofus.logic.game.fight.actions.ShowTacticModeAction;
   import com.ankamagames.jerakine.sequencer.SerialSequencer;
   import com.ankamagames.dofus.logic.game.common.frames.SpellInventoryManagementFrame;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import flash.display.Sprite;
   import com.ankamagames.dofus.logic.game.fight.miscs.PushUtil;
   import com.ankamagames.berilia.types.tooltip.TooltipPlacer;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageInfo;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamage;
   import com.ankamagames.dofus.logic.game.fight.types.EffectDamage;
   import com.ankamagames.jerakine.types.zones.IZone;
   import com.ankamagames.dofus.logic.game.fight.types.PushedEntity;
   import com.ankamagames.dofus.logic.game.fight.types.TriggeredSpell;
   import com.ankamagames.dofus.logic.game.fight.types.SplashDamage;
   import com.ankamagames.dofus.logic.game.fight.miscs.DamageUtil;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellZoneManager;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageList;
   import com.ankamagames.jerakine.interfaces.IRectangle;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.berilia.types.LocationEnum;
   import com.ankamagames.berilia.enums.StrataEnum;
   import com.ankamagames.atouin.enums.PlacementStrataEnums;
   import com.ankamagames.jerakine.types.Color;
   import com.ankamagames.dofus.logic.game.fight.miscs.FightReachableCellsMaker;
   import com.ankamagames.jerakine.types.zones.Custom;
   import com.ankamagames.dofus.network.types.game.actions.fight.GameActionMark;
   import com.ankamagames.dofus.types.sequences.AddGlyphGfxStep;
   import com.ankamagames.dofus.network.types.game.actions.fight.GameActionMarkedCell;
   import flash.display.DisplayObject;
   import com.ankamagames.dofus.network.enums.GameActionFightInvisibilityStateEnum;
   import com.ankamagames.dofus.network.types.game.context.GameContextActorInformations;
   
   public class FightContextFrame extends Object implements Frame
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(FightContextFrame));
      
      public static var preFightIsActive:Boolean = true;
      
      public static var fighterEntityTooltipId:int;
      
      public static var currentCell:int = -1;
       
      private const TYPE_LOG_FIGHT:uint = 30000.0;
      
      private const INVISIBLE_POSITION_SELECTION:String = "invisible_position";
      
      private var _entitiesFrame:FightEntitiesFrame;
      
      private var _preparationFrame:FightPreparationFrame;
      
      private var _battleFrame:FightBattleFrame;
      
      private var _pointCellFrame:FightPointCellFrame;
      
      private var _overEffectOk:GlowFilter;
      
      private var _overEffectKo:GlowFilter;
      
      private var _linkedEffect:ColorMatrixFilter;
      
      private var _linkedMainEffect:ColorMatrixFilter;
      
      private var _lastEffectEntity:WeakReference;
      
      private var _reachableRangeSelection:Selection;
      
      private var _unreachableRangeSelection:Selection;
      
      private var _timerFighterInfo:Timer;
      
      private var _timerMovementRange:Timer;
      
      private var _currentFighterInfo:GameFightFighterInformations;
      
      private var _currentMapRenderId:int = -1;
      
      private var _timelineOverEntity:Boolean;
      
      private var _timelineOverEntityId:int;
      
      private var _showPermanentTooltips:Boolean;
      
      private var _hideTooltipTimer:Timer;
      
      private var _hideTooltipEntityId:int;
      
      private var _hideTooltipsTimer:Timer;
      
      private var _hideTooltips:Boolean;
      
      public var _challengesList:Array;
      
      private var _fightType:uint;
      
      private var _fightAttackerId:uint;
      
      private var _spellTargetsTooltips:Dictionary;
      
      private var _spellDamages:Dictionary;
      
      private var _spellAlreadyTriggered:Boolean;
      
      private var _namedPartyTeams:Vector.<NamedPartyTeam>;
      
      private var _fightersPositionsHistory:Dictionary;
      
      private var _fightIdols:Vector.<Idol>;
      
      public var isFightLeader:Boolean;
      
      public function FightContextFrame()
      {
         this._spellTargetsTooltips = new Dictionary();
         this._spellDamages = new Dictionary();
         this._fightersPositionsHistory = new Dictionary();
         super();
      }
      
      public function get priority() : int
      {
         return Priority.NORMAL;
      }
      
      public function get entitiesFrame() : FightEntitiesFrame
      {
         return this._entitiesFrame;
      }
      
      public function get battleFrame() : FightBattleFrame
      {
         return this._battleFrame;
      }
      
      public function get challengesList() : Array
      {
         return this._challengesList;
      }
      
      public function get fightType() : uint
      {
         return this._fightType;
      }
      
      public function set fightType(param1:uint) : void
      {
         this._fightType = param1;
         var _loc2_:PartyManagementFrame = Kernel.getWorker().getFrame(PartyManagementFrame) as PartyManagementFrame;
         _loc2_.lastFightType = param1;
      }
      
      public function get timelineOverEntity() : Boolean
      {
         return this._timelineOverEntity;
      }
      
      public function get timelineOverEntityId() : int
      {
         return this._timelineOverEntityId;
      }
      
      public function get showPermanentTooltips() : Boolean
      {
         return this._showPermanentTooltips;
      }
      
      public function get fightersPositionsHistory() : Dictionary
      {
         return this._fightersPositionsHistory;
      }
      
      public function pushed() : Boolean
      {
         if(!Kernel.beingInReconection)
         {
            Atouin.getInstance().displayGrid(true,true);
         }
         currentCell = -1;
         this._overEffectOk = new GlowFilter(16777215,1,4,4,3,1);
         this._overEffectKo = new GlowFilter(14090240,1,4,4,3,1);
         var _loc1_:Array = new Array();
         _loc1_ = _loc1_.concat([0.5,0,0,0,100]);
         _loc1_ = _loc1_.concat([0,0.5,0,0,100]);
         _loc1_ = _loc1_.concat([0,0,0.5,0,100]);
         _loc1_ = _loc1_.concat([0,0,0,1,0]);
         this._linkedEffect = new ColorMatrixFilter(_loc1_);
         var _loc2_:Array = new Array();
         _loc2_ = _loc2_.concat([0.5,0,0,0,0]);
         _loc2_ = _loc2_.concat([0,0.5,0,0,0]);
         _loc2_ = _loc2_.concat([0,0,0.5,0,0]);
         _loc2_ = _loc2_.concat([0,0,0,1,0]);
         this._linkedMainEffect = new ColorMatrixFilter(_loc2_);
         this._entitiesFrame = new FightEntitiesFrame();
         this._preparationFrame = new FightPreparationFrame(this);
         this._battleFrame = new FightBattleFrame();
         this._pointCellFrame = new FightPointCellFrame();
         this._challengesList = new Array();
         this._timerFighterInfo = new Timer(100,1);
         this._timerFighterInfo.addEventListener(TimerEvent.TIMER,this.showFighterInfo,false,0,true);
         this._timerMovementRange = new Timer(200,1);
         this._timerMovementRange.addEventListener(TimerEvent.TIMER,this.showMovementRange,false,0,true);
         if(MapDisplayManager.getInstance().getDataMapContainer())
         {
            MapDisplayManager.getInstance().getDataMapContainer().setTemporaryAnimatedElementState(false);
         }
         if(Kernel.getWorker().contains(MonstersInfoFrame))
         {
            Kernel.getWorker().removeFrame(Kernel.getWorker().getFrame(MonstersInfoFrame) as MonstersInfoFrame);
         }
         this._showPermanentTooltips = OptionManager.getOptionManager("dofus")["showPermanentTargetsTooltips"];
         OptionManager.getOptionManager("dofus").addEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onPropertyChanged);
         Berilia.getInstance().addEventListener(UiUnloadEvent.UNLOAD_UI_COMPLETE,this.onUiUnloaded);
         return true;
      }
      
      private function onUiUnloaded(param1:UiUnloadEvent) : void
      {
         var _loc2_:* = 0;
         if(this._showPermanentTooltips && this.battleFrame)
         {
            for each(_loc2_ in this.battleFrame.targetedEntities)
            {
               this.displayEntityTooltip(_loc2_);
            }
         }
      }
      
      public function getFighterName(param1:int) : String
      {
         var _loc2_:GameFightFighterInformations = null;
         var _loc3_:GameFightCompanionInformations = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:GameFightTaxCollectorInformations = null;
         var _loc7_:String = null;
         _loc2_ = this.getFighterInfos(param1);
         if(!_loc2_)
         {
            return "Unknown Fighter";
         }
         switch(true)
         {
            case _loc2_ is GameFightFighterNamedInformations:
               return (_loc2_ as GameFightFighterNamedInformations).name;
            case _loc2_ is GameFightMonsterInformations:
               return Monster.getMonsterById((_loc2_ as GameFightMonsterInformations).creatureGenericId).name;
            case _loc2_ is GameFightCompanionInformations:
               _loc3_ = _loc2_ as GameFightCompanionInformations;
               _loc5_ = Companion.getCompanionById(_loc3_.companionGenericId).name;
               if(_loc3_.masterId != PlayedCharacterManager.getInstance().id)
               {
                  _loc7_ = this.getFighterName(_loc3_.masterId);
                  _loc4_ = I18n.getUiText("ui.common.belonging",[_loc5_,_loc7_]);
               }
               else
               {
                  _loc4_ = _loc5_;
               }
               return _loc4_;
            case _loc2_ is GameFightTaxCollectorInformations:
               _loc6_ = _loc2_ as GameFightTaxCollectorInformations;
               return TaxCollectorFirstname.getTaxCollectorFirstnameById(_loc6_.firstNameId).firstname + " " + TaxCollectorName.getTaxCollectorNameById(_loc6_.lastNameId).name;
            default:
               return "Unknown Fighter Type";
         }
      }
      
      public function getFighterStatus(param1:int) : uint
      {
         var _loc2_:GameFightFighterInformations = this.getFighterInfos(param1);
         if(!_loc2_)
         {
            return 1;
         }
         switch(true)
         {
            case _loc2_ is GameFightFighterNamedInformations:
               return (_loc2_ as GameFightFighterNamedInformations).status.statusId;
            default:
               return 1;
         }
      }
      
      public function getFighterLevel(param1:int) : uint
      {
         var _loc2_:GameFightFighterInformations = null;
         var _loc3_:Monster = null;
         _loc2_ = this.getFighterInfos(param1);
         if(!_loc2_)
         {
            return 0;
         }
         switch(true)
         {
            case _loc2_ is GameFightMutantInformations:
               return (_loc2_ as GameFightMutantInformations).powerLevel;
            case _loc2_ is GameFightCharacterInformations:
               return (_loc2_ as GameFightCharacterInformations).level;
            case _loc2_ is GameFightCompanionInformations:
               return (_loc2_ as GameFightCompanionInformations).level;
            case _loc2_ is GameFightMonsterInformations:
               _loc3_ = Monster.getMonsterById((_loc2_ as GameFightMonsterInformations).creatureGenericId);
               return _loc3_.getMonsterGrade((_loc2_ as GameFightMonsterInformations).creatureGrade).level;
            case _loc2_ is GameFightTaxCollectorInformations:
               return (_loc2_ as GameFightTaxCollectorInformations).level;
            default:
               return 0;
         }
      }
      
      public function getChallengeById(param1:uint) : ChallengeWrapper
      {
         var _loc2_:ChallengeWrapper = null;
         for each(_loc2_ in this._challengesList)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function process(param1:Message) : Boolean
      {
         var _loc2_:* = undefined;
         var _loc3_:GameFightStartingMessage = null;
         var _loc4_:CurrentMapMessage = null;
         var _loc5_:WorldPointWrapper = null;
         var _loc6_:ByteArray = null;
         var _loc7_:GameContextReadyMessage = null;
         var _loc8_:MapsLoadingCompleteMessage = null;
         var _loc9_:GameFightResumeMessage = null;
         var _loc10_:* = 0;
         var _loc11_:Vector.<GameFightResumeSlaveInfo> = null;
         var _loc12_:GameFightResumeSlaveInfo = null;
         var _loc13_:CurrentPlayedFighterManager = null;
         var _loc14_:* = 0;
         var _loc15_:* = 0;
         var _loc16_:GameFightResumeSlaveInfo = null;
         var _loc17_:SpellCastInFightManager = null;
         var _loc18_:Array = null;
         var _loc19_:Array = null;
         var _loc20_:Array = null;
         var _loc21_:CastingSpell = null;
         var _loc22_:uint = 0;
         var _loc23_:FightDispellableEffectExtendedInformations = null;
         var _loc24_:GameFightUpdateTeamMessage = null;
         var _loc25_:GameFightSpectateMessage = null;
         var _loc26_:* = NaN;
         var _loc27_:String = null;
         var _loc28_:String = null;
         var _loc29_:Array = null;
         var _loc30_:Array = null;
         var _loc31_:Array = null;
         var _loc32_:CastingSpell = null;
         var _loc33_:GameFightSpectatorJoinMessage = null;
         var _loc34_:* = 0;
         var _loc35_:String = null;
         var _loc36_:String = null;
         var _loc37_:GameFightJoinMessage = null;
         var _loc38_:* = 0;
         var _loc39_:GameActionFightCarryCharacterMessage = null;
         var _loc40_:GameFightStartMessage = null;
         var _loc41_:CellOverMessage = null;
         var _loc42_:AnimatedCharacter = null;
         var _loc43_:MarkedCellsManager = null;
         var _loc44_:MarkInstance = null;
         var _loc45_:CellOutMessage = null;
         var _loc46_:AnimatedCharacter = null;
         var _loc47_:MarkedCellsManager = null;
         var _loc48_:MarkInstance = null;
         var _loc49_:EntityMouseOverMessage = null;
         var _loc50_:EntityMouseOutMessage = null;
         var _loc51_:GameFightLeaveMessage = null;
         var _loc52_:TimelineEntityOverAction = null;
         var _loc53_:FightSpellCastFrame = null;
         var _loc54_:TimelineEntityOutAction = null;
         var _loc55_:* = 0;
         var _loc56_:Vector.<int> = null;
         var _loc57_:TogglePointCellAction = null;
         var _loc58_:GameFightEndMessage = null;
         var _loc59_:ChallengeTargetsListRequestAction = null;
         var _loc60_:ChallengeTargetsListRequestMessage = null;
         var _loc61_:ChallengeTargetsListMessage = null;
         var _loc62_:ChallengeInfoMessage = null;
         var _loc63_:ChallengeWrapper = null;
         var _loc64_:ChallengeTargetUpdateMessage = null;
         var _loc65_:ChallengeResultMessage = null;
         var _loc66_:MapObstacleUpdateMessage = null;
         var _loc67_:GameActionFightNoSpellCastMessage = null;
         var _loc68_:uint = 0;
         var _loc69_:String = null;
         var _loc70_:GameFightResumeWithSlavesMessage = null;
         var _loc71_:BasicBuff = null;
         var _loc72_:NamedPartyTeam = null;
         var _loc73_:FightDispellableEffectExtendedInformations = null;
         var _loc74_:BasicBuff = null;
         var _loc75_:NamedPartyTeam = null;
         var _loc76_:IEntity = null;
         var _loc77_:MarkInstance = null;
         var _loc78_:Glyph = null;
         var _loc79_:Vector.<MapPoint> = null;
         var _loc80_:Vector.<uint> = null;
         var _loc81_:IEntity = null;
         var _loc82_:MarkInstance = null;
         var _loc83_:Glyph = null;
         var _loc84_:FightEndingMessage = null;
         var _loc85_:Vector.<FightResultEntryWrapper> = null;
         var _loc86_:uint = 0;
         var _loc87_:FightResultEntryWrapper = null;
         var _loc88_:Vector.<FightResultEntryWrapper> = null;
         var _loc89_:Array = null;
         var _loc90_:FightResultListEntry = null;
         var _loc91_:String = null;
         var _loc92_:String = null;
         var _loc93_:NamedPartyTeamWithOutcome = null;
         var _loc94_:Object = null;
         var _loc95_:Vector.<uint> = null;
         var _loc96_:FightResultEntryWrapper = null;
         var _loc97_:* = 0;
         var _loc98_:FightResultListEntry = null;
         var _loc99_:uint = 0;
         var _loc100_:ItemWrapper = null;
         var _loc101_:* = 0;
         var _loc102_:* = 0;
         var _loc103_:FightResultEntryWrapper = null;
         var _loc104_:uint = 0;
         var _loc105_:* = 0;
         var _loc106_:* = NaN;
         var _loc107_:MapObstacle = null;
         var _loc108_:SpellLevel = null;
         switch(true)
         {
            case param1 is MapLoadedMessage:
               MapDisplayManager.getInstance().getDataMapContainer().setTemporaryAnimatedElementState(false);
               return true;
            case param1 is GameFightStartingMessage:
               _loc3_ = param1 as GameFightStartingMessage;
               TooltipManager.hideAll();
               Atouin.getInstance().cancelZoom();
               KernelEventsManager.getInstance().processCallback(HookList.StartZoom,false);
               MapDisplayManager.getInstance().activeIdentifiedElements(false);
               FightEventsHelper.reset();
               KernelEventsManager.getInstance().processCallback(HookList.GameFightStarting,_loc3_.fightType);
               this.fightType = _loc3_.fightType;
               this._fightAttackerId = _loc3_.attackerId;
               CurrentPlayedFighterManager.getInstance().currentFighterId = PlayedCharacterManager.getInstance().id;
               CurrentPlayedFighterManager.getInstance().getSpellCastManager().currentTurn = 0;
               SoundManager.getInstance().manager.playFightMusic();
               SoundManager.getInstance().manager.playUISound(UISoundEnum.INTRO_FIGHT);
               return true;
            case param1 is CurrentMapMessage:
               _loc4_ = param1 as CurrentMapMessage;
               ConnectionsHandler.pause();
               Kernel.getWorker().pause();
               if(TacticModeManager.getInstance().tacticModeActivated)
               {
                  TacticModeManager.getInstance().hide();
               }
               _loc5_ = new WorldPointWrapper(_loc4_.mapId);
               KernelEventsManager.getInstance().processCallback(HookList.StartZoom,false);
               Atouin.getInstance().initPreDisplay(_loc5_);
               Atouin.getInstance().clearEntities();
               if(_loc4_.mapKey && _loc4_.mapKey.length)
               {
                  _loc69_ = XmlConfig.getInstance().getEntry("config.maps.encryptionKey");
                  if(!_loc69_)
                  {
                     _loc69_ = _loc4_.mapKey;
                  }
                  _loc6_ = Hex.toArray(Hex.fromString(_loc69_));
               }
               this._currentMapRenderId = Atouin.getInstance().display(_loc5_,_loc6_);
               _log.info("Ask map render for fight #" + this._currentMapRenderId);
               PlayedCharacterManager.getInstance().currentMap = _loc5_;
               KernelEventsManager.getInstance().processCallback(HookList.CurrentMap,_loc4_.mapId);
               return true;
            case param1 is MapsLoadingCompleteMessage:
               _log.info("MapsLoadingCompleteMessage #" + MapsLoadingCompleteMessage(param1).renderRequestId);
               if(this._currentMapRenderId != MapsLoadingCompleteMessage(param1).renderRequestId)
               {
                  return false;
               }
               Atouin.getInstance().showWorld(true);
               Atouin.getInstance().displayGrid(true,true);
               Atouin.getInstance().cellOverEnabled = true;
               _loc7_ = new GameContextReadyMessage();
               _loc7_.initGameContextReadyMessage(MapDisplayManager.getInstance().currentMapPoint.mapId);
               ConnectionsHandler.getConnection().send(_loc7_);
               _loc8_ = param1 as MapsLoadingCompleteMessage;
               SoundManager.getInstance().manager.setSubArea(_loc8_.mapData);
               Kernel.getWorker().resume();
               ConnectionsHandler.resume();
               return true;
            case param1 is GameFightResumeMessage:
               _loc9_ = param1 as GameFightResumeMessage;
               _loc10_ = PlayedCharacterManager.getInstance().id;
               this.tacticModeHandler();
               CurrentPlayedFighterManager.getInstance().setCurrentSummonedCreature(_loc9_.summonCount,_loc10_);
               CurrentPlayedFighterManager.getInstance().setCurrentSummonedBomb(_loc9_.bombCount,_loc10_);
               this._battleFrame.turnsCount = _loc9_.gameTurn - 1;
               KernelEventsManager.getInstance().processCallback(FightHookList.TurnCountUpdated,_loc9_.gameTurn - 1);
               this._fightIdols = _loc9_.idols;
               KernelEventsManager.getInstance().processCallback(FightHookList.FightIdolList,_loc9_.idols);
               if(param1 is GameFightResumeWithSlavesMessage)
               {
                  _loc70_ = param1 as GameFightResumeWithSlavesMessage;
                  _loc11_ = _loc70_.slavesInfo;
               }
               else
               {
                  _loc11_ = new Vector.<GameFightResumeSlaveInfo>();
               }
               _loc12_ = new GameFightResumeSlaveInfo();
               _loc12_.spellCooldowns = _loc9_.spellCooldowns;
               _loc12_.slaveId = PlayedCharacterManager.getInstance().id;
               _loc11_.unshift(_loc12_);
               _loc13_ = CurrentPlayedFighterManager.getInstance();
               _loc15_ = _loc11_.length;
               _loc14_ = 0;
               while(_loc14_ < _loc15_)
               {
                  _loc16_ = _loc11_[_loc14_];
                  _loc17_ = _loc13_.getSpellCastManagerById(_loc16_.slaveId);
                  _loc17_.currentTurn = _loc9_.gameTurn - 1;
                  _loc17_.updateCooldowns(_loc11_[_loc14_].spellCooldowns);
                  if(_loc16_.slaveId != _loc10_)
                  {
                     CurrentPlayedFighterManager.getInstance().setCurrentSummonedCreature(_loc16_.summonCount,_loc16_.slaveId);
                     CurrentPlayedFighterManager.getInstance().setCurrentSummonedBomb(_loc16_.bombCount,_loc16_.slaveId);
                  }
                  _loc14_++;
               }
               _loc18_ = [];
               _loc22_ = _loc9_.effects.length;
               _loc14_ = 0;
               while(_loc14_ < _loc22_)
               {
                  _loc23_ = _loc9_.effects[_loc14_];
                  if(!_loc18_[_loc23_.effect.targetId])
                  {
                     _loc18_[_loc23_.effect.targetId] = [];
                  }
                  _loc19_ = _loc18_[_loc23_.effect.targetId];
                  if(!_loc19_[_loc23_.effect.turnDuration])
                  {
                     _loc19_[_loc23_.effect.turnDuration] = [];
                  }
                  _loc20_ = _loc19_[_loc23_.effect.turnDuration];
                  _loc21_ = _loc20_[_loc23_.effect.spellId];
                  if(!_loc21_)
                  {
                     _loc21_ = new CastingSpell();
                     _loc21_.casterId = _loc23_.sourceId;
                     _loc21_.spell = Spell.getSpellById(_loc23_.effect.spellId);
                     _loc20_[_loc23_.effect.spellId] = _loc21_;
                  }
                  _loc71_ = BuffManager.makeBuffFromEffect(_loc23_.effect,_loc21_,_loc23_.actionId);
                  BuffManager.getInstance().addBuff(_loc71_);
                  _loc14_++;
               }
               this.addMarks(_loc9_.marks);
               Kernel.beingInReconection = false;
               return true;
            case param1 is GameFightUpdateTeamMessage:
               _loc24_ = param1 as GameFightUpdateTeamMessage;
               PlayedCharacterManager.getInstance().teamId = _loc24_.team.teamId;
               return true;
            case param1 is GameFightSpectateMessage:
               _loc25_ = param1 as GameFightSpectateMessage;
               this.tacticModeHandler();
               this._battleFrame.turnsCount = _loc25_.gameTurn - 1;
               KernelEventsManager.getInstance().processCallback(FightHookList.TurnCountUpdated,_loc25_.gameTurn - 1);
               this._fightIdols = _loc25_.idols;
               KernelEventsManager.getInstance().processCallback(FightHookList.FightIdolList,_loc25_.idols);
               _loc26_ = _loc25_.fightStart;
               _loc27_ = "";
               _loc28_ = "";
               for each(_loc72_ in this._namedPartyTeams)
               {
                  if(_loc72_.partyName && _loc72_.partyName != "")
                  {
                     if(_loc72_.teamId == TeamEnum.TEAM_CHALLENGER)
                     {
                        _loc27_ = _loc72_.partyName;
                     }
                     else if(_loc72_.teamId == TeamEnum.TEAM_DEFENDER)
                     {
                        _loc28_ = _loc72_.partyName;
                     }
                  }
               }
               KernelEventsManager.getInstance().processCallback(FightHookList.SpectateUpdate,_loc26_,_loc27_,_loc28_);
               _loc29_ = [];
               for each(_loc73_ in _loc25_.effects)
               {
                  if(!_loc29_[_loc73_.effect.targetId])
                  {
                     _loc29_[_loc73_.effect.targetId] = [];
                  }
                  _loc30_ = _loc29_[_loc73_.effect.targetId];
                  if(!_loc30_[_loc73_.effect.turnDuration])
                  {
                     _loc30_[_loc73_.effect.turnDuration] = [];
                  }
                  _loc31_ = _loc30_[_loc73_.effect.turnDuration];
                  _loc32_ = _loc31_[_loc73_.effect.spellId];
                  if(!_loc32_)
                  {
                     _loc32_ = new CastingSpell();
                     _loc32_.casterId = _loc73_.sourceId;
                     _loc32_.spell = Spell.getSpellById(_loc73_.effect.spellId);
                     _loc31_[_loc73_.effect.spellId] = _loc32_;
                  }
                  _loc74_ = BuffManager.makeBuffFromEffect(_loc73_.effect,_loc32_,_loc73_.actionId);
                  BuffManager.getInstance().addBuff(_loc74_,!(_loc74_ is StatBuff));
               }
               this.addMarks(_loc25_.marks);
               FightEventsHelper.sendAllFightEvent();
               return true;
            case param1 is GameFightSpectatorJoinMessage:
               _loc33_ = param1 as GameFightSpectatorJoinMessage;
               preFightIsActive = !_loc33_.isFightStarted;
               this.fightType = _loc33_.fightType;
               Kernel.getWorker().addFrame(this._entitiesFrame);
               if(preFightIsActive)
               {
                  Kernel.getWorker().addFrame(this._preparationFrame);
               }
               else
               {
                  Kernel.getWorker().removeFrame(this._preparationFrame);
                  Kernel.getWorker().addFrame(this._battleFrame);
                  KernelEventsManager.getInstance().processCallback(HookList.GameFightStart);
               }
               PlayedCharacterManager.getInstance().isSpectator = true;
               PlayedCharacterManager.getInstance().isFighting = true;
               _loc34_ = _loc33_.timeMaxBeforeFightStart * 100;
               if(_loc34_ == 0 && preFightIsActive)
               {
                  _loc34_ = -1;
               }
               KernelEventsManager.getInstance().processCallback(HookList.GameFightJoin,_loc33_.canBeCancelled,_loc33_.canSayReady,true,_loc34_,_loc33_.fightType);
               this._namedPartyTeams = _loc33_.namedPartyTeams;
               _loc35_ = "";
               _loc36_ = "";
               for each(_loc75_ in _loc33_.namedPartyTeams)
               {
                  if(_loc75_.partyName && _loc75_.partyName != "")
                  {
                     if(_loc75_.teamId == TeamEnum.TEAM_CHALLENGER)
                     {
                        _loc35_ = _loc75_.partyName;
                     }
                     else if(_loc75_.teamId == TeamEnum.TEAM_DEFENDER)
                     {
                        _loc36_ = _loc75_.partyName;
                     }
                  }
               }
               KernelEventsManager.getInstance().processCallback(FightHookList.SpectateUpdate,0,_loc35_,_loc36_);
               return true;
            case param1 is INetworkMessage && INetworkMessage(param1).getMessageId() == GameFightJoinMessage.protocolId:
               _loc37_ = param1 as GameFightJoinMessage;
               preFightIsActive = !_loc37_.isFightStarted;
               this.fightType = _loc37_.fightType;
               Kernel.getWorker().addFrame(this._entitiesFrame);
               if(preFightIsActive)
               {
                  Kernel.getWorker().addFrame(this._preparationFrame);
               }
               else
               {
                  Kernel.getWorker().removeFrame(this._preparationFrame);
                  Kernel.getWorker().addFrame(this._battleFrame);
                  KernelEventsManager.getInstance().processCallback(HookList.GameFightStart);
               }
               PlayedCharacterManager.getInstance().isSpectator = false;
               PlayedCharacterManager.getInstance().isFighting = true;
               _loc38_ = _loc37_.timeMaxBeforeFightStart * 100;
               if(_loc38_ == 0 && preFightIsActive)
               {
                  _loc38_ = -1;
               }
               KernelEventsManager.getInstance().processCallback(HookList.GameFightJoin,_loc37_.canBeCancelled,_loc37_.canSayReady,false,_loc38_,_loc37_.fightType);
               return true;
            case param1 is GameActionFightCarryCharacterMessage:
               _loc39_ = param1 as GameActionFightCarryCharacterMessage;
               if(this._lastEffectEntity && this._lastEffectEntity.object.id == _loc39_.targetId)
               {
                  this.process(new EntityMouseOutMessage(this._lastEffectEntity.object as IInteractive));
               }
               return false;
            case param1 is GameFightStartMessage:
               _loc40_ = param1 as GameFightStartMessage;
               preFightIsActive = false;
               Kernel.getWorker().removeFrame(this._preparationFrame);
               this._entitiesFrame.removeSwords();
               CurrentPlayedFighterManager.getInstance().getSpellCastManager().resetInitialCooldown();
               Kernel.getWorker().addFrame(this._battleFrame);
               KernelEventsManager.getInstance().processCallback(HookList.GameFightStart);
               this._fightIdols = _loc40_.idols;
               KernelEventsManager.getInstance().processCallback(FightHookList.FightIdolList,_loc40_.idols);
               return true;
            case param1 is GameContextDestroyMessage:
               TooltipManager.hide();
               Kernel.getWorker().removeFrame(this);
               return true;
            case param1 is CellOverMessage:
               _loc41_ = param1 as CellOverMessage;
               for each(_loc76_ in EntitiesManager.getInstance().getEntitiesOnCell(_loc41_.cellId))
               {
                  if(_loc76_ is AnimatedCharacter && !(_loc76_ as AnimatedCharacter).isMoving)
                  {
                     _loc42_ = _loc76_ as AnimatedCharacter;
                     break;
                  }
               }
               currentCell = _loc41_.cellId;
               if(_loc42_)
               {
                  this.overEntity(_loc42_.id);
               }
               _loc43_ = MarkedCellsManager.getInstance();
               _loc44_ = _loc43_.getMarkAtCellId(_loc41_.cellId,GameActionMarkTypeEnum.PORTAL);
               if(_loc44_)
               {
                  for each(_loc77_ in _loc43_.getMarks(_loc44_.markType,_loc44_.teamId,false))
                  {
                     _loc78_ = _loc43_.getGlyph(_loc77_.markId);
                     if(_loc78_ && _loc78_.lbl_number)
                     {
                        _loc78_.lbl_number.visible = true;
                     }
                  }
                  if(_loc44_.active && _loc43_.getActivePortalsCount(_loc44_.teamId) >= 2)
                  {
                     _loc79_ = _loc43_.getMarksMapPoint(GameActionMarkTypeEnum.PORTAL,_loc44_.teamId);
                     _loc80_ = LinkedCellsManager.getInstance().getLinks(MapPoint.fromCellId(_loc41_.cellId),_loc79_);
                     if(_loc80_)
                     {
                        LinkedCellsManager.getInstance().drawPortalLinks(_loc80_);
                     }
                  }
               }
               return true;
            case param1 is CellOutMessage:
               _loc45_ = param1 as CellOutMessage;
               for each(_loc81_ in EntitiesManager.getInstance().getEntitiesOnCell(_loc45_.cellId))
               {
                  if(_loc81_ is AnimatedCharacter)
                  {
                     _loc46_ = _loc81_ as AnimatedCharacter;
                     break;
                  }
               }
               currentCell = -1;
               if(_loc46_)
               {
                  TooltipManager.hide();
                  TooltipManager.hide("fighter");
                  this.outEntity(_loc46_.id);
               }
               _loc47_ = MarkedCellsManager.getInstance();
               _loc48_ = _loc47_.getMarkAtCellId(_loc45_.cellId,GameActionMarkTypeEnum.PORTAL);
               if(_loc48_)
               {
                  for each(_loc82_ in _loc47_.getMarks(_loc48_.markType,_loc48_.teamId,false))
                  {
                     _loc83_ = _loc47_.getGlyph(_loc82_.markId);
                     if(_loc83_ && _loc83_.lbl_number)
                     {
                        _loc83_.lbl_number.visible = false;
                     }
                  }
               }
               LinkedCellsManager.getInstance().clearLinks();
               return true;
            case param1 is EntityMouseOverMessage:
               _loc49_ = param1 as EntityMouseOverMessage;
               currentCell = _loc49_.entity.position.cellId;
               this.overEntity(_loc49_.entity.id);
               return true;
            case param1 is EntityMouseOutMessage:
               _loc50_ = param1 as EntityMouseOutMessage;
               currentCell = -1;
               this.outEntity(_loc50_.entity.id);
               return true;
            case param1 is GameFightLeaveMessage:
               _loc51_ = param1 as GameFightLeaveMessage;
               if(TooltipManager.isVisible("tooltipOverEntity_" + _loc51_.charId))
               {
                  currentCell = -1;
                  this.outEntity(_loc51_.charId);
               }
               return false;
            case param1 is TimelineEntityOverAction:
               _loc52_ = param1 as TimelineEntityOverAction;
               this._timelineOverEntity = true;
               this._timelineOverEntityId = _loc52_.targetId;
               _loc53_ = Kernel.getWorker().getFrame(FightSpellCastFrame) as FightSpellCastFrame;
               if(!_loc53_)
               {
                  this.removeSpellTargetsTooltips();
               }
               this.overEntity(_loc52_.targetId,_loc52_.showRange,_loc52_.highlightTimelineFighter);
               return true;
            case param1 is TimelineEntityOutAction:
               _loc54_ = param1 as TimelineEntityOutAction;
               _loc56_ = this._entitiesFrame.getEntitiesIdsList();
               for each(_loc55_ in _loc56_)
               {
                  if((!this._showPermanentTooltips || this._showPermanentTooltips && this._battleFrame.targetedEntities.indexOf(_loc55_) == -1) && _loc55_ != _loc54_.targetId)
                  {
                     TooltipManager.hide("tooltipOverEntity_" + _loc55_);
                  }
               }
               this._timelineOverEntity = false;
               this.outEntity(_loc54_.targetId);
               this.removeSpellTargetsTooltips();
               return true;
            case param1 is TogglePointCellAction:
               _loc57_ = param1 as TogglePointCellAction;
               if(Kernel.getWorker().contains(FightPointCellFrame))
               {
                  KernelEventsManager.getInstance().processCallback(HookList.ShowCell);
                  Kernel.getWorker().removeFrame(this._pointCellFrame);
               }
               else
               {
                  Kernel.getWorker().addFrame(this._pointCellFrame);
               }
               return true;
            case param1 is GameFightEndMessage:
               _loc58_ = param1 as GameFightEndMessage;
               if(TacticModeManager.getInstance().tacticModeActivated)
               {
                  TacticModeManager.getInstance().hide(true);
               }
               if(this._entitiesFrame.isInCreaturesFightMode())
               {
                  this._entitiesFrame.showCreaturesInFight(false);
               }
               TooltipManager.hide();
               TooltipManager.hide("fighter");
               this.hideMovementRange();
               CurrentPlayedFighterManager.getInstance().resetPlayerSpellList();
               MapDisplayManager.getInstance().activeIdentifiedElements(true);
               FightEventsHelper.sendAllFightEvent(true);
               if(!PlayedCharacterManager.getInstance().isSpectator)
               {
                  FightEventsHelper.sendFightEvent(FightEventEnum.FIGHT_END,[],0,-1,true);
               }
               SoundManager.getInstance().manager.stopFightMusic();
               PlayedCharacterManager.getInstance().isFighting = false;
               SpellWrapper.removeAllSpellWrapperBut(PlayedCharacterManager.getInstance().id,SecureCenter.ACCESS_KEY);
               SpellWrapper.resetAllCoolDown(PlayedCharacterManager.getInstance().id,SecureCenter.ACCESS_KEY);
               if(_loc58_.results == null)
               {
                  KernelEventsManager.getInstance().processCallback(FightHookList.SpectatorWantLeave);
               }
               else
               {
                  _loc84_ = new FightEndingMessage();
                  _loc84_.initFightEndingMessage();
                  Kernel.getWorker().process(_loc84_);
                  _loc85_ = new Vector.<FightResultEntryWrapper>();
                  _loc86_ = 0;
                  _loc88_ = new Vector.<FightResultEntryWrapper>();
                  _loc89_ = new Array();
                  for each(_loc90_ in _loc58_.results)
                  {
                     _loc89_.push(_loc90_);
                  }
                  _loc14_ = 0;
                  while(_loc14_ < _loc89_.length)
                  {
                     _loc98_ = _loc89_[_loc14_];
                     switch(true)
                     {
                        case _loc98_ is FightResultPlayerListEntry:
                           _loc97_ = (_loc98_ as FightResultPlayerListEntry).id;
                           _loc96_ = new FightResultEntryWrapper(_loc98_,this._entitiesFrame.getEntityInfos(_loc97_) as GameFightFighterInformations);
                           _loc96_.alive = FightResultPlayerListEntry(_loc98_).alive;
                           break;
                        case _loc98_ is FightResultTaxCollectorListEntry:
                           _loc97_ = (_loc98_ as FightResultTaxCollectorListEntry).id;
                           _loc96_ = new FightResultEntryWrapper(_loc98_,this._entitiesFrame.getEntityInfos(_loc97_) as GameFightFighterInformations);
                           _loc96_.alive = FightResultTaxCollectorListEntry(_loc98_).alive;
                           break;
                        case _loc98_ is FightResultFighterListEntry:
                           _loc97_ = (_loc98_ as FightResultFighterListEntry).id;
                           _loc96_ = new FightResultEntryWrapper(_loc98_,this._entitiesFrame.getEntityInfos(_loc97_) as GameFightFighterInformations);
                           _loc96_.alive = FightResultFighterListEntry(_loc98_).alive;
                           break;
                        case _loc98_ is FightResultListEntry:
                           _loc96_ = new FightResultEntryWrapper(_loc98_);
                           break;
                     }
                     if(this._fightAttackerId == _loc97_)
                     {
                        _loc96_.fightInitiator = true;
                     }
                     else
                     {
                        _loc96_.fightInitiator = false;
                     }
                     _loc96_.wave = _loc98_.wave;
                     if(_loc14_ + 1 < _loc89_.length && _loc89_[_loc14_ + 1] && _loc89_[_loc14_ + 1].outcome == _loc98_.outcome && _loc89_[_loc14_ + 1].wave != _loc98_.wave)
                     {
                        _loc96_.isLastOfHisWave = true;
                     }
                     if(_loc98_.outcome == FightOutcomeEnum.RESULT_DEFENDER_GROUP)
                     {
                        _loc87_ = _loc96_;
                     }
                     else
                     {
                        if(_loc98_.outcome == FightOutcomeEnum.RESULT_VICTORY)
                        {
                           _loc88_.push(_loc96_);
                        }
                        _loc85_[_loc86_++] = _loc96_;
                     }
                     if(_loc96_.id == PlayedCharacterManager.getInstance().id)
                     {
                        switch(_loc98_.outcome)
                        {
                           case FightOutcomeEnum.RESULT_VICTORY:
                              KernelEventsManager.getInstance().processCallback(TriggerHookList.FightResultVictory);
                              SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_FIGHT_WON);
                              break;
                           case FightOutcomeEnum.RESULT_LOST:
                              SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_FIGHT_LOST);
                              break;
                        }
                        if(_loc96_.rewards.objects.length >= SpeakingItemManager.GREAT_DROP_LIMIT)
                        {
                           SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_GREAT_DROP);
                        }
                     }
                     _loc14_++;
                  }
                  if(_loc87_)
                  {
                     _loc99_ = 0;
                     for each(_loc100_ in _loc87_.rewards.objects)
                     {
                        _loc88_[_loc99_].rewards.objects.push(_loc100_);
                        _loc99_++;
                        _loc99_ = _loc99_ % _loc88_.length;
                     }
                     _loc101_ = _loc87_.rewards.kamas;
                     _loc102_ = _loc101_ / _loc88_.length;
                     if(_loc101_ % _loc88_.length != 0)
                     {
                        _loc102_++;
                     }
                     for each(_loc103_ in _loc88_)
                     {
                        if(_loc101_ < _loc102_)
                        {
                           _loc103_.rewards.kamas = _loc101_;
                        }
                        else
                        {
                           _loc103_.rewards.kamas = _loc102_;
                        }
                        _loc101_ = _loc101_ - _loc103_.rewards.kamas;
                     }
                  }
                  _loc91_ = "";
                  _loc92_ = "";
                  for each(_loc93_ in _loc58_.namedPartyTeamsOutcomes)
                  {
                     if(_loc93_.team.partyName && _loc93_.team.partyName != "")
                     {
                        if(_loc93_.outcome == FightOutcomeEnum.RESULT_VICTORY)
                        {
                           _loc91_ = _loc93_.team.partyName;
                        }
                        else if(_loc93_.outcome == FightOutcomeEnum.RESULT_LOST)
                        {
                           _loc92_ = _loc93_.team.partyName;
                        }
                     }
                  }
                  _loc94_ = new Object();
                  _loc94_.results = _loc85_;
                  _loc94_.ageBonus = _loc58_.ageBonus;
                  _loc94_.sizeMalus = _loc58_.lootShareLimitMalus;
                  _loc94_.duration = _loc58_.duration;
                  _loc94_.challenges = this.challengesList;
                  _loc94_.turns = this._battleFrame.turnsCount;
                  _loc94_.fightType = this._fightType;
                  _loc94_.winnersName = _loc91_;
                  _loc94_.losersName = _loc92_;
                  _loc95_ = new Vector.<uint>();
                  if(this._fightIdols)
                  {
                     _loc104_ = this._fightIdols.length;
                     _loc105_ = 0;
                     while(_loc105_ < _loc104_)
                     {
                        _loc95_.push(this._fightIdols[_loc105_].id);
                        _loc105_++;
                     }
                  }
                  _loc94_.idols = _loc95_;
                  KernelEventsManager.getInstance().processCallback(HookList.GameFightEnd,_loc94_);
               }
               Kernel.getWorker().removeFrame(this);
               return true;
            case param1 is ChallengeTargetsListRequestAction:
               _loc59_ = param1 as ChallengeTargetsListRequestAction;
               _loc60_ = new ChallengeTargetsListRequestMessage();
               _loc60_.initChallengeTargetsListRequestMessage(_loc59_.challengeId);
               ConnectionsHandler.getConnection().send(_loc60_);
               return true;
            case param1 is ChallengeTargetsListMessage:
               _loc61_ = param1 as ChallengeTargetsListMessage;
               for each(_loc106_ in _loc61_.targetCells)
               {
                  if(_loc106_ != -1)
                  {
                     HyperlinkShowCellManager.showCell(_loc106_);
                  }
               }
               return true;
            case param1 is ChallengeInfoMessage:
               _loc62_ = param1 as ChallengeInfoMessage;
               _loc63_ = this.getChallengeById(_loc62_.challengeId);
               if(!_loc63_)
               {
                  _loc63_ = new ChallengeWrapper();
                  this.challengesList.push(_loc63_);
               }
               _loc63_.id = _loc62_.challengeId;
               _loc63_.targetId = _loc62_.targetId;
               _loc63_.xpBonus = _loc62_.xpBonus;
               _loc63_.dropBonus = _loc62_.dropBonus;
               _loc63_.result = 0;
               KernelEventsManager.getInstance().processCallback(FightHookList.ChallengeInfoUpdate,this.challengesList);
               return true;
            case param1 is ChallengeTargetUpdateMessage:
               _loc64_ = param1 as ChallengeTargetUpdateMessage;
               _loc63_ = this.getChallengeById(_loc64_.challengeId);
               if(_loc63_ == null)
               {
                  _log.warn("Got a challenge result with no corresponding challenge (challenge id " + _loc64_.challengeId + "), skipping.");
                  return false;
               }
               _loc63_.targetId = _loc64_.targetId;
               KernelEventsManager.getInstance().processCallback(FightHookList.ChallengeInfoUpdate,this.challengesList);
               return true;
            case param1 is ChallengeResultMessage:
               _loc65_ = param1 as ChallengeResultMessage;
               _loc63_ = this.getChallengeById(_loc65_.challengeId);
               if(!_loc63_)
               {
                  _log.warn("Got a challenge result with no corresponding challenge (challenge id " + _loc65_.challengeId + "), skipping.");
                  return false;
               }
               _loc63_.result = _loc65_.success?1:2;
               KernelEventsManager.getInstance().processCallback(FightHookList.ChallengeInfoUpdate,this.challengesList);
               return true;
            case param1 is MapObstacleUpdateMessage:
               _loc66_ = param1 as MapObstacleUpdateMessage;
               for each(_loc107_ in _loc66_.obstacles)
               {
                  InteractiveCellManager.getInstance().updateCell(_loc107_.obstacleCellId,_loc107_.state == MapObstacleStateEnum.OBSTACLE_OPENED);
               }
               return true;
            case param1 is GameActionFightNoSpellCastMessage:
               _loc67_ = param1 as GameActionFightNoSpellCastMessage;
               if(_loc67_.spellLevelId != 0 || !PlayedCharacterManager.getInstance().currentWeapon)
               {
                  if(_loc67_.spellLevelId == 0)
                  {
                     _loc108_ = Spell.getSpellById(0).getSpellLevel(1);
                  }
                  else
                  {
                     _loc108_ = SpellLevel.getLevelById(_loc67_.spellLevelId);
                  }
                  _loc68_ = _loc108_.apCost;
               }
               else
               {
                  _loc68_ = PlayedCharacterManager.getInstance().currentWeapon.apCost;
               }
               CurrentPlayedFighterManager.getInstance().getCharacteristicsInformations().actionPointsCurrent = CurrentPlayedFighterManager.getInstance().getCharacteristicsInformations().actionPointsCurrent + _loc68_;
               return true;
            case param1 is ShowTacticModeAction:
               if(PlayedCharacterApi.isInPreFight())
               {
                  return false;
               }
               if(PlayedCharacterApi.isInFight() || PlayedCharacterManager.getInstance().isSpectator)
               {
                  this.tacticModeHandler(true);
               }
               return true;
            default:
               return false;
         }
      }
      
      public function pulled() : Boolean
      {
         if(TacticModeManager.getInstance().tacticModeActivated)
         {
            TacticModeManager.getInstance().hide(true);
         }
         if(this._entitiesFrame)
         {
            Kernel.getWorker().removeFrame(this._entitiesFrame);
         }
         if(this._preparationFrame)
         {
            Kernel.getWorker().removeFrame(this._preparationFrame);
         }
         if(this._battleFrame)
         {
            Kernel.getWorker().removeFrame(this._battleFrame);
         }
         if(this._pointCellFrame)
         {
            Kernel.getWorker().removeFrame(this._pointCellFrame);
         }
         SerialSequencer.clearByType(FightSequenceFrame.FIGHT_SEQUENCERS_CATEGORY);
         this._preparationFrame = null;
         this._battleFrame = null;
         this._pointCellFrame = null;
         this._lastEffectEntity = null;
         TooltipManager.hideAll();
         this._timerFighterInfo.reset();
         this._timerFighterInfo.removeEventListener(TimerEvent.TIMER,this.showFighterInfo);
         this._timerFighterInfo = null;
         this._timerMovementRange.reset();
         this._timerMovementRange.removeEventListener(TimerEvent.TIMER,this.showMovementRange);
         this._timerMovementRange = null;
         this._currentFighterInfo = null;
         if(MapDisplayManager.getInstance().getDataMapContainer())
         {
            MapDisplayManager.getInstance().getDataMapContainer().setTemporaryAnimatedElementState(true);
         }
         Atouin.getInstance().displayGrid(false);
         OptionManager.getOptionManager("dofus").removeEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onPropertyChanged);
         Berilia.getInstance().removeEventListener(UiUnloadEvent.UNLOAD_UI_COMPLETE,this.onUiUnloaded);
         if(this._hideTooltipsTimer)
         {
            this._hideTooltipsTimer.removeEventListener(TimerEvent.TIMER,this.onShowPermanentTooltips);
            this._hideTooltipsTimer.stop();
         }
         if(this._hideTooltipTimer)
         {
            this._hideTooltipTimer.removeEventListener(TimerEvent.TIMER,this.onShowTooltip);
            this._hideTooltipTimer.stop();
         }
         var _loc1_:SpellInventoryManagementFrame = Kernel.getWorker().getFrame(SpellInventoryManagementFrame) as SpellInventoryManagementFrame;
         _loc1_.deleteSpellsGlobalCoolDownsData();
         PlayedCharacterManager.getInstance().isSpectator = false;
         return true;
      }
      
      public function outEntity(param1:int) : void
      {
         var _loc7_:* = 0;
         this._timerFighterInfo.reset();
         this._timerMovementRange.reset();
         var _loc2_:Vector.<int> = this._entitiesFrame.getEntitiesIdsList();
         fighterEntityTooltipId = param1;
         var _loc3_:IEntity = DofusEntities.getEntity(fighterEntityTooltipId);
         if(!_loc3_)
         {
            if(_loc2_.indexOf(fighterEntityTooltipId) == -1)
            {
               _log.warn("Mouse over an unknown entity : " + param1);
               return;
            }
         }
         if(this._lastEffectEntity && this._lastEffectEntity.object)
         {
            Sprite(this._lastEffectEntity.object).filters = [];
         }
         this._lastEffectEntity = null;
         var _loc4_:String = "tooltipOverEntity_" + param1;
         if((!this._showPermanentTooltips || this._showPermanentTooltips && this.battleFrame.targetedEntities.indexOf(param1) == -1) && TooltipManager.isVisible(_loc4_))
         {
            TooltipManager.hide(_loc4_);
         }
         if(this._showPermanentTooltips)
         {
            for each(_loc7_ in this.battleFrame.targetedEntities)
            {
               this.displayEntityTooltip(_loc7_);
            }
         }
         if(_loc3_ != null)
         {
            Sprite(_loc3_).filters = [];
         }
         this.hideMovementRange();
         var _loc5_:Selection = SelectionManager.getInstance().getSelection(this.INVISIBLE_POSITION_SELECTION);
         if(_loc5_)
         {
            _loc5_.remove();
         }
         this.removeAsLinkEntityEffect();
         if(this._currentFighterInfo && this._currentFighterInfo.contextualId == param1)
         {
            KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,null);
            if(PlayedCharacterManager.getInstance().isSpectator && OptionManager.getOptionManager("dofus")["spectatorAutoShowCurrentFighterInfo"] == true)
            {
               KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,FightEntitiesFrame.getCurrentInstance().getEntityInfos(this._battleFrame.currentPlayerId) as GameFightFighterInformations);
            }
         }
         var _loc6_:FightPreparationFrame = Kernel.getWorker().getFrame(FightPreparationFrame) as FightPreparationFrame;
         if(_loc6_)
         {
            _loc6_.updateSwapPositionRequestsIcons();
         }
      }
      
      public function removeSpellTargetsTooltips() : void
      {
         var _loc1_:* = undefined;
         PushUtil.reset();
         this._spellAlreadyTriggered = false;
         for(_loc1_ in this._spellTargetsTooltips)
         {
            TooltipPlacer.removeTooltipPositionByName("tooltip_tooltipOverEntity_" + _loc1_);
            delete this._spellTargetsTooltips[_loc1_];
            TooltipManager.hide("tooltipOverEntity_" + _loc1_);
            delete this._spellDamages[_loc1_];
            if(this._showPermanentTooltips && this._battleFrame.targetedEntities.indexOf(_loc1_) != -1)
            {
               this.displayEntityTooltip(_loc1_);
            }
         }
      }
      
      public function displayEntityTooltip(param1:int, param2:Object = null, param3:SpellDamageInfo = null, param4:Boolean = false, param5:int = -1, param6:Object = null) : void
      {
         var _loc11_:* = false;
         var _loc15_:AnimatedCharacter = null;
         var _loc16_:SpellDamageInfo = null;
         var _loc17_:SpellDamage = null;
         var _loc18_:EffectDamage = null;
         var _loc19_:IZone = null;
         var _loc20_:Vector.<uint> = null;
         var _loc21_:* = 0;
         var _loc22_:SpellWrapper = null;
         var _loc23_:uint = 0;
         var _loc24_:PushedEntity = null;
         var _loc25_:* = 0;
         var _loc26_:* = false;
         var _loc27_:SpellDamageInfo = null;
         var _loc28_:* = false;
         var _loc29_:TriggeredSpell = null;
         var _loc30_:* = false;
         var _loc31_:Vector.<TriggeredSpell> = null;
         var _loc32_:Vector.<TriggeredSpell> = null;
         var _loc33_:Vector.<int> = null;
         var _loc34_:* = 0;
         var _loc35_:* = NaN;
         var _loc36_:SpellDamage = null;
         var _loc37_:SpellDamage = null;
         var _loc38_:EffectDamage = null;
         var _loc39_:Vector.<int> = null;
         var _loc40_:Vector.<SplashDamage> = null;
         var _loc41_:* = false;
         var _loc42_:SplashDamage = null;
         var _loc43_:SpellDamageInfo = null;
         var _loc44_:* = undefined;
         var _loc45_:* = 0;
         var _loc46_:Object = null;
         var _loc47_:* = false;
         var _loc48_:SpellDamage = null;
         var _loc49_:Vector.<SpellDamage> = null;
         var _loc50_:* = 0;
         var _loc51_:* = 0;
         var _loc7_:IDisplayable = DofusEntities.getEntity(param1) as IDisplayable;
         var _loc8_:GameFightFighterInformations = this._entitiesFrame.getEntityInfos(param1) as GameFightFighterInformations;
         if(!_loc7_ || !_loc8_ || this._battleFrame.targetedEntities.indexOf(param1) != -1 && this._hideTooltips)
         {
            return;
         }
         var _loc9_:Object = param6;
         if(_loc8_.disposition.cellId != currentCell && !(this._timelineOverEntity && param1 == this.timelineOverEntityId))
         {
            if(!_loc9_)
            {
               _loc9_ = new Object();
            }
            _loc9_.showName = false;
         }
         var _loc10_:uint = param5 != -1?param5:currentCell;
         if(param2 && !param3)
         {
            _loc15_ = _loc7_ as AnimatedCharacter;
            _loc11_ = param2 && DamageUtil.isDamagedOrHealedBySpell(CurrentPlayedFighterManager.getInstance().currentFighterId,param1,param2,_loc10_);
            if(_loc15_ && _loc15_.parentSprite && _loc15_.parentSprite.carriedEntity == _loc15_ && !_loc11_)
            {
               TooltipPlacer.removeTooltipPositionByName("tooltip_tooltipOverEntity_" + param1);
               return;
            }
         }
         var _loc12_:Boolean = param2 && OptionManager.getOptionManager("dofus")["showDamagesPreview"] == true && FightSpellCastFrame.isCurrentTargetTargetable();
         if(_loc12_)
         {
            if(!param4 && this._spellTargetsTooltips[param1])
            {
               return;
            }
            _loc19_ = SpellZoneManager.getInstance().getSpellZone(param2);
            _loc20_ = _loc19_.getCells(_loc10_);
            if(!param3)
            {
               if(_loc11_)
               {
                  if(DamageUtil.BOMB_SPELLS_IDS.indexOf(param2.id) != -1)
                  {
                     _loc22_ = DamageUtil.getBombDirectDamageSpellWrapper(param2 as SpellWrapper);
                     _loc16_ = SpellDamageInfo.fromCurrentPlayer(_loc22_,param1,_loc10_);
                     for each(_loc21_ in _loc16_.originalTargetsIds)
                     {
                        this.displayEntityTooltip(_loc21_,_loc22_,_loc16_);
                     }
                     return;
                  }
                  _loc16_ = SpellDamageInfo.fromCurrentPlayer(param2,param1,_loc10_);
                  if(param2 is SpellWrapper)
                  {
                     _loc16_.pushedEntities = PushUtil.getPushedEntities(param2 as SpellWrapper,this.entitiesFrame.getEntityInfos(param2.playerId).disposition.cellId,_loc10_);
                     _loc23_ = _loc16_.pushedEntities?_loc16_.pushedEntities.length:0;
                     if(_loc23_ > 0)
                     {
                        _loc25_ = 0;
                        while(_loc25_ < _loc23_)
                        {
                           _loc24_ = _loc16_.pushedEntities[_loc25_];
                           if(!_loc26_)
                           {
                              _loc26_ = param1 == _loc24_.id;
                           }
                           if(_loc24_.id == param1)
                           {
                              this.displayEntityTooltip(_loc24_.id,param2,_loc16_,true);
                           }
                           else
                           {
                              _loc27_ = SpellDamageInfo.fromCurrentPlayer(param2,_loc24_.id,_loc10_);
                              _loc27_.pushedEntities = _loc16_.pushedEntities;
                              this.displayEntityTooltip(_loc24_.id,param2,_loc27_,true);
                           }
                           _loc25_++;
                        }
                        if(_loc26_)
                        {
                           return;
                        }
                     }
                  }
               }
            }
            else
            {
               _loc16_ = param3;
            }
            this._spellTargetsTooltips[param1] = true;
            if(_loc16_)
            {
               if(!_loc9_)
               {
                  _loc9_ = new Object();
               }
               if(_loc16_.targetId != param1)
               {
                  _loc16_.targetId = param1;
               }
               if(!_loc16_.damageSharingTargets)
               {
                  _loc33_ = _loc16_.getDamageSharingTargets();
                  _loc16_.damageSharingTargets = _loc33_;
                  if(_loc33_ && _loc33_.length > 1)
                  {
                     _loc35_ = 1 / _loc33_.length;
                     _loc36_ = new SpellDamage();
                     for each(_loc16_.targetId in _loc16_.originalTargetsIds)
                     {
                        _loc37_ = DamageUtil.getSpellDamage(_loc16_);
                        for each(_loc38_ in _loc37_.effectDamages)
                        {
                           _loc38_.applyDamageMultiplier(_loc35_);
                           _loc36_.addEffectDamage(_loc38_);
                        }
                     }
                     _loc36_.updateDamage();
                     _loc16_.sharedDamage = _loc36_;
                     for each(_loc21_ in _loc33_)
                     {
                        _loc28_ = !this._spellDamages[_loc21_] && _loc20_.indexOf(this.entitiesFrame.getEntityInfos(_loc21_).disposition.cellId) != -1;
                        this.displayEntityTooltip(_loc21_,param2,_loc16_,true);
                        if(_loc28_)
                        {
                           this._spellTargetsTooltips[_loc21_] = false;
                        }
                     }
                     return;
                  }
               }
               _loc30_ = !_loc16_.damageSharingTargets || _loc16_.damageSharingTargets.indexOf(param1) != -1 && _loc16_.originalTargetsIds.indexOf(param1) != -1;
               _loc31_ = _loc30_?_loc16_.triggeredSpellsByCasterOnTarget:null;
               if(!this._spellAlreadyTriggered && _loc31_)
               {
                  for each(_loc29_ in _loc31_)
                  {
                     if(_loc29_.triggers != "I")
                     {
                        this._spellAlreadyTriggered = true;
                     }
                     for each(_loc21_ in _loc29_.targets)
                     {
                        _loc28_ = !this._spellDamages[_loc21_] && _loc20_.indexOf(this.entitiesFrame.getEntityInfos(_loc21_).disposition.cellId) != -1;
                        this.displayEntityTooltip(_loc21_,_loc29_.spell,null,true,this.entitiesFrame.getEntityInfos(_loc29_.targetId).disposition.cellId);
                        if(_loc28_)
                        {
                           this._spellTargetsTooltips[_loc21_] = false;
                        }
                     }
                  }
               }
               _loc32_ = _loc30_?_loc16_.targetTriggeredSpells:null;
               if(!this._spellAlreadyTriggered && _loc32_)
               {
                  _loc40_ = DamageUtil.getSplashDamages(_loc32_,_loc16_);
                  if(_loc40_)
                  {
                     if(!_loc16_.splashDamages)
                     {
                        _loc16_.splashDamages = new Vector.<SplashDamage>(0);
                     }
                     for each(_loc42_ in _loc40_)
                     {
                        _loc16_.splashDamages.push(_loc42_);
                        if(!_loc39_)
                        {
                           _loc39_ = new Vector.<int>(0);
                        }
                        for each(_loc21_ in _loc42_.targets)
                        {
                           if(_loc39_.indexOf(_loc21_) == -1)
                           {
                              _loc39_.push(_loc21_);
                           }
                        }
                     }
                  }
                  _loc41_ = _loc16_.addTriggeredSpellsEffects(_loc32_);
                  if(_loc41_ && !_loc39_)
                  {
                     _loc39_ = new Vector.<int>(0);
                  }
                  if(_loc39_)
                  {
                     for each(_loc29_ in _loc32_)
                     {
                        if(_loc29_.triggers != "I")
                        {
                           this._spellAlreadyTriggered = true;
                           break;
                        }
                     }
                     if(_loc39_.indexOf(param1) == -1)
                     {
                        _loc39_.push(param1);
                     }
                     for each(_loc21_ in _loc39_)
                     {
                        if(_loc21_ == _loc16_.casterId)
                        {
                           _loc16_.reflectDamages = _loc16_.getReflectDamages();
                        }
                        this.displayEntityTooltip(_loc21_,param2,_loc16_,true);
                     }
                     return;
                  }
               }
               if(_loc16_.originalTargetsIds.indexOf(_loc16_.casterId) == -1 && !this._spellTargetsTooltips[_loc16_.casterId])
               {
                  _loc43_ = SpellDamageInfo.fromCurrentPlayer(param2,_loc16_.casterId,_loc10_);
                  _loc43_.reflectDamages = _loc16_.getReflectDamages();
                  if(_loc43_.reflectDamages)
                  {
                     this.displayEntityTooltip(_loc16_.casterId,param2,_loc43_);
                  }
               }
               _loc17_ = DamageUtil.getSpellDamage(_loc16_);
            }
            if(_loc17_)
            {
               if(!this._spellDamages[param1])
               {
                  this._spellDamages[param1] = new Array();
               }
               for each(_loc46_ in this._spellDamages[param1])
               {
                  if(_loc46_.spellId == param2.id)
                  {
                     _loc45_++;
                     if(!_loc16_.damageSharingTargets)
                     {
                        break;
                     }
                  }
               }
               if(_loc45_ == 0 || _loc16_.damageSharingTargets && _loc45_ + 1 < _loc16_.originalTargetsIds.length)
               {
                  this._spellDamages[param1].push({
                     "spellId":param2.id,
                     "spellDamage":_loc17_
                  });
               }
               if(this._spellDamages[param1].length > 1)
               {
                  _loc47_ = true;
                  if(_loc47_)
                  {
                     _loc44_ = new SpellDamage();
                     for each(_loc46_ in this._spellDamages[param1])
                     {
                        _loc48_ = _loc46_.spellDamage;
                        for each(_loc18_ in _loc48_.effectDamages)
                        {
                           _loc44_.addEffectDamage(_loc18_);
                        }
                        if(_loc48_.invulnerableState)
                        {
                           _loc44_.invulnerableState = true;
                        }
                        if(_loc48_.unhealableState)
                        {
                           _loc44_.unhealableState = true;
                        }
                        if(_loc48_.hasCriticalDamage)
                        {
                           _loc44_.hasCriticalDamage = true;
                        }
                        if(_loc48_.hasCriticalShieldPointsRemoved)
                        {
                           _loc44_.hasCriticalShieldPointsRemoved = true;
                        }
                        if(_loc48_.hasCriticalLifePointsAdded)
                        {
                           _loc44_.hasCriticalLifePointsAdded = true;
                        }
                        if(_loc48_.isHealingSpell)
                        {
                           _loc44_.isHealingSpell = true;
                        }
                        if(_loc48_.hasHeal)
                        {
                           _loc44_.hasHeal = true;
                        }
                     }
                     _loc44_.updateDamage();
                  }
                  else
                  {
                     _loc49_ = new Vector.<SpellDamage>(0);
                     _loc51_ = this._spellDamages[param1].length;
                     _loc50_ = 0;
                     while(_loc50_ < _loc51_)
                     {
                        _loc49_.push(this._spellDamages[param1][_loc50_].spellDamage);
                        _loc50_++;
                     }
                     _loc44_ = new SpellDamageList(_loc49_);
                  }
               }
               else
               {
                  _loc44_ = _loc17_;
               }
               _loc9_.spellDamage = _loc44_;
            }
         }
         if(_loc8_.disposition.cellId == -1)
         {
            return;
         }
         var _loc13_:IRectangle = _loc9_ && _loc9_.target?_loc9_.target:_loc7_.absoluteBounds;
         if(_loc8_ is GameFightCharacterInformations)
         {
            TooltipManager.show(_loc8_,_loc13_,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),false,"tooltipOverEntity_" + _loc8_.contextualId,LocationEnum.POINT_BOTTOM,LocationEnum.POINT_TOP,0,true,null,null,_loc9_,"PlayerShortInfos" + _loc8_.contextualId,false,StrataEnum.STRATA_WORLD);
         }
         else if(_loc8_ is GameFightCompanionInformations)
         {
            TooltipManager.show(_loc8_,_loc13_,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),false,"tooltipOverEntity_" + _loc8_.contextualId,LocationEnum.POINT_BOTTOM,LocationEnum.POINT_TOP,0,true,"companionFighter",null,_loc9_,"EntityShortInfos" + _loc8_.contextualId);
         }
         else
         {
            TooltipManager.show(_loc8_,_loc13_,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),false,"tooltipOverEntity_" + _loc8_.contextualId,LocationEnum.POINT_BOTTOM,LocationEnum.POINT_TOP,0,true,"monsterFighter",null,_loc9_,"EntityShortInfos" + _loc8_.contextualId,false,StrataEnum.STRATA_WORLD);
         }
         var _loc14_:FightPreparationFrame = Kernel.getWorker().getFrame(FightPreparationFrame) as FightPreparationFrame;
         if(_loc14_)
         {
            _loc14_.updateSwapPositionRequestsIcons();
         }
      }
      
      public function hideEntityTooltip(param1:int, param2:uint) : void
      {
         if(!(this._showPermanentTooltips && this._battleFrame.targetedEntities.indexOf(param1) != -1) && TooltipManager.isVisible("tooltipOverEntity_" + param1))
         {
            TooltipManager.hide("tooltipOverEntity_" + param1);
            this._hideTooltipEntityId = param1;
            if(!this._hideTooltipTimer)
            {
               this._hideTooltipTimer = new Timer(param2);
            }
            this._hideTooltipTimer.stop();
            this._hideTooltipTimer.delay = param2;
            this._hideTooltipTimer.removeEventListener(TimerEvent.TIMER,this.onShowTooltip);
            this._hideTooltipTimer.addEventListener(TimerEvent.TIMER,this.onShowTooltip);
            this._hideTooltipTimer.start();
         }
      }
      
      public function hidePermanentTooltips(param1:uint) : void
      {
         var _loc2_:* = 0;
         this._hideTooltips = true;
         if(this._battleFrame.targetedEntities.length > 0)
         {
            for each(_loc2_ in this._battleFrame.targetedEntities)
            {
               TooltipManager.hide("tooltipOverEntity_" + _loc2_);
            }
            if(!this._hideTooltipsTimer)
            {
               this._hideTooltipsTimer = new Timer(param1);
            }
            this._hideTooltipsTimer.stop();
            this._hideTooltipsTimer.delay = param1;
            this._hideTooltipsTimer.removeEventListener(TimerEvent.TIMER,this.onShowPermanentTooltips);
            this._hideTooltipsTimer.addEventListener(TimerEvent.TIMER,this.onShowPermanentTooltips);
            this._hideTooltipsTimer.start();
         }
      }
      
      public function getFighterPreviousPosition(param1:int) : int
      {
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         if(this._fightersPositionsHistory[param1])
         {
            _loc3_ = this._fightersPositionsHistory[param1];
            _loc2_ = _loc3_.length > 0?_loc3_[_loc3_.length - 1]:null;
         }
         return _loc2_?_loc2_.cellId:-1;
      }
      
      public function deleteFighterPreviousPosition(param1:int) : void
      {
         if(this._fightersPositionsHistory[param1])
         {
            this._fightersPositionsHistory[param1].pop();
         }
      }
      
      public function saveFighterPosition(param1:int, param2:uint) : void
      {
         if(!this._fightersPositionsHistory[param1])
         {
            this._fightersPositionsHistory[param1] = new Array();
         }
         this._fightersPositionsHistory[param1].push({
            "cellId":param2,
            "lives":2
         });
      }
      
      public function refreshTimelineOverEntityInfos() : void
      {
         var _loc1_:IEntity = null;
         if(this._timelineOverEntity && this._timelineOverEntityId)
         {
            _loc1_ = DofusEntities.getEntity(this._timelineOverEntityId);
            if(_loc1_ && _loc1_.position)
            {
               FightContextFrame.currentCell = _loc1_.position.cellId;
               this.overEntity(this._timelineOverEntityId);
            }
         }
      }
      
      private function getFighterInfos(param1:int) : GameFightFighterInformations
      {
         return this.entitiesFrame.getEntityInfos(param1) as GameFightFighterInformations;
      }
      
      private function showFighterInfo(param1:TimerEvent) : void
      {
         this._timerFighterInfo.reset();
         KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,this._currentFighterInfo);
      }
      
      private function showMovementRange(param1:TimerEvent) : void
      {
         this._timerMovementRange.reset();
         this._reachableRangeSelection = new Selection();
         this._reachableRangeSelection.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_AREA);
         this._reachableRangeSelection.color = new Color(52326);
         this._unreachableRangeSelection = new Selection();
         this._unreachableRangeSelection.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_AREA);
         this._unreachableRangeSelection.color = new Color(6684672);
         var _loc2_:FightReachableCellsMaker = new FightReachableCellsMaker(this._currentFighterInfo);
         this._reachableRangeSelection.zone = new Custom(_loc2_.reachableCells);
         this._unreachableRangeSelection.zone = new Custom(_loc2_.unreachableCells);
         SelectionManager.getInstance().addSelection(this._reachableRangeSelection,"movementReachableRange",this._currentFighterInfo.disposition.cellId);
         SelectionManager.getInstance().addSelection(this._unreachableRangeSelection,"movementUnreachableRange",this._currentFighterInfo.disposition.cellId);
      }
      
      private function hideMovementRange() : void
      {
         var _loc1_:Selection = SelectionManager.getInstance().getSelection("movementReachableRange");
         if(_loc1_)
         {
            _loc1_.remove();
            this._reachableRangeSelection = null;
         }
         _loc1_ = SelectionManager.getInstance().getSelection("movementUnreachableRange");
         if(_loc1_)
         {
            _loc1_.remove();
            this._unreachableRangeSelection = null;
         }
      }
      
      private function addMarks(param1:Vector.<GameActionMark>) : void
      {
         var _loc2_:GameActionMark = null;
         var _loc3_:Spell = null;
         var _loc4_:AddGlyphGfxStep = null;
         var _loc5_:GameActionMarkedCell = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = Spell.getSpellById(_loc2_.markSpellId);
            if(_loc2_.markType == GameActionMarkTypeEnum.WALL)
            {
               if(_loc3_.getParamByName("glyphGfxId"))
               {
                  for each(_loc5_ in _loc2_.cells)
                  {
                     _loc4_ = new AddGlyphGfxStep(_loc3_.getParamByName("glyphGfxId"),_loc5_.cellId,_loc2_.markId,_loc2_.markType,_loc2_.markTeamId,_loc2_.active);
                     _loc4_.start();
                  }
               }
            }
            else if(_loc3_.getParamByName("glyphGfxId") && !MarkedCellsManager.getInstance().getGlyph(_loc2_.markId) && _loc2_.markimpactCell != -1)
            {
               _loc4_ = new AddGlyphGfxStep(_loc3_.getParamByName("glyphGfxId"),_loc2_.markimpactCell,_loc2_.markId,_loc2_.markType,_loc2_.markTeamId,_loc2_.active);
               _loc4_.start();
            }
            MarkedCellsManager.getInstance().addMark(_loc2_.markId,_loc2_.markType,_loc3_,_loc3_.getSpellLevel(_loc2_.markSpellLevel),_loc2_.cells,_loc2_.markTeamId,_loc2_.active,_loc2_.markimpactCell);
         }
      }
      
      private function removeAsLinkEntityEffect() : void
      {
         var _loc1_:* = 0;
         var _loc2_:DisplayObject = null;
         var _loc3_:* = 0;
         for each(_loc1_ in this._entitiesFrame.getEntitiesIdsList())
         {
            _loc2_ = DofusEntities.getEntity(_loc1_) as DisplayObject;
            if(_loc2_ && _loc2_.filters && _loc2_.filters.length)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.filters.length)
               {
                  if(_loc2_.filters[_loc3_] is ColorMatrixFilter)
                  {
                     _loc2_.filters = _loc2_.filters.splice(_loc3_,_loc3_);
                     break;
                  }
                  _loc3_++;
               }
               continue;
            }
         }
      }
      
      private function highlightAsLinkedEntity(param1:int, param2:Boolean) : void
      {
         var _loc5_:ColorMatrixFilter = null;
         var _loc3_:IEntity = DofusEntities.getEntity(param1);
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:Sprite = _loc3_ as Sprite;
         if(_loc4_)
         {
            _loc5_ = param2?this._linkedMainEffect:this._linkedEffect;
            if(_loc4_.filters.length)
            {
               if(_loc4_.filters[0] != _loc5_)
               {
                  _loc4_.filters = [_loc5_];
               }
            }
            else
            {
               _loc4_.filters = [_loc5_];
            }
         }
      }
      
      private function overEntity(param1:int, param2:Boolean = true, param3:Boolean = true) : void
      {
         var _loc8_:* = 0;
         var _loc9_:* = false;
         var _loc14_:GameFightFighterInformations = null;
         var _loc15_:Selection = null;
         var _loc16_:* = 0;
         var _loc17_:* = 0;
         var _loc18_:FightReachableCellsMaker = null;
         var _loc19_:GlowFilter = null;
         var _loc20_:FightTurnFrame = null;
         var _loc21_:* = false;
         var _loc4_:Vector.<int> = this._entitiesFrame.getEntitiesIdsList();
         fighterEntityTooltipId = param1;
         var _loc5_:IEntity = DofusEntities.getEntity(fighterEntityTooltipId);
         if(!_loc5_)
         {
            if(_loc4_.indexOf(fighterEntityTooltipId) == -1)
            {
               _log.warn("Mouse over an unknown entity : " + param1);
               return;
            }
            var param2:* = false;
         }
         var _loc6_:GameFightFighterInformations = this._entitiesFrame.getEntityInfos(param1) as GameFightFighterInformations;
         if(!_loc6_)
         {
            _log.warn("Mouse over an unknown entity : " + param1);
            return;
         }
         var _loc7_:int = _loc6_.stats.summoner;
         if(_loc6_ is GameFightCompanionInformations)
         {
            _loc7_ = (_loc6_ as GameFightCompanionInformations).masterId;
         }
         for each(_loc8_ in _loc4_)
         {
            if(_loc8_ != param1)
            {
               _loc14_ = this._entitiesFrame.getEntityInfos(_loc8_) as GameFightFighterInformations;
               if(_loc14_.stats.summoner == param1 || _loc7_ == _loc8_ || _loc14_.stats.summoner == _loc7_ && _loc7_ || _loc14_ is GameFightCompanionInformations && (_loc14_ as GameFightCompanionInformations).masterId == param1)
               {
                  this.highlightAsLinkedEntity(_loc8_,_loc7_ == _loc8_);
               }
            }
         }
         this._currentFighterInfo = _loc6_;
         _loc9_ = true;
         if(PlayedCharacterManager.getInstance().isSpectator && OptionManager.getOptionManager("dofus")["spectatorAutoShowCurrentFighterInfo"] == true)
         {
            _loc9_ = this._battleFrame.currentPlayerId != param1;
         }
         if(_loc9_ && param3)
         {
            this._timerFighterInfo.reset();
            this._timerFighterInfo.start();
         }
         if(_loc6_.stats.invisibilityState == GameActionFightInvisibilityStateEnum.INVISIBLE)
         {
            _log.info("Mouse over an invisible entity in timeline");
            _loc15_ = SelectionManager.getInstance().getSelection(this.INVISIBLE_POSITION_SELECTION);
            if(!_loc15_)
            {
               _loc15_ = new Selection();
               _loc15_.color = new Color(52326);
               _loc15_.renderer = new ZoneDARenderer(PlacementStrataEnums.STRATA_AREA);
               SelectionManager.getInstance().addSelection(_loc15_,this.INVISIBLE_POSITION_SELECTION);
            }
            _loc16_ = FightEntitiesFrame.getCurrentInstance().getLastKnownEntityPosition(_loc6_.contextualId);
            if(_loc16_ > -1)
            {
               _loc17_ = FightEntitiesFrame.getCurrentInstance().getLastKnownEntityMovementPoint(_loc6_.contextualId);
               _loc18_ = new FightReachableCellsMaker(this._currentFighterInfo,_loc16_,_loc17_);
               _loc15_.zone = new Custom(_loc18_.reachableCells);
               SelectionManager.getInstance().update(this.INVISIBLE_POSITION_SELECTION,_loc16_);
            }
            return;
         }
         var _loc10_:FightSpellCastFrame = Kernel.getWorker().getFrame(FightSpellCastFrame) as FightSpellCastFrame;
         var _loc11_:Object = null;
         if(_loc10_ && (SelectionManager.getInstance().isInside(currentCell,"SpellCastTarget") || this._spellTargetsTooltips[param1]))
         {
            _loc11_ = _loc10_.currentSpell;
         }
         this.displayEntityTooltip(param1,_loc11_);
         var _loc12_:Selection = SelectionManager.getInstance().getSelection(FightTurnFrame.SELECTION_PATH);
         if(_loc12_)
         {
            _loc12_.remove();
         }
         if(param2)
         {
            if(Kernel.getWorker().contains(FightBattleFrame) && !Kernel.getWorker().contains(FightSpellCastFrame))
            {
               this._timerMovementRange.reset();
               this._timerMovementRange.start();
            }
         }
         if(this._lastEffectEntity && this._lastEffectEntity.object is Sprite && this._lastEffectEntity.object != _loc5_)
         {
            Sprite(this._lastEffectEntity.object).filters = [];
         }
         var _loc13_:Sprite = _loc5_ as Sprite;
         if(_loc13_)
         {
            _loc20_ = Kernel.getWorker().getFrame(FightTurnFrame) as FightTurnFrame;
            _loc21_ = _loc20_?_loc20_.myTurn:true;
            if((!_loc10_ || FightSpellCastFrame.isCurrentTargetTargetable()) && _loc21_)
            {
               _loc19_ = this._overEffectOk;
            }
            else
            {
               _loc19_ = this._overEffectKo;
            }
            if(_loc13_.filters.length)
            {
               if(_loc13_.filters[0] != _loc19_)
               {
                  _loc13_.filters = [_loc19_];
               }
            }
            else
            {
               _loc13_.filters = [_loc19_];
            }
            this._lastEffectEntity = new WeakReference(_loc5_);
         }
      }
      
      private function tacticModeHandler(param1:Boolean = false) : void
      {
         if(param1 && !TacticModeManager.getInstance().tacticModeActivated)
         {
            TacticModeManager.getInstance().show(PlayedCharacterManager.getInstance().currentMap);
         }
         else if(TacticModeManager.getInstance().tacticModeActivated)
         {
            TacticModeManager.getInstance().hide();
         }
      }
      
      private function onPropertyChanged(param1:PropertyChangeEvent) : void
      {
         var _loc2_:* = 0;
         var _loc3_:* = false;
         switch(param1.propertyName)
         {
            case "showPermanentTargetsTooltips":
               this._showPermanentTooltips = param1.propertyValue as Boolean;
               for each(_loc2_ in this._battleFrame.targetedEntities)
               {
                  if(!this._showPermanentTooltips)
                  {
                     TooltipManager.hide("tooltipOverEntity_" + _loc2_);
                  }
                  else
                  {
                     this.displayEntityTooltip(_loc2_);
                  }
               }
               break;
            case "spectatorAutoShowCurrentFighterInfo":
               if(PlayedCharacterManager.getInstance().isSpectator)
               {
                  _loc3_ = param1.propertyValue as Boolean;
                  if(!_loc3_)
                  {
                     KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,null);
                  }
                  else
                  {
                     KernelEventsManager.getInstance().processCallback(FightHookList.FighterInfoUpdate,FightEntitiesFrame.getCurrentInstance().getEntityInfos(this._battleFrame.currentPlayerId) as GameFightFighterInformations);
                  }
               }
               break;
         }
      }
      
      private function onShowPermanentTooltips(param1:TimerEvent) : void
      {
         var _loc2_:* = 0;
         this._hideTooltips = false;
         this._hideTooltipsTimer.removeEventListener(TimerEvent.TIMER,this.onShowPermanentTooltips);
         this._hideTooltipsTimer.stop();
         for each(_loc2_ in this._battleFrame.targetedEntities)
         {
            this.displayEntityTooltip(_loc2_);
         }
      }
      
      private function onShowTooltip(param1:TimerEvent) : void
      {
         this._hideTooltipTimer.removeEventListener(TimerEvent.TIMER,this.onShowTooltip);
         this._hideTooltipTimer.stop();
         var _loc2_:GameContextActorInformations = this._entitiesFrame.getEntityInfos(this._hideTooltipEntityId);
         if(_loc2_ && (_loc2_.disposition.cellId == currentCell || this.timelineOverEntity && this._hideTooltipEntityId == this.timelineOverEntityId))
         {
            this.displayEntityTooltip(this._hideTooltipEntityId);
         }
      }
   }
}
