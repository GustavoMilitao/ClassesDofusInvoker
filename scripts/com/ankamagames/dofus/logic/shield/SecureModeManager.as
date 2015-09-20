package com.ankamagames.dofus.logic.shield
{
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.utils.Timer;
   import flash.utils.Dictionary;
   import com.ankamagames.dofus.misc.utils.RpcServiceManager;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.dofus.network.types.secure.TrustCertificate;
   import com.ankamagames.dofus.logic.connection.managers.AuthentificationManager;
   import com.ankamagames.dofus.BuildInfos;
   import com.ankamagames.dofus.network.enums.BuildTypeEnum;
   import com.ankamagames.dofus.types.events.RpcEvent;
   import com.ankamagames.jerakine.data.I18n;
   import flash.filesystem.File;
   import com.ankamagames.jerakine.types.CustomSharedObject;
   import flash.filesystem.FileStream;
   import by.blooddy.crypto.MD5;
   import flash.filesystem.FileMode;
   import com.ankamagames.jerakine.managers.ErrorManager;
   import com.ankamagames.jerakine.managers.StoreDataManager;
   import com.ankamagames.dofus.Constants;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   
   public class SecureModeManager extends Object
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(SecureModeManager));
      
      private static const VALIDATECODE_CODEEXPIRE:String = "CODEEXPIRE";
      
      private static const VALIDATECODE_CODEBADCODE:String = "CODEBADCODE";
      
      private static const VALIDATECODE_CODENOTFOUND:String = "CODENOTFOUND";
      
      private static const VALIDATECODE_SECURITY:String = "SECURITY";
      
      private static const VALIDATECODE_TOOMANYCERTIFICATE:String = "TOOMANYCERTIFICATE";
      
      private static const VALIDATECODE_NOTAVAILABLE:String = "NOTAVAILABLE";
      
      private static const ACCOUNT_AUTHENTIFICATION_FAILED:String = "ACCOUNT_AUTHENTIFICATION_FAILED";
      
      private static var RPC_URL:String;
      
      private static const RPC_METHOD_SECURITY_CODE:String = "SecurityCode";
      
      private static const RPC_METHOD_VALIDATE_CODE:String = "ValidateCode";
      
      private static const RPC_METHOD_MIGRATE:String = "Migrate";
      
      private static var _self:SecureModeManager;
       
      private var _timeout:Timer;
      
      private var _active:Boolean;
      
      private var _computerName:String;
      
      private var _methodsCallback:Dictionary;
      
      private var _hasV1Certif:Boolean;
      
      private var _rpcManager:RpcServiceManager;
      
      public var shieldLevel:uint;
      
      public function SecureModeManager()
      {
         this._timeout = new Timer(30000);
         this._methodsCallback = new Dictionary();
         this.shieldLevel = StoreDataManager.getInstance().getSetData(Constants.DATASTORE_COMPUTER_OPTIONS,"shieldLevel",ShieldSecureLevel.MEDIUM);
         super();
         if(_self)
         {
            throw new SingletonError();
         }
         this.initRPC();
      }
      
      public static function getInstance() : SecureModeManager
      {
         if(!_self)
         {
            _self = new SecureModeManager();
         }
         return _self;
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(param1:Boolean) : void
      {
         this._active = param1;
         KernelEventsManager.getInstance().processCallback(HookList.SecureModeChange,param1);
      }
      
      public function get computerName() : String
      {
         return this._computerName;
      }
      
      public function set computerName(param1:String) : void
      {
         this._computerName = param1;
      }
      
      public function get certificate() : TrustCertificate
      {
         return this.retreiveCertificate();
      }
      
      public function askCode(param1:Function) : void
      {
         this._methodsCallback[RPC_METHOD_SECURITY_CODE] = param1;
         this._rpcManager.callMethod(RPC_METHOD_SECURITY_CODE,[this.getUsername(),AuthentificationManager.getInstance().ankamaPortalKey,1]);
      }
      
      public function sendCode(param1:String, param2:Function) : void
      {
         var _loc3_:ShieldCertifcate = new ShieldCertifcate();
         _loc3_.secureLevel = this.shieldLevel;
         this._methodsCallback[RPC_METHOD_VALIDATE_CODE] = param2;
         this._rpcManager.callMethod(RPC_METHOD_VALIDATE_CODE,[this.getUsername(),AuthentificationManager.getInstance().ankamaPortalKey,1,param1.toUpperCase(),_loc3_.hash,_loc3_.reverseHash,this._computerName?true:false,this._computerName?this._computerName:""]);
      }
      
      private function initRPC() : void
      {
         var _loc2_:* = false;
         §§push(BuildInfos.BUILD_TYPE);
         if(!_loc2_)
         {
            §§push(BuildTypeEnum.DEBUG);
            if(!_loc2_)
            {
               §§push(§§pop() == §§pop());
               if(_loc1_)
               {
                  if(!§§dup(§§pop()))
                  {
                     if(_loc1_)
                     {
                     }
                  }
                  addr41:
                  if(§§pop())
                  {
                     RPC_URL = "http://api.ankama.tst/ankama/shield.json";
                  }
                  else
                  {
                     §§push(BuildInfos.BUILD_TYPE);
                  }
                  addr100:
                  while(true)
                  {
                     this._rpcManager = new RpcServiceManager(RPC_URL,"json");
                     if(!_loc2_)
                     {
                        loop1:
                        while(true)
                        {
                           this._rpcManager.addEventListener(RpcEvent.EVENT_DATA,this.onRpcData);
                           if(_loc2_)
                           {
                              break;
                           }
                           addr70:
                           while(true)
                           {
                              this._rpcManager.addEventListener(RpcEvent.EVENT_ERROR,this.onRpcData);
                              if(!_loc1_)
                              {
                                 continue loop1;
                              }
                           }
                        }
                        continue;
                     }
                     return;
                  }
               }
               §§pop();
               §§push(BuildInfos.BUILD_TYPE);
               if(_loc1_)
               {
                  §§push(BuildTypeEnum.INTERNAL);
                  if(_loc1_)
                  {
                  }
                  addr50:
                  if(§§pop() == §§pop())
                  {
                     if(!_loc2_)
                     {
                        RPC_URL = "http://api.ankama.lan/ankama/shield.json";
                     }
                  }
                  else
                  {
                     RPC_URL = "https://api.ankama.com/ankama/shield.json";
                     if(_loc2_)
                     {
                        §§goto(addr70);
                     }
                  }
                  §§goto(addr100);
               }
            }
            §§goto(addr41);
            §§push(§§pop() == §§pop());
         }
         §§goto(addr50);
      }
      
      private function getUsername() : String
      {
         var _loc1_:* = true;
         var _loc2_:* = false;
         §§push(AuthentificationManager.getInstance().username.toLowerCase().split("|"));
         §§push(0);
         if(!_loc1_)
         {
            §§push(§§pop() + 1 + 80 + 5);
         }
         return §§pop()[§§pop()];
      }
      
      private function parseRpcValidateResponse(param1:Object, param2:String) : Object
      {
         if(_loc6_)
         {
            _loc3_.error = param1.error;
            if(_loc6_)
            {
               if(!_loc6_)
               {
                  addr33:
                  while(true)
                  {
                     _loc3_.retry = false;
                     if(_loc6_)
                     {
                     }
                     break;
                  }
                  if(_loc6_)
                  {
                  }
                  if(VALIDATECODE_CODEEXPIRE === _loc5_)
                  {
                     §§push(0);
                     if(_loc7_)
                     {
                        §§push((§§pop() * 92 * 31 - 1 + 46 + 66) * 22);
                     }
                  }
                  else if(VALIDATECODE_CODEBADCODE === _loc5_)
                  {
                     §§push(1);
                     if(!_loc6_)
                     {
                        §§push((-§§pop() - 1 + 1 - 81) * 11);
                     }
                  }
                  else if(VALIDATECODE_CODENOTFOUND === _loc5_)
                  {
                     §§push(2);
                     if(_loc7_)
                     {
                        §§push(§§pop() * 118 * 97 * 5 * 44 + 1);
                     }
                  }
                  else if(VALIDATECODE_SECURITY === _loc5_)
                  {
                     §§push(3);
                     if(_loc7_)
                     {
                        §§push(-((§§pop() - 73 - 42) * 38 + 109 - 1 + 1));
                     }
                  }
                  else if(VALIDATECODE_TOOMANYCERTIFICATE === _loc5_)
                  {
                     §§push(4);
                     if(!_loc6_)
                     {
                        §§push(§§pop() + 1 + 49 - 1);
                     }
                  }
                  else
                  {
                     §§push(VALIDATECODE_NOTAVAILABLE);
                     if(_loc6_)
                     {
                        if(§§pop() === _loc5_)
                        {
                           §§push(5);
                           if(!_loc6_)
                           {
                              §§push(§§pop() - 55 - 1 + 7 - 9 - 32 + 1);
                           }
                        }
                        else
                        {
                           §§push(ACCOUNT_AUTHENTIFICATION_FAILED);
                        }
                     }
                     if(§§pop() === _loc5_)
                     {
                        §§push(6);
                        if(_loc7_)
                        {
                           §§push(§§pop() + 105 - 59 + 1);
                        }
                     }
                     else
                     {
                        §§push(7);
                        if(_loc7_)
                        {
                           §§push(-(-(§§pop() - 1) + 87 + 1 - 1) * 18);
                        }
                     }
                  }
                  loop21:
                  switch(§§pop())
                  {
                     case 0:
                        if(_loc7_)
                        {
                           addr71:
                           while(true)
                           {
                              _loc3_.fatal = true;
                              if(_loc7_)
                              {
                              }
                              break;
                           }
                           §§goto(addr436);
                        }
                        while(true)
                        {
                           _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.expire");
                           if(!_loc7_)
                           {
                              §§goto(addr71);
                           }
                           §§goto(addr90);
                        }
                     case 1:
                        if(_loc7_)
                        {
                           addr99:
                           while(true)
                           {
                              _loc3_.retry = true;
                              if(_loc6_)
                              {
                                 if(_loc7_)
                                 {
                                 }
                                 addr123:
                                 break;
                              }
                              loop4:
                              while(!_loc6_)
                              {
                                 while(true)
                                 {
                                    _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.404") + " (1)";
                                    if(!_loc7_)
                                    {
                                       if(!_loc6_)
                                       {
                                          break loop4;
                                       }
                                       addr132:
                                       while(true)
                                       {
                                          _loc3_.fatal = true;
                                          continue loop4;
                                       }
                                    }
                                    break;
                                 }
                              }
                              break;
                              §§goto(addr483);
                           }
                           §§goto(addr436);
                        }
                        while(true)
                        {
                           _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.403");
                           if(!_loc7_)
                           {
                              if(_loc7_)
                              {
                                 §§goto(addr123);
                              }
                              else
                              {
                                 §§goto(addr99);
                              }
                           }
                           else
                           {
                              loop6:
                              while(true)
                              {
                                 if(!_loc7_)
                                 {
                                    addr223:
                                    while(true)
                                    {
                                       _loc3_.fatal = true;
                                       if(_loc6_)
                                       {
                                          if(_loc7_)
                                          {
                                             addr235:
                                             while(true)
                                             {
                                                _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.202");
                                                if(_loc6_)
                                                {
                                                   continue loop6;
                                                }
                                                §§goto(addr483);
                                             }
                                          }
                                          §§goto(addr475);
                                       }
                                       else
                                       {
                                          break loop21;
                                       }
                                    }
                                 }
                              }
                           }
                           §§goto(addr436);
                        }
                     case 2:
                        if(_loc7_)
                        {
                           §§goto(addr132);
                        }
                        §§goto(addr141);
                     case 3:
                        if(_loc7_)
                        {
                           addr164:
                           while(true)
                           {
                              _loc3_.fatal = true;
                              if(!_loc7_)
                              {
                                 if(_loc7_)
                                 {
                                 }
                                 addr186:
                                 §§goto(addr436);
                              }
                              break;
                           }
                           §§goto(addr455);
                        }
                        while(true)
                        {
                           _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.security");
                           if(!_loc6_)
                           {
                              break;
                           }
                           §§goto(addr164);
                        }
                        §§goto(addr186);
                     case 4:
                        if(!_loc6_)
                        {
                           addr195:
                           while(true)
                           {
                              _loc3_.fatal = true;
                              if(_loc7_)
                              {
                              }
                              break;
                           }
                           §§goto(addr436);
                        }
                        while(true)
                        {
                           _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.413");
                           if(_loc6_)
                           {
                              §§goto(addr195);
                           }
                           §§goto(addr214);
                        }
                     case 5:
                        if(!_loc6_)
                        {
                           §§goto(addr223);
                        }
                        §§goto(addr235);
                     case 6:
                        if(_loc7_)
                        {
                           addr261:
                           while(true)
                           {
                              _loc3_.fatal = true;
                              break loop21;
                           }
                        }
                        addr270:
                        while(true)
                        {
                           _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.404") + " (2)";
                           if(_loc7_)
                           {
                              addr282:
                              §§goto(addr436);
                           }
                           else
                           {
                              §§goto(addr261);
                           }
                        }
                     default:
                        _loc3_.text = param1.error?param1.error:I18n.getUiText("ui.secureMode.error.default");
                        if(!_loc7_)
                        {
                           _loc3_.fatal = true;
                           if(_loc6_)
                           {
                           }
                           addr455:
                           §§push(this.addCertificate(param1.id,param1.certificate,this.shieldLevel));
                           if(_loc6_)
                           {
                              addr466:
                              §§push(§§pop());
                              if(!_loc7_)
                              {
                                 addr474:
                              }
                           }
                           addr475:
                           if(!§§pop())
                           {
                              _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.202.fatal");
                              if(_loc6_)
                              {
                                 addr483:
                                 _loc3_.fatal = true;
                              }
                           }
                           return _loc3_;
                        }
                        addr436:
                        §§push(param1.certificate);
                        if(!_loc7_)
                        {
                           §§push(§§dup(§§pop()));
                           if(_loc6_)
                           {
                              if(§§pop())
                              {
                                 if(_loc7_)
                                 {
                                 }
                                 §§goto(addr475);
                              }
                              addr454:
                              if(§§pop())
                              {
                                 §§goto(addr455);
                              }
                              §§goto(addr475);
                           }
                           §§goto(addr474);
                        }
                        §§pop();
                        §§push(param1.id);
                        if(_loc6_)
                        {
                           §§goto(addr454);
                        }
                        §§goto(addr466);
                  }
                  while(!_loc6_)
                  {
                     §§goto(addr270);
                  }
                  §§goto(addr282);
               }
               addr45:
               while(true)
               {
                  _loc3_.fatal = false;
                  if(_loc6_)
                  {
                  }
                  §§goto(addr436);
               }
            }
            while(_loc7_)
            {
               §§goto(addr45);
            }
            _loc3_.text = "";
            if(_loc6_)
            {
               §§goto(addr62);
            }
            §§goto(addr436);
         }
         while(true)
         {
            if(!_loc6_)
            {
               §§goto(addr56);
            }
            else
            {
               §§goto(addr33);
            }
            §§goto(addr436);
         }
      }
      
      private function parseRpcASkCodeResponse(param1:Object, param2:String) : Object
      {
         var _loc3_:Object = new Object();
         if(_loc6_)
         {
            _loc3_.error = !_loc3_.error;
            if(!_loc6_)
            {
               addr29:
               while(true)
               {
                  _loc3_.retry = false;
               }
            }
            addr38:
            while(true)
            {
               _loc3_.fatal = false;
               if(!_loc6_)
               {
                  break;
               }
               §§goto(addr29);
            }
            _loc3_.text = "";
            if(_loc5_)
            {
            }
            if(!param1.error)
            {
               _loc3_.domain = param1.domain;
               _loc3_.error = false;
            }
            else
            {
               if(!_loc5_)
               {
                  §§push(ACCOUNT_AUTHENTIFICATION_FAILED);
                  if(!_loc5_)
                  {
                     if(§§pop() === _loc4_)
                     {
                        if(_loc5_)
                        {
                        }
                        addr226:
                        loop12:
                        switch(§§pop())
                        {
                           case 0:
                              if(_loc5_)
                              {
                                 addr69:
                                 while(true)
                                 {
                                    _loc3_.fatal = true;
                                    if(!_loc5_)
                                    {
                                       if(_loc6_)
                                       {
                                       }
                                       addr95:
                                       §§goto(addr162);
                                    }
                                    break;
                                 }
                                 §§goto(addr147);
                              }
                              while(true)
                              {
                                 _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.404") + " (3)";
                                 if(!_loc5_)
                                 {
                                    if(!_loc5_)
                                    {
                                       §§goto(addr69);
                                    }
                                    §§goto(addr95);
                                 }
                                 break;
                              }
                              §§goto(addr157);
                           case 1:
                              if(!_loc6_)
                              {
                                 loop7:
                                 while(true)
                                 {
                                    _loc3_.fatal = true;
                                    if(_loc6_)
                                    {
                                       if(_loc6_)
                                       {
                                          if(_loc6_)
                                          {
                                          }
                                          addr131:
                                          break;
                                       }
                                       addr126:
                                       while(true)
                                       {
                                          if(!_loc6_)
                                          {
                                             §§goto(addr131);
                                          }
                                          else
                                          {
                                             continue loop7;
                                          }
                                       }
                                    }
                                    else
                                    {
                                       §§goto(addr147);
                                    }
                                 }
                                 §§goto(addr162);
                              }
                              while(true)
                              {
                                 _loc3_.text = I18n.getUiText("ui.secureMode.error.checkCode.expire");
                                 §§goto(addr126);
                              }
                           default:
                              if(!_loc6_)
                              {
                                 loop2:
                                 while(true)
                                 {
                                    _loc3_.fatal = true;
                                    if(!_loc5_)
                                    {
                                       addr147:
                                       while(_loc5_)
                                       {
                                          break loop12;
                                       }
                                       return _loc3_;
                                    }
                                    addr157:
                                    while(true)
                                    {
                                       if(!_loc6_)
                                       {
                                          break loop2;
                                       }
                                       continue loop2;
                                    }
                                 }
                                 §§goto(addr162);
                              }
                        }
                        while(true)
                        {
                           _loc3_.text = I18n.getUiText("ui.secureMode.error.default");
                           §§goto(addr157);
                        }
                     }
                     else
                     {
                        §§push(VALIDATECODE_CODEEXPIRE);
                     }
                     addr198:
                     §§push(1);
                     if(!_loc6_)
                     {
                        §§push(§§pop() - 33 - 1 - 1);
                     }
                     if(_loc6_)
                     {
                        addr207:
                     }
                     §§goto(addr226);
                  }
                  if(§§pop() === _loc4_)
                  {
                     §§goto(addr198);
                  }
                  else
                  {
                     §§push(2);
                     if(_loc5_)
                     {
                        §§push(§§pop() + 1 - 102 + 104 + 1);
                     }
                  }
                  §§goto(addr226);
               }
               §§push(0);
               if(_loc5_)
               {
                  §§push(-(-(§§pop() - 119 - 79) + 1 - 6 + 35));
               }
               if(_loc5_)
               {
                  §§goto(addr207);
               }
               §§goto(addr226);
            }
            §§goto(addr162);
         }
         while(true)
         {
            if(_loc5_)
            {
               §§goto(addr38);
            }
            §§goto(addr46);
         }
      }
      
      private function getCertifFolder(param1:uint, param2:Boolean = false) : File
      {
         var _loc6_:* = false;
         var _loc7_:* = true;
         var _loc3_:File = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         if(!param2)
         {
            if(!_loc6_)
            {
               §§push(File.applicationStorageDirectory.nativePath.split(File.separator));
               if(!_loc6_)
               {
                  _loc4_ = §§pop();
                  §§push(_loc4_);
                  if(_loc6_)
                  {
                  }
                  addr46:
                  addr48:
                  §§pop().pop();
                  §§push(_loc4_.join(File.separator));
                  if(_loc7_)
                  {
                     _loc5_ = §§pop();
                     addr70:
                     §§push(param1);
                     if(!_loc6_)
                     {
                        §§push(1);
                        if(!_loc7_)
                        {
                           §§push(-(-((§§pop() - 1) * 55) * 105));
                        }
                        if(!_loc6_)
                        {
                           if(§§pop() == §§pop())
                           {
                              _loc3_ = new File(_loc5_ + File.separator + "AnkamaCertificates/");
                           }
                           §§push(param1);
                        }
                        addr108:
                        addr119:
                        if(§§pop() == §§pop())
                        {
                        }
                        _loc3_.createDirectory();
                        return _loc3_;
                     }
                     §§push(2);
                     if(_loc6_)
                     {
                        §§push(-§§pop() - 90 + 1);
                     }
                     §§goto(addr108);
                  }
                  else
                  {
                     addr65:
                     §§push(§§pop());
                  }
               }
               §§pop().pop();
               §§push(_loc4_);
               if(_loc7_)
               {
                  §§goto(addr46);
               }
               §§goto(addr48);
            }
            addr109:
            _loc3_ = new File(_loc5_ + File.separator + "AnkamaCertificates/v2-RELEASE");
            §§goto(addr119);
         }
         else
         {
            §§push(CustomSharedObject.getCustomSharedObjectDirectory());
            if(_loc7_)
            {
               §§goto(addr65);
            }
         }
         _loc5_ = §§pop();
         if(_loc7_)
         {
            §§goto(addr70);
         }
         §§goto(addr109);
      }
      
      private function addCertificate(param1:uint, param2:String, param3:uint = 2) : Boolean
      {
         var cert:ShieldCertifcate = null;
         if(!_loc7_)
         {
            break loop2;
         }
         continue loop6;
      }
      
      public function checkMigrate() : void
      {
         if(!this._hasV1Certif)
         {
            return;
         }
         var _loc1_:TrustCertificate = this.retreiveCertificate();
         this.migrate(_loc1_.id,_loc1_.hash);
      }
      
      private function getCertificateFile() : File
      {
         var _loc3_:* = true;
         var _loc4_:* = false;
         if(_loc3_)
         {
            var userName:String = null;
            if(!_loc4_)
            {
               var f:File = null;
            }
         }
         try
         {
            §§push(_loc1_);
            §§push(this.getUsername());
            if(!_loc4_)
            {
               §§push(§§pop());
            }
            var /*UnknownSlot*/:* = §§pop();
            if(!_loc4_)
            {
               §§push(_loc1_);
               §§push(this);
               §§push(2);
               if(_loc4_)
               {
                  §§push(-§§pop() - 90 - 100 - 1 - 105);
               }
               var /*UnknownSlot*/:* = §§pop().getCertifFolder(§§pop()).resolvePath(MD5.hash(userName));
               if(!f.exists)
               {
                  if(_loc4_)
                  {
                  }
                  addr114:
                  if(f.exists)
                  {
                     return f;
                  }
               }
               addr86:
               if(!f.exists)
               {
                  §§push(_loc1_);
                  §§push(this);
                  §§push(2);
                  if(_loc4_)
                  {
                     §§push(-(--(§§pop() - 63 + 1) * 108 - 111));
                  }
                  var /*UnknownSlot*/:* = §§pop().getCertifFolder(§§pop(),true).resolvePath(MD5.hash(userName));
               }
               §§goto(addr114);
            }
            §§push(_loc1_);
            §§push(this);
            §§push(1);
            if(_loc4_)
            {
               §§push(-(§§pop() + 1 - 1));
            }
            var /*UnknownSlot*/:* = §§pop().getCertifFolder(§§pop()).resolvePath(MD5.hash(userName));
            §§goto(addr86);
         }
         catch(e:Error)
         {
            if(_loc3_)
            {
               §§push(_log);
               §§push("Erreur lors de la recherche du certifcat : ");
               if(!_loc4_)
               {
                  §§push(§§pop() + e.message);
               }
               §§pop().error(§§pop());
            }
         }
         return null;
      }
      
      public function retreiveCertificate() : TrustCertificate
      {
         var f:File = null;
         var fs:FileStream = null;
         var certif:ShieldCertifcate = null;
         try
         {
            this._hasV1Certif = false;
            f = this.getCertificateFile();
            if(f)
            {
               fs = new FileStream();
               fs.open(f,FileMode.READ);
               certif = ShieldCertifcate.fromRaw(fs);
               fs.close();
               if(certif.id == 0)
               {
                  _log.error("Certificat invalide (id=0)");
                  return null;
               }
               return certif.toNetwork();
            }
         }
         catch(e:Error)
         {
            ErrorManager.addError("Impossible de lire le fichier de certificat.",e);
         }
         return null;
      }
      
      private function onRpcData(param1:RpcEvent) : void
      {
         var _loc3_:* = true;
         var _loc4_:* = false;
         §§push(param1.type == RpcEvent.EVENT_ERROR);
         if(_loc3_)
         {
            if(§§dup(§§pop()))
            {
               if(!_loc4_)
               {
                  §§pop();
                  §§push(!param1.result);
               }
            }
         }
         if(§§pop())
         {
            if(!_loc4_)
            {
               this._methodsCallback[param1.method]({
                  "error":true,
                  "fatal":true,
                  "text":I18n.getUiText("ui.secureMode.error.checkCode.503")
               });
               return;
            }
         }
         else
         {
            §§push(param1.method);
            if(!_loc4_)
            {
               §§push(RPC_METHOD_SECURITY_CODE);
               if(_loc3_)
               {
                  if(§§pop() == §§pop())
                  {
                     this._methodsCallback[param1.method](this.parseRpcASkCodeResponse(param1.result,param1.method));
                     if(_loc4_)
                     {
                     }
                     addr128:
                  }
                  §§push(param1.method);
                  if(!_loc4_)
                  {
                     §§push(RPC_METHOD_VALIDATE_CODE);
                     if(_loc4_)
                     {
                     }
                     addr115:
                     if(§§pop() == §§pop())
                     {
                        addr116:
                        if(param1.result.success)
                        {
                           this.migrationSuccess(param1.result);
                           §§goto(addr128);
                        }
                        else
                        {
                           §§push(_log);
                           §§push("Impossible de migrer le certificat : ");
                           if(!_loc4_)
                           {
                              §§push(§§pop() + param1.result.error);
                           }
                           §§pop().error(§§pop());
                        }
                     }
                  }
               }
               if(§§pop() == §§pop())
               {
                  if(_loc3_)
                  {
                     this._methodsCallback[param1.method](this.parseRpcValidateResponse(param1.result,param1.method));
                  }
                  §§goto(addr116);
               }
               §§push(param1.method);
            }
            §§goto(addr115);
            §§push(RPC_METHOD_MIGRATE);
         }
      }
      
      private function migrate(param1:uint, param2:String) : void
      {
         var _loc4_:* = true;
         var _loc5_:* = false;
         var _loc3_:ShieldCertifcate = new ShieldCertifcate();
         if(!_loc5_)
         {
            _loc3_.secureLevel = this.shieldLevel;
            if(_loc4_)
            {
               §§push(this._rpcManager);
               §§push(RPC_METHOD_MIGRATE);
               §§push(this.getUsername());
               §§push(AuthentificationManager.getInstance().ankamaPortalKey);
               §§push(1);
               if(!_loc4_)
               {
                  §§push(-(§§pop() + 63 + 10 + 101 - 57 + 1));
               }
               §§pop().callMethod(§§pop(),null);
            }
         }
      }
      
      private function migrationSuccess(param1:Object) : void
      {
         var _loc3_:* = true;
         var _loc4_:* = false;
         var _loc2_:File = this.getCertificateFile();
         if(!_loc4_)
         {
            if(_loc2_.exists)
            {
               if(_loc4_)
               {
               }
               addr34:
               return;
            }
         }
         this.addCertificate(param1.id,param1.certificate);
         §§goto(addr34);
      }
   }
}
