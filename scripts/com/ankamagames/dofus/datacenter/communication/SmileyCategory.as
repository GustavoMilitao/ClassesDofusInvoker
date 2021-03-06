package com.ankamagames.dofus.datacenter.communication
{
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.data.GameData;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   
   public class SmileyCategory extends Object implements IDataCenter
   {
      
      public static const MODULE:String = "SmileyCategories";
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(SmileyCategory));
       
      public var id:int;
      
      public var order:uint;
      
      public var gfxId:String;
      
      public var isFake:Boolean;
      
      public function SmileyCategory()
      {
         super();
      }
      
      public static function getSmileyCategoryById(param1:int) : SmileyCategory
      {
         return GameData.getObject(MODULE,param1) as SmileyCategory;
      }
      
      public static function getSmileyCategories() : Array
      {
         return GameData.getObjects(MODULE);
      }
   }
}
