package com.ankamagames.atouin.data.elements
{
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.utils.IDataInput;
   import com.ankamagames.jerakine.utils.errors.AbstractMethodCallError;
   
   public class GraphicalElementData extends Object
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(GraphicalElementData));
       
      public var id:int;
      
      public var type:int;
      
      public function GraphicalElementData(param1:int, param2:int)
      {
         super();
         this.id = param1;
         this.type = param2;
      }
      
      public function fromRaw(param1:IDataInput, param2:int) : void
      {
         throw new AbstractMethodCallError();
      }
   }
}
