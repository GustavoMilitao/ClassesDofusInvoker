package com.ankamagames.dofus.datacenter.alignments
{
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.data.GameData;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.jerakine.data.I18n;
   
   public class AlignmentGift extends Object implements IDataCenter
   {
      
      public static const MODULE:String = "AlignmentGift";
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(AlignmentGift));
       
      public var id:int;
      
      public var nameId:uint;
      
      public var effectId:int;
      
      public var gfxId:uint;
      
      private var _name:String;
      
      public function AlignmentGift()
      {
         super();
      }
      
      public static function getAlignmentGiftById(param1:int) : AlignmentGift
      {
         return GameData.getObject(MODULE,param1) as AlignmentGift;
      }
      
      public static function getAlignmentGifts() : Array
      {
         return GameData.getObjects(MODULE);
      }
      
      public function get name() : String
      {
         if(!this._name)
         {
            this._name = I18n.getText(this.nameId);
         }
         return this._name;
      }
   }
}
