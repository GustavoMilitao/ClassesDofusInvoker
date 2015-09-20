package com.ankamagames.dofus.logic.game.common.frames
{
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.logger.Logger;
   import flash.filesystem.File;
   import com.ankamagames.jerakine.utils.system.SystemManager;
   import com.ankamagames.jerakine.enum.OperatingSystem;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.display.BitmapData;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import flash.events.Event;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.dofus.logic.game.common.actions.CaptureScreenWithoutUIAction;
   import com.ankamagames.dofus.logic.game.common.actions.ChangeScreenshotsDirectoryAction;
   import com.ankamagames.dofus.logic.game.common.actions.CaptureScreenAction;
   import com.ankamagames.jerakine.types.enums.Priority;
   import com.ankamagames.jerakine.managers.OptionManager;
   import com.ankamagames.jerakine.data.I18n;
   import flash.filesystem.FileStream;
   import com.ankamagames.dofus.logic.game.common.managers.TimeManager;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import flash.filesystem.FileMode;
   import flash.utils.Dictionary;
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.ankamagames.dofus.console.moduleLogger.ModuleDebugManager;
   import com.ankamagames.dofus.uiApi.CaptureApi;
   import flash.geom.Rectangle;
   import flash.desktop.Clipboard;
   import flash.desktop.ClipboardFormats;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.ChatHookList;
   import com.ankamagames.dofus.network.enums.ChatActivableChannelsEnum;
   import com.ankamagames.berilia.types.data.UiModule;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.berilia.enums.StrataEnum;
   
   public class ScreenCaptureFrame extends Object implements Frame
   {
      
      private static const _log:Logger = Log.getLogger(getQualifiedClassName(ScreenCaptureFrame));
      
      private static const MAP_HEIGHT:uint = 886;
       
      private var _lastClipboardBitmap:BitmapData;
      
      private var _encoder:PNGEncoder2;
      
      private var _capturing:Boolean;
      
      private var _captureCount:uint = 1;
      
      public function ScreenCaptureFrame()
      {
         super();
      }
      
      public static function getDefaultDirectory() : String
      {
         var _loc1_:String = null;
         switch(SystemManager.getSingleton().os)
         {
            case OperatingSystem.WINDOWS:
            case OperatingSystem.MAC_OS:
               _loc1_ = File.userDirectory.nativePath + File.separator + "Pictures";
               break;
            case OperatingSystem.LINUX:
               _loc1_ = File.userDirectory.nativePath + File.separator + "Images";
               break;
         }
         var _loc2_:File = new File(_loc1_);
         if(!_loc2_.exists)
         {
            _loc1_ = File.documentsDirectory.nativePath + File.separator + "Dofus" + File.separator + "screenshots";
         }
         return _loc1_;
      }
      
      public function pushed() : Boolean
      {
         PNGEncoder2.level = CompressionLevel.UNCOMPRESSED;
         if(StageShareManager.isActive)
         {
            this.onActivate(null);
         }
         StageShareManager.stage.addEventListener(Event.ACTIVATE,this.onActivate);
         return true;
      }
      
      public function pulled() : Boolean
      {
         StageShareManager.stage.removeEventListener(Event.ACTIVATE,this.onActivate);
         return true;
      }
      
      public function process(param1:Message) : Boolean
      {
         switch(true)
         {
            case param1 is ChangeScreenshotsDirectoryAction:
               this.selectDirectory();
               return true;
            case param1 is CaptureScreenAction:
            case param1 is CaptureScreenWithoutUIAction:
               if(!this._capturing)
               {
                  this._capturing = true;
                  this.captureScreen(param1 is CaptureScreenWithoutUIAction);
                  this.updateClipboardBitmap();
               }
               return true;
            default:
               return false;
         }
      }
      
      public function get priority() : int
      {
         return Priority.NORMAL;
      }
      
      private function selectDirectory() : void
      {
         var _loc1_:String = OptionManager.getOptionManager("dofus")["screenshotsDirectory"];
         if(!_loc1_)
         {
            _loc1_ = getDefaultDirectory();
         }
         var _loc2_:File = new File(_loc1_);
         _loc2_.addEventListener(Event.SELECT,this.onFileSelect);
         _loc2_.browseForDirectory(I18n.getUiText("ui.gameuicore.screenshot.changeDirectory"));
      }
      
      private function onSaveFile(param1:Event) : void
      {
         var _loc3_:File = null;
         var _loc4_:Date = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:FileStream = null;
         var _loc9_:* = 0;
         var _loc10_:String = null;
         this._encoder.removeEventListener(Event.COMPLETE,this.onSaveFile);
         var _loc2_:String = OptionManager.getOptionManager("dofus")["screenshotsDirectory"];
         if(!_loc2_)
         {
            _loc2_ = getDefaultDirectory();
         }
         if(this.checkWritePermissions(_loc2_))
         {
            _loc4_ = new Date();
            _loc5_ = TimeManager.getInstance().formatDateIRL(_loc4_.time).split("/");
            _loc6_ = TimeManager.getInstance().formatClock(_loc4_.time) + ":" + (_loc4_.seconds < 10?"0" + _loc4_.seconds:_loc4_.seconds);
            _loc7_ = "dofus-" + _loc5_[2] + "-" + _loc5_[1] + "-" + _loc5_[0] + "_" + _loc6_.replace(new RegExp(":","g"),"-") + "-" + PlayedCharacterManager.getInstance().infos.name + ".png";
            _loc8_ = new FileStream();
            _loc3_ = new File(_loc2_).resolvePath(_loc7_);
            if(_loc3_.exists)
            {
               this._captureCount++;
               _loc9_ = _loc7_.lastIndexOf("-");
               _loc10_ = _loc7_.substring(0,_loc9_) + "_" + this._captureCount + _loc7_.substring(_loc9_);
               _loc3_ = new File(_loc2_).resolvePath(_loc10_);
            }
            else
            {
               this._captureCount = 1;
            }
            _loc8_.open(_loc3_,FileMode.WRITE);
            _loc8_.writeBytes(this._encoder.png);
            _loc8_.close();
            this.displayChatMessage(_loc3_);
            this._capturing = false;
            PNGEncoder2.freeCachedMemory();
            this.updateClipboardBitmap();
         }
      }
      
      private function captureScreen(param1:Boolean = false) : void
      {
         var _loc2_:BitmapData = null;
         var _loc3_:Dictionary = null;
         var _loc4_:* = undefined;
         var _loc5_:* = false;
         var _loc6_:Vector.<String> = null;
         if(param1)
         {
            _loc3_ = Berilia.getInstance().uiList;
            _loc6_ = new Vector.<String>(0);
            for(_loc4_ in _loc3_)
            {
               if((_loc4_ as String).indexOf("tooltip_entity") == -1)
               {
                  if(_loc3_[_loc4_].visible)
                  {
                     _loc3_[_loc4_].visible = false;
                     _loc6_.push(_loc4_);
                  }
               }
            }
            if(XmlConfig.getInstance().getBooleanEntry("config.dev.mode") && XmlConfig.getInstance().getBooleanEntry("config.dev.auto.display.controler"))
            {
               _loc5_ = true;
               ModuleDebugManager.display(false);
            }
            _loc2_ = CaptureApi.getScreen(new Rectangle(0,0,StageShareManager.startWidth,MAP_HEIGHT));
            for each(_loc4_ in _loc6_)
            {
               _loc3_[_loc4_].visible = true;
            }
            if(_loc5_)
            {
               ModuleDebugManager.display(true);
            }
         }
         else
         {
            _loc2_ = CaptureApi.getScreen();
         }
         this._encoder = PNGEncoder2.encodeAsync(_loc2_);
         this._encoder.addEventListener(Event.COMPLETE,this.onSaveFile);
      }
      
      private function updateClipboardBitmap() : void
      {
         if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.BITMAP_FORMAT))
         {
            this._lastClipboardBitmap = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData;
         }
      }
      
      private function displayChatMessage(param1:File) : void
      {
         KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,"{system," + param1.parent.nativePath + "::" + I18n.getUiText("ui.gameuicore.screenshot",[param1.nativePath]) + "}",ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp(),false);
      }
      
      private function checkWritePermissions(param1:String) : Boolean
      {
         var success:Boolean = false;
         var fs:FileStream = null;
         var f:File = null;
         var mod:UiModule = null;
         var pPath:String = param1;
         try
         {
            fs = new FileStream();
            f = new File(pPath).resolvePath("foo.bar");
            fs.open(f,FileMode.WRITE);
            success = true;
         }
         catch(e:Error)
         {
            mod = UiModuleManager.getInstance().getModule("Ankama_Common");
            Berilia.getInstance().loadUi(mod,mod.uis["popup"],"screenshot_error_popup",{
               "title":I18n.getUiText("ui.common.error"),
               "content":I18n.getUiText("ui.gameuicore.screenshot.changeDirectory.error"),
               "buttonText":[I18n.getUiText("ui.common.ok")],
               "buttonCallback":[selectDirectory],
               "onEnterKey":selectDirectory
            },false,StrataEnum.STRATA_TOP);
         }
         if(success)
         {
            fs.close();
            f.deleteFile();
         }
         return success;
      }
      
      private function onFileSelect(param1:Event) : void
      {
         var _loc2_:File = param1.currentTarget as File;
         _loc2_.removeEventListener(Event.SELECT,this.onFileSelect);
         if(this.checkWritePermissions(_loc2_.nativePath))
         {
            OptionManager.getOptionManager("dofus")["screenshotsDirectory"] = _loc2_.nativePath;
         }
      }
      
      private function onActivate(param1:Event) : void
      {
         this.updateClipboardBitmap();
      }
   }
}
