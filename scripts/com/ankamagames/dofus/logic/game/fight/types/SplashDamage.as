package com.ankamagames.dofus.logic.game.fight.types
{
   public class SplashDamage extends Object
   {
       
      private var _spellId:int;
      
      private var _casterId:int;
      
      private var _targets:Vector.<int>;
      
      private var _damage:SpellDamage;
      
      private var _spellShape:uint;
      
      private var _spellShapeSize:Object;
      
      private var _spellShapeMinSize:Object;
      
      private var _spellShapeEfficiencyPercent:Object;
      
      private var _spellShapeMaxEfficiency:Object;
      
      private var _hasCritical:Boolean;
      
      public function SplashDamage(param1:int, param2:int, param3:Vector.<int>, param4:SpellDamage, param5:uint, param6:int, param7:int, param8:int, param9:uint, param10:Object, param11:Object, param12:Object, param13:Object, param14:Boolean)
      {
         var _loc15_:EffectDamage = null;
         var _loc16_:EffectDamage = null;
         super();
         this._spellId = param1;
         this._casterId = param2;
         this._targets = param3;
         this._damage = new SpellDamage();
         this._spellShape = param9;
         this._spellShapeSize = param10;
         this._spellShapeMinSize = param11;
         this._spellShapeEfficiencyPercent = param12;
         this._spellShapeMaxEfficiency = param13;
         this._hasCritical = param14;
         for each(_loc15_ in param4.effectDamages)
         {
            _loc16_ = new EffectDamage(param5,param7 != -1 && _loc15_.element != -1?param7:_loc15_.element,param8);
            _loc16_.minDamage = this.getSplashDamage(_loc15_.minDamage,_loc15_.minDamageList,param6);
            _loc16_.maxDamage = this.getSplashDamage(_loc15_.maxDamage,_loc15_.maxDamageList,param6);
            _loc16_.minCriticalDamage = this.getSplashDamage(_loc15_.minCriticalDamage,_loc15_.minCriticalDamageList,param6);
            _loc16_.maxCriticalDamage = this.getSplashDamage(_loc15_.maxCriticalDamage,_loc15_.maxCriticalDamageList,param6);
            _loc16_.hasCritical = _loc15_.hasCritical;
            this._damage.addEffectDamage(_loc16_);
         }
         this._damage.hasCriticalDamage = param4.hasCriticalDamage;
         this._damage.updateDamage();
      }
      
      public function get spellId() : int
      {
         return this._spellId;
      }
      
      public function get casterId() : int
      {
         return this._casterId;
      }
      
      public function get targets() : Vector.<int>
      {
         return this._targets;
      }
      
      public function get damage() : SpellDamage
      {
         return this._damage;
      }
      
      public function get spellShape() : uint
      {
         return this._spellShape;
      }
      
      public function get spellShapeSize() : Object
      {
         return this._spellShapeSize;
      }
      
      public function get spellShapeMinSize() : Object
      {
         return this._spellShapeMinSize;
      }
      
      public function get spellShapeEfficiencyPercent() : Object
      {
         return this._spellShapeEfficiencyPercent;
      }
      
      public function get spellShapeMaxEfficiency() : Object
      {
         return this._spellShapeMaxEfficiency;
      }
      
      public function get hasCritical() : Boolean
      {
         return this._hasCritical;
      }
      
      private function getSplashDamage(param1:int, param2:Vector.<int>, param3:int) : int
      {
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         if(param2)
         {
            for each(_loc4_ in param2)
            {
               _loc5_ = _loc5_ + _loc4_ * param3 / 100;
            }
         }
         else
         {
            _loc5_ = param1 * param3 / 100;
         }
         return _loc5_;
      }
   }
}
