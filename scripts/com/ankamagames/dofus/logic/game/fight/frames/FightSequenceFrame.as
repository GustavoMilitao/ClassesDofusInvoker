package com.ankamagames.dofus.logic.game.fight.frames
{
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.dofus.logic.game.common.misc.ISpellCastProvider;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.dofus.logic.game.fight.types.CastingSpell;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.jerakine.sequencer.ISequencable;
   import com.ankamagames.jerakine.sequencer.SerialSequencer;
   import com.ankamagames.jerakine.types.enums.Priority;
   import com.ankamagames.jerakine.sequencer.ISequencer;
   import com.ankamagames.jerakine.sequencer.ParallelStartSequenceStep;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.dofus.network.messages.game.context.fight.character.GameFightRefreshFighterMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightSpellCastMessage;
   import flash.utils.Dictionary;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.network.messages.game.context.GameMapMovementMessage;
   import com.ankamagames.jerakine.types.positions.MovementPath;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightPointsVariationMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightLifeAndShieldPointsLostMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightLifePointsGainMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightLifePointsLostMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightTeleportOnSameMapMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightExchangePositionsMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightSlideMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightSummonMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightMarkCellsMessage;
   import com.ankamagames.dofus.datacenter.spells.SpellLevel;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightUnmarkCellsMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightChangeLookMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightInvisibilityMessage;
   import com.ankamagames.dofus.network.types.game.context.GameContextActorInformations;
   import com.ankamagames.dofus.logic.game.fight.messages.GameActionFightLeaveMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightDeathMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightVanishMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightDispellEffectMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightDispellSpellMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightDispellMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightDodgePointLossMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightSpellCooldownVariationMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightSpellImmunityMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightKillMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightReduceDamagesMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightReflectDamagesMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightReflectSpellMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightStealKamaMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightTackledMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightTriggerGlyphTrapMessage;
   import com.ankamagames.dofus.logic.game.fight.types.MarkInstance;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightActivateGlyphTrapMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightDispellableEffectMessage;
   import com.ankamagames.dofus.network.types.game.actions.fight.AbstractFightDispellableEffect;
   import com.ankamagames.dofus.logic.game.fight.types.BasicBuff;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightModifyEffectsDurationMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightCarryCharacterMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightThrowCharacterMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightDropCharacterMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightInvisibleDetectedMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightTurnListMessage;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightCloseCombatMessage;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.datacenter.spells.Spell;
   import com.ankamagames.dofus.logic.game.common.frames.SpellInventoryManagementFrame;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightSpellCooldown;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.tiphon.display.TiphonSprite;
   import com.ankamagames.atouin.types.GraphicCell;
   import flash.geom.Point;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.dofus.network.messages.game.context.fight.character.GameFightShowFighterRandomStaticPoseMessage;
   import flash.display.Sprite;
   import com.ankamagames.dofus.network.messages.game.context.fight.character.GameFightShowFighterMessage;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightCharacterInformations;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
   import com.ankamagames.dofus.logic.game.fight.types.StateBuff;
   import com.ankamagames.dofus.network.enums.FightSpellCastCriticalEnum;
   import com.ankamagames.dofus.logic.game.fight.managers.MarkedCellsManager;
   import com.ankamagames.dofus.logic.game.fight.managers.BuffManager;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.dofus.logic.game.fight.managers.CurrentPlayedFighterManager;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.TriggerHookList;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightCompanionInformations;
   import com.ankamagames.dofus.logic.game.common.managers.SpeakingItemManager;
   import com.ankamagames.jerakine.utils.display.spellZone.SpellShapeEnum;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.atouin.managers.InteractiveCellManager;
   import com.ankamagames.dofus.logic.game.common.managers.MapMovementAdapter;
   import com.ankamagames.dofus.logic.game.fight.miscs.ActionIdConverter;
   import com.ankamagames.dofus.logic.game.fight.miscs.TackleUtil;
   import com.ankamagames.dofus.network.messages.game.actions.sequence.SequenceEndMessage;
   import com.ankamagames.dofus.network.messages.game.actions.sequence.SequenceStartMessage;
   import com.ankamagames.dofus.network.enums.GameActionMarkTypeEnum;
   import com.ankamagames.dofus.logic.game.fight.steps.FightLeavingStateStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightEnteringStateStep;
   import com.ankamagames.dofus.network.types.game.actions.fight.FightTemporaryBoostEffect;
   import com.ankamagames.dofus.logic.game.fight.types.StatBuff;
   import com.ankamagames.dofus.network.messages.game.actions.fight.GameActionFightTriggerEffectMessage;
   import com.ankamagames.dofus.network.messages.game.actions.AbstractGameActionMessage;
   import flash.utils.getTimer;
   import com.ankamagames.dofus.scripts.SpellScriptManager;
   import com.ankamagames.jerakine.types.Callback;
   import com.ankamagames.tiphon.sequence.WaitAnimationEventStep;
   import com.ankamagames.tiphon.sequence.PlayAnimationStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightDeathStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightActionPointsVariationStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightShieldPointsVariationStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightLifeVariationStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightMarkTriggeredStep;
   import com.ankamagames.jerakine.managers.OptionManager;
   import com.ankamagames.dofus.types.enums.AnimationEnum;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.berilia.managers.TooltipManager;
   import com.ankamagames.dofus.types.sequences.AddGfxEntityStep;
   import com.ankamagames.dofus.types.sequences.AddGfxInLineStep;
   import com.ankamagames.atouin.types.sequences.ParableGfxMovementStep;
   import com.ankamagames.atouin.types.sequences.AddWorldEntityStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightLossAnimStep;
   import com.ankamagames.jerakine.types.events.SequencerEvent;
   import com.ankamagames.dofus.logic.game.fight.steps.FightRefreshFighterStep;
   import com.ankamagames.jerakine.sequencer.CallbackStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightEntityMovementStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightTeleportStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightExchangePositionsStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightEntitySlideStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightSummonStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightVisibilityStep;
   import com.ankamagames.dofus.network.types.game.actions.fight.GameActionMarkedCell;
   import com.ankamagames.dofus.logic.game.fight.steps.FightMarkCellsStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightUnmarkCellsStep;
   import com.ankamagames.dofus.network.types.game.look.EntityLook;
   import com.ankamagames.dofus.logic.game.fight.steps.FightChangeLookStep;
   import com.ankamagames.dofus.misc.EntityLookAdapter;
   import com.ankamagames.dofus.logic.game.fight.steps.FightChangeVisibilityStep;
   import com.ankamagames.dofus.logic.game.fight.steps.IFightStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightMovementPointsVariationStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightTemporaryBoostStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightActionPointsLossDodgeStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightMovementPointsLossDodgeStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightVanishStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightDispellStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightDispellEffectStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightDispellSpellStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightSpellCooldownVariationStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightSpellImmunityStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightKillStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightReducedDamagesStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightReflectedDamagesStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightReflectedSpellStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightSpellCastStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightCloseCombatStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightStealingKamasStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightTackledStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightMarkActivateStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightDisplayBuffStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightModifyEffectsDurationStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightCarryCharacterStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightThrowCharacterStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightInvisibleTemporarilyDetectedStep;
   import com.ankamagames.dofus.logic.game.fight.steps.FightTurnListStep;
   
   public class FightSequenceFrame extends Object implements Frame, ISpellCastProvider
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(FightSequenceFrame));
      
      private static var _lastCastingSpell:CastingSpell;
      
      private static var _currentInstanceId:uint;
      
      public static const FIGHT_SEQUENCERS_CATEGORY:String = "FightSequencer";
       
      private var _fxScriptId:uint;
      
      private var _scriptStarted:uint;
      
      private var _castingSpell:CastingSpell;
      
      private var _castingSpells:Vector.<CastingSpell>;
      
      private var _stepsBuffer:Vector.<ISequencable>;
      
      public var mustAck:Boolean;
      
      public var ackIdent:int;
      
      private var _sequenceEndCallback:Function;
      
      private var _subSequenceWaitingCount:uint = 0;
      
      private var _scriptInit:Boolean;
      
      private var _sequencer:SerialSequencer;
      
      private var _parent:FightSequenceFrame;
      
      private var _fightBattleFrame:FightBattleFrame;
      
      private var _fightEntitiesFrame:FightEntitiesFrame;
      
      private var _instanceId:uint;
      
      private var _teleportThroughPortal:Boolean;
      
      private var _teleportPortalId:int;
      
      public function FightSequenceFrame(param1:FightBattleFrame, param2:FightSequenceFrame = null)
      {
         super();
         this._instanceId = _currentInstanceId++;
         this._fightBattleFrame = param1;
         this._parent = param2;
         this.clearBuffer();
      }
      
      public static function get lastCastingSpell() : CastingSpell
      {
         return _lastCastingSpell;
      }
      
      public static function get currentInstanceId() : uint
      {
         return _currentInstanceId;
      }
      
      private static function deleteTooltip(param1:int) : void
      {
         var _loc2_:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         if(FightContextFrame.fighterEntityTooltipId == param1 && FightContextFrame.fighterEntityTooltipId != _loc2_.timelineOverEntityId)
         {
            if(_loc2_)
            {
               _loc2_.outEntity(param1);
            }
         }
      }
      
      public function get priority() : int
      {
         return Priority.HIGHEST;
      }
      
      public function get castingSpell() : CastingSpell
      {
         return this._castingSpell;
      }
      
      public function get stepsBuffer() : Vector.<ISequencable>
      {
         return this._stepsBuffer;
      }
      
      public function get parent() : FightSequenceFrame
      {
         return this._parent;
      }
      
      public function get isWaiting() : Boolean
      {
         return this._subSequenceWaitingCount != 0 || !this._scriptInit;
      }
      
      public function get instanceId() : uint
      {
         return this._instanceId;
      }
      
      public function pushed() : Boolean
      {
         this._scriptInit = false;
         return true;
      }
      
      public function pulled() : Boolean
      {
         this._stepsBuffer = null;
         this._castingSpell = null;
         this._castingSpells = null;
         _lastCastingSpell = null;
         this._sequenceEndCallback = null;
         this._parent = null;
         this._fightBattleFrame = null;
         this._fightEntitiesFrame = null;
         this._sequencer.clear();
         return true;
      }
      
      public function get fightEntitiesFrame() : FightEntitiesFrame
      {
         if(!this._fightEntitiesFrame)
         {
            this._fightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         }
         return this._fightEntitiesFrame;
      }
      
      public function addSubSequence(param1:ISequencer) : void
      {
         this._subSequenceWaitingCount++;
         this._stepsBuffer.push(new ParallelStartSequenceStep([param1],false));
      }
      
      public function process(param1:Message) : Boolean
      {
         var _loc2_:FightContextFrame = null;
         var _loc3_:GameFightRefreshFighterMessage = null;
         var _loc4_:GameActionFightSpellCastMessage = null;
         var _loc5_:* = false;
         var _loc6_:uint = 0;
         var _loc7_:* = 0;
         var _loc8_:CastingSpell = null;
         var _loc9_:* = false;
         var _loc10_:Dictionary = null;
         var _loc11_:GameFightFighterInformations = null;
         var _loc12_:PlayedCharacterManager = null;
         var _loc13_:* = false;
         var _loc14_:GameFightFighterInformations = null;
         var _loc15_:GameMapMovementMessage = null;
         var _loc16_:MovementPath = null;
         var _loc17_:Vector.<uint> = null;
         var _loc18_:* = 0;
         var _loc19_:* = 0;
         var _loc20_:FightSpellCastFrame = null;
         var _loc21_:GameActionFightPointsVariationMessage = null;
         var _loc22_:GameActionFightLifeAndShieldPointsLostMessage = null;
         var _loc23_:GameActionFightLifePointsGainMessage = null;
         var _loc24_:GameActionFightLifePointsLostMessage = null;
         var _loc25_:GameActionFightTeleportOnSameMapMessage = null;
         var _loc26_:GameActionFightExchangePositionsMessage = null;
         var _loc27_:GameActionFightSlideMessage = null;
         var _loc28_:GameActionFightSummonMessage = null;
         var _loc29_:GameActionFightMarkCellsMessage = null;
         var _loc30_:uint = 0;
         var _loc31_:SpellLevel = null;
         var _loc32_:GameActionFightUnmarkCellsMessage = null;
         var _loc33_:GameActionFightChangeLookMessage = null;
         var _loc34_:GameActionFightInvisibilityMessage = null;
         var _loc35_:GameContextActorInformations = null;
         var _loc36_:GameActionFightLeaveMessage = null;
         var _loc37_:Dictionary = null;
         var _loc38_:GameContextActorInformations = null;
         var _loc39_:GameActionFightDeathMessage = null;
         var _loc40_:Dictionary = null;
         var _loc41_:GameFightFighterInformations = null;
         var _loc42_:* = 0;
         var _loc43_:GameFightFighterInformations = null;
         var _loc44_:GameFightFighterInformations = null;
         var _loc45_:GameFightFighterInformations = null;
         var _loc46_:GameContextActorInformations = null;
         var _loc47_:FightTurnFrame = null;
         var _loc48_:* = false;
         var _loc49_:GameActionFightVanishMessage = null;
         var _loc50_:GameContextActorInformations = null;
         var _loc51_:GameActionFightDispellEffectMessage = null;
         var _loc52_:GameActionFightDispellSpellMessage = null;
         var _loc53_:GameActionFightDispellMessage = null;
         var _loc54_:GameActionFightDodgePointLossMessage = null;
         var _loc55_:GameActionFightSpellCooldownVariationMessage = null;
         var _loc56_:GameActionFightSpellImmunityMessage = null;
         var _loc57_:GameActionFightKillMessage = null;
         var _loc58_:GameActionFightReduceDamagesMessage = null;
         var _loc59_:GameActionFightReflectDamagesMessage = null;
         var _loc60_:GameActionFightReflectSpellMessage = null;
         var _loc61_:GameActionFightStealKamaMessage = null;
         var _loc62_:GameActionFightTackledMessage = null;
         var _loc63_:GameActionFightTriggerGlyphTrapMessage = null;
         var _loc64_:* = 0;
         var _loc65_:MarkInstance = null;
         var _loc66_:GameActionFightActivateGlyphTrapMessage = null;
         var _loc67_:GameActionFightDispellableEffectMessage = null;
         var _loc68_:CastingSpell = null;
         var _loc69_:SpellLevel = null;
         var _loc70_:AbstractFightDispellableEffect = null;
         var _loc71_:BasicBuff = null;
         var _loc72_:GameActionFightModifyEffectsDurationMessage = null;
         var _loc73_:GameActionFightCarryCharacterMessage = null;
         var _loc74_:GameActionFightThrowCharacterMessage = null;
         var _loc75_:uint = 0;
         var _loc76_:GameActionFightDropCharacterMessage = null;
         var _loc77_:uint = 0;
         var _loc78_:GameActionFightInvisibleDetectedMessage = null;
         var _loc79_:GameFightTurnListMessage = null;
         var _loc80_:GameActionFightCloseCombatMessage = null;
         var _loc81_:Array = null;
         var _loc82_:* = false;
         var _loc83_:SpellLevel = null;
         var _loc84_:SpellWrapper = null;
         var _loc85_:Spell = null;
         var _loc86_:SpellLevel = null;
         var _loc87_:Dictionary = null;
         var _loc88_:GameFightFighterInformations = null;
         var _loc89_:SpellInventoryManagementFrame = null;
         var _loc90_:* = 0;
         var _loc91_:GameFightSpellCooldown = null;
         var _loc92_:uint = 0;
         var _loc93_:EffectInstance = null;
         var _loc94_:TiphonSprite = null;
         var _loc95_:GraphicCell = null;
         var _loc96_:Point = null;
         var _loc97_:TiphonSprite = null;
         var _loc98_:AnimatedCharacter = null;
         var _loc99_:GameFightShowFighterRandomStaticPoseMessage = null;
         var _loc100_:Sprite = null;
         var _loc101_:GameFightShowFighterMessage = null;
         var _loc102_:Sprite = null;
         var _loc103_:* = 0;
         var _loc104_:* = false;
         var _loc105_:* = false;
         var _loc106_:GameContextActorInformations = null;
         var _loc107_:GameFightMonsterInformations = null;
         var _loc108_:Monster = null;
         var _loc109_:GameFightCharacterInformations = null;
         var _loc110_:Spell = null;
         var _loc111_:EffectInstanceDice = null;
         var _loc112_:GameContextActorInformations = null;
         var _loc113_:* = 0;
         var _loc114_:GameFightMonsterInformations = null;
         var _loc115_:Monster = null;
         var _loc116_:GameContextActorInformations = null;
         var _loc117_:GameFightMonsterInformations = null;
         var _loc118_:GameFightFighterInformations = null;
         var _loc119_:CastingSpell = null;
         var _loc120_:* = 0;
         var _loc121_:StateBuff = null;
         var _loc122_:Object = null;
         var _loc123_:* = 0;
         switch(true)
         {
            case param1 is GameFightRefreshFighterMessage:
               _loc3_ = param1 as GameFightRefreshFighterMessage;
               this.pushRefreshFighterStep(_loc3_.informations);
               return true;
            case param1 is GameActionFightCloseCombatMessage:
            case param1 is GameActionFightSpellCastMessage:
               if(!this._castingSpells)
               {
                  this._castingSpells = new Vector.<CastingSpell>();
               }
               if(param1 is GameActionFightSpellCastMessage)
               {
                  _loc4_ = param1 as GameActionFightSpellCastMessage;
               }
               else
               {
                  _loc80_ = param1 as GameActionFightCloseCombatMessage;
                  _loc5_ = true;
                  _loc6_ = _loc80_.weaponGenericId;
                  _loc4_ = new GameActionFightSpellCastMessage();
                  _loc4_.initGameActionFightSpellCastMessage(_loc80_.actionId,_loc80_.sourceId,_loc80_.targetId,_loc80_.destinationCellId,_loc80_.critical,_loc80_.silentCast,0,1);
               }
               _loc7_ = this.fightEntitiesFrame.getEntityInfos(_loc4_.sourceId).disposition.cellId;
               _loc8_ = new CastingSpell();
               _loc8_.casterId = _loc4_.sourceId;
               _loc8_.spell = Spell.getSpellById(_loc4_.spellId);
               _loc8_.spellRank = _loc8_.spell.getSpellLevel(_loc4_.spellLevel);
               _loc8_.isCriticalFail = _loc4_.critical == FightSpellCastCriticalEnum.CRITICAL_FAIL;
               _loc8_.isCriticalHit = _loc4_.critical == FightSpellCastCriticalEnum.CRITICAL_HIT;
               _loc8_.silentCast = _loc4_.silentCast;
               _loc8_.portalIds = _loc4_.portalsIds;
               _loc8_.portalMapPoints = MarkedCellsManager.getInstance().getMapPointsFromMarkIds(_loc4_.portalsIds);
               if(!this._fightBattleFrame.currentPlayerId)
               {
                  BuffManager.getInstance().spellBuffsToIgnore.push(_loc8_);
               }
               if(_loc4_.destinationCellId != -1)
               {
                  _loc8_.targetedCell = MapPoint.fromCellId(_loc4_.destinationCellId);
               }
               if(this._castingSpell)
               {
                  if(_loc5_ && _loc6_ != 0)
                  {
                     this.pushCloseCombatStep(_loc4_.sourceId,_loc6_,_loc4_.critical);
                  }
                  else
                  {
                     this.pushSpellCastStep(_loc4_.sourceId,_loc4_.destinationCellId,_loc7_,_loc4_.spellId,_loc4_.spellLevel,_loc4_.critical);
                  }
                  _log.error("Il ne peut y avoir qu\'un seul cast de sort par séquence (" + param1 + ")");
                  this._castingSpells.push(_loc8_);
                  break;
               }
               this._castingSpell = _loc8_;
               if(this._castingSpell.isCriticalFail)
               {
                  this._fxScriptId = 0;
               }
               else
               {
                  this._fxScriptId = this._castingSpell.spell.getScriptId(this._castingSpell.isCriticalHit);
               }
               if(param1 is GameActionFightCloseCombatMessage)
               {
                  this._fxScriptId = 7;
                  this._castingSpell.weaponId = GameActionFightCloseCombatMessage(param1).weaponGenericId;
               }
               if(_loc4_.sourceId == CurrentPlayedFighterManager.getInstance().currentFighterId && _loc4_.critical != FightSpellCastCriticalEnum.CRITICAL_FAIL)
               {
                  _loc81_ = new Array();
                  _loc81_.push(_loc4_.targetId);
                  CurrentPlayedFighterManager.getInstance().getSpellCastManager().castSpell(_loc4_.spellId,_loc4_.spellLevel,_loc81_);
               }
               _loc9_ = _loc4_.critical == FightSpellCastCriticalEnum.CRITICAL_HIT;
               _loc10_ = FightEntitiesFrame.getCurrentInstance().getEntitiesDictionnary();
               _loc11_ = _loc10_[_loc4_.sourceId];
               if(_loc5_ && _loc6_ != 0)
               {
                  this.pushCloseCombatStep(_loc4_.sourceId,_loc6_,_loc4_.critical);
               }
               else
               {
                  this.pushSpellCastStep(_loc4_.sourceId,_loc4_.destinationCellId,_loc7_,_loc4_.spellId,_loc4_.spellLevel,_loc4_.critical);
               }
               if(_loc4_.sourceId == CurrentPlayedFighterManager.getInstance().currentFighterId)
               {
                  KernelEventsManager.getInstance().processCallback(TriggerHookList.FightSpellCast);
               }
               _loc12_ = PlayedCharacterManager.getInstance();
               _loc13_ = false;
               if(_loc10_[_loc12_.id] && _loc11_ && (_loc10_[_loc12_.id] as GameFightFighterInformations).teamId == _loc11_.teamId)
               {
                  _loc13_ = true;
               }
               if(_loc4_.sourceId != _loc12_.id && _loc13_ && !this._castingSpell.isCriticalFail)
               {
                  _loc82_ = false;
                  for each(_loc84_ in _loc12_.spellsInventory)
                  {
                     if(_loc84_.id == _loc4_.spellId)
                     {
                        _loc82_ = true;
                        _loc83_ = _loc84_.spellLevelInfos;
                        break;
                     }
                  }
                  _loc85_ = Spell.getSpellById(_loc4_.spellId);
                  _loc86_ = _loc85_.getSpellLevel(_loc4_.spellLevel);
                  if(_loc86_.globalCooldown)
                  {
                     if(_loc82_)
                     {
                        if(_loc86_.globalCooldown == -1)
                        {
                           _loc90_ = _loc83_.minCastInterval;
                        }
                        else
                        {
                           _loc90_ = _loc86_.globalCooldown;
                        }
                        this.pushSpellCooldownVariationStep(_loc12_.id,0,_loc4_.spellId,_loc90_);
                     }
                     _loc87_ = this.fightEntitiesFrame.getEntitiesDictionnary();
                     _loc89_ = Kernel.getWorker().getFrame(SpellInventoryManagementFrame) as SpellInventoryManagementFrame;
                     for each(_loc88_ in _loc87_)
                     {
                        if(_loc88_ is GameFightCompanionInformations && _loc4_.sourceId != _loc88_.contextualId && (_loc88_ as GameFightCompanionInformations).masterId == _loc12_.id)
                        {
                           _loc91_ = new GameFightSpellCooldown();
                           _loc91_.initGameFightSpellCooldown(_loc4_.spellId,_loc86_.globalCooldown);
                           _loc89_.addSpellGlobalCoolDownInfo(_loc88_.contextualId,_loc91_);
                        }
                     }
                  }
               }
               _loc42_ = PlayedCharacterManager.getInstance().id;
               _loc43_ = this.fightEntitiesFrame.getEntityInfos(_loc4_.sourceId) as GameFightFighterInformations;
               _loc45_ = this.fightEntitiesFrame.getEntityInfos(_loc42_) as GameFightFighterInformations;
               if(_loc9_)
               {
                  if(_loc4_.sourceId == _loc42_)
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_CC_OWNER);
                  }
                  else if(_loc45_ && _loc43_.teamId == _loc45_.teamId)
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_CC_ALLIED);
                  }
                  else
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_CC_ENEMY);
                  }
               }
               else if(_loc4_.critical == FightSpellCastCriticalEnum.CRITICAL_FAIL)
               {
                  if(_loc4_.sourceId == _loc42_)
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_EC_OWNER);
                  }
                  else if(_loc45_ && _loc43_.teamId == _loc45_.teamId)
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_EC_ALLIED);
                  }
                  else
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_EC_ENEMY);
                  }
               }
               _loc14_ = this.fightEntitiesFrame.getEntityInfos(_loc4_.targetId) as GameFightFighterInformations;
               if(_loc14_ && _loc14_.disposition.cellId == -1)
               {
                  for each(_loc93_ in this._castingSpell.spellRank.effects)
                  {
                     if(_loc93_.hasOwnProperty("zoneShape"))
                     {
                        _loc92_ = _loc93_.zoneShape;
                        break;
                     }
                  }
                  if(_loc92_ == SpellShapeEnum.P)
                  {
                     _loc94_ = DofusEntities.getEntity(_loc4_.targetId) as TiphonSprite;
                     if(_loc94_ && this._castingSpell && this._castingSpell.targetedCell)
                     {
                        _loc95_ = InteractiveCellManager.getInstance().getCell(this._castingSpell.targetedCell.cellId);
                        _loc96_ = _loc95_.parent.localToGlobal(new Point(_loc95_.x + _loc95_.width / 2,_loc95_.y + _loc95_.height / 2));
                        _loc94_.x = _loc96_.x;
                        _loc94_.y = _loc96_.y;
                     }
                  }
               }
               this._castingSpells.push(this._castingSpell);
               return true;
            case param1 is GameMapMovementMessage:
               _loc15_ = param1 as GameMapMovementMessage;
               if(_loc15_.actorId == CurrentPlayedFighterManager.getInstance().currentFighterId)
               {
                  KernelEventsManager.getInstance().processCallback(TriggerHookList.PlayerFightMove);
               }
               _loc16_ = MapMovementAdapter.getClientMovement(_loc15_.keyMovements);
               _loc17_ = _loc16_.getCells();
               _loc2_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               _loc19_ = _loc17_.length;
               _loc18_ = 0;
               while(_loc18_ < _loc19_ - 1)
               {
                  _loc2_.saveFighterPosition(_loc15_.actorId,_loc17_[_loc18_]);
                  _loc97_ = DofusEntities.getEntity(_loc15_.actorId) as TiphonSprite;
                  _loc98_ = _loc97_.carriedEntity as AnimatedCharacter;
                  while(_loc98_)
                  {
                     _loc2_.saveFighterPosition(_loc98_.id,_loc17_[_loc18_]);
                     _loc98_ = _loc98_.carriedEntity as AnimatedCharacter;
                  }
                  _loc18_++;
               }
               _loc20_ = Kernel.getWorker().getFrame(FightSpellCastFrame) as FightSpellCastFrame;
               if(_loc20_)
               {
                  _loc20_.entityMovement(_loc15_.actorId);
               }
               this.pushMovementStep(_loc15_.actorId,_loc16_);
               return true;
            case param1 is GameActionFightPointsVariationMessage:
               _loc21_ = param1 as GameActionFightPointsVariationMessage;
               this.pushPointsVariationStep(_loc21_.targetId,_loc21_.actionId,_loc21_.delta);
               return true;
            case param1 is GameActionFightLifeAndShieldPointsLostMessage:
               _loc22_ = param1 as GameActionFightLifeAndShieldPointsLostMessage;
               this.pushShieldPointsVariationStep(_loc22_.targetId,-_loc22_.shieldLoss,_loc22_.actionId);
               this.pushLifePointsVariationStep(_loc22_.targetId,-_loc22_.loss,-_loc22_.permanentDamages,_loc22_.actionId);
               return true;
            case param1 is GameActionFightLifePointsGainMessage:
               _loc23_ = param1 as GameActionFightLifePointsGainMessage;
               this.pushLifePointsVariationStep(_loc23_.targetId,_loc23_.delta,0,_loc23_.actionId);
               return true;
            case param1 is GameActionFightLifePointsLostMessage:
               _loc24_ = param1 as GameActionFightLifePointsLostMessage;
               this.pushLifePointsVariationStep(_loc24_.targetId,-_loc24_.loss,-_loc24_.permanentDamages,_loc24_.actionId);
               return true;
            case param1 is GameActionFightTeleportOnSameMapMessage:
               _loc25_ = param1 as GameActionFightTeleportOnSameMapMessage;
               _loc2_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               if(!this.isSpellTeleportingToPreviousPosition())
               {
                  if(!this._teleportThroughPortal)
                  {
                     _loc2_.saveFighterPosition(_loc25_.targetId,_loc2_.entitiesFrame.getEntityInfos(_loc25_.targetId).disposition.cellId);
                  }
                  else
                  {
                     _loc2_.saveFighterPosition(_loc25_.targetId,MarkedCellsManager.getInstance().getMarkDatas(this._teleportPortalId).cells[0]);
                  }
               }
               else if(_loc2_.getFighterPreviousPosition(_loc25_.targetId) == _loc25_.cellId)
               {
                  _loc2_.deleteFighterPreviousPosition(_loc25_.targetId);
               }
               this.pushTeleportStep(_loc25_.targetId,_loc25_.cellId);
               this._teleportThroughPortal = false;
               return true;
            case param1 is GameActionFightExchangePositionsMessage:
               _loc26_ = param1 as GameActionFightExchangePositionsMessage;
               _loc2_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               if(!this.isSpellTeleportingToPreviousPosition())
               {
                  _loc2_.saveFighterPosition(_loc26_.sourceId,_loc2_.entitiesFrame.getEntityInfos(_loc26_.sourceId).disposition.cellId);
               }
               else
               {
                  _loc2_.deleteFighterPreviousPosition(_loc26_.sourceId);
               }
               _loc2_.saveFighterPosition(_loc26_.targetId,_loc2_.entitiesFrame.getEntityInfos(_loc26_.targetId).disposition.cellId);
               this.pushExchangePositionsStep(_loc26_.sourceId,_loc26_.casterCellId,_loc26_.targetId,_loc26_.targetCellId);
               return true;
            case param1 is GameActionFightSlideMessage:
               _loc27_ = param1 as GameActionFightSlideMessage;
               _loc2_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               _loc2_.saveFighterPosition(_loc27_.targetId,_loc2_.entitiesFrame.getEntityInfos(_loc27_.targetId).disposition.cellId);
               this.pushSlideStep(_loc27_.targetId,_loc27_.startCellId,_loc27_.endCellId);
               return true;
            case param1 is GameActionFightSummonMessage:
               _loc28_ = param1 as GameActionFightSummonMessage;
               if(_loc28_.actionId == 1024 || _loc28_.actionId == 1097)
               {
                  _loc99_ = new GameFightShowFighterRandomStaticPoseMessage();
                  _loc99_.initGameFightShowFighterRandomStaticPoseMessage(_loc28_.summon);
                  Kernel.getWorker().getFrame(FightEntitiesFrame).process(_loc99_);
                  _loc100_ = DofusEntities.getEntity(_loc28_.summon.contextualId) as Sprite;
                  if(_loc100_)
                  {
                     _loc100_.visible = false;
                  }
                  this.pushVisibilityStep(_loc28_.summon.contextualId,true);
               }
               else
               {
                  _loc101_ = new GameFightShowFighterMessage();
                  _loc101_.initGameFightShowFighterMessage(_loc28_.summon);
                  Kernel.getWorker().getFrame(FightEntitiesFrame).process(_loc101_);
                  _loc102_ = DofusEntities.getEntity(_loc28_.summon.contextualId) as Sprite;
                  if(_loc102_)
                  {
                     _loc102_.visible = false;
                  }
                  this.pushSummonStep(_loc28_.sourceId,_loc28_.summon);
                  if(_loc28_.sourceId == CurrentPlayedFighterManager.getInstance().currentFighterId && _loc28_.actionId != 185)
                  {
                     _loc104_ = false;
                     _loc105_ = false;
                     if(_loc28_.actionId == 1008)
                     {
                        _loc104_ = true;
                     }
                     else
                     {
                        _loc106_ = FightEntitiesFrame.getCurrentInstance().getEntityInfos(_loc28_.summon.contextualId);
                        _loc104_ = false;
                        _loc107_ = _loc106_ as GameFightMonsterInformations;
                        if(_loc107_)
                        {
                           _loc108_ = Monster.getMonsterById(_loc107_.creatureGenericId);
                           if(_loc108_ && _loc108_.useBombSlot)
                           {
                              _loc104_ = true;
                           }
                           if(_loc108_ && _loc108_.useSummonSlot)
                           {
                              _loc105_ = true;
                           }
                        }
                        else
                        {
                           _loc109_ = _loc106_ as GameFightCharacterInformations;
                        }
                     }
                     if(_loc105_ || _loc109_)
                     {
                        CurrentPlayedFighterManager.getInstance().addSummonedCreature();
                     }
                     else if(_loc104_)
                     {
                        CurrentPlayedFighterManager.getInstance().addSummonedBomb();
                     }
                  }
                  _loc103_ = this._fightBattleFrame.getNextPlayableCharacterId();
                  if(this._fightBattleFrame.currentPlayerId != CurrentPlayedFighterManager.getInstance().currentFighterId && _loc103_ != CurrentPlayedFighterManager.getInstance().currentFighterId && _loc103_ == _loc28_.summon.contextualId)
                  {
                     this._fightBattleFrame.prepareNextPlayableCharacter();
                  }
               }
               return true;
            case param1 is GameActionFightMarkCellsMessage:
               _loc29_ = param1 as GameActionFightMarkCellsMessage;
               _loc30_ = _loc29_.mark.markSpellId;
               if(this._castingSpell && this._castingSpell.spell && this._castingSpell.spell.id != 1750)
               {
                  this._castingSpell.markId = _loc29_.mark.markId;
                  this._castingSpell.markType = _loc29_.mark.markType;
                  _loc31_ = this._castingSpell.spellRank;
               }
               else
               {
                  _loc110_ = Spell.getSpellById(_loc30_);
                  _loc31_ = _loc110_.getSpellLevel(_loc29_.mark.markSpellLevel);
                  for each(_loc111_ in _loc31_.effects)
                  {
                     if(_loc111_.effectId == ActionIdConverter.ACTION_FIGHT_ADD_TRAP_CASTING_SPELL || _loc111_.effectId == ActionIdConverter.ACTION_FIGHT_ADD_GLYPH_CASTING_SPELL || _loc111_.effectId == ActionIdConverter.ACTION_FIGHT_ADD_GLYPH_CASTING_SPELL_ENDTURN)
                     {
                        _loc30_ = _loc111_.parameter0 as uint;
                        _loc31_ = Spell.getSpellById(_loc30_).getSpellLevel(_loc111_.parameter1 as uint);
                        break;
                     }
                  }
               }
               this.pushMarkCellsStep(_loc29_.mark.markId,_loc29_.mark.markType,_loc29_.mark.cells,_loc30_,_loc31_,_loc29_.mark.markTeamId,_loc29_.mark.markimpactCell);
               return true;
            case param1 is GameActionFightUnmarkCellsMessage:
               _loc32_ = param1 as GameActionFightUnmarkCellsMessage;
               this.pushUnmarkCellsStep(_loc32_.markId);
               return true;
            case param1 is GameActionFightChangeLookMessage:
               _loc33_ = param1 as GameActionFightChangeLookMessage;
               this.pushChangeLookStep(_loc33_.targetId,_loc33_.entityLook);
               return true;
            case param1 is GameActionFightInvisibilityMessage:
               _loc34_ = param1 as GameActionFightInvisibilityMessage;
               _loc35_ = this.fightEntitiesFrame.getEntityInfos(_loc34_.targetId);
               FightEntitiesFrame.getCurrentInstance().setLastKnownEntityPosition(_loc34_.targetId,_loc35_.disposition.cellId);
               FightEntitiesFrame.getCurrentInstance().setLastKnownEntityMovementPoint(_loc34_.targetId,0,true);
               this.pushChangeVisibilityStep(_loc34_.targetId,_loc34_.state);
               return true;
            case param1 is GameActionFightLeaveMessage:
               _loc36_ = param1 as GameActionFightLeaveMessage;
               _loc37_ = FightEntitiesFrame.getCurrentInstance().getEntitiesDictionnary();
               for each(_loc112_ in _loc37_)
               {
                  if(_loc112_ is GameFightFighterInformations)
                  {
                     _loc113_ = (_loc112_ as GameFightFighterInformations).stats.summoner;
                     if(_loc113_ == _loc36_.targetId)
                     {
                        this.pushDeathStep(_loc112_.contextualId);
                     }
                  }
               }
               this.pushDeathStep(_loc36_.targetId,false);
               _loc38_ = FightEntitiesFrame.getCurrentInstance().getEntityInfos(_loc36_.targetId);
               if(_loc38_ is GameFightMonsterInformations)
               {
                  _loc114_ = _loc38_ as GameFightMonsterInformations;
                  if(CurrentPlayedFighterManager.getInstance().checkPlayableEntity(_loc114_.stats.summoner))
                  {
                     _loc115_ = Monster.getMonsterById(_loc114_.creatureGenericId);
                     if(_loc115_.useSummonSlot)
                     {
                        CurrentPlayedFighterManager.getInstance().removeSummonedCreature(_loc114_.stats.summoner);
                     }
                     if(_loc115_.useBombSlot)
                     {
                        CurrentPlayedFighterManager.getInstance().removeSummonedBomb(_loc114_.stats.summoner);
                     }
                  }
               }
               return true;
            case param1 is GameActionFightDeathMessage:
               _loc39_ = param1 as GameActionFightDeathMessage;
               _loc40_ = FightEntitiesFrame.getCurrentInstance().getEntitiesDictionnary();
               for each(_loc116_ in _loc40_)
               {
                  if(_loc116_ is GameFightFighterInformations)
                  {
                     _loc41_ = _loc116_ as GameFightFighterInformations;
                     if(_loc41_.alive && _loc41_.stats.summoner == _loc39_.targetId)
                     {
                        this.pushDeathStep(_loc116_.contextualId);
                     }
                  }
               }
               _loc42_ = PlayedCharacterManager.getInstance().id;
               _loc43_ = this.fightEntitiesFrame.getEntityInfos(_loc39_.sourceId) as GameFightFighterInformations;
               _loc44_ = this.fightEntitiesFrame.getEntityInfos(_loc39_.targetId) as GameFightFighterInformations;
               _loc45_ = this.fightEntitiesFrame.getEntityInfos(_loc42_) as GameFightFighterInformations;
               if(_loc39_.targetId != this._fightBattleFrame.currentPlayerId && (this._fightBattleFrame.slaveId == _loc39_.targetId || this._fightBattleFrame.masterId == _loc39_.targetId))
               {
                  this._fightBattleFrame.prepareNextPlayableCharacter(_loc39_.targetId);
               }
               if(_loc39_.targetId == _loc42_)
               {
                  if(_loc39_.sourceId == _loc39_.targetId)
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_KILLED_HIMSELF);
                  }
                  else if(_loc43_.teamId != _loc45_.teamId)
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_KILLED_BY_ENEMY);
                  }
                  else
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_KILLED_BY_ENEMY);
                  }
               }
               else if(_loc39_.sourceId == _loc42_)
               {
                  if(_loc44_.teamId != _loc45_.teamId)
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_KILL_ENEMY);
                  }
                  else
                  {
                     SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_KILL_ALLY);
                  }
               }
               this.pushDeathStep(_loc39_.targetId);
               _loc46_ = FightEntitiesFrame.getCurrentInstance().getEntityInfos(_loc39_.targetId);
               _loc47_ = Kernel.getWorker().getFrame(FightTurnFrame) as FightTurnFrame;
               _loc48_ = _loc47_ && _loc47_.myTurn && _loc39_.targetId != _loc42_ && TackleUtil.isTackling(_loc45_,_loc44_,_loc47_.lastPath);
               if(_loc46_ is GameFightMonsterInformations)
               {
                  _loc117_ = _loc46_ as GameFightMonsterInformations;
                  _loc117_.alive = false;
                  if(CurrentPlayedFighterManager.getInstance().checkPlayableEntity(_loc117_.stats.summoner))
                  {
                     _loc115_ = Monster.getMonsterById(_loc117_.creatureGenericId);
                     if(_loc115_.useSummonSlot)
                     {
                        CurrentPlayedFighterManager.getInstance().removeSummonedCreature(_loc117_.stats.summoner);
                     }
                     if(_loc115_.useBombSlot)
                     {
                        CurrentPlayedFighterManager.getInstance().removeSummonedBomb(_loc117_.stats.summoner);
                     }
                     SpellWrapper.refreshAllPlayerSpellHolder(_loc117_.stats.summoner);
                  }
               }
               else if(_loc46_ is GameFightFighterInformations)
               {
                  (_loc46_ as GameFightFighterInformations).alive = false;
                  if((_loc46_ as GameFightFighterInformations).stats.summoner != 0)
                  {
                     _loc118_ = _loc46_ as GameFightFighterInformations;
                     if(CurrentPlayedFighterManager.getInstance().checkPlayableEntity(_loc118_.stats.summoner))
                     {
                        CurrentPlayedFighterManager.getInstance().removeSummonedCreature(_loc118_.stats.summoner);
                        SpellWrapper.refreshAllPlayerSpellHolder(_loc118_.stats.summoner);
                     }
                  }
               }
               _loc2_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               if(_loc2_)
               {
                  _loc2_.outEntity(_loc39_.targetId);
               }
               FightEntitiesFrame.getCurrentInstance().updateRemovedEntity(_loc39_.targetId);
               if(_loc48_)
               {
                  _loc47_.updatePath();
               }
               return true;
            case param1 is GameActionFightVanishMessage:
               _loc49_ = param1 as GameActionFightVanishMessage;
               this.pushVanishStep(_loc49_.targetId,_loc49_.sourceId);
               _loc50_ = FightEntitiesFrame.getCurrentInstance().getEntityInfos(_loc49_.targetId);
               if(_loc50_ is GameFightFighterInformations)
               {
                  (_loc50_ as GameFightFighterInformations).alive = false;
               }
               _loc2_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               if(_loc2_)
               {
                  _loc2_.outEntity(_loc49_.targetId);
               }
               FightEntitiesFrame.getCurrentInstance().updateRemovedEntity(_loc49_.targetId);
               return true;
            case param1 is GameActionFightTriggerEffectMessage:
               return true;
            case param1 is GameActionFightDispellEffectMessage:
               _loc51_ = param1 as GameActionFightDispellEffectMessage;
               this.pushDispellEffectStep(_loc51_.targetId,_loc51_.boostUID);
               return true;
            case param1 is GameActionFightDispellSpellMessage:
               _loc52_ = param1 as GameActionFightDispellSpellMessage;
               this.pushDispellSpellStep(_loc52_.targetId,_loc52_.spellId);
               return true;
            case param1 is GameActionFightDispellMessage:
               _loc53_ = param1 as GameActionFightDispellMessage;
               this.pushDispellStep(_loc53_.targetId);
               return true;
            case param1 is GameActionFightDodgePointLossMessage:
               _loc54_ = param1 as GameActionFightDodgePointLossMessage;
               this.pushPointsLossDodgeStep(_loc54_.targetId,_loc54_.actionId,_loc54_.amount);
               return true;
            case param1 is GameActionFightSpellCooldownVariationMessage:
               _loc55_ = param1 as GameActionFightSpellCooldownVariationMessage;
               this.pushSpellCooldownVariationStep(_loc55_.targetId,_loc55_.actionId,_loc55_.spellId,_loc55_.value);
               return true;
            case param1 is GameActionFightSpellImmunityMessage:
               _loc56_ = param1 as GameActionFightSpellImmunityMessage;
               this.pushSpellImmunityStep(_loc56_.targetId);
               return true;
            case param1 is GameActionFightKillMessage:
               _loc57_ = param1 as GameActionFightKillMessage;
               this.pushKillStep(_loc57_.targetId,_loc57_.sourceId);
               return true;
            case param1 is GameActionFightReduceDamagesMessage:
               _loc58_ = param1 as GameActionFightReduceDamagesMessage;
               this.pushReducedDamagesStep(_loc58_.targetId,_loc58_.amount);
               return true;
            case param1 is GameActionFightReflectDamagesMessage:
               _loc59_ = param1 as GameActionFightReflectDamagesMessage;
               this.pushReflectedDamagesStep(_loc59_.sourceId);
               return true;
            case param1 is GameActionFightReflectSpellMessage:
               _loc60_ = param1 as GameActionFightReflectSpellMessage;
               this.pushReflectedSpellStep(_loc60_.targetId);
               return true;
            case param1 is GameActionFightStealKamaMessage:
               _loc61_ = param1 as GameActionFightStealKamaMessage;
               this.pushStealKamasStep(_loc61_.sourceId,_loc61_.targetId,_loc61_.amount);
               return true;
            case param1 is GameActionFightTackledMessage:
               _loc62_ = param1 as GameActionFightTackledMessage;
               this.pushTackledStep(_loc62_.sourceId);
               return true;
            case param1 is GameActionFightTriggerGlyphTrapMessage:
               if(this._castingSpell)
               {
                  this._fightBattleFrame.process(new SequenceEndMessage());
                  this._fightBattleFrame.process(new SequenceStartMessage());
                  this._fightBattleFrame.currentSequenceFrame.process(param1);
                  return true;
               }
               _loc63_ = param1 as GameActionFightTriggerGlyphTrapMessage;
               this.pushMarkTriggeredStep(_loc63_.triggeringCharacterId,_loc63_.sourceId,_loc63_.markId);
               this._fxScriptId = 1;
               this._castingSpell = new CastingSpell();
               this._castingSpell.casterId = _loc63_.sourceId;
               _loc64_ = FightEntitiesFrame.getCurrentInstance().getEntityInfos(_loc63_.triggeringCharacterId).disposition.cellId;
               if(_loc64_ != -1)
               {
                  this._castingSpell.targetedCell = MapPoint.fromCellId(_loc64_);
                  this._castingSpell.spell = Spell.getSpellById(1750);
                  this._castingSpell.spellRank = this._castingSpell.spell.getSpellLevel(1);
               }
               _loc65_ = MarkedCellsManager.getInstance().getMarkDatas(_loc63_.markId);
               if(_loc65_ && _loc65_.markType == GameActionMarkTypeEnum.PORTAL)
               {
                  this._teleportThroughPortal = true;
                  this._teleportPortalId = _loc65_.markId;
               }
               return true;
            case param1 is GameActionFightActivateGlyphTrapMessage:
               _loc66_ = param1 as GameActionFightActivateGlyphTrapMessage;
               this.pushMarkActivateStep(_loc66_.markId,_loc66_.active);
               return true;
            case param1 is GameActionFightDispellableEffectMessage:
               _loc67_ = param1 as GameActionFightDispellableEffectMessage;
               for each(_loc119_ in this._castingSpells)
               {
                  for each(_loc120_ in _loc119_.spell.spellLevels)
                  {
                     _loc69_ = SpellLevel.getLevelById(_loc120_);
                     if(_loc69_)
                     {
                        for each(_loc93_ in _loc69_.effects)
                        {
                           if(_loc93_.effectUid == _loc67_.effect.effectId)
                           {
                              _loc68_ = _loc119_;
                           }
                        }
                     }
                  }
               }
               if(!_loc68_)
               {
                  if(_loc67_.actionId == ActionIdConverter.ACTION_CHARACTER_UPDATE_BOOST)
                  {
                     _loc68_ = new CastingSpell(false);
                  }
                  else
                  {
                     _loc68_ = new CastingSpell(this._castingSpell == null);
                  }
                  if(this._castingSpell)
                  {
                     _loc68_.castingSpellId = this._castingSpell.castingSpellId;
                     if(this._castingSpell.spell && this._castingSpell.spell.id == _loc67_.effect.spellId)
                     {
                        _loc68_.spellRank = this._castingSpell.spellRank;
                     }
                  }
                  _loc68_.spell = Spell.getSpellById(_loc67_.effect.spellId);
                  _loc68_.casterId = _loc67_.sourceId;
               }
               _loc70_ = _loc67_.effect;
               _loc71_ = BuffManager.makeBuffFromEffect(_loc70_,_loc68_,_loc67_.actionId);
               if(_loc71_ is StateBuff)
               {
                  _loc121_ = _loc71_ as StateBuff;
                  if(_loc121_.actionId == ActionIdConverter.ACTION_FIGHT_DISABLE_STATE)
                  {
                     _loc122_ = new FightLeavingStateStep(_loc121_.targetId,_loc121_.stateId);
                  }
                  else
                  {
                     _loc122_ = new FightEnteringStateStep(_loc121_.targetId,_loc121_.stateId,_loc121_.effect.durationString);
                  }
                  if(_loc68_ != null)
                  {
                     _loc122_.castingSpellId = _loc68_.castingSpellId;
                  }
                  this._stepsBuffer.push(_loc122_);
               }
               if(_loc70_ is FightTemporaryBoostEffect)
               {
                  _loc123_ = _loc67_.actionId;
                  if(_loc123_ != ActionIdConverter.ACTION_CHARACTER_MAKE_INVISIBLE && _loc123_ != ActionIdConverter.ACTION_CHARACTER_UPDATE_BOOST && _loc123_ != ActionIdConverter.ACTION_CHARACTER_CHANGE_LOOK && _loc123_ != ActionIdConverter.ACTION_CHARACTER_CHANGE_COLOR && _loc123_ != ActionIdConverter.ACTION_CHARACTER_ADD_APPEARANCE && _loc123_ != ActionIdConverter.ACTION_FIGHT_SET_STATE)
                  {
                     this.pushTemporaryBoostStep(_loc67_.effect.targetId,_loc71_.effect.description,_loc71_.effect.duration,_loc71_.effect.durationString,_loc71_.effect.visibleInFightLog);
                  }
                  if(_loc123_ == ActionIdConverter.ACTION_CHARACTER_BOOST_SHIELD)
                  {
                     this.pushShieldPointsVariationStep(_loc67_.effect.targetId,(_loc71_ as StatBuff).delta,_loc123_);
                  }
               }
               this.pushDisplayBuffStep(_loc71_);
               return true;
            case param1 is GameActionFightModifyEffectsDurationMessage:
               _loc72_ = param1 as GameActionFightModifyEffectsDurationMessage;
               this.pushModifyEffectsDurationStep(_loc72_.sourceId,_loc72_.targetId,_loc72_.delta);
               return false;
            case param1 is GameActionFightCarryCharacterMessage:
               _loc73_ = param1 as GameActionFightCarryCharacterMessage;
               if(_loc73_.cellId != -1)
               {
                  _loc2_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
                  _loc2_.saveFighterPosition(_loc73_.targetId,_loc73_.cellId);
                  this.pushCarryCharacterStep(_loc73_.sourceId,_loc73_.targetId,_loc73_.cellId);
               }
               return false;
            case param1 is GameActionFightThrowCharacterMessage:
               _loc74_ = param1 as GameActionFightThrowCharacterMessage;
               _loc75_ = this._castingSpell?this._castingSpell.targetedCell.cellId:_loc74_.cellId;
               _loc2_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               _loc2_.saveFighterPosition(_loc74_.targetId,DofusEntities.getEntity(_loc74_.targetId).position.cellId);
               this.pushThrowCharacterStep(_loc74_.sourceId,_loc74_.targetId,_loc75_);
               return false;
            case param1 is GameActionFightDropCharacterMessage:
               _loc76_ = param1 as GameActionFightDropCharacterMessage;
               _loc77_ = _loc76_.cellId;
               if(_loc77_ == -1 && this._castingSpell)
               {
                  _loc77_ = this._castingSpell.targetedCell.cellId;
               }
               this.pushThrowCharacterStep(_loc76_.sourceId,_loc76_.targetId,_loc77_);
               return false;
            case param1 is GameActionFightInvisibleDetectedMessage:
               _loc78_ = param1 as GameActionFightInvisibleDetectedMessage;
               this.pushFightInvisibleTemporarilyDetectedStep(_loc78_.sourceId,_loc78_.cellId);
               FightEntitiesFrame.getCurrentInstance().setLastKnownEntityPosition(_loc78_.targetId,_loc78_.cellId);
               FightEntitiesFrame.getCurrentInstance().setLastKnownEntityMovementPoint(_loc78_.targetId,0);
               return true;
            case param1 is GameFightTurnListMessage:
               _loc79_ = param1 as GameFightTurnListMessage;
               this.pushTurnListStep(_loc79_.ids,_loc79_.deadsIds);
               return true;
            case param1 is AbstractGameActionMessage:
               _log.error("Unsupported game action " + param1 + " ! This action was discarded.");
               return true;
         }
         return false;
      }
      
      public function execute(param1:Function = null) : void
      {
         this._sequencer = new SerialSequencer(FIGHT_SEQUENCERS_CATEGORY);
         if(this._parent)
         {
            _log.info("Process sub sequence");
            this._parent.addSubSequence(this._sequencer);
         }
         else
         {
            _log.info("Execute sequence");
         }
         if(this._fxScriptId > 0)
         {
            if(this._castingSpell && this._castingSpell.spell)
            {
               _log.info("Executing SpellScript" + this._fxScriptId + " for spell \'" + this._castingSpell.spell.name + "\' (" + this._castingSpell.spell.id + ")");
            }
            else
            {
               _log.info("Executing SpellScript" + this._fxScriptId + " for unknown spell");
            }
            this._scriptStarted = getTimer();
            SpellScriptManager.getInstance().runSpellScript(this._fxScriptId,this,new Callback(this.executeBuffer,param1,true,true),new Callback(this.executeBuffer,param1,true,false));
         }
         else
         {
            this.executeBuffer(param1,false);
         }
      }
      
      private function executeBuffer(param1:Function, param2:Boolean, param3:Boolean = false) : void
      {
         var _loc8_:ISequencable = null;
         var _loc10_:* = false;
         var _loc11_:* = false;
         var _loc12_:Array = null;
         var _loc13_:Array = null;
         var _loc14_:* = false;
         var _loc15_:Dictionary = null;
         var _loc16_:Dictionary = null;
         var _loc17_:Dictionary = null;
         var _loc18_:Dictionary = null;
         var _loc19_:Dictionary = null;
         var _loc20_:* = 0;
         var _loc21_:* = 0;
         var _loc22_:* = undefined;
         var _loc23_:* = undefined;
         var _loc24_:WaitAnimationEventStep = null;
         var _loc25_:uint = 0;
         var _loc26_:PlayAnimationStep = null;
         var _loc27_:FightDeathStep = null;
         var _loc28_:* = 0;
         var _loc29_:FightActionPointsVariationStep = null;
         var _loc30_:FightShieldPointsVariationStep = null;
         var _loc31_:FightLifeVariationStep = null;
         var _loc32_:* = 0;
         var _loc33_:* = 0;
         var _loc34_:* = undefined;
         var _loc35_:uint = 0;
         if(param2)
         {
            _loc25_ = getTimer() - this._scriptStarted;
            if(!param3)
            {
               _log.warn("Script failed during a fight sequence, but still took " + _loc25_ + "ms.");
            }
            else
            {
               _log.info("Script successfuly executed in " + _loc25_ + "ms.");
            }
         }
         var _loc4_:Array = [];
         var _loc5_:Dictionary = new Dictionary(true);
         var _loc6_:Dictionary = new Dictionary(true);
         var _loc7_:Dictionary = new Dictionary(true);
         var _loc9_:* = false;
         for each(_loc8_ in this._stepsBuffer)
         {
            switch(true)
            {
               case _loc8_ is FightMarkTriggeredStep:
                  _loc9_ = true;
                  continue;
               default:
                  continue;
            }
         }
         _loc10_ = OptionManager.getOptionManager("dofus")["allowHitAnim"];
         _loc11_ = OptionManager.getOptionManager("dofus")["allowSpellEffects"];
         _loc12_ = [];
         _loc13_ = [];
         _loc15_ = new Dictionary();
         _loc16_ = new Dictionary(true);
         _loc17_ = new Dictionary(true);
         _loc18_ = new Dictionary(true);
         _loc19_ = new Dictionary(true);
         _loc20_ = 0;
         _loc21_ = this._stepsBuffer.length;
         while(--_loc21_ >= 0)
         {
            if(_loc14_ && _loc8_)
            {
               _loc8_.clear();
            }
            _loc14_ = true;
            _loc8_ = this._stepsBuffer[_loc21_];
            switch(true)
            {
               case _loc8_ is PlayAnimationStep:
                  _loc26_ = _loc8_ as PlayAnimationStep;
                  if(_loc26_.animation.indexOf(AnimationEnum.ANIM_HIT) != -1)
                  {
                     if(!_loc10_)
                     {
                        continue;
                     }
                     _loc26_.waitEvent = _loc9_;
                     if(_loc26_.target == null)
                     {
                        continue;
                     }
                     if(_loc5_[EntitiesManager.getInstance().getEntityID(_loc26_.target as IEntity)])
                     {
                        continue;
                     }
                     if(_loc6_[_loc26_.target])
                     {
                        continue;
                     }
                     if(_loc26_.animation != AnimationEnum.ANIM_HIT && _loc26_.animation != AnimationEnum.ANIM_HIT_CARRYING && !_loc26_.target.hasAnimation(_loc26_.animation,1))
                     {
                        _loc26_.animation = AnimationEnum.ANIM_HIT;
                     }
                     _loc6_[_loc26_.target] = true;
                  }
                  if(this._castingSpell.casterId < 0)
                  {
                     if(_loc15_[_loc26_.target])
                     {
                        _loc4_.unshift(_loc15_[_loc26_.target]);
                        delete _loc15_[_loc26_.target];
                     }
                     if(_loc26_.animation.indexOf(AnimationEnum.ANIM_ATTAQUE_BASE) != -1)
                     {
                        _loc15_[_loc26_.target] = new WaitAnimationEventStep(_loc26_);
                     }
                  }
                  break;
               case _loc8_ is FightDeathStep:
                  _loc27_ = _loc8_ as FightDeathStep;
                  _loc5_[_loc27_.entityId] = true;
                  _loc28_ = this._fightBattleFrame.targetedEntities.indexOf(_loc27_.entityId);
                  if(_loc28_ != -1)
                  {
                     this._fightBattleFrame.targetedEntities.splice(_loc28_,1);
                     TooltipManager.hide("tooltipOverEntity_" + _loc27_.entityId);
                  }
                  _loc20_++;
                  break;
               case _loc8_ is FightActionPointsVariationStep:
                  _loc29_ = _loc8_ as FightActionPointsVariationStep;
                  if(_loc29_.voluntarlyUsed)
                  {
                     _loc12_.push(_loc29_);
                     _loc14_ = false;
                     continue;
                  }
                  break;
               case _loc8_ is FightShieldPointsVariationStep:
                  _loc30_ = _loc8_ as FightShieldPointsVariationStep;
                  if(_loc30_.target == null)
                  {
                     break;
                  }
                  if(_loc30_.value < 0)
                  {
                     _loc30_.virtual = true;
                     if(_loc18_[_loc30_.target] == null)
                     {
                        _loc18_[_loc30_.target] = 0;
                     }
                     _loc18_[_loc30_.target] = _loc18_[_loc30_.target] + _loc30_.value;
                     _loc19_[_loc30_.target] = _loc30_;
                  }
                  this.showTargetTooltip(_loc30_.target.id);
                  break;
               case _loc8_ is FightLifeVariationStep:
                  _loc31_ = _loc8_ as FightLifeVariationStep;
                  if(_loc31_.target == null)
                  {
                     break;
                  }
                  if(_loc31_.delta < 0)
                  {
                     _loc7_[_loc31_.target] = _loc31_;
                  }
                  if(_loc16_[_loc31_.target] == null)
                  {
                     _loc16_[_loc31_.target] = 0;
                  }
                  _loc16_[_loc31_.target] = _loc16_[_loc31_.target] + _loc31_.delta;
                  _loc17_[_loc31_.target] = _loc31_;
                  this.showTargetTooltip(_loc31_.target.id);
                  break;
               case _loc8_ is AddGfxEntityStep:
               case _loc8_ is AddGfxInLineStep:
               case _loc8_ is ParableGfxMovementStep:
               case _loc8_ is AddWorldEntityStep:
                  if(!_loc11_)
                  {
                     continue;
                  }
                  break;
            }
            _loc14_ = false;
            _loc4_.unshift(_loc8_);
         }
         this._fightBattleFrame.deathPlayingNumber = _loc20_;
         for each(_loc22_ in _loc4_)
         {
            if(_loc22_ is FightLifeVariationStep && _loc16_[_loc22_.target] == 0 && _loc18_[_loc22_.target] != null)
            {
               _loc22_.skipTextEvent = true;
            }
         }
         for(_loc23_ in _loc16_)
         {
            if(_loc23_ != "null" && _loc16_[_loc23_] != 0)
            {
               _loc32_ = _loc4_.indexOf(_loc17_[_loc23_]);
               _loc4_.splice(_loc32_,0,new FightLossAnimStep(_loc23_,_loc16_[_loc23_],FightLifeVariationStep.COLOR));
            }
            _loc17_[_loc23_] = -1;
            _loc16_[_loc23_] = 0;
         }
         for(_loc23_ in _loc18_)
         {
            if(_loc23_ != "null" && _loc18_[_loc23_] != 0)
            {
               _loc33_ = _loc4_.indexOf(_loc19_[_loc23_]);
               _loc4_.splice(_loc33_,0,new FightLossAnimStep(_loc23_,_loc18_[_loc23_],FightShieldPointsVariationStep.COLOR));
            }
            _loc19_[_loc23_] = -1;
            _loc18_[_loc23_] = 0;
         }
         for each(_loc24_ in _loc15_)
         {
            _loc13_.push(_loc24_);
         }
         if(_loc10_)
         {
            for(_loc34_ in _loc7_)
            {
               if(!_loc6_[_loc34_])
               {
                  _loc35_ = 0;
                  while(_loc35_ < _loc4_.length)
                  {
                     if(_loc4_[_loc35_] == _loc7_[_loc34_])
                     {
                        _loc4_.splice(_loc35_,0,new PlayAnimationStep(_loc34_ as TiphonSprite,AnimationEnum.ANIM_HIT,true,false));
                        break;
                     }
                     _loc35_++;
                  }
                  continue;
               }
            }
         }
         _loc4_ = _loc12_.concat(_loc4_).concat(_loc13_);
         for each(_loc8_ in _loc4_)
         {
            this._sequencer.addStep(_loc8_);
         }
         this.clearBuffer();
         if(param1 != null && !this._parent)
         {
            this._sequenceEndCallback = param1;
            this._sequencer.addEventListener(SequencerEvent.SEQUENCE_END,this.onSequenceEnd);
         }
         _lastCastingSpell = this._castingSpell;
         this._scriptInit = true;
         if(!this._parent)
         {
            if(!this._subSequenceWaitingCount)
            {
               this._sequencer.start();
            }
            else
            {
               _log.warn("Waiting sub sequence init end (" + this._subSequenceWaitingCount + " seq)");
            }
         }
         else
         {
            if(param1 != null)
            {
               param1();
            }
            this._parent.subSequenceInitDone();
         }
      }
      
      private function onSequenceEnd(param1:SequencerEvent) : void
      {
         this._sequencer.removeEventListener(SequencerEvent.SEQUENCE_END,this.onSequenceEnd);
         this._sequenceEndCallback();
      }
      
      private function subSequenceInitDone() : void
      {
         this._subSequenceWaitingCount--;
         if(!this.isWaiting && this._sequencer && !this._sequencer.running)
         {
            _log.warn("Sub sequence init end -- Run main sequence");
            this._sequencer.start();
         }
      }
      
      private function pushRefreshFighterStep(param1:GameContextActorInformations) : void
      {
         this._stepsBuffer.push(new FightRefreshFighterStep(param1));
      }
      
      private function pushMovementStep(param1:int, param2:MovementPath) : void
      {
         this._stepsBuffer.push(new CallbackStep(new Callback(deleteTooltip,param1)));
         var _loc3_:FightEntityMovementStep = new FightEntityMovementStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushTeleportStep(param1:int, param2:int) : void
      {
         var _loc3_:FightTeleportStep = null;
         this._stepsBuffer.push(new CallbackStep(new Callback(deleteTooltip,param1)));
         if(param2 != -1)
         {
            _loc3_ = new FightTeleportStep(param1,MapPoint.fromCellId(param2));
            if(this.castingSpell != null)
            {
               _loc3_.castingSpellId = this.castingSpell.castingSpellId;
            }
            this._stepsBuffer.push(_loc3_);
         }
      }
      
      private function pushExchangePositionsStep(param1:int, param2:int, param3:int, param4:int) : void
      {
         this._stepsBuffer.push(new CallbackStep(new Callback(deleteTooltip,param1)));
         this._stepsBuffer.push(new CallbackStep(new Callback(deleteTooltip,param3)));
         var _loc5_:FightExchangePositionsStep = new FightExchangePositionsStep(param1,param2,param3,param4);
         if(this.castingSpell != null)
         {
            _loc5_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc5_);
      }
      
      private function pushSlideStep(param1:int, param2:int, param3:int) : void
      {
         if(param2 < 0 || param3 < 0)
         {
            return;
         }
         this._stepsBuffer.push(new CallbackStep(new Callback(deleteTooltip,param1)));
         var _loc4_:FightEntitySlideStep = new FightEntitySlideStep(param1,MapPoint.fromCellId(param2),MapPoint.fromCellId(param3));
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushSummonStep(param1:int, param2:GameFightFighterInformations) : void
      {
         var _loc3_:FightSummonStep = new FightSummonStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushVisibilityStep(param1:int, param2:Boolean) : void
      {
         var _loc3_:FightVisibilityStep = new FightVisibilityStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushMarkCellsStep(param1:int, param2:int, param3:Vector.<GameActionMarkedCell>, param4:int, param5:SpellLevel, param6:int, param7:int) : void
      {
         var _loc8_:FightMarkCellsStep = new FightMarkCellsStep(param1,param2,param3,param4,param5,param6,param7);
         if(this.castingSpell != null)
         {
            _loc8_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc8_);
      }
      
      private function pushUnmarkCellsStep(param1:int) : void
      {
         var _loc2_:FightUnmarkCellsStep = new FightUnmarkCellsStep(param1);
         if(this.castingSpell != null)
         {
            _loc2_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc2_);
      }
      
      private function pushChangeLookStep(param1:int, param2:EntityLook) : void
      {
         var _loc3_:FightChangeLookStep = new FightChangeLookStep(param1,EntityLookAdapter.fromNetwork(param2));
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushChangeVisibilityStep(param1:int, param2:int) : void
      {
         var _loc3_:FightChangeVisibilityStep = new FightChangeVisibilityStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushPointsVariationStep(param1:int, param2:uint, param3:int) : void
      {
         var _loc4_:IFightStep = null;
         switch(param2)
         {
            case ActionIdConverter.ACTION_CHARACTER_ACTION_POINTS_USE:
               _loc4_ = new FightActionPointsVariationStep(param1,param3,true);
               break;
            case ActionIdConverter.ACTION_CHARACTER_ACTION_POINTS_LOST:
            case ActionIdConverter.ACTION_CHARACTER_ACTION_POINTS_WIN:
               _loc4_ = new FightActionPointsVariationStep(param1,param3,false);
               break;
            case ActionIdConverter.ACTION_CHARACTER_MOVEMENT_POINTS_USE:
               _loc4_ = new FightMovementPointsVariationStep(param1,param3,true);
               break;
            case ActionIdConverter.ACTION_CHARACTER_MOVEMENT_POINTS_LOST:
            case ActionIdConverter.ACTION_CHARACTER_MOVEMENT_POINTS_WIN:
               _loc4_ = new FightMovementPointsVariationStep(param1,param3,false);
               break;
            default:
               _log.warn("Points variation with unsupported action (" + param2 + "), skipping.");
               return;
         }
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushShieldPointsVariationStep(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:FightShieldPointsVariationStep = new FightShieldPointsVariationStep(param1,param2,param3);
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushTemporaryBoostStep(param1:int, param2:String, param3:int, param4:String, param5:Boolean = true) : void
      {
         var _loc6_:FightTemporaryBoostStep = new FightTemporaryBoostStep(param1,param2,param3,param4,param5);
         if(this.castingSpell != null)
         {
            _loc6_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc6_);
      }
      
      private function pushPointsLossDodgeStep(param1:int, param2:uint, param3:int) : void
      {
         var _loc4_:IFightStep = null;
         switch(param2)
         {
            case ActionIdConverter.ACTION_FIGHT_SPELL_DODGED_PA:
               _loc4_ = new FightActionPointsLossDodgeStep(param1,param3);
               break;
            case ActionIdConverter.ACTION_FIGHT_SPELL_DODGED_PM:
               _loc4_ = new FightMovementPointsLossDodgeStep(param1,param3);
               break;
            default:
               _log.warn("Points dodge with unsupported action (" + param2 + "), skipping.");
               return;
         }
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushLifePointsVariationStep(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:FightLifeVariationStep = new FightLifeVariationStep(param1,param2,param3,param4);
         if(this.castingSpell != null)
         {
            _loc5_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc5_);
      }
      
      private function pushDeathStep(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:FightDeathStep = new FightDeathStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushVanishStep(param1:int, param2:int) : void
      {
         var _loc3_:FightVanishStep = new FightVanishStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushDispellStep(param1:int) : void
      {
         var _loc2_:FightDispellStep = new FightDispellStep(param1);
         if(this.castingSpell != null)
         {
            _loc2_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc2_);
      }
      
      private function pushDispellEffectStep(param1:int, param2:int) : void
      {
         var _loc3_:FightDispellEffectStep = new FightDispellEffectStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushDispellSpellStep(param1:int, param2:int) : void
      {
         var _loc3_:FightDispellSpellStep = new FightDispellSpellStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushSpellCooldownVariationStep(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:FightSpellCooldownVariationStep = new FightSpellCooldownVariationStep(param1,param2,param3,param4);
         if(this.castingSpell != null)
         {
            _loc5_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc5_);
      }
      
      private function pushSpellImmunityStep(param1:int) : void
      {
         var _loc2_:FightSpellImmunityStep = new FightSpellImmunityStep(param1);
         if(this.castingSpell != null)
         {
            _loc2_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc2_);
      }
      
      private function pushKillStep(param1:int, param2:int) : void
      {
         var _loc3_:FightKillStep = new FightKillStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushReducedDamagesStep(param1:int, param2:int) : void
      {
         var _loc3_:FightReducedDamagesStep = new FightReducedDamagesStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushReflectedDamagesStep(param1:int) : void
      {
         var _loc2_:FightReflectedDamagesStep = new FightReflectedDamagesStep(param1);
         if(this.castingSpell != null)
         {
            _loc2_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc2_);
      }
      
      private function pushReflectedSpellStep(param1:int) : void
      {
         var _loc2_:FightReflectedSpellStep = new FightReflectedSpellStep(param1);
         if(this.castingSpell != null)
         {
            _loc2_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc2_);
      }
      
      private function pushSpellCastStep(param1:int, param2:int, param3:int, param4:int, param5:uint, param6:uint) : void
      {
         var _loc7_:FightSpellCastStep = new FightSpellCastStep(param1,param2,param3,param4,param5,param6);
         if(this.castingSpell != null)
         {
            _loc7_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc7_);
      }
      
      private function pushCloseCombatStep(param1:int, param2:uint, param3:uint) : void
      {
         var _loc4_:FightCloseCombatStep = new FightCloseCombatStep(param1,param2,param3);
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushStealKamasStep(param1:int, param2:int, param3:uint) : void
      {
         var _loc4_:FightStealingKamasStep = new FightStealingKamasStep(param1,param2,param3);
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushTackledStep(param1:int) : void
      {
         var _loc2_:FightTackledStep = new FightTackledStep(param1);
         if(this.castingSpell != null)
         {
            _loc2_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc2_);
      }
      
      private function pushMarkTriggeredStep(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:FightMarkTriggeredStep = new FightMarkTriggeredStep(param1,param2,param3);
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushMarkActivateStep(param1:int, param2:Boolean) : void
      {
         var _loc3_:FightMarkActivateStep = new FightMarkActivateStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function pushDisplayBuffStep(param1:BasicBuff) : void
      {
         var _loc2_:FightDisplayBuffStep = new FightDisplayBuffStep(param1);
         if(this.castingSpell != null)
         {
            _loc2_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc2_);
      }
      
      private function pushModifyEffectsDurationStep(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:FightModifyEffectsDurationStep = new FightModifyEffectsDurationStep(param1,param2,param3);
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushCarryCharacterStep(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:FightCarryCharacterStep = new FightCarryCharacterStep(param1,param2,param3);
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
         this._stepsBuffer.push(new CallbackStep(new Callback(deleteTooltip,param2)));
      }
      
      private function pushThrowCharacterStep(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:FightThrowCharacterStep = new FightThrowCharacterStep(param1,param2,param3);
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
            _loc4_.portals = this.castingSpell.portalMapPoints;
            _loc4_.portalIds = this.castingSpell.portalIds;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushFightInvisibleTemporarilyDetectedStep(param1:int, param2:uint) : void
      {
         var _loc3_:AnimatedCharacter = DofusEntities.getEntity(param1) as AnimatedCharacter;
         var _loc4_:FightInvisibleTemporarilyDetectedStep = new FightInvisibleTemporarilyDetectedStep(_loc3_,param2);
         if(this.castingSpell != null)
         {
            _loc4_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc4_);
      }
      
      private function pushTurnListStep(param1:Vector.<int>, param2:Vector.<int>) : void
      {
         var _loc3_:FightTurnListStep = new FightTurnListStep(param1,param2);
         if(this.castingSpell != null)
         {
            _loc3_.castingSpellId = this.castingSpell.castingSpellId;
         }
         this._stepsBuffer.push(_loc3_);
      }
      
      private function clearBuffer() : void
      {
         this._stepsBuffer = new Vector.<ISequencable>(0,false);
      }
      
      private function showTargetTooltip(param1:int) : void
      {
         var _loc2_:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         var _loc3_:GameFightFighterInformations = this.fightEntitiesFrame.getEntityInfos(param1) as GameFightFighterInformations;
         if(_loc3_.alive && this._castingSpell && (this._castingSpell.casterId == PlayedCharacterManager.getInstance().id || _loc2_.battleFrame.playingSlaveEntity) && param1 != this.castingSpell.casterId && this._fightBattleFrame.targetedEntities.indexOf(param1) == -1)
         {
            this._fightBattleFrame.targetedEntities.push(param1);
            if(OptionManager.getOptionManager("dofus")["showPermanentTargetsTooltips"] == true)
            {
               _loc2_.displayEntityTooltip(param1);
            }
         }
      }
      
      private function isSpellTeleportingToPreviousPosition() : Boolean
      {
         var _loc1_:EffectInstanceDice = null;
         if(this._castingSpell && this._castingSpell.spellRank)
         {
            for each(_loc1_ in this._castingSpell.spellRank.effects)
            {
               if(_loc1_.effectId == 1100)
               {
                  return true;
               }
            }
         }
         return false;
      }
   }
}
