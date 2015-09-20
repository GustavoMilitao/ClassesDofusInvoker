package com.ankamagames.dofus.logic.connection.managers
{
   import com.ankamagames.jerakine.interfaces.IDestroyable;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.jerakine.utils.system.CommandLineArguments;
   import com.ankamagames.dofus.misc.utils.RpcServiceCenter;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.connection.actions.LoginValidationAsGuestAction;
   import com.ankamagames.dofus.logic.game.common.frames.ExternalGameFrame;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.types.CustomSharedObject;
   import by.blooddy.crypto.MD5;
   import flash.utils.ByteArray;
   import com.hurlant.crypto.symmetric.PKCS5;
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.ankamagames.jerakine.utils.system.AirScanner;
   import flash.external.ExternalInterface;
   import com.ankamagames.jerakine.messages.Frame;
   import flash.events.ErrorEvent;
   import flash.events.IOErrorEvent;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.dofus.logic.game.common.frames.ProtectPishingFrame;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import com.ankamagames.jerakine.utils.system.SystemManager;
   import com.ankamagames.jerakine.enum.WebBrowserEnum;
   import flash.net.URLRequestMethod;
   import flash.net.navigateToURL;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import com.ankamagames.jerakine.data.XmlConfig;
   
   public class GuestModeManager extends Object implements IDestroyable
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(GuestModeManager));
      
      private static var _self:GuestModeManager;
       
      private var _forceGuestMode:Boolean;
      
      private var _domainExtension:String;
      
      private var _locale:String;
      
      public var isLoggingAsGuest:Boolean = false;
      
      public function GuestModeManager()
      {
         super();
         if(_self != null)
         {
            throw new SingletonError("GuestModeManager is a singleton and should not be instanciated directly.");
         }
         this._forceGuestMode = false;
         this._domainExtension = RpcServiceCenter.getInstance().apiDomain.split(".").pop() as String;
         this._locale = XmlConfig.getInstance().getEntry("config.lang.current");
         if(CommandLineArguments.getInstance().hasArgument("guest"))
         {
            this._forceGuestMode = CommandLineArguments.getInstance().getArgument("guest") == "true";
         }
      }
      
      public static function getInstance() : GuestModeManager
      {
         if(_self == null)
         {
            _self = new GuestModeManager();
         }
         return _self;
      }
      
      public function get forceGuestMode() : Boolean
      {
         return this._forceGuestMode;
      }
      
      public function set forceGuestMode(param1:Boolean) : void
      {
         this._forceGuestMode = param1;
      }
      
      public function logAsGuest() : void
      {
         var _loc2_:Array = null;
         var _loc1_:Object = this.getStoredCredentials();
         if(!_loc1_)
         {
            _loc2_ = [this._locale];
            if(CommandLineArguments.getInstance().hasArgument("webParams"))
            {
               _loc2_.push(CommandLineArguments.getInstance().getArgument("webParams"));
            }
            RpcServiceCenter.getInstance().makeRpcCall(RpcServiceCenter.getInstance().apiDomain + "/ankama/guest.json","json","1.0","Create",_loc2_,this.onGuestAccountCreated,true,false);
         }
         else
         {
            Kernel.getWorker().process(LoginValidationAsGuestAction.create(_loc1_.login,_loc1_.password));
         }
      }
      
      public function convertGuestAccount() : void
      {
         var _loc2_:Object = null;
         var _loc1_:ExternalGameFrame = Kernel.getWorker().getFrame(ExternalGameFrame) as ExternalGameFrame;
         if(_loc1_)
         {
            _loc1_.getIceToken(this.onIceTokenReceived);
         }
         else
         {
            _loc2_ = UiModuleManager.getInstance().getModule("Ankama_Common").mainClass;
            _loc2_.openPopup(I18n.getUiText("ui.common.error"),I18n.getUiText("ui.secureMode.error.default"),[I18n.getUiText("ui.common.ok")]);
         }
      }
      
      public function clearStoredCredentials() : void
      {
         var _loc1_:CustomSharedObject = CustomSharedObject.getLocal("Dofus_Guest");
         if(_loc1_ && _loc1_.data)
         {
            _loc1_.data = new Object();
            _loc1_.flush();
         }
      }
      
      public function hasGuestAccount() : Boolean
      {
         return this.getStoredCredentials() != null;
      }
      
      public function destroy() : void
      {
         _self = null;
      }
      
      private function storeCredentials(param1:String, param2:String) : void
      {
         var _loc10_:* = false;
         §§push(MD5.hash(param1));
         if(!_loc10_)
         {
            §§push(§§pop());
         }
         var _loc3_:* = §§pop();
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.writeUTFBytes(_loc3_);
         var _loc5_:PKCS5 = new PKCS5();
         if(_loc9_)
         {
            _loc5_.setBlockSize(_loc6_.getBlockSize());
         }
         var _loc7_:ByteArray = new ByteArray();
         _loc7_.writeUTFBytes(param2);
         if(_loc9_)
         {
            _loc6_.encrypt(_loc7_);
         }
         if(_loc8_)
         {
            if(!_loc10_)
            {
               if(!_loc8_.data)
               {
                  if(_loc9_)
                  {
                     _loc8_.data = new Object();
                     if(_loc9_)
                     {
                        if(_loc10_)
                        {
                           addr87:
                           while(true)
                           {
                              _loc8_.data.password = _loc7_;
                              if(!_loc10_)
                              {
                                 if(_loc10_)
                                 {
                                 }
                              }
                              break;
                           }
                           if(_loc9_)
                           {
                           }
                        }
                     }
                     while(!_loc9_)
                     {
                     }
                     _loc8_.flush();
                     §§goto(addr116);
                  }
               }
               while(true)
               {
                  _loc8_.data.login = param1;
               }
            }
            while(true)
            {
               if(_loc9_)
               {
                  §§goto(addr87);
               }
               §§goto(addr114);
            }
         }
      }
      
      private function getStoredCredentials() : Object
      {
         var _loc3_:ByteArray = null;
         var _loc6_:ByteArray = null;
         var _loc8_:String = null;
         var _loc1_:CustomSharedObject = CustomSharedObject.getLocal("Dofus_Guest");
         if(!_loc10_)
         {
            §§push(_loc1_);
            if(§§dup(_loc1_))
            {
               §§pop();
               if(_loc11_)
               {
                  §§push(_loc1_.data);
               }
               addr95:
               §§push(MD5.hash(_loc1_.data.login));
               if(!_loc10_)
               {
                  §§push(§§pop());
               }
               addr104:
               addr104:
               if(_loc10_)
               {
                  loop0:
                  while(true)
                  {
                     §§push(_loc7_);
                     §§push(0);
                     if(!_loc11_)
                     {
                        §§push(-(§§pop() + 1 - 79 - 106) + 1 + 1 + 70);
                     }
                     §§pop().position = §§pop();
                     if(_loc11_)
                     {
                        if(_loc10_)
                        {
                           loop1:
                           while(true)
                           {
                              _loc6_ = _loc1_.data.password as ByteArray;
                              if(!_loc10_)
                              {
                                 loop2:
                                 while(true)
                                 {
                                    new ByteArray().writeBytes(_loc6_);
                                    if(!_loc10_)
                                    {
                                       if(_loc10_)
                                       {
                                          loop3:
                                          while(true)
                                          {
                                             _loc3_.writeUTFBytes(_loc2_);
                                             if(_loc11_)
                                             {
                                                if(_loc10_)
                                                {
                                                }
                                                loop4:
                                                while(true)
                                                {
                                                   if(_loc10_)
                                                   {
                                                      addr184:
                                                      while(true)
                                                      {
                                                         §§push(_loc7_.readUTFBytes(_loc7_.length));
                                                         if(_loc11_)
                                                         {
                                                            if(!_loc10_)
                                                            {
                                                               if(!_loc10_)
                                                               {
                                                                  if(_loc10_)
                                                                  {
                                                                  }
                                                               }
                                                               else
                                                               {
                                                                  break;
                                                               }
                                                            }
                                                         }
                                                         else
                                                         {
                                                            addr245:
                                                            while(true)
                                                            {
                                                               _loc8_ = §§pop();
                                                            }
                                                         }
                                                      }
                                                      while(true)
                                                      {
                                                         if(_loc11_)
                                                         {
                                                            continue loop0;
                                                         }
                                                      }
                                                   }
                                                   while(!_loc10_)
                                                   {
                                                      _loc4_.setBlockSize(_loc5_.getBlockSize());
                                                      if(_loc11_)
                                                      {
                                                         if(!_loc11_)
                                                         {
                                                            continue loop4;
                                                         }
                                                         break loop4;
                                                      }
                                                   }
                                                   continue loop2;
                                                }
                                                continue loop1;
                                             }
                                             addr267:
                                             while(true)
                                             {
                                                if(!_loc11_)
                                                {
                                                   break loop3;
                                                }
                                                continue loop3;
                                             }
                                          }
                                          return null;
                                       }
                                       addr251:
                                       while(true)
                                       {
                                          _loc5_.decrypt(_loc7_);
                                          §§goto(addr254);
                                       }
                                    }
                                 }
                              }
                              return {
                                 "login":_loc8_,
                                 "password":_loc9_
                              };
                           }
                        }
                        while(true)
                        {
                           §§goto(addr245);
                        }
                     }
                     while(true)
                     {
                        if(_loc10_)
                        {
                           §§goto(addr251);
                        }
                        §§goto(addr184);
                     }
                  }
               }
               while(true)
               {
                  _loc3_ = new ByteArray();
                  §§goto(addr267);
               }
            }
            §§push(§§pop());
            if(_loc11_)
            {
               §§push(§§dup(§§pop()));
               if(_loc11_)
               {
                  if(§§pop())
                  {
                     if(!_loc10_)
                     {
                        §§pop();
                        if(_loc11_)
                        {
                           §§push(_loc1_.data.hasOwnProperty("login"));
                           if(_loc10_)
                           {
                           }
                        }
                        §§goto(addr104);
                     }
                  }
                  §§push(§§dup(§§pop()));
               }
               if(§§pop())
               {
                  if(!_loc10_)
                  {
                     §§pop();
                     if(_loc11_)
                     {
                     }
                     §§goto(addr104);
                  }
               }
            }
            addr92:
            if(§§pop())
            {
               if(_loc11_)
               {
                  §§goto(addr95);
               }
               §§goto(addr104);
            }
            §§goto(addr272);
         }
         §§goto(addr92);
      }
      
      private function onGuestAccountCreated(param1:Boolean, param2:*, param3:*) : void
      {
         var _loc4_:* = false;
         var _loc5_:* = true;
         §§push(_log);
         §§push("onGuestAccountCreated - ");
         if(_loc5_)
         {
            §§push(§§pop() + param1);
         }
         §§pop().debug(§§pop());
         §§push(param1);
         if(_loc5_)
         {
            if(§§pop())
            {
               if(_loc5_)
               {
                  if(param2.error)
                  {
                     this.onGuestAccountError(param2.error);
                  }
                  else
                  {
                     this.storeCredentials(param2.login,param2.password);
                     §§push(AirScanner.isStreamingVersion());
                     if(_loc5_)
                     {
                        §§push(§§pop());
                        if(!_loc4_)
                        {
                           if(§§dup(§§pop()))
                           {
                              if(_loc4_)
                              {
                              }
                           }
                        }
                     }
                     §§pop();
                     §§push(ExternalInterface.available);
                  }
               }
               addr82:
            }
            else
            {
               this.onGuestAccountError(param2);
            }
            addr86:
            return;
         }
         if(§§pop())
         {
            ExternalInterface.call("onGuestAccountCreated");
         }
         Kernel.getWorker().process(LoginValidationAsGuestAction.create(param2.login,param2.password));
         if(!_loc4_)
         {
            §§goto(addr82);
         }
         §§goto(addr86);
      }
      
      private function onGuestAccountError(param1:*) : void
      {
         var _loc10_:* = true;
         var _loc4_:Frame = null;
         if(!_loc9_)
         {
            _log.error(param1);
         }
         var _loc2_:Object = UiModuleManager.getInstance().getModule("Ankama_Common").mainClass;
         §§push(param1 is ErrorEvent);
         §§push(§§dup(param1 is ErrorEvent));
         if(_loc10_)
         {
            if(§§pop())
            {
               §§pop();
               if(_loc10_)
               {
                  §§push(param1.type == IOErrorEvent.NETWORK_ERROR);
               }
               addr59:
               addr128:
               _loc2_.openPopup(I18n.getUiText("ui.common.error"),I18n.getUiText("ui.connection.guestAccountCreationTimedOut"),[I18n.getUiText("ui.common.ok")]);
               loop0:
               while(true)
               {
                  §§push(KernelEventsManager.getInstance());
                  §§push(HookList.IdentificationFailed);
                  §§push(0);
                  if(_loc9_)
                  {
                     §§push((--§§pop() - 1) * 56 + 40);
                  }
                  §§pop().processCallback(§§pop(),§§pop());
                  if(_loc10_)
                  {
                     if(_loc9_)
                     {
                        addr155:
                        while(true)
                        {
                           _loc2_.openPopup(I18n.getUiText("ui.common.error"),_loc3_,[I18n.getUiText("ui.common.ok")]);
                           if(!_loc9_)
                           {
                              if(_loc10_)
                              {
                                 addr127:
                                 while(true)
                                 {
                                    continue loop0;
                                 }
                              }
                           }
                           break loop0;
                        }
                     }
                     if(this._forceGuestMode)
                     {
                        if(_loc10_)
                        {
                        }
                        this._forceGuestMode = false;
                        break;
                     }
                     addr289:
                     return;
                  }
                  break;
               }
               if(Kernel.getWorker().contains(ProtectPishingFrame))
               {
                  if(_loc10_)
                  {
                     _log.error("Oh oh ! ProtectPishingFrame is still here, it shoudln\'t be. Who else is in here ?");
                     §§push(0);
                     if(_loc9_)
                     {
                        §§push(-((§§pop() - 1) * 12) * 0 - 90 + 79);
                     }
                     if(!_loc9_)
                     {
                        if(!_loc9_)
                        {
                           while(§§hasnext(Kernel.getWorker().framesList,_loc7_))
                           {
                              if(!_loc10_)
                              {
                                 addr222:
                                 while(true)
                                 {
                                    §§push(getQualifiedClassName(_loc4_));
                                    if(_loc10_)
                                    {
                                       §§push(_loc5_);
                                    }
                                    if(!_loc9_)
                                    {
                                       if(_loc9_)
                                       {
                                       }
                                       addr256:
                                       §§push(_log);
                                       §§push(" - ");
                                       if(_loc10_)
                                       {
                                          §§push(§§pop() + _loc6_[_loc6_.length - 1]);
                                       }
                                       §§pop().error(§§pop());
                                       break;
                                    }
                                    break;
                                 }
                                 if(_loc9_)
                                 {
                                 }
                                 continue;
                              }
                              while(true)
                              {
                                 _loc4_ = §§nextvalue(_loc7_,_loc8_);
                                 if(!_loc9_)
                                 {
                                    if(!_loc10_)
                                    {
                                       §§goto(addr256);
                                    }
                                    else
                                    {
                                       §§goto(addr222);
                                    }
                                 }
                                 §§goto(addr267);
                              }
                           }
                        }
                     }
                     Kernel.getWorker().removeFrame(Kernel.getWorker().getFrame(ProtectPishingFrame));
                  }
                  §§goto(addr289);
               }
               KernelEventsManager.getInstance().processCallback(HookList.AuthentificationStart);
               §§goto(addr289);
            }
            §§push(§§dup(§§pop()));
         }
         if(!§§pop())
         {
            §§pop();
            §§push(param1 is IOErrorEvent);
         }
         if(§§pop())
         {
            §§goto(addr59);
         }
         else if(param1 is String)
         {
            _loc2_.openPopup(I18n.getUiText("ui.common.error"),param1,[I18n.getUiText("ui.common.ok")]);
            §§goto(addr128);
         }
         else
         {
            §§push(I18n.getUiText("ui.secureMode.error.default"));
            if(_loc10_)
            {
               §§push(§§pop());
               if(_loc10_)
               {
                  §§push(param1 is ErrorEvent);
                  if(!_loc9_)
                  {
                     if(§§pop())
                     {
                        §§push(_loc3_);
                        if(!_loc9_)
                        {
                           §§push(" (#");
                           if(!_loc9_)
                           {
                              §§push(§§pop() + (param1 as ErrorEvent).errorID);
                              if(_loc10_)
                              {
                              }
                              addr119:
                              §§push(§§pop() + §§pop());
                           }
                           §§goto(addr119);
                           §§push(§§pop() + ")");
                        }
                     }
                  }
                  §§goto(addr184);
               }
            }
            if(!_loc10_)
            {
               §§goto(addr127);
            }
         }
         §§goto(addr155);
      }
      
      private function onIceTokenReceived(param1:String) : void
      {
         var _loc6_:* = false;
         var _loc7_:* = true;
         var _loc4_:Object = null;
         var _loc5_:URLRequest = null;
         if(!_loc6_)
         {
            if(param1)
            {
               §§push("http://go.ankama.");
               if(!_loc6_)
               {
                  §§push(this._domainExtension);
                  if(!_loc6_)
                  {
                     §§push(§§pop() + §§pop());
                     if(!_loc6_)
                     {
                        §§push("/");
                        if(_loc7_)
                        {
                           §§push(§§pop() + §§pop());
                           if(_loc6_)
                           {
                           }
                           addr67:
                           §§push("/go/dofus/complete-guest");
                        }
                        addr69:
                        var _loc3_:URLVariables = new URLVariables();
                        if(_loc7_)
                        {
                           _loc3_.key = param1;
                           if(_loc7_)
                           {
                              §§push(SystemManager.getSingleton().browser == WebBrowserEnum.CHROME);
                              if(_loc7_)
                              {
                                 if(§§dup(§§pop()))
                                 {
                                    if(_loc7_)
                                    {
                                    }
                                 }
                                 addr107:
                                 if(§§pop())
                                 {
                                    if(_loc7_)
                                    {
                                    }
                                    addr120:
                                 }
                                 else
                                 {
                                    _loc5_ = new URLRequest(_loc2_);
                                    _loc5_.method = URLRequestMethod.GET;
                                    if(_loc7_)
                                    {
                                       if(_loc6_)
                                       {
                                          addr138:
                                          while(true)
                                          {
                                             navigateToURL(_loc5_,"_blank");
                                             if(_loc7_)
                                             {
                                                if(_loc6_)
                                                {
                                                }
                                                break;
                                             }
                                          }
                                       }
                                       while(true)
                                       {
                                          _loc5_.data = _loc3_;
                                       }
                                    }
                                    while(true)
                                    {
                                       if(_loc7_)
                                       {
                                          §§goto(addr138);
                                       }
                                    }
                                 }
                                 return;
                              }
                              §§pop();
                              if(_loc7_)
                              {
                              }
                              §§goto(addr120);
                           }
                           ExternalInterface.call("window.open",_loc2_ + "?" + _loc3_.toString(),"_blank");
                           §§goto(addr120);
                        }
                        §§goto(addr107);
                        §§push(ExternalInterface.available);
                     }
                  }
                  addr64:
                  §§push(§§pop() + §§pop());
                  if(_loc7_)
                  {
                     §§goto(addr67);
                  }
                  §§goto(addr69);
               }
               §§goto(addr64);
               §§push(this._locale);
            }
         }
         _loc4_ = UiModuleManager.getInstance().getModule("Ankama_Common").mainClass;
         _loc4_.openPopup(I18n.getUiText("ui.common.error"),I18n.getUiText("ui.secureMode.error.default"),[I18n.getUiText("ui.common.ok")]);
      }
   }
}
