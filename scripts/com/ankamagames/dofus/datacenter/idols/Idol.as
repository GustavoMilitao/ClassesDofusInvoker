package com.ankamagames.dofus.datacenter.idols
{
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   import com.ankamagames.dofus.misc.utils.GameDataQuery;
   import com.ankamagames.jerakine.data.GameData;
   import com.ankamagames.dofus.datacenter.items.Item;
   import com.ankamagames.dofus.datacenter.spells.SpellPair;
   
   public class Idol extends Object implements IDataCenter
   {
      
      public static const MODULE:String = "Idols";
       
      private var _item:Item;
      
      private var _spellPair:SpellPair;
      
      public var id:int;
      
      public var description:String;
      
      public var categoryId:int;
      
      public var itemId:int;
      
      public var groupOnly:Boolean;
      
      public var spellPairId:int;
      
      public var score:int;
      
      public var experienceBonus:int;
      
      public var dropBonus:int;
      
      public var synergyIdolsIds:Vector.<int>;
      
      public var synergyIdolsCoeff:Vector.<Number>;
      
      public function Idol()
      {
         super();
      }
      
      public static function getIdolByItemId(param1:int) : Idol
      {
         var _loc2_:Vector.<uint> = GameDataQuery.queryEquals(Idol,"itemId",param1);
         return _loc2_ && _loc2_.length > 0?getIdolById(_loc2_[0]):null;
      }
      
      public static function getIdolById(param1:int) : Idol
      {
         return GameData.getObject(MODULE,param1) as Idol;
      }
      
      public static function getIdols() : Array
      {
         return GameData.getObjects(MODULE);
      }
      
      public function get item() : Item
      {
         if(!this._item)
         {
            this._item = Item.getItemById(this.itemId);
         }
         return this._item;
      }
      
      public function get spellPair() : SpellPair
      {
         if(!this._spellPair)
         {
            this._spellPair = SpellPair.getSpellPairById(this.spellPairId);
         }
         return this._spellPair;
      }
   }
}
