package com.ankamagames.dofus.logic.connection.managers
{
   import com.ankamagames.jerakine.interfaces.IDestroyable;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.dofus.logic.connection.actions.LoginValidationAction;
   import com.ankamagames.dofus.network.types.secure.TrustCertificate;
   import flash.utils.ByteArray;
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.symmetric.NullPad;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.crypto.rsa.RSAKey;
   import com.hurlant.util.der.PEM;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.utils.crypto.Base64;
   import com.ankamagames.dofus.logic.shield.SecureModeManager;
   import com.ankamagames.dofus.logic.game.common.frames.ProtectPishingFrame;
   import by.blooddy.crypto.MD5;
   import com.ankamagames.dofus.logic.connection.actions.LoginValidationWithTicketAction;
   import com.ankamagames.dofus.network.messages.connection.IdentificationMessage;
   import com.ankamagames.dofus.network.messages.connection.IdentificationAccountForceMessage;
   import com.ankamagames.dofus.BuildInfos;
   import com.ankamagames.jerakine.utils.system.AirScanner;
   import com.ankamagames.dofus.network.enums.BuildTypeEnum;
   import com.ankamagames.jerakine.data.XmlConfig;
   import com.ankamagames.dofus.network.enums.ClientInstallTypeEnum;
   import com.ankamagames.dofus.network.enums.ClientTechnologyEnum;
   import flash.filesystem.File;
   import com.ankamagames.jerakine.utils.crypto.RSA;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   
   public class AuthentificationManager extends Object implements IDestroyable
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(AuthentificationManager));
      
      private static var _self:AuthentificationManager;
      
      private static const AES_KEY_LENGTH = 32;
      
      private static const PUBLIC_KEY_V2:Class = AuthentificationManager_PUBLIC_KEY_V2;
       
      private var _publicKey:String;
      
      private var _salt:String;
      
      private var _lva:LoginValidationAction;
      
      private var _certificate:TrustCertificate;
      
      private var _AESKey:ByteArray;
      
      private var _verifyKey:Class;
      
      private var _gameServerTicket:String;
      
      public var ankamaPortalKey:String;
      
      public var username:String;
      
      public var nextToken:String;
      
      public var tokenMode:Boolean = false;
      
      public function AuthentificationManager()
      {
         this._verifyKey = AuthentificationManager__verifyKey;
         super();
         if(_self != null)
         {
            throw new SingletonError("AuthentificationManager is a singleton and should not be instanciated directly.");
         }
      }
      
      public static function getInstance() : AuthentificationManager
      {
         if(_self == null)
         {
            _self = new AuthentificationManager();
         }
         return _self;
      }
      
      public function get gameServerTicket() : String
      {
         return this._gameServerTicket;
      }
      
      public function set gameServerTicket(param1:String) : void
      {
         this._gameServerTicket = param1;
      }
      
      public function get salt() : String
      {
         return this._salt;
      }
      
      public function initAESKey() : void
      {
         this._AESKey = this.generateRandomAESKey();
      }
      
      public function decodeWithAES(param1:*) : ByteArray
      {
         var _loc4_:* = 0;
         var _loc2_:ICipher = Crypto.getCipher("simple-aes256-cbc",this._AESKey,new NullPad());
         this._AESKey.position = 0;
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeBytes(this._AESKey,0,16);
         if(param1 is Vector.<int> || param1 is Vector.<uint>)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc3_.writeByte(param1[_loc4_]);
               _loc4_++;
            }
         }
         else if(param1 is ByteArray)
         {
            _loc3_.writeBytes(param1 as ByteArray);
         }
         else
         {
            throw new ArgumentError("Argument must be a bytearray or a vector of int/uint");
         }
         _loc2_.decrypt(_loc3_);
         return _loc3_;
      }
      
      public function setSalt(param1:String) : void
      {
         this._salt = param1;
         if(this._salt.length < 32)
         {
            _log.warn("Authentification salt size is lower than 32 ");
            while(this._salt.length < 32)
            {
               this._salt = this._salt + " ";
            }
         }
      }
      
      public function setPublicKey(param1:Vector.<int>) : void
      {
         var commonMod:Object = null;
         var publicKey:Vector.<int> = param1;
         var baSignedKey:ByteArray = new ByteArray();
         var i:int = 0;
         while(i < publicKey.length)
         {
            baSignedKey.writeByte(publicKey[i]);
            i++;
         }
         baSignedKey.position = 0;
         var key:ByteArray = new ByteArray();
         var readKey:RSAKey = PEM.readRSAPublicKey((new this._verifyKey() as ByteArray).readUTFBytes((new this._verifyKey() as ByteArray).length));
         try
         {
            readKey.verify(baSignedKey,key,baSignedKey.length);
         }
         catch(e:Error)
         {
            commonMod = UiModuleManager.getInstance().getModule("Ankama_Common").mainClass;
            commonMod.openPopup(I18n.getUiText("ui.common.error"),I18n.getUiText("ui.server.authentificationImpossible"),[I18n.getUiText("ui.common.ok")]);
            return;
         }
         this._publicKey = "-----BEGIN PUBLIC KEY-----\n" + Base64.encodeByteArray(key) + "-----END PUBLIC KEY-----";
      }
      
      public function setValidationAction(param1:LoginValidationAction) : void
      {
         this.username = param1["username"];
         this._lva = param1;
         this._certificate = SecureModeManager.getInstance().retreiveCertificate();
         ProtectPishingFrame.setPasswordHash(MD5.hash(param1.password.toUpperCase()),param1.password.length);
      }
      
      public function get loginValidationAction() : LoginValidationAction
      {
         return this._lva;
      }
      
      public function get canAutoConnectWithToken() : Boolean
      {
         return this.nextToken != null;
      }
      
      public function get isLoggingWithTicket() : Boolean
      {
         return this._lva is LoginValidationWithTicketAction;
      }
      
      public function getIdentificationMessage() : IdentificationMessage
      {
         var _loc2_:IdentificationMessage = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:IdentificationAccountForceMessage = null;
         var _loc1_:uint = BuildInfos.BUILD_VERSION.buildType;
         if(AirScanner.isStreamingVersion() && BuildInfos.BUILD_VERSION.buildType == BuildTypeEnum.BETA)
         {
            _loc1_ = BuildTypeEnum.RELEASE;
         }
         if(this._lva.username.indexOf("|") == -1)
         {
            _loc2_ = new IdentificationMessage();
            if(this._lva is LoginValidationWithTicketAction || this.nextToken)
            {
               _loc3_ = this.nextToken?this.nextToken:LoginValidationWithTicketAction(this._lva).ticket;
               this.nextToken = null;
               this.ankamaPortalKey = this.cipherMd5String(_loc3_);
               _loc2_.initIdentificationMessage(_loc2_.version,XmlConfig.getInstance().getEntry("config.lang.current"),this.cipherRsa("   ",_loc3_,this._certificate),this._lva.serverId,this._lva.autoSelectServer,this._certificate != null,true);
            }
            else
            {
               this.ankamaPortalKey = this.cipherMd5String(this._lva.password);
               _loc2_.initIdentificationMessage(_loc2_.version,XmlConfig.getInstance().getEntry("config.lang.current"),this.cipherRsa(this._lva.username,this._lva.password,this._certificate),this._lva.serverId,this._lva.autoSelectServer,this._certificate != null,false);
            }
            _loc2_.version.initVersionExtended(BuildInfos.BUILD_VERSION.major,BuildInfos.BUILD_VERSION.minor,BuildInfos.BUILD_VERSION.release,BuildInfos.BUILD_REVISION,BuildInfos.BUILD_PATCH,_loc1_,AirScanner.isStreamingVersion()?ClientInstallTypeEnum.CLIENT_STREAMING:ClientInstallTypeEnum.CLIENT_BUNDLE,AirScanner.hasAir()?ClientTechnologyEnum.CLIENT_AIR:ClientTechnologyEnum.CLIENT_FLASH);
            return _loc2_;
         }
         this.ankamaPortalKey = this.cipherMd5String(this._lva.password);
         _loc4_ = this._lva.username.split("|");
         _loc5_ = new IdentificationAccountForceMessage();
         _loc5_.initIdentificationAccountForceMessage(_loc5_.version,XmlConfig.getInstance().getEntry("config.lang.current"),this.cipherRsa(_loc4_[0],this._lva.password,this._certificate),this._lva.serverId,this._lva.autoSelectServer,this._certificate != null,false,0,null,_loc4_[1]);
         _loc5_.version.initVersionExtended(BuildInfos.BUILD_VERSION.major,BuildInfos.BUILD_VERSION.minor,BuildInfos.BUILD_VERSION.release,BuildInfos.BUILD_REVISION,BuildInfos.BUILD_PATCH,_loc1_,AirScanner.isStreamingVersion()?ClientInstallTypeEnum.CLIENT_STREAMING:ClientInstallTypeEnum.CLIENT_BUNDLE,AirScanner.hasAir()?ClientTechnologyEnum.CLIENT_AIR:ClientTechnologyEnum.CLIENT_FLASH);
         return _loc5_;
      }
      
      public function destroy() : void
      {
         _self = null;
      }
      
      private function cipherMd5String(param1:String) : String
      {
         var _loc2_:* = true;
         var _loc3_:* = false;
         return MD5.hash(param1 + this._salt);
      }
      
      private function cipherRsa(param1:String, param2:String, param3:TrustCertificate) : Vector.<int>
      {
         var baOut:ByteArray = null;
         if(_loc7_)
         {
         }
         var debugOutput:ByteArray = null;
         if(!_loc6_)
         {
            if(_loc6_)
            {
               loop0:
               while(true)
               {
                  var certificate:TrustCertificate = param3;
                  if(!_loc6_)
                  {
                     if(_loc6_)
                     {
                        addr49:
                        while(true)
                        {
                           baIn.writeUTFBytes(this._salt);
                           if(!_loc7_)
                           {
                              addr60:
                              while(true)
                              {
                                 var login:String = param1;
                                 if(!_loc6_)
                                 {
                                    if(_loc7_)
                                    {
                                    }
                                    var pwd:String = param2;
                                    if(_loc7_)
                                    {
                                       continue loop0;
                                    }
                                 }
                                 break;
                              }
                              if(_loc6_)
                              {
                              }
                              if(certificate)
                              {
                                 baIn.writeUnsignedInt(certificate.id);
                                 if(_loc7_)
                                 {
                                    if(_loc6_)
                                    {
                                    }
                                    baIn.writeUTFBytes(certificate.hash);
                                    if(_loc6_)
                                    {
                                       addr143:
                                       baIn.writeUTFBytes(login);
                                    }
                                 }
                              }
                              baIn.writeByte(login.length);
                              if(_loc7_)
                              {
                                 §§goto(addr143);
                              }
                              baIn.writeUTFBytes(pwd);
                              if(_loc6_)
                              {
                              }
                              try
                              {
                                 §§push(File.applicationDirectory.resolvePath("debug-login.txt"));
                                 if(_loc7_)
                                 {
                                    if(!§§dup(§§pop()))
                                    {
                                       if(_loc7_)
                                       {
                                       }
                                    }
                                    addr195:
                                    if(§§pop())
                                    {
                                       _log.debug("login with certificate");
                                       if(_loc7_)
                                       {
                                          if(_loc7_)
                                          {
                                          }
                                          debugOutput = new ByteArray();
                                          if(_loc7_)
                                          {
                                          }
                                          §§push(baIn);
                                          §§push(0);
                                          if(_loc6_)
                                          {
                                             §§push((§§pop() + 104 + 1) * 10 - 33 - 2);
                                          }
                                          addr231:
                                          §§pop().position = §§pop();
                                          addr292:
                                          if(!_loc7_)
                                          {
                                             addr237:
                                             while(true)
                                             {
                                                debugOutput = RSA.publicEncrypt((new PUBLIC_KEY_V2() as ByteArray).readUTFBytes((new PUBLIC_KEY_V2() as ByteArray).length),baIn);
                                                if(!_loc6_)
                                                {
                                                   if(_loc6_)
                                                   {
                                                   }
                                                   §§push(_log);
                                                   §§push("Login info (RSA Encrypted, ");
                                                   if(_loc7_)
                                                   {
                                                      §§push(§§pop() + debugOutput.length);
                                                      if(_loc7_)
                                                      {
                                                      }
                                                      addr286:
                                                      §§pop().debug(§§pop());
                                                   }
                                                   §§push(§§pop() + " bytes) : ");
                                                   if(_loc7_)
                                                   {
                                                      §§push(§§pop() + Base64.encodeByteArray(debugOutput));
                                                   }
                                                   §§goto(addr286);
                                                }
                                             }
                                          }
                                          while(true)
                                          {
                                             §§push(debugOutput);
                                             §§push(0);
                                             if(!_loc7_)
                                             {
                                                §§push(§§pop() + 24 - 95 + 1 + 1 + 1 - 109);
                                             }
                                             §§pop().position = §§pop();
                                             if(_loc6_)
                                             {
                                                break;
                                             }
                                             §§goto(addr237);
                                             §§goto(addr231);
                                          }
                                       }
                                       while(true)
                                       {
                                          if(_loc6_)
                                          {
                                             §§goto(addr292);
                                          }
                                       }
                                    }
                                 }
                                 §§pop();
                                 if(_loc6_)
                                 {
                                 }
                                 §§goto(addr195);
                              }
                              catch(e:Error)
                              {
                                 if(!_loc6_)
                                 {
                                    §§push(_log);
                                    §§push("Erreur lors du log des informations de login ");
                                    if(!_loc6_)
                                    {
                                       §§push(§§pop() + e.getStackTrace());
                                    }
                                    §§pop().error(§§pop());
                                 }
                              }
                              baOut = RSA.publicEncrypt(this._publicKey,baIn);
                              if(!_loc6_)
                              {
                                 if(_loc6_)
                                 {
                                    loop7:
                                    while(true)
                                    {
                                       §§push(baOut);
                                       §§push(0);
                                       if(_loc6_)
                                       {
                                          §§push(-(-(§§pop() * 25) - 110 + 30 - 47) + 32);
                                       }
                                       §§pop().position = §§pop();
                                       if(!_loc6_)
                                       {
                                          if(!_loc6_)
                                          {
                                             if(_loc7_)
                                             {
                                             }
                                             addr398:
                                             §§push(_loc4_);
                                             §§push(0);
                                             if(!_loc7_)
                                             {
                                                §§push(§§pop() + 64 - 1 + 117 + 2);
                                             }
                                             var /*UnknownSlot*/:* = §§pop();
                                             if(!_loc6_)
                                             {
                                                break;
                                             }
                                          }
                                          addr393:
                                          while(true)
                                          {
                                             if(!_loc7_)
                                             {
                                                §§goto(addr398);
                                             }
                                             else
                                             {
                                                continue loop7;
                                             }
                                          }
                                       }
                                       break;
                                    }
                                    if(_loc6_)
                                    {
                                    }
                                    while(true)
                                    {
                                       §§push(baOut.bytesAvailable);
                                       §§push(0);
                                       if(!_loc7_)
                                       {
                                          §§push(-§§pop() - 81 - 1);
                                       }
                                       if(§§pop() == §§pop())
                                       {
                                          break;
                                       }
                                       if(_loc6_)
                                       {
                                          loop9:
                                          while(true)
                                          {
                                             ret[i] = n;
                                             if(!_loc6_)
                                             {
                                                if(!_loc6_)
                                                {
                                                   if(_loc6_)
                                                   {
                                                   }
                                                   §§push(i);
                                                   if(!_loc6_)
                                                   {
                                                      §§push(§§pop() + 1);
                                                   }
                                                   var i:int = §§pop();
                                                }
                                                addr460:
                                                while(_loc7_)
                                                {
                                                   continue loop9;
                                                }
                                                break;
                                             }
                                             if(_loc7_)
                                             {
                                                break;
                                             }
                                          }
                                          continue;
                                       }
                                       while(true)
                                       {
                                          var n:int = baOut.readByte();
                                          §§goto(addr460);
                                       }
                                    }
                                 }
                                 while(true)
                                 {
                                    var ret:Vector.<int> = new Vector.<int>();
                                    §§goto(addr393);
                                 }
                              }
                              if(_loc6_)
                              {
                              }
                              return ret;
                           }
                           break;
                        }
                        baIn.writeBytes(this._AESKey);
                        §§goto(addr113);
                     }
                     while(true)
                     {
                        var baIn:ByteArray = new ByteArray();
                        if(!_loc6_)
                        {
                           §§goto(addr49);
                        }
                        §§goto(addr60);
                     }
                  }
                  addr103:
                  while(true)
                  {
                     if(_loc6_)
                     {
                        §§goto(addr108);
                     }
                     else
                     {
                        §§goto(addr60);
                     }
                     §§goto(addr113);
                  }
               }
            }
            while(true)
            {
               §§push(_loc4_);
               §§push(0);
               if(_loc6_)
               {
                  §§push(-(§§pop() + 93 - 66 - 106) - 1 + 1);
               }
               var /*UnknownSlot*/:* = §§pop();
               §§goto(addr103);
            }
         }
         while(_loc6_)
         {
            §§goto(addr154);
         }
         §§goto(addr165);
      }
      
      private function generateRandomAESKey() : ByteArray
      {
         var _loc3_:* = true;
         var _loc4_:* = false;
         var _loc1_:ByteArray = new ByteArray();
         §§push(0);
         if(!_loc3_)
         {
            §§push(-(§§pop() + 30 + 119 + 1) * 8 + 32 + 1);
         }
         var _loc2_:* = §§pop();
         if(!_loc4_)
         {
            while(_loc2_ < AES_KEY_LENGTH)
            {
               §§push(_loc1_);
               §§push(_loc2_);
               §§push(Math);
               §§push(Math.random());
               §§push(256);
               if(!_loc3_)
               {
                  §§push(-(§§pop() + 1 - 112 - 1));
               }
               §§pop()[§§pop()] = §§pop().floor(§§pop() * §§pop());
               if(_loc3_)
               {
                  _loc2_++;
               }
            }
         }
         return _loc1_;
      }
   }
}
