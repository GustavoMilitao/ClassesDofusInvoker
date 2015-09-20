package com.ankamagames.dofus.logic.game.fight.types
{
   public class ReflectDamage extends Object
   {
       
      private var _effects:Vector.<EffectDamage>;
      
      private var _sourceId:int;
      
      private var _reflectValue:uint;
      
      public function ReflectDamage(param1:int, param2:uint)
      {
         super();
         this._sourceId = param1;
         this._reflectValue = param2;
      }
      
      public function get sourceId() : int
      {
         return this._sourceId;
      }
      
      public function get effects() : Vector.<EffectDamage>
      {
         return this._effects;
      }
      
      public function get reflectValue() : uint
      {
         return this._reflectValue;
      }
      
      public function addEffect(param1:EffectDamage) : void
      {
         if(!this._effects)
         {
            this._effects = new Vector.<EffectDamage>(0);
         }
         this._effects.push(param1);
      }
   }
}
