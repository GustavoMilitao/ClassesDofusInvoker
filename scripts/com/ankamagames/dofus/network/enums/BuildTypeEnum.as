package com.ankamagames.dofus.network.enums
{
   [Trusted]
   public class BuildTypeEnum extends Object
   {
      
      public static const RELEASE:uint = 0;
      
      public static const BETA:uint = 1;
      
      public static const ALPHA:uint = 2;
      
      public static const TESTING:uint = 3;
      
      public static const INTERNAL:uint = 4;
      
      public static const DEBUG:uint = 5;
      
      public static const EXPERIMENTAL:uint = 6;
       
      public function BuildTypeEnum()
      {
         super();
      }
   }
}
