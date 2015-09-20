package com.ankamagames.berilia.factories
{
   import flash.utils.Dictionary;
   import flash.text.StyleSheet;
   import flash.events.EventDispatcher;
   import flash.text.TextField;
   import flash.events.TextEvent;
   import com.ankamagames.berilia.events.LinkInteractionEvent;
   import com.ankamagames.berilia.managers.HtmlManager;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.ankamagames.jerakine.utils.display.FrameIdManager;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.berilia.frames.ShortcutsFrame;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.berilia.utils.BeriliaHookList;
   import flash.utils.Timer;
   import flash.events.TimerEvent;
   
   public class HyperlinkFactory extends Object
   {
      
      private static var LEFT:String = "{";
      
      private static var RIGHT:String = "}";
      
      private static var SEPARATOR:String = "::";
      
      private static var PROTOCOL:Dictionary = new Dictionary();
      
      private static var PROTOCOL_TEXT:Dictionary = new Dictionary();
      
      private static var PROTOCOL_SHIFT:Dictionary = new Dictionary();
      
      private static var PROTOCOL_BOLD:Dictionary = new Dictionary();
      
      private static var PROTOCOL_ROLL_OVER:Dictionary = new Dictionary();
      
      private static var staticStyleSheet:StyleSheet;
      
      public static var lastClickEventFrame:uint;
      
      private static var _rollOverTimer:Timer;
      
      private static var _rollOverData:String;
       
      public function HyperlinkFactory()
      {
         super();
      }
      
      public static function protocolIsRegister(param1:String) : Boolean
      {
         return PROTOCOL[param1]?true:false;
      }
      
      public static function textProtocolIsRegister(param1:String) : Boolean
      {
         return PROTOCOL_TEXT[param1]?true:false;
      }
      
      public static function shiftProtocolIsRegister(param1:String) : Boolean
      {
         return PROTOCOL_SHIFT[param1]?true:false;
      }
      
      public static function boldProtocolIsRegister(param1:String) : Boolean
      {
         return PROTOCOL_BOLD[param1]?true:false;
      }
      
      public static function createTextClickHandler(param1:EventDispatcher, param2:Boolean = false) : void
      {
         var _loc3_:TextField = null;
         if(param1 is TextField)
         {
            _loc3_ = param1 as TextField;
            _loc3_.htmlText = decode(_loc3_.htmlText,true,param2?_loc3_:null);
            _loc3_.mouseEnabled = true;
         }
         param1.addEventListener(TextEvent.LINK,processClick);
      }
      
      public static function createRollOverHandler(param1:EventDispatcher) : void
      {
         param1.addEventListener(LinkInteractionEvent.ROLL_OVER,processRollOver);
         param1.addEventListener(LinkInteractionEvent.ROLL_OUT,processRollOut);
      }
      
      public static function activeSmallHyperlink(param1:TextField) : void
      {
         param1.addEventListener(TextEvent.LINK,processClick);
      }
      
      public static function decode(param1:String, param2:Boolean = true, param3:TextField = null) : String
      {
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Array = null;
         var _loc12_:String = null;
         var _loc13_:Array = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:String = null;
         var _loc17_:* = 0;
         var _loc18_:* = 0;
         var _loc19_:String = null;
         var _loc20_:Function = null;
         var _loc21_:* = false;
         var _loc22_:StyleSheet = null;
         var _loc4_:String = param1;
         while(true)
         {
            _loc5_ = _loc4_.indexOf(LEFT);
            if(_loc5_ == -1)
            {
               break;
            }
            _loc6_ = _loc4_.indexOf(RIGHT);
            if(_loc6_ == -1)
            {
               break;
            }
            if(_loc5_ > _loc6_)
            {
               break;
            }
            _loc7_ = _loc4_.substring(0,_loc5_);
            _loc8_ = _loc4_.substring(_loc6_ + 1);
            _loc9_ = _loc4_.substring(_loc5_,_loc6_);
            _loc11_ = _loc9_.split("::");
            _loc12_ = _loc11_[0].substr(1);
            _loc13_ = _loc12_.split(",");
            _loc14_ = _loc13_.shift();
            _loc18_ = _loc13_.length;
            _loc17_ = 0;
            while(_loc17_ < _loc18_)
            {
               _loc19_ = _loc13_[_loc17_];
               if(_loc19_.indexOf("linkColor") != -1)
               {
                  _loc15_ = _loc19_.split(":")[1];
                  _loc13_.splice(_loc17_,1);
                  _loc17_--;
                  _loc18_--;
               }
               if(_loc19_.indexOf("hoverColor") != -1)
               {
                  _loc16_ = _loc19_.split(":")[1];
                  _loc13_.splice(_loc17_,1);
                  _loc17_--;
                  _loc18_--;
               }
               _loc17_++;
            }
            if(_loc15_ || _loc16_)
            {
               _loc12_ = _loc14_ + "," + _loc13_.join(",");
            }
            if(_loc11_.length == 1)
            {
               _loc20_ = PROTOCOL_TEXT[_loc14_];
               if(_loc20_ != null)
               {
                  _loc11_.push(_loc20_.apply(_loc20_,_loc13_));
               }
            }
            if(param2)
            {
               _loc10_ = _loc11_[1];
               if(PROTOCOL_BOLD[_loc14_])
               {
                  _loc10_ = HtmlManager.addTag(_loc10_,HtmlManager.BOLD);
               }
               _loc4_ = _loc7_;
               _loc4_ = _loc4_ + HtmlManager.addLink(_loc10_,"event:" + _loc12_,null,true);
               _loc4_ = _loc4_ + _loc8_;
               if(param3)
               {
                  _loc21_ = _loc15_ || _loc16_;
                  if(!_loc15_)
                  {
                     _loc15_ = XmlConfig.getInstance().getEntry("colors.hyperlink.link");
                     _loc15_ = _loc15_.replace("0x","#");
                  }
                  if(!_loc16_)
                  {
                     _loc16_ = XmlConfig.getInstance().getEntry("colors.hyperlink.hover");
                     _loc16_ = _loc16_.replace("0x","#");
                  }
                  if(!_loc21_)
                  {
                     if(!staticStyleSheet)
                     {
                        staticStyleSheet = new StyleSheet();
                     }
                     _loc22_ = staticStyleSheet;
                  }
                  else
                  {
                     _loc22_ = new StyleSheet();
                  }
                  if(_loc22_.styleNames.length == 0)
                  {
                     _loc22_.setStyle("a:link",{"color":_loc15_});
                     _loc22_.setStyle("a:hover",{"color":_loc16_});
                  }
                  param3.styleSheet = _loc22_;
               }
            }
            else
            {
               _loc10_ = _loc11_.length == 2?_loc11_[1]:"";
               _loc4_ = _loc7_ + _loc10_ + _loc8_;
            }
         }
         return _loc4_;
      }
      
      public static function registerProtocol(param1:String, param2:Function, param3:Function = null, param4:Function = null, param5:Boolean = true, param6:Function = null) : void
      {
         PROTOCOL[param1] = param2;
         if(param3 != null)
         {
            PROTOCOL_TEXT[param1] = param3;
         }
         if(param4 != null)
         {
            PROTOCOL_SHIFT[param1] = param4;
         }
         if(param5)
         {
            PROTOCOL_BOLD[param1] = true;
         }
         if(param6 != null)
         {
            PROTOCOL_ROLL_OVER[param1] = param6;
         }
      }
      
      public static function processClick(param1:TextEvent) : void
      {
         var _loc3_:Function = null;
         var _loc4_:Function = null;
         lastClickEventFrame = FrameIdManager.frameId;
         StageShareManager.stage.focus = StageShareManager.stage;
         var _loc2_:Array = param1.text.split(",");
         if(ShortcutsFrame.shiftKey)
         {
            _loc3_ = PROTOCOL_SHIFT[_loc2_[0]];
            if(_loc3_ == null)
            {
               KernelEventsManager.getInstance().processCallback(BeriliaHookList.ChatHyperlink,"{" + _loc2_.join(",") + "}");
            }
            else
            {
               _loc2_.shift();
               _loc3_.apply(null,_loc2_);
            }
         }
         else
         {
            _loc4_ = PROTOCOL[_loc2_.shift()];
            if(_loc4_ != null)
            {
               _loc4_.apply(null,_loc2_);
            }
         }
      }
      
      public static function processRollOver(param1:LinkInteractionEvent) : void
      {
         if(_rollOverTimer == null)
         {
            _rollOverTimer = new Timer(800,1);
            _rollOverTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onRollOverTimerComplete);
         }
         else
         {
            _rollOverTimer.reset();
         }
         _rollOverData = param1.text;
         _rollOverTimer.start();
      }
      
      public static function processRollOut(param1:LinkInteractionEvent) : void
      {
         if(_rollOverTimer != null)
         {
            _rollOverTimer.reset();
         }
         _rollOverData = null;
      }
      
      private static function onRollOverTimerComplete(param1:TimerEvent) : void
      {
         if(_rollOverData == null)
         {
            return;
         }
         _rollOverTimer.stop();
         var _loc2_:Array = _rollOverData.split(",");
         _loc2_[1] = StageShareManager.stage.mouseX;
         var _loc3_:Function = PROTOCOL_ROLL_OVER[_loc2_.shift()];
         if(_loc3_ != null)
         {
            _loc3_.apply(null,_loc2_);
         }
      }
   }
}
