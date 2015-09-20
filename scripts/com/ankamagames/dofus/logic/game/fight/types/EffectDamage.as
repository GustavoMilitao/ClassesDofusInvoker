package com.ankamagames.dofus.logic.game.fight.types
{
   public class EffectDamage extends Object
   {
       
      private var _effectId:int;
      
      private var _element:int;
      
      private var _random:int;
      
      public var efficiencyMultiplier:Number;
      
      public var minDamage:int;
      
      public var minDamageList:Vector.<int>;
      
      public var maxDamage:int;
      
      public var maxDamageList:Vector.<int>;
      
      public var minCriticalDamage:int;
      
      public var minCriticalDamageList:Vector.<int>;
      
      public var maxCriticalDamage:int;
      
      public var maxCriticalDamageList:Vector.<int>;
      
      public var minErosionPercent:int;
      
      public var maxErosionPercent:int;
      
      public var minCriticalErosionPercent:int;
      
      public var maxCriticalErosionPercent:int;
      
      public var minErosionDamage:int;
      
      public var maxErosionDamage:int;
      
      public var minCriticalErosionDamage:int;
      
      public var maxCriticalErosionDamage:int;
      
      public var minShieldPointsRemoved:int;
      
      public var maxShieldPointsRemoved:int;
      
      public var minCriticalShieldPointsRemoved:int;
      
      public var maxCriticalShieldPointsRemoved:int;
      
      public var minLifePointsAdded:int;
      
      public var maxLifePointsAdded:int;
      
      public var minCriticalLifePointsAdded:int;
      
      public var maxCriticalLifePointsAdded:int;
      
      public var lifePointsAddedBasedOnLifePercent:int;
      
      public var criticalLifePointsAddedBasedOnLifePercent:int;
      
      public var hasCritical:Boolean;
      
      public var damageConvertedToHeal:Boolean;
      
      public function EffectDamage(param1:int, param2:int, param3:int)
      {
         super();
         this._effectId = param1;
         this._element = param2;
         this._random = param3;
      }
      
      public function get effectId() : int
      {
         return this._effectId;
      }
      
      public function set effectId(param1:int) : void
      {
         this._effectId = param1;
      }
      
      public function get element() : int
      {
         return this._element;
      }
      
      public function set element(param1:int) : void
      {
         this._element = param1;
      }
      
      public function get random() : int
      {
         return this._random;
      }
      
      public function set random(param1:int) : void
      {
         this._random = param1;
      }
      
      public function applyDamageMultiplier(param1:Number) : void
      {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         _loc3_ = this.minDamageList?this.minDamageList.length:0;
         if(_loc3_ > 0)
         {
            this.minDamage = 0;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               this.minDamageList[_loc2_] = this.minDamageList[_loc2_] * param1;
               this.minDamage = this.minDamage + this.minDamageList[_loc2_];
               _loc2_++;
            }
         }
         else
         {
            this.minDamage = this.minDamage * param1;
         }
         _loc3_ = this.maxDamageList?this.maxDamageList.length:0;
         if(_loc3_ > 0)
         {
            this.maxDamage = 0;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               this.maxDamageList[_loc2_] = this.maxDamageList[_loc2_] * param1;
               this.maxDamage = this.maxDamage + this.maxDamageList[_loc2_];
               _loc2_++;
            }
         }
         else
         {
            this.maxDamage = this.maxDamage * param1;
         }
         _loc3_ = this.minCriticalDamageList?this.minCriticalDamageList.length:0;
         if(_loc3_ > 0)
         {
            this.minCriticalDamage = 0;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               this.minCriticalDamageList[_loc2_] = this.minCriticalDamageList[_loc2_] * param1;
               this.minCriticalDamage = this.minCriticalDamage + this.minCriticalDamageList[_loc2_];
               _loc2_++;
            }
         }
         else
         {
            this.minCriticalDamage = this.minCriticalDamage * param1;
         }
         _loc3_ = this.maxCriticalDamageList?this.maxCriticalDamageList.length:0;
         if(_loc3_ > 0)
         {
            this.maxCriticalDamage = 0;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               this.maxCriticalDamageList[_loc2_] = this.maxCriticalDamageList[_loc2_] * param1;
               this.maxCriticalDamage = this.maxCriticalDamage + this.maxCriticalDamageList[_loc2_];
               _loc2_++;
            }
         }
         else
         {
            this.maxCriticalDamage = this.maxCriticalDamage * param1;
         }
      }
      
      public function convertDamageToHeal() : void
      {
         this.minLifePointsAdded = this.minLifePointsAdded + this.minDamage;
         this.minDamage = 0;
         this.maxLifePointsAdded = this.maxLifePointsAdded + this.maxDamage;
         this.maxDamage = 0;
         this.minCriticalLifePointsAdded = this.minCriticalLifePointsAdded + this.minCriticalDamage;
         this.minCriticalDamage = 0;
         this.maxCriticalLifePointsAdded = this.maxCriticalLifePointsAdded + this.maxCriticalDamage;
         this.maxCriticalDamage = 0;
         this.damageConvertedToHeal = true;
      }
   }
}
