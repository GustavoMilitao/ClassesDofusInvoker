package com.ankamagames.dofus.logic.game.fight.miscs
{
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.dofus.datacenter.effects.EffectInstance;
   import com.ankamagames.dofus.logic.game.fight.frames.FightContextFrame;
   import com.ankamagames.jerakine.types.zones.IZone;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.dofus.logic.game.fight.types.BasicBuff;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightFighterInformations;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.tiphon.display.TiphonSprite;
   import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
   import com.ankamagames.dofus.logic.game.fight.managers.SpellZoneManager;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.dofus.logic.game.fight.managers.BuffManager;
   import com.ankamagames.dofus.datacenter.spells.SpellBomb;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceDice;
   import com.ankamagames.dofus.datacenter.spells.SpellLevel;
   import com.ankamagames.dofus.datacenter.effects.Effect;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamageInfo;
   import flash.utils.Dictionary;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.dofus.logic.game.fight.managers.FightersStateManager;
   import com.ankamagames.dofus.logic.game.fight.managers.CurrentPlayedFighterManager;
   import com.ankamagames.jerakine.utils.display.spellZone.SpellShapeEnum;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightCompanionInformations;
   import com.ankamagames.dofus.logic.game.fight.types.SpellDamage;
   import com.ankamagames.dofus.logic.game.fight.types.EffectDamage;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceInteger;
   import com.ankamagames.dofus.datacenter.effects.instances.EffectInstanceMinMax;
   import com.ankamagames.dofus.network.enums.CharacterSpellModificationTypeEnum;
   import com.ankamagames.dofus.network.types.game.character.characteristic.CharacterSpellModification;
   import com.ankamagames.dofus.datacenter.monsters.MonsterGrade;
   import com.ankamagames.dofus.logic.game.fight.types.SplashDamage;
   import com.ankamagames.dofus.logic.game.fight.types.PushedEntity;
   import com.ankamagames.dofus.logic.game.fight.types.ReflectDamage;
   import com.ankamagames.dofus.logic.game.fight.types.StatBuff;
   import com.ankamagames.dofus.logic.game.fight.types.EffectModification;
   import com.ankamagames.dofus.logic.game.fight.types.MarkInstance;
   import com.ankamagames.dofus.logic.game.fight.managers.MarkedCellsManager;
   import com.ankamagames.dofus.network.enums.GameActionMarkTypeEnum;
   import com.ankamagames.dofus.logic.game.fight.managers.LinkedCellsManager;
   import com.ankamagames.dofus.logic.game.fight.types.TriggeredSpell;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   
   public class DamageUtil extends Object
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(DamageUtil));
      
      private static const exclusiveTargetMasks:RegExp = new RegExp("\\*?[bBeEfFzZKoOPpTWUvV][0-9]*","g");
      
      public static const NEUTRAL_ELEMENT:int = 0;
      
      public static const EARTH_ELEMENT:int = 1;
      
      public static const FIRE_ELEMENT:int = 2;
      
      public static const WATER_ELEMENT:int = 3;
      
      public static const AIR_ELEMENT:int = 4;
      
      public static const NONE_ELEMENT:int = 5;
      
      public static const EFFECTSHAPE_DEFAULT_AREA_SIZE:int = 1;
      
      public static const EFFECTSHAPE_DEFAULT_MIN_AREA_SIZE:int = 0;
      
      public static const EFFECTSHAPE_DEFAULT_EFFICIENCY:int = 10;
      
      public static const EFFECTSHAPE_DEFAULT_MAX_EFFICIENCY_APPLY:int = 4;
      
      private static const DAMAGE_NOT_BOOSTED:int = 1;
      
      private static const UNLIMITED_ZONE_SIZE:int = 50;
      
      private static const AT_LEAST_MASK_TYPES:Array = ["B","F","Z"];
      
      public static const DAMAGE_EFFECT_CATEGORY:int = 2;
      
      public static const EROSION_DAMAGE_EFFECTS_IDS:Array = [1092,1093,1094,1095,1096];
      
      public static const HEALING_EFFECTS_IDS:Array = [81,108,1109,90];
      
      public static const IMMEDIATE_BOOST_EFFECTS_IDS:Array = [266,268,269,271,414];
      
      public static const BOMB_SPELLS_IDS:Array = [2796,2797,2808];
      
      public static const SPLASH_EFFECTS_IDS:Array = [1123,1124,1125,1126,1127,1128,2020];
      
      public static const SPLASH_HEAL_EFFECT_ID:uint = 2020;
      
      public static const MP_BASED_DAMAGE_EFFECTS_IDS:Array = [1012,1013,1014,1015,1016];
      
      public static const HP_BASED_DAMAGE_EFFECTS_IDS:Array = [672,85,86,87,88,89];
      
      public static const TARGET_HP_BASED_DAMAGE_EFFECTS_IDS:Array = [1067,1068,1069,1070,1071];
      
      public static const TRIGGERED_EFFECTS_IDS:Array = [138,1040];
      
      public static const NO_BOOST_EFFECTS_IDS:Array = [144,82];
       
      public function DamageUtil()
      {
         super();
      }
      
      public static function isDamagedOrHealedBySpell(param1:int, param2:int, param3:Object, param4:int) : Boolean
      {
         var _loc11_:* = false;
         var _loc12_:EffectInstance = null;
         var _loc14_:FightContextFrame = null;
         var _loc15_:IZone = null;
         var _loc16_:Vector.<uint> = null;
         var _loc17_:uint = 0;
         var _loc18_:Array = null;
         var _loc19_:AnimatedCharacter = null;
         var _loc20_:Array = null;
         var _loc21_:BasicBuff = null;
         var _loc5_:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!param3 || !_loc5_)
         {
            return false;
         }
         var _loc6_:GameFightFighterInformations = _loc5_.getEntityInfos(param2) as GameFightFighterInformations;
         if(!_loc6_)
         {
            return false;
         }
         var _loc7_:TiphonSprite = DofusEntities.getEntity(param2) as AnimatedCharacter;
         var _loc8_:* = param2 == param1;
         var _loc9_:Boolean = _loc7_ && _loc7_.parentSprite && _loc7_.parentSprite.carriedEntity == _loc7_;
         var _loc10_:GameFightFighterInformations = _loc5_.getEntityInfos(param1) as GameFightFighterInformations;
         if(!(param3 is SpellWrapper) || param3.id == 0)
         {
            if(!_loc8_ && !_loc9_)
            {
               return true;
            }
            if(!_loc9_)
            {
               _loc14_ = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
               _loc15_ = SpellZoneManager.getInstance().getSpellZone(param3,false,false);
               _loc15_.direction = MapPoint.fromCellId(_loc10_.disposition.cellId).advancedOrientationTo(MapPoint.fromCellId(param4),false);
               _loc16_ = _loc15_.getCells(param4);
               for each(_loc17_ in _loc16_)
               {
                  if(_loc17_ != _loc10_.disposition.cellId)
                  {
                     _loc18_ = EntitiesManager.getInstance().getEntitiesOnCell(_loc17_,AnimatedCharacter);
                     for each(_loc19_ in _loc18_)
                     {
                        if(_loc19_.id != param1 && _loc14_.entitiesFrame.getEntityInfos(_loc19_.id) && isDamagedOrHealedBySpell(param1,_loc19_.id,param3,param4) && getReflectDamageValue(_loc19_.id) > 0)
                        {
                           return true;
                        }
                     }
                  }
               }
               return false;
            }
            return false;
         }
         var _loc13_:Boolean = PushUtil.isPushableEntity(_loc6_);
         if(BOMB_SPELLS_IDS.indexOf(param3.id) != -1)
         {
            var param3:Object = getBombDirectDamageSpellWrapper(param3 as SpellWrapper);
         }
         for each(_loc12_ in param3.effects)
         {
            if(_loc12_.triggers == "I" && (_loc12_.category == 2 || HEALING_EFFECTS_IDS.indexOf(_loc12_.effectId) != -1 || _loc12_.effectId == 5 && _loc13_) && verifySpellEffectMask(param1,param2,_loc12_,param4) && (_loc12_.targetMask.indexOf("C") != -1 && _loc8_ || verifySpellEffectZone(param2,_loc12_,param4,_loc10_.disposition.cellId)))
            {
               _loc11_ = true;
               break;
            }
         }
         if(!_loc11_)
         {
            for each(_loc12_ in param3.criticalEffect)
            {
               if(_loc12_.triggers == "I" && (_loc12_.category == 2 || HEALING_EFFECTS_IDS.indexOf(_loc12_.effectId) != -1 || _loc12_.effectId == 5 && _loc13_) && verifySpellEffectMask(param1,param2,_loc12_,param4) && verifySpellEffectZone(param2,_loc12_,param4,_loc10_.disposition.cellId))
               {
                  _loc11_ = true;
                  break;
               }
            }
         }
         if(!_loc11_)
         {
            _loc20_ = BuffManager.getInstance().getAllBuff(param2);
            if(_loc20_)
            {
               for each(_loc21_ in _loc20_)
               {
                  if(_loc21_.effect.category == DAMAGE_EFFECT_CATEGORY)
                  {
                     for each(_loc12_ in param3.effects)
                     {
                        if(verifyEffectTrigger(param1,param2,param3.effects,_loc12_,param3 is SpellWrapper,_loc21_.effect.triggers,param4))
                        {
                           _loc11_ = true;
                           break;
                        }
                     }
                     for each(_loc12_ in param3.criticalEffect)
                     {
                        if(verifyEffectTrigger(param1,param2,param3.criticalEffect,_loc12_,param3 is SpellWrapper,_loc21_.effect.triggers,param4))
                        {
                           _loc11_ = true;
                           break;
                        }
                     }
                  }
               }
            }
         }
         return _loc11_;
      }
      
      public static function getBombDirectDamageSpellWrapper(param1:SpellWrapper) : SpellWrapper
      {
         return SpellWrapper.create(0,SpellBomb.getSpellBombById((param1.effects[0] as EffectInstanceDice).diceNum).instantSpellId,param1.spellLevel,true,param1.playerId);
      }
      
      public static function getBuffEffectElements(param1:BasicBuff) : Vector.<int>
      {
         var _loc2_:Vector.<int> = null;
         var _loc4_:EffectInstance = null;
         var _loc5_:SpellLevel = null;
         var _loc3_:Effect = Effect.getEffectById(param1.effect.effectId);
         if(_loc3_.elementId == -1)
         {
            _loc5_ = param1.castingSpell.spellRank;
            if(!_loc5_)
            {
               _loc5_ = SpellLevel.getLevelById(param1.castingSpell.spell.spellLevels[0]);
            }
            for each(_loc4_ in _loc5_.effects)
            {
               if(_loc4_.effectId == param1.effect.effectId)
               {
                  if(!_loc2_)
                  {
                     _loc2_ = new Vector.<int>(0);
                  }
                  if(_loc4_.triggers.indexOf("DA") != -1 && _loc2_.indexOf(AIR_ELEMENT) == -1)
                  {
                     _loc2_.push(AIR_ELEMENT);
                  }
                  if(_loc4_.triggers.indexOf("DE") != -1 && _loc2_.indexOf(EARTH_ELEMENT) == -1)
                  {
                     _loc2_.push(EARTH_ELEMENT);
                  }
                  if(_loc4_.triggers.indexOf("DF") != -1 && _loc2_.indexOf(FIRE_ELEMENT) == -1)
                  {
                     _loc2_.push(FIRE_ELEMENT);
                  }
                  if(_loc4_.triggers.indexOf("DN") != -1 && _loc2_.indexOf(NEUTRAL_ELEMENT) == -1)
                  {
                     _loc2_.push(NEUTRAL_ELEMENT);
                  }
                  if(_loc4_.triggers.indexOf("DW") != -1 && _loc2_.indexOf(WATER_ELEMENT) == -1)
                  {
                     _loc2_.push(WATER_ELEMENT);
                  }
                  break;
               }
            }
         }
         return _loc2_;
      }
      
      public static function verifyBuffTriggers(param1:SpellDamageInfo, param2:BasicBuff) : Boolean
      {
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:EffectInstance = null;
         var _loc3_:String = param2.effect.triggers;
         if(_loc3_)
         {
            _loc4_ = _loc3_.split("|");
            for each(_loc5_ in _loc4_)
            {
               for each(_loc6_ in param1.spellEffects)
               {
                  if(verifyEffectTrigger(param1.casterId,param1.targetId,param1.spellEffects,_loc6_,param1.isWeapon,_loc5_,param1.spellCenterCell))
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      public static function verifyEffectTrigger(param1:int, param2:int, param3:Vector.<EffectInstance>, param4:EffectInstance, param5:Boolean, param6:String, param7:int) : Boolean
      {
         var _loc10_:String = null;
         var _loc11_:* = false;
         var _loc8_:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!_loc8_)
         {
            return false;
         }
         var _loc9_:Array = param6.split("|");
         var _loc12_:GameFightFighterInformations = _loc8_.getEntityInfos(param1) as GameFightFighterInformations;
         var _loc13_:GameFightFighterInformations = _loc8_.getEntityInfos(param2) as GameFightFighterInformations;
         var _loc14_:* = _loc13_.teamId == (_loc8_.getEntityInfos(param1) as GameFightFighterInformations).teamId;
         var _loc15_:int = _loc13_.disposition.cellId != -1?MapPoint.fromCellId(_loc12_.disposition.cellId).distanceTo(MapPoint.fromCellId(_loc13_.disposition.cellId)):-1;
         for each(_loc10_ in _loc9_)
         {
            if(!(param4.effectId == 5 && _loc10_ != "MD"))
            {
               switch(_loc10_)
               {
                  case "I":
                     _loc11_ = true;
                     break;
                  case "D":
                     _loc11_ = param4.category == DAMAGE_EFFECT_CATEGORY;
                     break;
                  case "DA":
                     _loc11_ = param4.category == DAMAGE_EFFECT_CATEGORY && Effect.getEffectById(param4.effectId).elementId == AIR_ELEMENT;
                     break;
                  case "DBA":
                     _loc11_ = _loc14_;
                     break;
                  case "DBE":
                     _loc11_ = !_loc14_;
                     break;
                  case "DC":
                     _loc11_ = param5;
                     break;
                  case "DE":
                     _loc11_ = param4.category == DAMAGE_EFFECT_CATEGORY && Effect.getEffectById(param4.effectId).elementId == EARTH_ELEMENT;
                     break;
                  case "DF":
                     _loc11_ = param4.category == DAMAGE_EFFECT_CATEGORY && Effect.getEffectById(param4.effectId).elementId == FIRE_ELEMENT;
                     break;
                  case "DG":
                     break;
                  case "DI":
                     break;
                  case "DM":
                     _loc11_ = _loc15_ == -1?false:_loc15_ <= 1;
                     break;
                  case "DN":
                     _loc11_ = param4.category == DAMAGE_EFFECT_CATEGORY && Effect.getEffectById(param4.effectId).elementId == NEUTRAL_ELEMENT;
                     break;
                  case "DP":
                     break;
                  case "DR":
                     _loc11_ = _loc15_ == -1?false:_loc15_ > 1;
                     break;
                  case "Dr":
                     break;
                  case "DS":
                     _loc11_ = !param5;
                     break;
                  case "DTB":
                     break;
                  case "DTE":
                     break;
                  case "DW":
                     _loc11_ = param4.category == DAMAGE_EFFECT_CATEGORY && Effect.getEffectById(param4.effectId).elementId == WATER_ELEMENT;
                     break;
                  case "MD":
                     _loc11_ = PushUtil.hasPushDamages(param1,param2,param3,param4,param7);
                     break;
                  case "MDM":
                     break;
                  case "MDP":
                     break;
                  case "A":
                     _loc11_ = param4.effectId == 101;
                     break;
                  case "m":
                     _loc11_ = param4.effectId == 127;
                     break;
               }
               if(_loc11_)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public static function verifySpellEffectMask(param1:int, param2:int, param3:EffectInstance, param4:int, param5:int = 0) : Boolean
      {
         var _loc15_:RegExp = null;
         var _loc16_:String = null;
         var _loc17_:Array = null;
         var _loc18_:String = null;
         var _loc19_:String = null;
         var _loc20_:* = false;
         var _loc21_:* = false;
         var _loc22_:* = 0;
         var _loc23_:Dictionary = null;
         var _loc24_:Vector.<String> = null;
         var _loc25_:String = null;
         var _loc26_:Vector.<String> = null;
         var _loc27_:* = false;
         var _loc28_:String = null;
         var _loc29_:* = 0;
         var _loc6_:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!param3 || !_loc6_ || param3.delay > 0 || !param3.targetMask)
         {
            return false;
         }
         var _loc7_:TiphonSprite = DofusEntities.getEntity(param2) as AnimatedCharacter;
         var _loc8_:* = param2 == param1;
         var _loc9_:Boolean = _loc7_ && _loc7_.parentSprite && _loc7_.parentSprite.carriedEntity == _loc7_;
         var _loc10_:GameFightFighterInformations = _loc6_.getEntityInfos(param2) as GameFightFighterInformations;
         var _loc11_:GameFightMonsterInformations = _loc10_ as GameFightMonsterInformations;
         var _loc12_:Array = FightersStateManager.getInstance().getStates(param1);
         var _loc13_:Array = FightersStateManager.getInstance().getStates(param2);
         var _loc14_:* = _loc10_.teamId == (_loc6_.getEntityInfos(param1) as GameFightFighterInformations).teamId;
         if(param1 == CurrentPlayedFighterManager.getInstance().currentFighterId && param3.category == 0 && param3.targetMask == "C")
         {
            return true;
         }
         if(_loc8_)
         {
            if(param3.effectId == 90)
            {
               return true;
            }
            if(param3.targetMask.indexOf("g") == -1)
            {
               if(verifySpellEffectZone(param1,param3,param4,_loc10_.disposition.cellId))
               {
                  _loc16_ = "caC";
               }
               else
               {
                  _loc16_ = "C";
               }
            }
            else
            {
               return false;
            }
         }
         else
         {
            if(_loc9_ && param3.zoneShape != SpellShapeEnum.A && param3.zoneShape != SpellShapeEnum.a)
            {
               return false;
            }
            if(_loc10_.stats.summoned && _loc11_ && !Monster.getMonsterById(_loc11_.creatureGenericId).canPlay)
            {
               _loc16_ = _loc14_?"agsj":"ASJ";
            }
            else if(_loc10_.stats.summoned)
            {
               _loc16_ = _loc14_?"agij":"AIJ";
            }
            else if(_loc10_ is GameFightCompanionInformations)
            {
               _loc16_ = _loc14_?"agdl":"ADL";
            }
            else if(_loc10_ is GameFightMonsterInformations)
            {
               _loc16_ = _loc14_?"agm":"AM";
            }
            else
            {
               _loc16_ = _loc14_?"gahl":"AHL";
            }
         }
         _loc15_ = new RegExp("[" + _loc16_ + "]","g");
         _loc21_ = param3.targetMask.match(_loc15_).length > 0;
         if(_loc21_)
         {
            _loc17_ = param3.targetMask.match(exclusiveTargetMasks);
            if(_loc17_.length > 0)
            {
               _loc21_ = false;
               _loc23_ = new Dictionary();
               _loc24_ = new Vector.<String>(0);
               for each(_loc18_ in _loc17_)
               {
                  _loc25_ = _loc18_.charAt(0);
                  if(_loc25_ == "*")
                  {
                     _loc25_ = _loc18_.substr(0,2);
                  }
                  if(AT_LEAST_MASK_TYPES.indexOf(_loc25_) != -1)
                  {
                     if(_loc24_.indexOf(_loc25_) != -1)
                     {
                        if(!_loc23_[_loc25_])
                        {
                           _loc23_[_loc25_] = 2;
                        }
                        else
                        {
                           _loc23_[_loc25_]++;
                        }
                     }
                     else
                     {
                        _loc24_.push(_loc25_);
                     }
                  }
               }
               _loc26_ = new Vector.<String>(0);
               for each(_loc18_ in _loc17_)
               {
                  _loc20_ = _loc18_.charAt(0) == "*";
                  _loc18_ = _loc20_?_loc18_.substr(1,_loc18_.length - 1):_loc18_;
                  _loc19_ = _loc18_.length > 1?_loc18_.substr(1,_loc18_.length - 1):null;
                  _loc18_ = _loc18_.charAt(0);
                  switch(_loc18_)
                  {
                     case "b":
                        break;
                     case "B":
                        break;
                     case "e":
                        _loc22_ = parseInt(_loc19_);
                        if(_loc20_)
                        {
                           _loc21_ = !_loc12_ || _loc12_.indexOf(_loc22_) == -1;
                        }
                        else
                        {
                           _loc21_ = !_loc13_ || _loc13_.indexOf(_loc22_) == -1;
                        }
                        break;
                     case "E":
                        _loc22_ = parseInt(_loc19_);
                        if(_loc20_)
                        {
                           _loc21_ = _loc12_ && _loc12_.indexOf(_loc22_) != -1;
                        }
                        else
                        {
                           _loc21_ = _loc13_ && _loc13_.indexOf(_loc22_) != -1;
                        }
                        break;
                     case "f":
                        _loc21_ = !_loc11_ || _loc11_.creatureGenericId != parseInt(_loc19_);
                        break;
                     case "F":
                        _loc21_ = _loc11_ && _loc11_.creatureGenericId == parseInt(_loc19_);
                        break;
                     case "z":
                        break;
                     case "Z":
                        break;
                     case "K":
                        break;
                     case "o":
                        break;
                     case "O":
                        _loc21_ = param5 != 0 && param2 == param5;
                        break;
                     case "p":
                        break;
                     case "P":
                        break;
                     case "T":
                        break;
                     case "W":
                        break;
                     case "U":
                        break;
                     case "v":
                        _loc21_ = _loc10_.stats.lifePoints / _loc10_.stats.maxLifePoints * 100 > parseInt(_loc19_);
                        break;
                     case "V":
                        _loc21_ = _loc10_.stats.lifePoints / _loc10_.stats.maxLifePoints * 100 <= parseInt(_loc19_);
                        break;
                  }
                  _loc25_ = _loc20_?"*" + _loc18_:_loc18_;
                  _loc27_ = _loc23_[_loc25_];
                  if(!_loc28_ || _loc25_ == _loc28_)
                  {
                     _loc29_++;
                  }
                  else
                  {
                     _loc29_ = 0;
                  }
                  _loc28_ = _loc25_;
                  if(_loc21_ && _loc27_ && _loc26_.indexOf(_loc25_) == -1)
                  {
                     _loc26_.push(_loc25_);
                  }
                  if(!_loc21_)
                  {
                     if(!_loc27_)
                     {
                        return false;
                     }
                     if(_loc26_.indexOf(_loc25_) != -1)
                     {
                        _loc21_ = true;
                     }
                     else if(_loc23_[_loc25_] == _loc29_)
                     {
                        return false;
                     }
                  }
               }
            }
         }
         return _loc21_;
      }
      
      public static function verifySpellEffectZone(param1:int, param2:EffectInstance, param3:int, param4:int) : Boolean
      {
         var _loc6_:* = false;
         var _loc5_:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!_loc5_)
         {
            return false;
         }
         var _loc7_:GameFightFighterInformations = _loc5_.getEntityInfos(param1) as GameFightFighterInformations;
         var _loc8_:IZone = SpellZoneManager.getInstance().getZone(param2.zoneShape,uint(param2.zoneSize),uint(param2.zoneMinSize),false,uint(param2.zoneStopAtTarget));
         _loc8_.direction = MapPoint(MapPoint.fromCellId(param4)).advancedOrientationTo(MapPoint.fromCellId(FightContextFrame.currentCell),false);
         var _loc9_:Vector.<uint> = _loc8_.getCells(param3);
         if(_loc7_.disposition.cellId != -1)
         {
            _loc6_ = _loc9_?_loc9_.indexOf(_loc7_.disposition.cellId) != -1:false;
         }
         else if(param2.targetMask.indexOf("E263") != -1 && _loc8_.radius == 63)
         {
            _loc6_ = true;
         }
         return _loc6_;
      }
      
      public static function getSpellElementDamage(param1:Object, param2:int, param3:int, param4:int, param5:int) : SpellDamage
      {
         var _loc9_:EffectDamage = null;
         var _loc10_:EffectInstance = null;
         var _loc11_:EffectInstanceDice = null;
         var _loc12_:* = 0;
         var _loc15_:* = false;
         var _loc18_:* = 0;
         var _loc6_:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!_loc6_)
         {
            return null;
         }
         var _loc7_:GameFightFighterInformations = _loc6_.getEntityInfos(param4) as GameFightFighterInformations;
         var _loc8_:SpellDamage = new SpellDamage();
         var _loc13_:int = param1.effects.length;
         var _loc14_:Boolean = !(param1 is SpellWrapper) || param1.id == 0;
         _loc12_ = 0;
         while(_loc12_ < _loc13_)
         {
            _loc10_ = param1.effects[_loc12_];
            _loc15_ = HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(_loc10_.effectId) != -1 && _loc10_.targetMask == "C" && _loc10_.triggers != "I";
            if(_loc10_.category == DAMAGE_EFFECT_CATEGORY && (_loc14_ || _loc10_.triggers == "I") && HEALING_EFFECTS_IDS.indexOf(_loc10_.effectId) == -1 && Effect.getEffectById(_loc10_.effectId).elementId == param2 && !_loc10_.targetMask || _loc14_ || _loc10_.targetMask && DamageUtil.verifySpellEffectMask(param3,param4,_loc10_,param5) && !_loc15_)
            {
               _loc9_ = new EffectDamage(_loc10_.effectId,param2,_loc10_.random);
               _loc8_.addEffectDamage(_loc9_);
               if(EROSION_DAMAGE_EFFECTS_IDS.indexOf(_loc10_.effectId) != -1)
               {
                  _loc11_ = _loc10_ as EffectInstanceDice;
                  _loc9_.minErosionPercent = _loc9_.maxErosionPercent = _loc11_.diceNum;
               }
               else if(!(_loc10_ is EffectInstanceDice))
               {
                  if(_loc10_ is EffectInstanceInteger)
                  {
                     _loc9_.minDamage = _loc9_.minDamage + (_loc10_ as EffectInstanceInteger).value;
                     _loc9_.maxDamage = _loc9_.maxDamage + (_loc10_ as EffectInstanceInteger).value;
                  }
                  else if(_loc10_ is EffectInstanceMinMax)
                  {
                     _loc9_.minDamage = _loc9_.minDamage + (_loc10_ as EffectInstanceMinMax).min;
                     _loc9_.maxDamage = _loc9_.maxDamage + (_loc10_ as EffectInstanceMinMax).max;
                  }
               }
               else
               {
                  _loc11_ = _loc10_ as EffectInstanceDice;
                  _loc9_.minDamage = _loc9_.minDamage + _loc11_.diceNum;
                  _loc9_.maxDamage = _loc9_.maxDamage + (_loc11_.diceSide == 0?_loc11_.diceNum:_loc11_.diceSide);
               }
            }
            _loc12_++;
         }
         var _loc16_:int = _loc8_.effectDamages.length;
         var _loc17_:int = param1.criticalEffect?param1.criticalEffect.length:0;
         _loc12_ = 0;
         while(_loc12_ < _loc17_)
         {
            _loc10_ = param1.criticalEffect[_loc12_];
            _loc15_ = HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(_loc10_.effectId) != -1 && _loc10_.targetMask == "C" && _loc10_.triggers != "I";
            if(_loc10_.category == DAMAGE_EFFECT_CATEGORY && (_loc14_ || _loc10_.triggers == "I") && HEALING_EFFECTS_IDS.indexOf(_loc10_.effectId) == -1 && Effect.getEffectById(_loc10_.effectId).elementId == param2 && !_loc10_.targetMask || _loc14_ || _loc10_.targetMask && DamageUtil.verifySpellEffectMask(param3,param4,_loc10_,param5) && !_loc15_)
            {
               if(_loc18_ < _loc16_)
               {
                  _loc9_ = _loc8_.effectDamages[_loc18_];
               }
               else
               {
                  _loc9_ = new EffectDamage(_loc10_.effectId,param2,_loc10_.random);
                  _loc8_.addEffectDamage(_loc9_);
               }
               if(EROSION_DAMAGE_EFFECTS_IDS.indexOf(_loc10_.effectId) != -1)
               {
                  _loc11_ = _loc10_ as EffectInstanceDice;
                  _loc9_.minCriticalErosionPercent = _loc9_.maxCriticalErosionPercent = _loc11_.diceNum;
               }
               else if(!(_loc10_ is EffectInstanceDice))
               {
                  if(_loc10_ is EffectInstanceInteger)
                  {
                     _loc9_.minCriticalDamage = _loc9_.minCriticalDamage + (_loc10_ as EffectInstanceInteger).value;
                     _loc9_.maxCriticalDamage = _loc9_.maxCriticalDamage + (_loc10_ as EffectInstanceInteger).value;
                  }
                  else if(_loc10_ is EffectInstanceMinMax)
                  {
                     _loc9_.minCriticalDamage = _loc9_.minCriticalDamage + (_loc10_ as EffectInstanceMinMax).min;
                     _loc9_.maxCriticalDamage = _loc9_.maxCriticalDamage + (_loc10_ as EffectInstanceMinMax).max;
                  }
               }
               else
               {
                  _loc11_ = _loc10_ as EffectInstanceDice;
                  _loc9_.minCriticalDamage = _loc9_.minCriticalDamage + _loc11_.diceNum;
                  _loc9_.maxCriticalDamage = _loc9_.maxCriticalDamage + (_loc11_.diceSide == 0?_loc11_.diceNum:_loc11_.diceSide);
               }
               _loc8_.hasCriticalDamage = _loc9_.hasCritical = true;
               _loc18_++;
            }
            _loc12_++;
         }
         return _loc8_;
      }
      
      public static function applySpellModificationsOnEffect(param1:EffectDamage, param2:SpellWrapper) : void
      {
         if(!param2)
         {
            return;
         }
         var _loc3_:CharacterSpellModification = CurrentPlayedFighterManager.getInstance().getSpellModifications(param2.id,CharacterSpellModificationTypeEnum.BASE_DAMAGE);
         if(_loc3_)
         {
            param1.minDamage = param1.minDamage + (param1.minDamage > 0?_loc3_.value.contextModif:0);
            param1.maxDamage = param1.maxDamage + (param1.maxDamage > 0?_loc3_.value.contextModif:0);
            if(param1.hasCritical)
            {
               param1.minCriticalDamage = param1.minCriticalDamage + (param1.minCriticalDamage > 0?_loc3_.value.contextModif:0);
               param1.maxCriticalDamage = param1.maxCriticalDamage + (param1.maxCriticalDamage > 0?_loc3_.value.contextModif:0);
            }
         }
      }
      
      public static function getReflectDamageValue(param1:int) : int
      {
         var _loc2_:* = 0;
         var _loc5_:Monster = null;
         var _loc6_:MonsterGrade = null;
         var _loc3_:FightContextFrame = Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame;
         if(!_loc3_)
         {
            return 0;
         }
         var _loc4_:GameFightMonsterInformations = _loc3_.entitiesFrame.getEntityInfos(param1) as GameFightMonsterInformations;
         if(_loc4_)
         {
            _loc5_ = Monster.getMonsterById(_loc4_.creatureGenericId);
            for each(_loc6_ in _loc5_.grades)
            {
               if(_loc6_.grade == _loc4_.creatureGrade)
               {
                  _loc2_ = _loc6_.damageReflect;
                  break;
               }
            }
         }
         return _loc2_;
      }
      
      public static function getSpellDamage(param1:SpellDamageInfo, param2:Boolean = true, param3:Boolean = true, param4:* = true) : SpellDamage
      {
         var efficiencyMultiplier:Number = NaN;
         var splashEffectDamages:Vector.<EffectDamage> = null;
         var splashEffectDmg:EffectDamage = null;
         var hasHealingSplash:Boolean = false;
         var spellShape:uint = 0;
         var spellShapeSize:Object = null;
         var spellShapeMinSize:Object = null;
         var spellShapeEfficiencyPercent:Object = null;
         var spellShapeMaxEfficiency:Object = null;
         var shapeSize:int = 0;
         var finalNeutralDmg:EffectDamage = null;
         var finalEarthDmg:EffectDamage = null;
         var finalWaterDmg:EffectDamage = null;
         var finalAirDmg:EffectDamage = null;
         var finalFireDmg:EffectDamage = null;
         var erosion:EffectDamage = null;
         var targetHpBasedBuffDamages:Vector.<SpellDamage> = null;
         var dmgMultiplier:Number = NaN;
         var splashDmg:SplashDamage = null;
         var splashCasterCell:uint = 0;
         var effi:EffectInstance = null;
         var pushDamages:EffectDamage = null;
         var pushedEntity:PushedEntity = null;
         var pushIndex:uint = 0;
         var hasPushedDamage:Boolean = false;
         var pushDmg:int = 0;
         var criticalPushDmg:int = 0;
         var buff:BasicBuff = null;
         var buffDamage:EffectDamage = null;
         var buffEffectDamage:EffectDamage = null;
         var buffSpellDamage:SpellDamage = null;
         var effid:EffectInstanceDice = null;
         var buffEffectMinDamage:int = 0;
         var buffEffectMaxDamage:int = 0;
         var buffEffectDispelled:Boolean = false;
         var buffDamageMultiplier:Number = NaN;
         var isTargetHpBasedDamage:Boolean = false;
         var buffSpellEffectDmg:EffectDamage = null;
         var ed:EffectDamage = null;
         var reflectDmg:ReflectDamage = null;
         var reflectDmgEffect:EffectDamage = null;
         var tmpEffect:EffectDamage = null;
         var sourceDmgWithoutPercentResists:SpellDamage = null;
         var finalElementDmgWithoutPercentResists:EffectDamage = null;
         var currentTargetId:int = 0;
         var minimizeEffects:Boolean = false;
         var maximizeEffects:Boolean = false;
         var reflectSpellDmg:SpellDamage = null;
         var finalBuffDmg:EffectDamage = null;
         var currentTargetLifePoints:int = 0;
         var targetHpBasedBuffDamage:SpellDamage = null;
         var finalTargetHpBasedBuffDmg:EffectDamage = null;
         var minShieldDiff:int = 0;
         var maxShieldDiff:int = 0;
         var minCriticalShieldDiff:int = 0;
         var maxCriticalShieldDiff:int = 0;
         var pSpellDamageInfo:SpellDamageInfo = param1;
         var pWithTargetBuffs:Boolean = param2;
         var pWithTargetResists:Boolean = param3;
         var pWithTargetPercentResists:* = param4;
         var finalDamage:SpellDamage = new SpellDamage();
         if(pSpellDamageInfo.sharedDamage)
         {
            pSpellDamageInfo.sharedDamage.invulnerableState = pSpellDamageInfo.targetIsInvulnerable;
            pSpellDamageInfo.sharedDamage.hasCriticalDamage = pSpellDamageInfo.spellHasCriticalDamage;
            return pSpellDamageInfo.sharedDamage;
         }
         var currentCasterLifePoints:int = ((Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame).getEntityInfos(pSpellDamageInfo.casterId) as GameFightFighterInformations).stats.lifePoints;
         if(pSpellDamageInfo.splashDamages)
         {
            splashEffectDamages = new Vector.<EffectDamage>(0);
            for each(splashDmg in pSpellDamageInfo.splashDamages)
            {
               if(splashDmg.targets.indexOf(pSpellDamageInfo.targetId) != -1)
               {
                  splashCasterCell = EntitiesManager.getInstance().getEntity(splashDmg.casterId).position.cellId;
                  efficiencyMultiplier = getShapeEfficiency(splashDmg.spellShape,splashCasterCell,pSpellDamageInfo.targetCell,splashDmg.spellShapeSize != null?int(splashDmg.spellShapeSize):EFFECTSHAPE_DEFAULT_AREA_SIZE,splashDmg.spellShapeMinSize != null?int(splashDmg.spellShapeMinSize):EFFECTSHAPE_DEFAULT_MIN_AREA_SIZE,splashDmg.spellShapeEfficiencyPercent != null?int(splashDmg.spellShapeEfficiencyPercent):EFFECTSHAPE_DEFAULT_EFFICIENCY,splashDmg.spellShapeMaxEfficiency != null?int(splashDmg.spellShapeMaxEfficiency):EFFECTSHAPE_DEFAULT_MAX_EFFICIENCY_APPLY);
                  splashEffectDmg = computeDamage(splashDmg.damage,pSpellDamageInfo,efficiencyMultiplier,true,!splashDmg.hasCritical);
                  if(splashEffectDmg.effectId == SPLASH_HEAL_EFFECT_ID)
                  {
                     splashEffectDmg.convertDamageToHeal();
                     if(splashEffectDmg.hasCritical)
                     {
                        pSpellDamageInfo.spellHasCriticalHeal = true;
                     }
                     hasHealingSplash = true;
                  }
                  splashEffectDamages.push(splashEffectDmg);
                  finalDamage.addEffectDamage(splashEffectDmg);
                  if(pSpellDamageInfo.targetId == pSpellDamageInfo.casterId)
                  {
                     if(pSpellDamageInfo.casterLifePointsAfterNormalMinDamage == 0)
                     {
                        pSpellDamageInfo.casterLifePointsAfterNormalMinDamage = currentCasterLifePoints - splashEffectDmg.minDamage;
                     }
                     else
                     {
                        pSpellDamageInfo.casterLifePointsAfterNormalMinDamage = pSpellDamageInfo.casterLifePointsAfterNormalMinDamage - splashEffectDmg.minDamage;
                     }
                     if(pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage == 0)
                     {
                        pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage = currentCasterLifePoints - splashEffectDmg.maxDamage;
                     }
                     else
                     {
                        pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage = pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage - splashEffectDmg.maxDamage;
                     }
                     if(pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage == 0)
                     {
                        pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage = currentCasterLifePoints - splashEffectDmg.minCriticalDamage;
                     }
                     else
                     {
                        pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage = pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage - splashEffectDmg.minCriticalDamage;
                     }
                     if(pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage == 0)
                     {
                        pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage = currentCasterLifePoints - splashEffectDmg.maxCriticalDamage;
                     }
                     else
                     {
                        pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage = pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage - splashEffectDmg.maxCriticalDamage;
                     }
                  }
               }
            }
         }
         if(pSpellDamageInfo.isWeapon)
         {
            spellShapeEfficiencyPercent = pSpellDamageInfo.weaponShapeEfficiencyPercent;
         }
         else
         {
            for each(effi in pSpellDamageInfo.spellEffects)
            {
               if((effi.category == DamageUtil.DAMAGE_EFFECT_CATEGORY || DamageUtil.HEALING_EFFECTS_IDS.indexOf(effi.effectId) != -1) && DamageUtil.verifySpellEffectMask(pSpellDamageInfo.casterId,pSpellDamageInfo.targetId,effi,pSpellDamageInfo.spellCenterCell))
               {
                  if(effi.rawZone)
                  {
                     spellShape = effi.rawZone.charCodeAt(0);
                     spellShapeSize = effi.zoneSize;
                     spellShapeMinSize = effi.zoneMinSize;
                     spellShapeEfficiencyPercent = effi.zoneEfficiencyPercent;
                     spellShapeMaxEfficiency = effi.zoneMaxEfficiency;
                     break;
                  }
               }
            }
         }
         shapeSize = spellShapeSize != null?int(spellShapeSize):EFFECTSHAPE_DEFAULT_AREA_SIZE;
         var shapeMinSize:int = spellShapeMinSize != null?int(spellShapeMinSize):EFFECTSHAPE_DEFAULT_MIN_AREA_SIZE;
         var shapeEfficiencyPercent:int = spellShapeEfficiencyPercent != null?int(spellShapeEfficiencyPercent):EFFECTSHAPE_DEFAULT_EFFICIENCY;
         var shapeMaxEfficiency:int = spellShapeMaxEfficiency != null?int(spellShapeMaxEfficiency):EFFECTSHAPE_DEFAULT_MAX_EFFICIENCY_APPLY;
         if(shapeEfficiencyPercent == 0 || shapeMaxEfficiency == 0)
         {
            efficiencyMultiplier = DAMAGE_NOT_BOOSTED;
         }
         else
         {
            efficiencyMultiplier = getShapeEfficiency(spellShape,pSpellDamageInfo.spellCenterCell,pSpellDamageInfo.targetCell,shapeSize,shapeMinSize,shapeEfficiencyPercent,shapeMaxEfficiency);
         }
         efficiencyMultiplier = efficiencyMultiplier * pSpellDamageInfo.portalsSpellEfficiencyBonus;
         finalDamage.efficiencyMultiplier = efficiencyMultiplier;
         finalNeutralDmg = computeDamage(pSpellDamageInfo.neutralDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         finalEarthDmg = computeDamage(pSpellDamageInfo.earthDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         finalWaterDmg = computeDamage(pSpellDamageInfo.waterDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         finalAirDmg = computeDamage(pSpellDamageInfo.airDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         finalFireDmg = computeDamage(pSpellDamageInfo.fireDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
         var finalFixedDmg:EffectDamage = computeDamage(pSpellDamageInfo.fixedDamage,pSpellDamageInfo,1,true,true,true);
         pSpellDamageInfo.casterLifePointsAfterNormalMinDamage = 0;
         pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage = 0;
         pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage = 0;
         pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage = 0;
         var totalMinErosionDamage:int = finalNeutralDmg.minErosionDamage + finalEarthDmg.minErosionDamage + finalWaterDmg.minErosionDamage + finalAirDmg.minErosionDamage + finalFireDmg.minErosionDamage;
         var totalMaxErosionDamage:int = finalNeutralDmg.maxErosionDamage + finalEarthDmg.maxErosionDamage + finalWaterDmg.maxErosionDamage + finalAirDmg.maxErosionDamage + finalFireDmg.maxErosionDamage;
         var totalMinCriticaErosionDamage:int = finalNeutralDmg.minCriticalErosionDamage + finalEarthDmg.minCriticalErosionDamage + finalWaterDmg.minCriticalErosionDamage + finalAirDmg.minCriticalErosionDamage + finalFireDmg.minCriticalErosionDamage;
         var totalMaxCriticaErosionlDamage:int = finalNeutralDmg.maxCriticalErosionDamage + finalEarthDmg.maxCriticalErosionDamage + finalWaterDmg.maxCriticalErosionDamage + finalAirDmg.maxCriticalErosionDamage + finalFireDmg.maxCriticalErosionDamage;
         var casterIntelligence:int = pSpellDamageInfo.casterIntelligence <= 0?1:pSpellDamageInfo.casterIntelligence;
         var totalMinLifePointsAdded:int = Math.floor(pSpellDamageInfo.healDamage.minLifePointsAdded * (100 + casterIntelligence) / 100) + (pSpellDamageInfo.healDamage.minLifePointsAdded > 0?pSpellDamageInfo.casterHealBonus:0);
         var totalMaxLifePointsAdded:int = Math.floor(pSpellDamageInfo.healDamage.maxLifePointsAdded * (100 + casterIntelligence) / 100) + (pSpellDamageInfo.healDamage.maxLifePointsAdded > 0?pSpellDamageInfo.casterHealBonus:0);
         var totalMinCriticalLifePointsAdded:int = Math.floor(pSpellDamageInfo.healDamage.minCriticalLifePointsAdded * (100 + casterIntelligence) / 100) + (pSpellDamageInfo.healDamage.minCriticalLifePointsAdded > 0?pSpellDamageInfo.casterHealBonus:0);
         var totalMaxCriticalLifePointsAdded:int = Math.floor(pSpellDamageInfo.healDamage.maxCriticalLifePointsAdded * (100 + casterIntelligence) / 100) + (pSpellDamageInfo.healDamage.maxCriticalLifePointsAdded > 0?pSpellDamageInfo.casterHealBonus:0);
         totalMinLifePointsAdded = totalMinLifePointsAdded + pSpellDamageInfo.healDamage.lifePointsAddedBasedOnLifePercent;
         totalMaxLifePointsAdded = totalMaxLifePointsAdded + pSpellDamageInfo.healDamage.lifePointsAddedBasedOnLifePercent;
         totalMinCriticalLifePointsAdded = totalMinCriticalLifePointsAdded + pSpellDamageInfo.healDamage.criticalLifePointsAddedBasedOnLifePercent;
         totalMaxCriticalLifePointsAdded = totalMaxCriticalLifePointsAdded + pSpellDamageInfo.healDamage.criticalLifePointsAddedBasedOnLifePercent;
         finalDamage.hasHeal = totalMinLifePointsAdded > 0 || totalMaxLifePointsAdded > 0 || totalMinCriticalLifePointsAdded > 0 || totalMaxCriticalLifePointsAdded > 0 || hasHealingSplash;
         var targetLostLifePoints:int = pSpellDamageInfo.targetInfos.stats.maxLifePoints - pSpellDamageInfo.targetInfos.stats.lifePoints;
         if(targetLostLifePoints > 0 || pSpellDamageInfo.isHealingSpell)
         {
            totalMinLifePointsAdded = totalMinLifePointsAdded > targetLostLifePoints?targetLostLifePoints:totalMinLifePointsAdded;
            totalMaxLifePointsAdded = totalMaxLifePointsAdded > targetLostLifePoints?targetLostLifePoints:totalMaxLifePointsAdded;
            totalMinCriticalLifePointsAdded = totalMinCriticalLifePointsAdded > targetLostLifePoints?targetLostLifePoints:totalMinCriticalLifePointsAdded;
            totalMaxCriticalLifePointsAdded = totalMaxCriticalLifePointsAdded > targetLostLifePoints?targetLostLifePoints:totalMaxCriticalLifePointsAdded;
         }
         var heal:EffectDamage = new EffectDamage(-1,-1,-1);
         heal.minLifePointsAdded = totalMinLifePointsAdded * efficiencyMultiplier;
         heal.maxLifePointsAdded = totalMaxLifePointsAdded * efficiencyMultiplier;
         heal.minCriticalLifePointsAdded = totalMinCriticalLifePointsAdded * efficiencyMultiplier;
         heal.maxCriticalLifePointsAdded = totalMaxCriticalLifePointsAdded * efficiencyMultiplier;
         erosion = new EffectDamage(-1,-1,-1);
         erosion.minDamage = totalMinErosionDamage;
         erosion.maxDamage = totalMaxErosionDamage;
         erosion.minCriticalDamage = totalMinCriticaErosionDamage;
         erosion.maxCriticalDamage = totalMaxCriticaErosionlDamage;
         if(pSpellDamageInfo.pushedEntities && pSpellDamageInfo.pushedEntities.length > 0)
         {
            pushDamages = new EffectDamage(5,-1,-1);
            for each(pushedEntity in pSpellDamageInfo.pushedEntities)
            {
               if(pushedEntity.id == pSpellDamageInfo.targetId)
               {
                  pushedEntity.damage = 0;
                  for each(pushIndex in pushedEntity.pushedIndexes)
                  {
                     pushDmg = (pSpellDamageInfo.casterLevel / 2 + (pSpellDamageInfo.casterPushDamageBonus - pSpellDamageInfo.targetPushDamageFixedResist) + 32) * pushedEntity.force / (4 * Math.pow(2,pushIndex));
                     pushedEntity.damage = pushedEntity.damage + (pushDmg > 0?pushDmg:0);
                     criticalPushDmg = (pSpellDamageInfo.casterLevel / 2 + (pSpellDamageInfo.casterCriticalPushDamageBonus - pSpellDamageInfo.targetPushDamageFixedResist) + 32) * pushedEntity.force / (4 * Math.pow(2,pushIndex));
                     pushedEntity.criticalDamage = pushedEntity.criticalDamage + (criticalPushDmg > 0?criticalPushDmg:0);
                  }
                  hasPushedDamage = true;
                  break;
               }
            }
            if(hasPushedDamage)
            {
               pushDamages.minDamage = pushDamages.maxDamage = pushedEntity.damage;
               if(pSpellDamageInfo.spellHasCriticalDamage)
               {
                  pushDamages.minCriticalDamage = pushDamages.maxCriticalDamage = pushedEntity.criticalDamage;
               }
            }
            finalDamage.addEffectDamage(pushDamages);
         }
         var applyDamageMultiplier:Function = function(param1:Number, param2:Boolean = false):void
         {
            var _loc3_:EffectDamage = null;
            erosion.applyDamageMultiplier(param1);
            if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalNeutralDmg.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalNeutralDmg.effectId) == -1)
            {
               finalNeutralDmg.applyDamageMultiplier(param1);
            }
            if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalEarthDmg.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalEarthDmg.effectId) == -1)
            {
               finalEarthDmg.applyDamageMultiplier(param1);
            }
            if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalWaterDmg.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalWaterDmg.effectId) == -1)
            {
               finalWaterDmg.applyDamageMultiplier(param1);
            }
            if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalAirDmg.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalAirDmg.effectId) == -1)
            {
               finalAirDmg.applyDamageMultiplier(param1);
            }
            if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalFireDmg.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(finalFireDmg.effectId) == -1)
            {
               finalFireDmg.applyDamageMultiplier(param1);
            }
            if(!param2 && splashEffectDamages)
            {
               for each(_loc3_ in splashEffectDamages)
               {
                  _loc3_.applyDamageMultiplier(param1);
               }
            }
         };
         if(pWithTargetBuffs)
         {
            buffDamageMultiplier = 1;
            for each(buff in pSpellDamageInfo.targetBuffs)
            {
               buffEffectDispelled = buff.canBeDispell() && buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationReduction <= 0;
               if((!buff.hasOwnProperty("delay") || buff["delay"] == 0) && (!(buff is StatBuff) || !(buff as StatBuff).statName) && verifyBuffTriggers(pSpellDamageInfo,buff) && !buffEffectDispelled)
               {
                  switch(buff.actionId)
                  {
                     case 1163:
                        buffDamageMultiplier = buffDamageMultiplier * buff.param1 / 100;
                        break;
                     case 1164:
                        erosion.convertDamageToHeal();
                        finalNeutralDmg.convertDamageToHeal();
                        finalEarthDmg.convertDamageToHeal();
                        finalWaterDmg.convertDamageToHeal();
                        finalAirDmg.convertDamageToHeal();
                        finalFireDmg.convertDamageToHeal();
                        if(splashEffectDamages)
                        {
                           for each(splashEffectDmg in splashEffectDamages)
                           {
                              splashEffectDmg.convertDamageToHeal();
                           }
                        }
                        pSpellDamageInfo.spellHasCriticalHeal = pSpellDamageInfo.spellHasCriticalDamage;
                        break;
                  }
                  if(buff.targetId != pSpellDamageInfo.casterId && buff.effect.category == DAMAGE_EFFECT_CATEGORY && HEALING_EFFECTS_IDS.indexOf(buff.effect.effectId) == -1)
                  {
                     buffSpellDamage = new SpellDamage();
                     buffEffectDamage = new EffectDamage(buff.effect.effectId,Effect.getEffectById(buff.effect.effectId).elementId,-1);
                     if(buff.effect is EffectInstanceDice)
                     {
                        effid = buff.effect as EffectInstanceDice;
                        buffEffectMinDamage = effid.value + effid.diceNum;
                        buffEffectMaxDamage = effid.value + effid.diceSide;
                     }
                     else if(buff.effect is EffectInstanceMinMax)
                     {
                        buffEffectMinDamage = (buff.effect as EffectInstanceMinMax).min;
                        buffEffectMaxDamage = (buff.effect as EffectInstanceMinMax).max;
                     }
                     else if(buff.effect is EffectInstanceInteger)
                     {
                        buffEffectMinDamage = buffEffectMaxDamage = (buff.effect as EffectInstanceInteger).value;
                     }
                     buffEffectDamage.minDamage = buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationReduction > 0?buffEffectMinDamage:0;
                     buffEffectDamage.maxDamage = buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationReduction > 0?buffEffectMaxDamage:0;
                     buffEffectDamage.minCriticalDamage = buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationCriticalReduction > 0?buffEffectMinDamage:0;
                     buffEffectDamage.maxCriticalDamage = buff.effect.duration - pSpellDamageInfo.spellTargetEffectsDurationCriticalReduction > 0?buffEffectMaxDamage:0;
                     buffSpellDamage.addEffectDamage(buffEffectDamage);
                     isTargetHpBasedDamage = TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(buff.actionId) != -1;
                     if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(buff.actionId) != -1)
                     {
                        for each(buffSpellEffectDmg in buffSpellDamage.effectDamages)
                        {
                           switch(buffSpellEffectDmg.effectId)
                           {
                              case 85:
                                 buffSpellEffectDmg.effectId = 1068;
                                 continue;
                              case 86:
                                 buffSpellEffectDmg.effectId = 1070;
                                 continue;
                              case 87:
                                 buffSpellEffectDmg.effectId = 1067;
                                 continue;
                              case 88:
                                 buffSpellEffectDmg.effectId = 1069;
                                 continue;
                              case 89:
                                 buffSpellEffectDmg.effectId = 1071;
                                 continue;
                              default:
                                 continue;
                           }
                        }
                        isTargetHpBasedDamage = true;
                     }
                     if(!isTargetHpBasedDamage)
                     {
                        buffDamage = computeDamage(buffSpellDamage,pSpellDamageInfo,1);
                        finalDamage.addEffectDamage(buffDamage);
                     }
                     else
                     {
                        if(!targetHpBasedBuffDamages)
                        {
                           targetHpBasedBuffDamages = new Vector.<SpellDamage>(0);
                        }
                        targetHpBasedBuffDamages.push(buffSpellDamage);
                     }
                  }
               }
            }
            if(buffDamageMultiplier != 1)
            {
               applyDamageMultiplier(buffDamageMultiplier.toFixed(2));
            }
         }
         var damageBoostPercentTotal:int = pSpellDamageInfo.casterDamageBoostPercent - pSpellDamageInfo.casterDamageDeboostPercent;
         if(damageBoostPercentTotal != 0)
         {
            dmgMultiplier = 100 + damageBoostPercentTotal;
            applyDamageMultiplier(dmgMultiplier < 0?0:dmgMultiplier / 100,true);
         }
         var finalReflectDmg:Vector.<EffectDamage> = new Vector.<EffectDamage>(0);
         if(pSpellDamageInfo.reflectDamages)
         {
            currentTargetId = pSpellDamageInfo.targetId;
            minimizeEffects = true;
            maximizeEffects = true;
            for each(reflectDmg in pSpellDamageInfo.reflectDamages)
            {
               sourceDmgWithoutPercentResists = DamageUtil.getSpellDamage(SpellDamageInfo.fromCurrentPlayer(pSpellDamageInfo.spell,reflectDmg.sourceId,pSpellDamageInfo.spellCenterCell),true,true,false);
               if(!sourceDmgWithoutPercentResists.minimizedEffects)
               {
                  minimizeEffects = false;
               }
               if(!sourceDmgWithoutPercentResists.maximizedEffects)
               {
                  maximizeEffects = false;
               }
               for each(reflectDmgEffect in reflectDmg.effects)
               {
                  finalElementDmgWithoutPercentResists = null;
                  for each(ed in sourceDmgWithoutPercentResists.effectDamages)
                  {
                     if(ed.element == reflectDmgEffect.element)
                     {
                        finalElementDmgWithoutPercentResists = ed;
                        break;
                     }
                  }
                  if(finalElementDmgWithoutPercentResists)
                  {
                     tmpEffect = new EffectDamage(-1,finalElementDmgWithoutPercentResists.element,finalElementDmgWithoutPercentResists.random);
                     tmpEffect.minDamage = reflectDmgEffect.minDamage > 0?Math.min(finalElementDmgWithoutPercentResists.minDamage,reflectDmg.reflectValue):0;
                     tmpEffect.maxDamage = reflectDmgEffect.maxDamage > 0?Math.min(finalElementDmgWithoutPercentResists.maxDamage,reflectDmg.reflectValue):0;
                     tmpEffect.minCriticalDamage = reflectDmgEffect.minCriticalDamage > 0 || pSpellDamageInfo.isWeapon?Math.min(finalElementDmgWithoutPercentResists.minCriticalDamage,reflectDmg.reflectValue):0;
                     tmpEffect.maxCriticalDamage = reflectDmgEffect.maxCriticalDamage > 0 || pSpellDamageInfo.isWeapon?Math.min(finalElementDmgWithoutPercentResists.maxCriticalDamage,reflectDmg.reflectValue):0;
                     tmpEffect.hasCritical = finalElementDmgWithoutPercentResists.hasCritical;
                     reflectDmgEffect = computeDamageWithoutResistsBoosts(reflectDmg.sourceId,tmpEffect,pSpellDamageInfo,1,true,true);
                     reflectSpellDmg = new SpellDamage();
                     reflectSpellDmg.addEffectDamage(reflectDmgEffect);
                     reflectSpellDmg.hasCriticalDamage = reflectDmgEffect.hasCritical;
                     pSpellDamageInfo.targetId = currentTargetId;
                     ed = computeDamage(reflectSpellDmg,pSpellDamageInfo,1,true);
                     finalReflectDmg.push(ed);
                  }
               }
            }
            pSpellDamageInfo.minimizedEffects = minimizeEffects;
            pSpellDamageInfo.maximizedEffects = maximizeEffects;
            pSpellDamageInfo.targetId = currentTargetId;
         }
         if(pSpellDamageInfo.targetId == pSpellDamageInfo.casterId)
         {
            for each(ed in finalReflectDmg)
            {
               finalDamage.addEffectDamage(ed);
               if(ed.hasCritical)
               {
                  pSpellDamageInfo.spellHasCriticalDamage = true;
               }
            }
         }
         if(pSpellDamageInfo.originalTargetsIds.indexOf(pSpellDamageInfo.targetId) != -1 && (!pSpellDamageInfo.isWeapon || pSpellDamageInfo.casterId != pSpellDamageInfo.targetId))
         {
            finalDamage.addEffectDamage(heal);
            finalDamage.addEffectDamage(erosion);
            finalDamage.addEffectDamage(finalNeutralDmg);
            finalDamage.addEffectDamage(finalEarthDmg);
            finalDamage.addEffectDamage(finalWaterDmg);
            finalDamage.addEffectDamage(finalAirDmg);
            finalDamage.addEffectDamage(finalFireDmg);
            finalDamage.addEffectDamage(finalFixedDmg);
            if(pSpellDamageInfo.buffDamage)
            {
               finalDamage.updateDamage();
               pSpellDamageInfo.casterLifePointsAfterNormalMinDamage = currentCasterLifePoints - finalDamage.minDamage;
               pSpellDamageInfo.casterLifePointsAfterNormalMaxDamage = currentCasterLifePoints - finalDamage.maxDamage;
               pSpellDamageInfo.casterLifePointsAfterCriticalMinDamage = currentCasterLifePoints - finalDamage.minCriticalDamage;
               pSpellDamageInfo.casterLifePointsAfterCriticalMaxDamage = currentCasterLifePoints - finalDamage.maxCriticalDamage;
               finalBuffDmg = computeDamage(pSpellDamageInfo.buffDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
            }
            if(finalBuffDmg)
            {
               finalDamage.addEffectDamage(finalBuffDmg);
            }
            if(targetHpBasedBuffDamages)
            {
               finalDamage.updateDamage();
               currentTargetLifePoints = ((Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame).getEntityInfos(pSpellDamageInfo.targetId) as GameFightFighterInformations).stats.lifePoints;
               pSpellDamageInfo.targetLifePointsAfterNormalMinDamage = currentTargetLifePoints - finalDamage.minDamage < 0?0:currentTargetLifePoints - finalDamage.minDamage;
               pSpellDamageInfo.targetLifePointsAfterNormalMaxDamage = currentTargetLifePoints - finalDamage.maxDamage < 0?0:currentTargetLifePoints - finalDamage.maxDamage;
               pSpellDamageInfo.targetLifePointsAfterCriticalMinDamage = currentTargetLifePoints - finalDamage.minCriticalDamage < 0?0:currentTargetLifePoints - finalDamage.minCriticalDamage;
               pSpellDamageInfo.targetLifePointsAfterCriticalMaxDamage = currentTargetLifePoints - finalDamage.maxCriticalDamage < 0?0:currentTargetLifePoints - finalDamage.maxCriticalDamage;
               for each(targetHpBasedBuffDamage in targetHpBasedBuffDamages)
               {
                  finalTargetHpBasedBuffDmg = computeDamage(targetHpBasedBuffDamage,pSpellDamageInfo,efficiencyMultiplier,false,!pWithTargetResists,!pWithTargetResists,!pWithTargetPercentResists);
                  finalDamage.addEffectDamage(finalTargetHpBasedBuffDmg);
               }
            }
         }
         finalDamage.hasCriticalDamage = pSpellDamageInfo.spellHasCriticalDamage;
         finalDamage.isCriticalHit = pSpellDamageInfo.criticalHitRate == 100;
         finalDamage.minimizedEffects = pSpellDamageInfo.minimizedEffects;
         finalDamage.maximizedEffects = pSpellDamageInfo.maximizedEffects;
         finalDamage.updateDamage();
         pSpellDamageInfo.targetShieldPoints = pSpellDamageInfo.targetShieldPoints + pSpellDamageInfo.targetTriggeredShieldPoints;
         if(pSpellDamageInfo.targetShieldPoints > 0)
         {
            minShieldDiff = finalDamage.minDamage - pSpellDamageInfo.targetShieldPoints;
            if(minShieldDiff < 0)
            {
               finalDamage.minShieldPointsRemoved = finalDamage.minDamage;
               finalDamage.minDamage = 0;
            }
            else
            {
               finalDamage.minDamage = finalDamage.minDamage - pSpellDamageInfo.targetShieldPoints;
               finalDamage.minShieldPointsRemoved = pSpellDamageInfo.targetShieldPoints;
            }
            maxShieldDiff = finalDamage.maxDamage - pSpellDamageInfo.targetShieldPoints;
            if(maxShieldDiff < 0)
            {
               finalDamage.maxShieldPointsRemoved = finalDamage.maxDamage;
               finalDamage.maxDamage = 0;
            }
            else
            {
               finalDamage.maxDamage = finalDamage.maxDamage - pSpellDamageInfo.targetShieldPoints;
               finalDamage.maxShieldPointsRemoved = pSpellDamageInfo.targetShieldPoints;
            }
            minCriticalShieldDiff = finalDamage.minCriticalDamage - pSpellDamageInfo.targetShieldPoints;
            if(minCriticalShieldDiff < 0)
            {
               finalDamage.minCriticalShieldPointsRemoved = finalDamage.minCriticalDamage;
               finalDamage.minCriticalDamage = 0;
            }
            else
            {
               finalDamage.minCriticalDamage = finalDamage.minCriticalDamage - pSpellDamageInfo.targetShieldPoints;
               finalDamage.minCriticalShieldPointsRemoved = pSpellDamageInfo.targetShieldPoints;
            }
            maxCriticalShieldDiff = finalDamage.maxCriticalDamage - pSpellDamageInfo.targetShieldPoints;
            if(maxCriticalShieldDiff < 0)
            {
               finalDamage.maxCriticalShieldPointsRemoved = finalDamage.maxCriticalDamage;
               finalDamage.maxCriticalDamage = 0;
            }
            else
            {
               finalDamage.maxCriticalDamage = finalDamage.maxCriticalDamage - pSpellDamageInfo.targetShieldPoints;
               finalDamage.maxCriticalShieldPointsRemoved = pSpellDamageInfo.targetShieldPoints;
            }
            if(pSpellDamageInfo.spellHasCriticalDamage)
            {
               finalDamage.hasCriticalShieldPointsRemoved = true;
            }
         }
         if(pSpellDamageInfo.casterStatus.cantDealDamage)
         {
            finalDamage.minDamage = finalDamage.maxDamage = finalDamage.minCriticalDamage = finalDamage.maxCriticalDamage = 0;
         }
         finalDamage.hasCriticalLifePointsAdded = pSpellDamageInfo.spellHasCriticalHeal;
         finalDamage.invulnerableState = pSpellDamageInfo.targetIsInvulnerable;
         finalDamage.unhealableState = pSpellDamageInfo.targetIsUnhealable;
         finalDamage.isHealingSpell = pSpellDamageInfo.isHealingSpell;
         return finalDamage;
      }
      
      private static function computeDamageWithoutResistsBoosts(param1:int, param2:EffectDamage, param3:SpellDamageInfo, param4:Number, param5:Boolean = false, param6:Boolean = false) : EffectDamage
      {
         var _loc7_:SpellDamage = null;
         _loc7_ = new SpellDamage();
         _loc7_.addEffectDamage(param2);
         _loc7_.hasCriticalDamage = param2.hasCritical;
         param3.targetId = param1;
         return computeDamage(_loc7_,param3,param4,param5,false,false,false,true,param6);
      }
      
      private static function computeDamage(param1:SpellDamage, param2:SpellDamageInfo, param3:Number, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false, param7:Boolean = false, param8:Boolean = false, param9:Boolean = false) : EffectDamage
      {
         var _loc11_:* = 0;
         var _loc12_:* = 0;
         var _loc13_:* = 0;
         var _loc14_:* = 0;
         var _loc15_:* = 0;
         var _loc16_:* = 0;
         var _loc20_:* = 0;
         var _loc21_:EffectModification = null;
         var _loc22_:* = 0;
         var _loc23_:EffectDamage = null;
         var _loc25_:* = 0;
         var _loc26_:* = 0;
         var _loc27_:* = 0;
         var _loc28_:* = 0;
         var _loc29_:* = 0;
         var _loc30_:Vector.<int> = null;
         var _loc31_:* = 0;
         var _loc32_:Vector.<int> = null;
         var _loc33_:* = 0;
         var _loc34_:Vector.<int> = null;
         var _loc35_:* = 0;
         var _loc36_:Vector.<int> = null;
         var _loc47_:* = 0;
         var _loc48_:* = 0;
         var _loc51_:* = 0;
         var _loc52_:* = 0;
         var _loc53_:* = 0;
         var _loc10_:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!_loc10_)
         {
            return null;
         }
         var _loc17_:int = param2.casterAllDamagesBonus;
         var _loc18_:int = param2.casterCriticalDamageBonus;
         var _loc19_:int = param2.targetCriticalDamageFixedResist;
         var _loc24_:* = -1;
         var _loc37_:GameFightFighterInformations = _loc10_.getEntityInfos(param2.casterId) as GameFightFighterInformations;
         var _loc38_:Number = _loc37_.stats.movementPoints / _loc37_.stats.maxMovementPoints;
         var _loc39_:uint = param2.casterLifePointsAfterNormalMinDamage > 0?param2.casterLifePointsAfterNormalMinDamage:_loc37_.stats.lifePoints;
         var _loc40_:uint = param2.casterLifePointsAfterNormalMaxDamage > 0?param2.casterLifePointsAfterNormalMaxDamage:_loc37_.stats.lifePoints;
         var _loc41_:uint = param2.casterLifePointsAfterCriticalMinDamage > 0?param2.casterLifePointsAfterCriticalMinDamage:_loc37_.stats.lifePoints;
         var _loc42_:uint = param2.casterLifePointsAfterCriticalMaxDamage > 0?param2.casterLifePointsAfterCriticalMaxDamage:_loc37_.stats.lifePoints;
         var _loc43_:uint = param2.targetLifePointsAfterNormalMinDamage > 0?param2.targetLifePointsAfterNormalMinDamage:param2.targetInfos.stats.lifePoints;
         var _loc44_:uint = param2.targetLifePointsAfterNormalMaxDamage > 0?param2.targetLifePointsAfterNormalMaxDamage:param2.targetInfos.stats.lifePoints;
         var _loc45_:uint = param2.targetLifePointsAfterCriticalMinDamage > 0?param2.targetLifePointsAfterCriticalMinDamage:param2.targetInfos.stats.lifePoints;
         var _loc46_:uint = param2.targetLifePointsAfterCriticalMaxDamage > 0?param2.targetLifePointsAfterCriticalMaxDamage:param2.targetInfos.stats.lifePoints;
         var _loc49_:int = param1.effectDamages.length;
         _loc47_ = 0;
         while(_loc47_ < _loc49_)
         {
            _loc23_ = param1.effectDamages[_loc47_];
            _loc24_ = _loc23_.effectId;
            _loc14_ = 0;
            if(NO_BOOST_EFFECTS_IDS.indexOf(_loc23_.effectId) != -1)
            {
               var param4:* = true;
            }
            _loc21_ = param2.getEffectModification(_loc23_.effectId,_loc47_,_loc23_.hasCritical);
            if(_loc21_)
            {
               _loc22_ = _loc21_.damagesBonus;
               if(_loc21_.shieldPoints > param2.targetTriggeredShieldPoints)
               {
                  param2.targetTriggeredShieldPoints = _loc21_.shieldPoints;
               }
            }
            switch(_loc23_.element)
            {
               case NEUTRAL_ELEMENT:
                  if(!param4)
                  {
                     _loc48_ = param2.casterStrength;
                     _loc11_ = _loc48_ + param2.casterDamagesBonus + _loc22_ + (param2.isWeapon?param2.casterWeaponDamagesBonus:param2.casterSpellDamagesBonus);
                     _loc12_ = param2.casterStrengthBonus;
                     _loc13_ = param2.casterCriticalStrengthBonus;
                  }
                  if(!param6)
                  {
                     _loc14_ = param2.targetNeutralElementResistPercent;
                     _loc16_ = param2.targetNeutralElementReduction;
                  }
                  _loc20_ = param2.casterNeutralDamageBonus;
                  break;
               case EARTH_ELEMENT:
                  if(!param4)
                  {
                     _loc48_ = param2.casterStrength;
                     _loc11_ = _loc48_ + param2.casterDamagesBonus + _loc22_ + (param2.isWeapon?param2.casterWeaponDamagesBonus:param2.casterSpellDamagesBonus);
                     _loc12_ = param2.casterStrengthBonus;
                     _loc13_ = param2.casterCriticalStrengthBonus;
                  }
                  if(!param6)
                  {
                     _loc14_ = param2.targetEarthElementResistPercent;
                     _loc16_ = param2.targetEarthElementReduction;
                  }
                  _loc20_ = param2.casterEarthDamageBonus;
                  break;
               case FIRE_ELEMENT:
                  if(!param4)
                  {
                     _loc48_ = param2.casterIntelligence;
                     _loc11_ = _loc48_ + param2.casterDamagesBonus + _loc22_ + (param2.isWeapon?param2.casterWeaponDamagesBonus:param2.casterSpellDamagesBonus);
                     _loc12_ = param2.casterIntelligenceBonus;
                     _loc13_ = param2.casterCriticalIntelligenceBonus;
                  }
                  if(!param6)
                  {
                     _loc14_ = param2.targetFireElementResistPercent;
                     _loc16_ = param2.targetFireElementReduction;
                  }
                  _loc20_ = param2.casterFireDamageBonus;
                  break;
               case WATER_ELEMENT:
                  if(!param4)
                  {
                     _loc48_ = param2.casterChance;
                     _loc11_ = _loc48_ + param2.casterDamagesBonus + _loc22_ + (param2.isWeapon?param2.casterWeaponDamagesBonus:param2.casterSpellDamagesBonus);
                     _loc12_ = param2.casterChanceBonus;
                     _loc13_ = param2.casterCriticalChanceBonus;
                  }
                  if(!param6)
                  {
                     _loc14_ = param2.targetWaterElementResistPercent;
                     _loc16_ = param2.targetWaterElementReduction;
                  }
                  _loc20_ = param2.casterWaterDamageBonus;
                  break;
               case AIR_ELEMENT:
                  if(!param4)
                  {
                     _loc48_ = param2.casterAgility;
                     _loc11_ = _loc48_ + param2.casterDamagesBonus + _loc22_ + (param2.isWeapon?param2.casterWeaponDamagesBonus:param2.casterSpellDamagesBonus);
                     _loc12_ = param2.casterAgilityBonus;
                     _loc13_ = param2.casterCriticalAgilityBonus;
                  }
                  if(!param6)
                  {
                     _loc14_ = param2.targetAirElementResistPercent;
                     _loc16_ = param2.targetAirElementReduction;
                  }
                  _loc20_ = param2.casterAirDamageBonus;
                  break;
            }
            _loc11_ = Math.max(0,_loc11_);
            if(!param6)
            {
               _loc16_ = _loc16_ + getBuffElementReduction(param2,_loc23_,param2.targetId);
            }
            if(param9)
            {
               _loc16_ = 0;
            }
            if(!param2.targetIsMonster)
            {
               _loc14_ = Math.min(_loc14_,50);
            }
            if(param7)
            {
               _loc14_ = 0;
            }
            _loc14_ = 100 - _loc14_;
            _loc15_ = (isNaN(_loc23_.efficiencyMultiplier)?param3:_loc23_.efficiencyMultiplier) * 100;
            if(param8)
            {
               _loc14_ = Math.min(100,_loc14_);
            }
            if(HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(_loc23_.effectId) == -1 && TARGET_HP_BASED_DAMAGE_EFFECTS_IDS.indexOf(_loc23_.effectId) == -1)
            {
               if(param4)
               {
                  _loc20_ = _loc17_ = _loc18_ = 0;
               }
               if(param5)
               {
                  _loc19_ = 0;
               }
               _loc51_ = param2.spellDamageModification?param2.spellDamageModification.value.objectsAndMountBonus:0;
               _loc29_ = getDamage(_loc23_.minDamage,param4,_loc11_,_loc12_,_loc20_,_loc17_,_loc51_,_loc16_,_loc14_,_loc15_);
               _loc31_ = getDamage(!param4 && param2.spellWeaponCriticalBonus != 0?_loc23_.minDamage > 0?_loc23_.minDamage + param2.spellWeaponCriticalBonus:0:_loc23_.minCriticalDamage,param4,_loc11_,_loc13_,_loc20_ + _loc18_,_loc17_,_loc51_,_loc16_ + _loc19_,_loc14_,_loc15_);
               _loc33_ = getDamage(_loc23_.maxDamage,param4,_loc11_,_loc12_,_loc20_,_loc17_,_loc51_,_loc16_,_loc14_,_loc15_);
               _loc35_ = getDamage(!param4 && param2.spellWeaponCriticalBonus != 0?_loc23_.maxDamage > 0?_loc23_.maxDamage + param2.spellWeaponCriticalBonus:0:_loc23_.maxCriticalDamage,param4,_loc11_,_loc13_,_loc20_ + _loc18_,_loc17_,_loc51_,_loc16_ + _loc19_,_loc14_,_loc15_);
            }
            else
            {
               switch(_loc23_.effectId)
               {
                  case 672:
                     _loc52_ = _loc23_.maxDamage * _loc37_.stats.baseMaxLifePoints * getMidLifeDamageMultiplier(Math.min(100,Math.max(0,100 * _loc37_.stats.lifePoints / _loc37_.stats.maxLifePoints))) / 100 * _loc15_ / 100;
                     _loc29_ = _loc33_ = (_loc52_ - _loc16_) * _loc14_ / 100;
                     _loc53_ = _loc23_.maxCriticalDamage * _loc37_.stats.baseMaxLifePoints * getMidLifeDamageMultiplier(Math.min(100,Math.max(0,100 * _loc37_.stats.lifePoints / _loc37_.stats.maxLifePoints))) / 100 * _loc15_ / 100;
                     _loc31_ = _loc35_ = (_loc53_ - _loc16_) * _loc14_ / 100;
                     break;
                  case 85:
                  case 86:
                  case 87:
                  case 88:
                  case 89:
                     _loc52_ = _loc23_.minDamage * _loc39_ / 100 * _loc15_ / 100;
                     _loc29_ = (_loc52_ - _loc16_) * _loc14_ / 100;
                     _loc52_ = _loc23_.maxDamage * _loc40_ / 100 * _loc15_ / 100;
                     _loc33_ = (_loc52_ - _loc16_) * _loc14_ / 100;
                     _loc53_ = _loc23_.minCriticalDamage * _loc41_ / 100 * _loc15_ / 100;
                     _loc31_ = (_loc53_ - _loc16_) * _loc14_ / 100;
                     _loc53_ = _loc23_.maxCriticalDamage * _loc42_ / 100 * _loc15_ / 100;
                     _loc35_ = (_loc53_ - _loc16_) * _loc14_ / 100;
                     _loc39_ = _loc39_ - _loc29_;
                     _loc40_ = _loc40_ - _loc33_;
                     _loc41_ = _loc41_ - _loc31_;
                     _loc42_ = _loc42_ - _loc35_;
                     break;
                  case 1067:
                  case 1068:
                  case 1069:
                  case 1070:
                  case 1071:
                     _loc52_ = _loc23_.minDamage * _loc43_ / 100 * _loc15_ / 100;
                     _loc29_ = (_loc52_ - _loc16_) * _loc14_ / 100;
                     _loc52_ = _loc23_.maxDamage * _loc44_ / 100 * _loc15_ / 100;
                     _loc33_ = (_loc52_ - _loc16_) * _loc14_ / 100;
                     _loc53_ = _loc23_.minCriticalDamage * _loc45_ / 100 * _loc15_ / 100;
                     _loc31_ = (_loc53_ - _loc16_) * _loc14_ / 100;
                     _loc53_ = _loc23_.maxCriticalDamage * _loc46_ / 100 * _loc15_ / 100;
                     _loc35_ = (_loc53_ - _loc16_) * _loc14_ / 100;
                     _loc43_ = _loc43_ - _loc29_;
                     _loc44_ = _loc44_ - _loc33_;
                     _loc45_ = _loc45_ - _loc31_;
                     _loc46_ = _loc46_ - _loc35_;
                     break;
               }
            }
            _loc29_ = _loc29_ < 0?0:_loc29_;
            _loc33_ = _loc33_ < 0?0:_loc33_;
            _loc31_ = _loc31_ < 0?0:_loc31_;
            _loc35_ = _loc35_ < 0?0:_loc35_;
            if(MP_BASED_DAMAGE_EFFECTS_IDS.indexOf(_loc23_.effectId) != -1)
            {
               _loc29_ = _loc29_ * _loc38_;
               _loc33_ = _loc33_ * _loc38_;
               _loc31_ = _loc31_ * _loc38_;
               _loc35_ = _loc35_ * _loc38_;
            }
            if(DamageUtil.EROSION_DAMAGE_EFFECTS_IDS.indexOf(_loc23_.effectId) != -1)
            {
               _loc23_.minErosionDamage = _loc23_.minErosionDamage + (param2.targetErosionLifePoints + param2.targetSpellMinErosionLifePoints) * _loc23_.minErosionPercent / 100;
               _loc23_.maxErosionDamage = _loc23_.maxErosionDamage + (param2.targetErosionLifePoints + param2.targetSpellMaxErosionLifePoints) * _loc23_.maxErosionPercent / 100;
               if(_loc23_.hasCritical)
               {
                  _loc23_.minCriticalErosionDamage = _loc23_.minCriticalErosionDamage + (param2.targetErosionLifePoints + param2.targetSpellMinCriticalErosionLifePoints) * _loc23_.minCriticalErosionPercent / 100;
                  _loc23_.maxCriticalErosionDamage = _loc23_.maxCriticalErosionDamage + (param2.targetErosionLifePoints + param2.targetSpellMaxCriticalErosionLifePoints) * _loc23_.maxCriticalErosionPercent / 100;
               }
            }
            else
            {
               param2.targetSpellMinErosionLifePoints = param2.targetSpellMinErosionLifePoints + _loc29_ * (10 + param2.targetErosionPercentBonus) / 100;
               param2.targetSpellMaxErosionLifePoints = param2.targetSpellMaxErosionLifePoints + _loc33_ * (10 + param2.targetErosionPercentBonus) / 100;
               param2.targetSpellMinCriticalErosionLifePoints = param2.targetSpellMinCriticalErosionLifePoints + _loc31_ * (10 + param2.targetErosionPercentBonus) / 100;
               param2.targetSpellMaxCriticalErosionLifePoints = param2.targetSpellMaxCriticalErosionLifePoints + _loc35_ * (10 + param2.targetErosionPercentBonus) / 100;
            }
            if(!_loc30_)
            {
               _loc30_ = new Vector.<int>(0);
            }
            _loc30_.push(_loc29_);
            if(!_loc34_)
            {
               _loc34_ = new Vector.<int>(0);
            }
            _loc34_.push(_loc33_);
            if(!_loc32_)
            {
               _loc32_ = new Vector.<int>(0);
            }
            _loc32_.push(_loc31_);
            if(!_loc36_)
            {
               _loc36_ = new Vector.<int>(0);
            }
            _loc36_.push(_loc35_);
            _loc25_ = _loc25_ + _loc29_;
            _loc27_ = _loc27_ + _loc33_;
            _loc26_ = _loc26_ + _loc31_;
            _loc28_ = _loc28_ + _loc35_;
            _loc47_++;
         }
         var _loc50_:EffectDamage = new EffectDamage(_loc24_,param1.element,param1.random);
         _loc50_.minDamage = _loc25_;
         _loc50_.minDamageList = _loc30_;
         _loc50_.maxDamage = _loc27_;
         _loc50_.maxDamageList = _loc34_;
         _loc50_.minCriticalDamage = _loc26_;
         _loc50_.minCriticalDamageList = _loc32_;
         _loc50_.maxCriticalDamage = _loc28_;
         _loc50_.maxCriticalDamageList = _loc36_;
         _loc50_.minErosionDamage = param1.minErosionDamage * _loc15_ / 100;
         _loc50_.minErosionDamage = _loc50_.minErosionDamage * _loc14_ / 100;
         _loc50_.maxErosionDamage = param1.maxErosionDamage * _loc15_ / 100;
         _loc50_.maxErosionDamage = _loc50_.maxErosionDamage * _loc14_ / 100;
         _loc50_.minCriticalErosionDamage = param1.minCriticalErosionDamage * _loc15_ / 100;
         _loc50_.minCriticalErosionDamage = _loc50_.minCriticalErosionDamage * _loc14_ / 100;
         _loc50_.maxCriticalErosionDamage = param1.maxCriticalErosionDamage * _loc15_ / 100;
         _loc50_.maxCriticalErosionDamage = _loc50_.maxCriticalErosionDamage * _loc14_ / 100;
         _loc50_.hasCritical = param1.hasCriticalDamage;
         return _loc50_;
      }
      
      private static function getDamage(param1:int, param2:Boolean, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int, param10:int) : int
      {
         if(!param2 && param3 + param4 <= 0)
         {
            var param3:int = param4 = 0;
         }
         var _loc11_:int = param1 > 0?Math.floor(param1 * (100 + param3 + param4) / 100) + param5 + param6:0;
         var _loc12_:int = _loc11_ > 0?(_loc11_ + param7) * param10 / 100:0;
         var _loc13_:int = _loc12_ > 0?_loc12_ - param8:0;
         _loc13_ = _loc13_ < 0?0:_loc13_;
         return _loc13_ * param9 / 100;
      }
      
      private static function getMidLifeDamageMultiplier(param1:int) : Number
      {
         return Math.pow(Math.cos(2 * Math.PI * (param1 * 0.01 - 0.5)) + 1,2) / 4;
      }
      
      private static function getDistance(param1:uint, param2:uint) : int
      {
         return MapPoint.fromCellId(param1).distanceToCell(MapPoint.fromCellId(param2));
      }
      
      private static function getSquareDistance(param1:uint, param2:uint) : int
      {
         var _loc3_:MapPoint = MapPoint.fromCellId(param1);
         var _loc4_:MapPoint = MapPoint.fromCellId(param2);
         return Math.max(Math.abs(_loc3_.x - _loc4_.x),Math.abs(_loc3_.y - _loc4_.y));
      }
      
      public static function getShapeEfficiency(param1:uint, param2:uint, param3:uint, param4:int, param5:int, param6:int, param7:int) : Number
      {
         var _loc8_:* = 0;
         switch(param1)
         {
            case SpellShapeEnum.A:
            case SpellShapeEnum.a:
            case SpellShapeEnum.Z:
            case SpellShapeEnum.I:
            case SpellShapeEnum.O:
            case SpellShapeEnum.semicolon:
            case SpellShapeEnum.empty:
            case SpellShapeEnum.P:
               return DAMAGE_NOT_BOOSTED;
            case SpellShapeEnum.B:
            case SpellShapeEnum.V:
            case SpellShapeEnum.G:
            case SpellShapeEnum.W:
               _loc8_ = getSquareDistance(param2,param3);
               break;
            case SpellShapeEnum.minus:
            case SpellShapeEnum.plus:
            case SpellShapeEnum.U:
               _loc8_ = getDistance(param2,param3) / 2;
               break;
            default:
               _loc8_ = getDistance(param2,param3);
         }
         return getSimpleEfficiency(_loc8_,param4,param5,param6,param7);
      }
      
      public static function getSimpleEfficiency(param1:int, param2:int, param3:int, param4:int, param5:int) : Number
      {
         if(param4 == 0)
         {
            return DAMAGE_NOT_BOOSTED;
         }
         if(param2 <= 0 || param2 >= UNLIMITED_ZONE_SIZE)
         {
            return DAMAGE_NOT_BOOSTED;
         }
         if(param1 > param2)
         {
            return DAMAGE_NOT_BOOSTED;
         }
         if(param4 <= 0)
         {
            return DAMAGE_NOT_BOOSTED;
         }
         if(param3 != 0)
         {
            if(param1 <= param3)
            {
               return DAMAGE_NOT_BOOSTED;
            }
            return Math.max(0,DAMAGE_NOT_BOOSTED - 0.01 * Math.min(param1 - param3,param5) * param4);
         }
         return Math.max(0,DAMAGE_NOT_BOOSTED - 0.01 * Math.min(param1,param5) * param4);
      }
      
      public static function getPortalsSpellEfficiencyBonus(param1:int) : Number
      {
         var _loc3_:* = false;
         var _loc4_:MapPoint = null;
         var _loc8_:Vector.<MarkInstance> = null;
         var _loc9_:* = 0;
         var _loc10_:MarkInstance = null;
         var _loc11_:MarkInstance = null;
         var _loc12_:* = 0;
         var _loc13_:* = 0;
         var _loc2_:Number = 1;
         var _loc5_:Vector.<MapPoint> = MarkedCellsManager.getInstance().getMarksMapPoint(GameActionMarkTypeEnum.PORTAL);
         for each(_loc4_ in _loc5_)
         {
            if(_loc4_.cellId == param1)
            {
               _loc3_ = true;
               break;
            }
         }
         if(!_loc3_)
         {
            return _loc2_;
         }
         var _loc6_:Vector.<uint> = LinkedCellsManager.getInstance().getLinks(MapPoint.fromCellId(param1),_loc5_);
         var _loc7_:int = _loc6_.length;
         if(_loc7_ > 1)
         {
            _loc8_ = new Vector.<MarkInstance>(0);
            _loc9_ = 0;
            while(_loc9_ < _loc7_)
            {
               _loc8_.push(MarkedCellsManager.getInstance().getMarkAtCellId(_loc6_[_loc9_],GameActionMarkTypeEnum.PORTAL));
               _loc9_++;
            }
            _loc9_ = 0;
            while(_loc9_ < _loc7_)
            {
               _loc10_ = _loc8_[_loc9_];
               _loc12_ = Math.max(_loc12_,int(_loc10_.associatedSpellLevel.effects[0].parameter2));
               if(_loc11_)
               {
                  _loc13_ = _loc13_ + MapPoint.fromCellId(_loc10_.cells[0]).distanceToCell(MapPoint.fromCellId(_loc11_.cells[0]));
               }
               _loc11_ = _loc10_;
               _loc9_++;
            }
            _loc2_ = 1 + (_loc12_ + _loc8_.length * _loc13_) / 100;
         }
         return _loc2_;
      }
      
      public static function getSplashDamages(param1:Vector.<TriggeredSpell>, param2:SpellDamageInfo) : Vector.<SplashDamage>
      {
         var _loc3_:Vector.<SplashDamage> = null;
         var _loc4_:TriggeredSpell = null;
         var _loc5_:SpellWrapper = null;
         var _loc6_:EffectInstance = null;
         var _loc7_:IZone = null;
         var _loc8_:Vector.<uint> = null;
         var _loc9_:uint = 0;
         var _loc10_:Vector.<int> = null;
         var _loc12_:Array = null;
         var _loc13_:IEntity = null;
         var _loc11_:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         var _loc14_:uint = EntitiesManager.getInstance().getEntity(param2.casterId).position.cellId;
         for each(_loc4_ in param1)
         {
            _loc5_ = _loc4_.spell;
            for each(_loc6_ in _loc5_.effects)
            {
               if(SPLASH_EFFECTS_IDS.indexOf(_loc6_.effectId) != -1)
               {
                  _loc7_ = SpellZoneManager.getInstance().getSpellZone(_loc5_,false,false);
                  _loc8_ = _loc7_.getCells(param2.targetCell);
                  _loc10_ = null;
                  if(_loc6_.targetMask && _loc6_.targetMask.indexOf("O") != -1 && _loc8_.indexOf(_loc14_) == -1)
                  {
                     _loc8_.push(_loc14_);
                  }
                  for each(_loc9_ in _loc8_)
                  {
                     _loc12_ = EntitiesManager.getInstance().getEntitiesOnCell(_loc9_,AnimatedCharacter);
                     for each(_loc13_ in _loc12_)
                     {
                        if(_loc11_.getEntityInfos(_loc13_.id) && verifySpellEffectMask(_loc5_.playerId,_loc13_.id,_loc6_,param2.targetCell,param2.casterId))
                        {
                           if(!_loc3_)
                           {
                              _loc3_ = new Vector.<SplashDamage>(0);
                           }
                           if(!_loc10_)
                           {
                              _loc10_ = new Vector.<int>(0);
                           }
                           _loc10_.push(_loc13_.id);
                        }
                     }
                  }
                  if(_loc10_)
                  {
                     _loc3_.push(new SplashDamage(_loc5_.id,_loc5_.playerId,_loc10_,DamageUtil.getSpellDamage(param2,false,false),_loc6_.effectId,(_loc6_ as EffectInstanceDice).diceNum,Effect.getEffectById(_loc6_.effectId).elementId,_loc6_.random,_loc6_.rawZone.charCodeAt(0),_loc6_.zoneSize,_loc6_.zoneMinSize,_loc6_.zoneEfficiencyPercent,_loc6_.zoneMaxEfficiency,_loc4_.hasCritical));
                  }
               }
            }
         }
         return _loc3_;
      }
      
      public static function getAverageElementResistance(param1:uint, param2:Vector.<int>) : int
      {
         var _loc3_:String = null;
         switch(param1)
         {
            case NEUTRAL_ELEMENT:
               _loc3_ = "neutralElementResistPercent";
               break;
            case EARTH_ELEMENT:
               _loc3_ = "earthElementResistPercent";
               break;
            case FIRE_ELEMENT:
               _loc3_ = "fireElementResistPercent";
               break;
            case WATER_ELEMENT:
               _loc3_ = "waterElementResistPercent";
               break;
            case AIR_ELEMENT:
               _loc3_ = "airElementResistPercent";
               break;
         }
         return getAverageStat(_loc3_,param2);
      }
      
      public static function getAverageElementReduction(param1:uint, param2:Vector.<int>) : int
      {
         var _loc3_:String = null;
         switch(param1)
         {
            case NEUTRAL_ELEMENT:
               _loc3_ = "neutralElementReduction";
               break;
            case EARTH_ELEMENT:
               _loc3_ = "earthElementReduction";
               break;
            case FIRE_ELEMENT:
               _loc3_ = "fireElementReduction";
               break;
            case WATER_ELEMENT:
               _loc3_ = "waterElementReduction";
               break;
            case AIR_ELEMENT:
               _loc3_ = "airElementReduction";
               break;
         }
         return getAverageStat(_loc3_,param2);
      }
      
      public static function getAverageBuffElementReduction(param1:SpellDamageInfo, param2:EffectDamage, param3:Vector.<int>) : int
      {
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         for each(_loc5_ in param3)
         {
            _loc4_ = _loc4_ + getBuffElementReduction(param1,param2,_loc5_);
         }
         return _loc4_ / param3.length;
      }
      
      public static function getBuffElementReduction(param1:SpellDamageInfo, param2:EffectDamage, param3:int) : int
      {
         var _loc5_:BasicBuff = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:EffectInstance = null;
         var _loc10_:* = 0;
         var _loc12_:* = false;
         var _loc4_:Array = BuffManager.getInstance().getAllBuff(param3);
         var _loc11_:Dictionary = new Dictionary(true);
         _loc9_ = new EffectInstance();
         _loc9_.effectId = param2.effectId;
         for each(_loc5_ in _loc4_)
         {
            _loc7_ = _loc5_.effect.triggers;
            _loc12_ = _loc5_.canBeDispell() && _loc5_.effect.duration - param1.spellTargetEffectsDurationReduction <= 0;
            if(!_loc12_ && _loc7_)
            {
               _loc8_ = _loc7_.split("|");
               if(!_loc11_[_loc5_.castingSpell.spell.id])
               {
                  _loc11_[_loc5_.castingSpell.spell.id] = new Vector.<int>(0);
               }
               for each(_loc6_ in _loc8_)
               {
                  if(_loc5_.actionId == 265 && verifyEffectTrigger(param1.casterId,param3,null,_loc9_,param1.isWeapon,_loc6_,param1.spellCenterCell))
                  {
                     if(_loc11_[_loc5_.castingSpell.spell.id].indexOf(param2.element) == -1)
                     {
                        _loc10_ = _loc10_ + (param1.targetLevel / 20 + 1) * (_loc5_.effect as EffectInstanceInteger).value;
                        if(_loc11_[_loc5_.castingSpell.spell.id].indexOf(param2.element) == -1)
                        {
                           _loc11_[_loc5_.castingSpell.spell.id].push(param2.element);
                        }
                     }
                  }
               }
            }
         }
         return _loc10_;
      }
      
      public static function getAverageStat(param1:String, param2:Vector.<int>) : int
      {
         var _loc4_:* = 0;
         var _loc5_:GameFightFighterInformations = null;
         var _loc6_:* = 0;
         var _loc3_:FightEntitiesFrame = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
         if(!_loc3_ || !param2 || param2.length == 0)
         {
            return -1;
         }
         if(param1)
         {
            for each(_loc4_ in param2)
            {
               _loc5_ = _loc3_.getEntityInfos(_loc4_) as GameFightFighterInformations;
               _loc6_ = _loc6_ + _loc5_.stats[param1];
            }
         }
         return _loc6_ / param2.length;
      }
   }
}
