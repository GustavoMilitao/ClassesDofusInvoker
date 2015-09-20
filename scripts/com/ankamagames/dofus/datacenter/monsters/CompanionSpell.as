package com.ankamagames.dofus.datacenter.monsters
{
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   import com.ankamagames.jerakine.data.GameData;
   
   public class CompanionSpell extends Object implements IDataCenter
   {
      
      public static const MODULE:String = "CompanionSpells";
       
      public var id:int;
      
      public var spellId:int;
      
      public var companionId:int;
      
      public var gradeByLevel:String;
      
      public function CompanionSpell()
      {
         super();
      }
      
      public static function getCompanionSpellById(param1:uint) : CompanionSpell
      {
         return GameData.getObject(MODULE,param1) as CompanionSpell;
      }
      
      public static function getCompanionSpells() : Array
      {
         return GameData.getObjects(MODULE);
      }
   }
}
