package com.ankamagames.jerakine.network.messages
{
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.jerakine.messages.ILogableMessage;
   
   public class ExpectedSocketClosureMessage extends Object implements Message, ILogableMessage
   {
       
      public var reason:uint;
      
      public function ExpectedSocketClosureMessage(param1:uint = 0)
      {
         super();
         this.reason = param1;
      }
   }
}
