package com.ankamagames.dofus
{
   import com.ankamagames.jerakine.types.Version;
   import com.ankamagames.dofus.network.enums.BuildTypeEnum;
   
   public final class BuildInfos extends Object
   {
      
      public static var BUILD_VERSION:Version = new Version(2,30,3);
      
      public static var BUILD_TYPE:uint = BuildTypeEnum.RELEASE;
      
      public static var BUILD_REVISION:int = 98026;
      
      public static var BUILD_PATCH:int = 0;
      
      public static const BUILD_DATE:String = "Sep 14, 2015 - 16:09:09 CEST";
       
      public function BuildInfos()
      {
         super();
      }
   }
}
