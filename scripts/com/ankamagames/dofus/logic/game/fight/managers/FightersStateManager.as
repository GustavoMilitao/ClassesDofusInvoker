package com.ankamagames.dofus.logic.game.fight.managers
{
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.utils.Dictionary;
   import com.ankamagames.dofus.logic.game.fight.types.FighterStatus;
   import com.ankamagames.dofus.datacenter.spells.SpellState;
   
   public class FightersStateManager extends Object
   {
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(FightersStateManager));
      
      private static var _self:FightersStateManager;
       
      private var _entityStates:Dictionary;
      
      public function FightersStateManager()
      {
         this._entityStates = new Dictionary();
         super();
      }
      
      public static function getInstance() : FightersStateManager
      {
         if(!_self)
         {
            _self = new FightersStateManager();
         }
         return _self;
      }
      
      public function addStateOnTarget(param1:int, param2:int) : void
      {
         var _loc3_:Array = this._entityStates[param2];
         if(!_loc3_)
         {
            _loc3_ = new Array();
            this._entityStates[param2] = _loc3_;
         }
         _loc3_.push(param1);
      }
      
      public function removeStateOnTarget(param1:int, param2:int) : void
      {
         var _loc3_:Array = this._entityStates[param2];
         if(!_loc3_)
         {
            _log.error("Can\'t find state list for " + param2 + " to remove state");
            return;
         }
         var _loc4_:int = _loc3_.indexOf(param1);
         if(_loc4_ != -1)
         {
            _loc3_.splice(_loc4_,1);
         }
      }
      
      public function hasState(param1:int, param2:int) : Boolean
      {
         var _loc3_:Array = this._entityStates[param1];
         if(!_loc3_)
         {
            return false;
         }
         return _loc3_.indexOf(param2) != -1;
      }
      
      public function getStates(param1:int) : Array
      {
         return this._entityStates[param1];
      }
      
      public function getStatus(param1:int) : FighterStatus
      {
         var _loc3_:* = 0;
         var _loc4_:SpellState = null;
         var _loc2_:FighterStatus = new FighterStatus();
         for each(_loc3_ in this._entityStates[param1])
         {
            _loc4_ = SpellState.getSpellStateById(_loc3_);
            if(_loc4_)
            {
               if(_loc4_.preventsSpellCast)
               {
                  _loc2_.cantUseSpells = true;
               }
               if(_loc4_.preventsFight)
               {
                  _loc2_.cantUseCloseQuarterAttack = true;
               }
               if(_loc4_.cantDealDamage)
               {
                  _loc2_.cantDealDamage = true;
               }
               if(_loc4_.invulnerable)
               {
                  _loc2_.invulnerable = true;
               }
               if(_loc4_.incurable)
               {
                  _loc2_.incurable = true;
               }
               if(_loc4_.cantBeMoved)
               {
                  _loc2_.cantBeMoved = true;
               }
               if(_loc4_.cantBePushed)
               {
                  _loc2_.cantBePushed = true;
               }
               if(_loc4_.cantSwitchPosition)
               {
                  _loc2_.cantSwitchPosition = true;
               }
            }
         }
         return _loc2_;
      }
      
      public function endFight() : void
      {
         this._entityStates = new Dictionary();
      }
   }
}
