package com.ankamagames.jerakine.utils.crypto
{
   import com.hurlant.crypto.rsa.RSAKey;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.getTimer;
   import by.blooddy.crypto.MD5;
   import com.ankamagames.jerakine.utils.errors.SignatureError;
   import by.blooddy.crypto.SHA256;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.filesystem.FileMode;
   
   public class Signature extends Object
   {
      
      public static const ANKAMA_SIGNED_FILE_HEADER:String = "AKSF";
      
      public static const SIGNATURE_HEADER:String = "AKSD";
       
      private var _key:SignatureKey;
      
      private var _keyV2:RSAKey;
      
      public function Signature(... rest)
      {
         var _loc2_:* = undefined;
         super();
         if(rest.length == 0)
         {
            throw new ArgumentError("You must provide at least one key");
         }
         for each(_loc2_ in rest)
         {
            if(_loc2_ is SignatureKey)
            {
               this._key = _loc2_;
               continue;
            }
            if(_loc2_ is RSAKey)
            {
               this._keyV2 = _loc2_;
               continue;
            }
            throw new ArgumentError("Invalid key type");
         }
      }
      
      public function sign(param1:IDataInput, param2:Boolean = true) : ByteArray
      {
         var _loc3_:ByteArray = null;
         if(!this._key.canSign)
         {
            throw new Error("La clef fournit ne permet pas de signer des données");
         }
         if(param1 is ByteArray)
         {
            _loc3_ = param1 as ByteArray;
         }
         else
         {
            _loc3_ = new ByteArray();
            param1.readBytes(_loc3_);
            _loc3_.position = 0;
         }
         var _loc4_:uint = _loc3_["position"];
         var _loc5_:ByteArray = new ByteArray();
         var _loc6_:uint = Math.random() * 255;
         _loc5_.writeByte(_loc6_);
         _loc5_.writeUnsignedInt(_loc3_.bytesAvailable);
         var _loc7_:Number = getTimer();
         _loc5_.writeUTFBytes(MD5.hash(_loc3_.readUTFBytes(_loc3_.bytesAvailable)));
         trace("Temps de hash pour signature : " + (getTimer() - _loc7_) + " ms");
         var _loc8_:uint = 2;
         while(_loc8_ < _loc5_.length)
         {
            _loc5_[_loc8_] = _loc5_[_loc8_] ^ _loc6_;
            _loc8_++;
         }
         var _loc9_:ByteArray = new ByteArray();
         _loc5_.position = 0;
         this._key.sign(_loc5_,_loc9_,_loc5_.length);
         var _loc10_:ByteArray = new ByteArray();
         _loc10_.writeUTF(ANKAMA_SIGNED_FILE_HEADER);
         _loc10_.writeShort(1);
         _loc10_.writeInt(_loc9_.length);
         _loc9_.position = 0;
         _loc10_.writeBytes(_loc9_);
         if(param2)
         {
            _loc3_.position = _loc4_;
            _loc10_.writeBytes(_loc3_);
         }
         return _loc10_;
      }
      
      public function verify(param1:IDataInput, param2:ByteArray) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:* = 0;
         _loc3_ = param1.readUTF();
         if(_loc3_ != ANKAMA_SIGNED_FILE_HEADER)
         {
            param1["position"] = 0;
            _loc4_ = param1.bytesAvailable - ANKAMA_SIGNED_FILE_HEADER.length;
            param1["position"] = _loc4_;
            _loc3_ = param1.readUTFBytes(4);
            if(_loc3_ == ANKAMA_SIGNED_FILE_HEADER)
            {
               return this.verifyV2Signature(param1,param2,_loc4_);
            }
            throw new SignatureError("Invalid header",SignatureError.INVALID_HEADER);
         }
         return this.verifyV1Signature(param1,param2);
      }
      
      private function verifyV1Signature(param1:IDataInput, param2:ByteArray) : Boolean
      {
         §§push(_loc3_);
         §§push(0);
         if(!_loc6_)
         {
            §§push(§§pop() - 1 + 17 - 1 + 1 - 1 - 57);
         }
         var /*UnknownSlot*/:* = §§pop();
         if(_loc6_)
         {
         }
         var input:IDataInput = param1;
         if(_loc5_)
         {
            addr44:
            while(true)
            {
               var formatVersion:uint = input.readShort();
               if(_loc6_)
               {
               }
               var sigData:ByteArray = new ByteArray();
               if(_loc5_)
               {
               }
               break;
            }
            var decryptedHash:ByteArray = new ByteArray();
            if(_loc5_)
            {
            }
            try
            {
               var len:uint = input.readInt();
               if(_loc6_)
               {
                  §§push(input);
                  §§push(sigData);
                  §§push(0);
                  if(_loc5_)
                  {
                     §§push((§§pop() - 43 + 1 - 1) * 79);
                  }
                  §§pop().readBytes(§§pop(),§§pop(),len);
               }
            }
            catch(e:Error)
            {
               throw new SignatureError("Invalid signature format, not enough data.",SignatureError.INVALID_SIGNATURE);
            }
            try
            {
               this._key.verify(sigData,decryptedHash,sigData.length);
            }
            catch(e:Error)
            {
               return false;
            }
            §§push(decryptedHash);
            §§push(0);
            if(_loc5_)
            {
               §§push((§§pop() + 1 + 4) * 4 - 13);
            }
            §§pop().position = §§pop();
            if(_loc5_)
            {
               addr169:
               while(true)
               {
                  var hash:ByteArray = new ByteArray();
                  if(_loc6_)
                  {
                  }
                  break;
               }
               §§push(_loc3_);
               §§push(2);
               if(_loc5_)
               {
                  §§push((--§§pop() * 69 + 1) * 102 * 26 + 1);
               }
               var /*UnknownSlot*/:* = §§pop();
               if(_loc5_)
               {
               }
               loop2:
               while(i < decryptedHash.length)
               {
                  if(_loc5_)
                  {
                     loop3:
                     while(true)
                     {
                        §§push(i);
                        if(_loc6_)
                        {
                           §§push(§§pop() + 1);
                        }
                        var i:uint = §§pop();
                        if(!_loc5_)
                        {
                           if(_loc6_)
                           {
                              continue loop2;
                           }
                        }
                        addr250:
                        while(true)
                        {
                           if(_loc5_)
                           {
                              break loop3;
                           }
                           continue loop3;
                        }
                     }
                     continue;
                  }
                  while(true)
                  {
                     decryptedHash[i] = decryptedHash[i] ^ ramdomPart;
                     §§goto(addr250);
                  }
               }
               if(_loc6_)
               {
               }
               var contentLen:int = decryptedHash.readUnsignedInt();
               if(!_loc6_)
               {
                  loop6:
                  while(true)
                  {
                     trace("Temps de hash pour validation de signature : " + (getTimer() - tH) + " ms");
                     if(!_loc6_)
                     {
                        loop7:
                        while(true)
                        {
                           §§push(_loc3_);
                           §§push(MD5.hash(output.readUTFBytes(output.bytesAvailable)));
                           if(!_loc5_)
                           {
                              §§push(1);
                              if(_loc5_)
                              {
                                 §§push(--§§pop() * 42 * 38 - 1);
                              }
                              §§push(§§pop().substr(§§pop()));
                           }
                           var /*UnknownSlot*/:* = §§pop();
                           if(!_loc5_)
                           {
                              if(_loc5_)
                              {
                                 loop8:
                                 while(true)
                                 {
                                    input.readBytes(output);
                                    if(_loc5_)
                                    {
                                    }
                                    addr370:
                                    while(true)
                                    {
                                       var tH:Number = getTimer();
                                       if(_loc5_)
                                       {
                                          addr380:
                                          while(true)
                                          {
                                             §§push(_loc3_);
                                             §§push(decryptedHash.readUTFBytes(decryptedHash.bytesAvailable));
                                             §§push(1);
                                             if(_loc5_)
                                             {
                                                §§push((§§pop() - 48) * 8 - 1);
                                             }
                                             var /*UnknownSlot*/:* = §§pop().substr(§§pop());
                                             if(_loc5_)
                                             {
                                                break loop8;
                                             }
                                             continue loop8;
                                          }
                                       }
                                       else
                                       {
                                          continue loop7;
                                       }
                                    }
                                 }
                                 §§push(_loc3_);
                                 if(_loc6_)
                                 {
                                    §§push(signHash);
                                    if(_loc6_)
                                    {
                                       §§push(§§pop());
                                       if(!_loc5_)
                                       {
                                          §§push(§§dup(§§pop()));
                                          if(!_loc5_)
                                          {
                                             if(§§pop())
                                             {
                                                if(!_loc5_)
                                                {
                                                   §§pop();
                                                   if(_loc6_)
                                                   {
                                                   }
                                                   addr443:
                                                   §§push(contentLen == testedContentLen);
                                                   addr451:
                                                   if(_loc6_)
                                                   {
                                                   }
                                                   addr451:
                                                   var /*UnknownSlot*/:* = §§pop();
                                                   break;
                                                }
                                                addr450:
                                                §§goto(addr451);
                                                §§push(§§pop());
                                             }
                                          }
                                          addr434:
                                          if(§§pop())
                                          {
                                             if(_loc6_)
                                             {
                                                §§pop();
                                                §§goto(addr443);
                                             }
                                             §§goto(addr451);
                                          }
                                          §§goto(addr450);
                                       }
                                       addr433:
                                       §§goto(addr434);
                                       §§push(§§dup(§§pop()));
                                    }
                                    addr428:
                                    §§push(§§pop() == contentHash);
                                    if(!_loc5_)
                                    {
                                       §§goto(addr433);
                                    }
                                    §§goto(addr450);
                                 }
                                 §§goto(addr428);
                                 §§push(signHash);
                              }
                              else
                              {
                                 continue loop6;
                              }
                           }
                           break;
                        }
                        if(_loc6_)
                        {
                        }
                        return result;
                     }
                     while(true)
                     {
                        §§push(output);
                        §§push(0);
                        if(!_loc6_)
                        {
                           §§push((§§pop() - 81 + 1 - 11 - 0) * 81);
                        }
                        §§pop().position = §§pop();
                        if(_loc6_)
                        {
                           if(_loc5_)
                           {
                           }
                           §§goto(addr403);
                        }
                        §§goto(addr452);
                     }
                  }
               }
               while(true)
               {
                  var testedContentLen:int = input.bytesAvailable;
                  if(!_loc6_)
                  {
                     §§goto(addr370);
                  }
                  §§goto(addr380);
               }
            }
            while(true)
            {
               var ramdomPart:int = decryptedHash.readByte();
               if(!_loc5_)
               {
                  §§goto(addr169);
               }
               §§goto(addr191);
            }
         }
         while(true)
         {
            var output:ByteArray = param2;
            if(_loc6_)
            {
               §§goto(addr44);
            }
            §§goto(addr74);
         }
      }
      
      private function verifyV2Signature(param1:IDataInput, param2:ByteArray, param3:int) : Boolean
      {
         if(_loc6_)
         {
            §§push(_loc4_);
            §§push(0);
            if(_loc7_)
            {
               §§push((§§pop() + 1) * 67 * 66 + 1);
            }
            var /*UnknownSlot*/:* = §§pop();
            if(_loc7_)
            {
               loop0:
               while(true)
               {
                  var output:ByteArray = param2;
                  if(!_loc7_)
                  {
                     if(_loc6_)
                     {
                        if(!_loc6_)
                        {
                           loop1:
                           while(true)
                           {
                              var contentHash:String = null;
                              if(!_loc6_)
                              {
                                 addr58:
                                 while(true)
                                 {
                                    §§push(_loc4_);
                                    §§push(0);
                                    if(_loc7_)
                                    {
                                       §§push(§§pop() - 104 - 87 + 112 - 1 - 1);
                                    }
                                    var /*UnknownSlot*/:* = §§pop();
                                    if(_loc7_)
                                    {
                                    }
                                    break;
                                 }
                                 throw new SignatureError("No key for this signature version");
                              }
                              addr81:
                              while(true)
                              {
                                 var sigDate:Date = null;
                                 if(_loc6_)
                                 {
                                    if(_loc7_)
                                    {
                                       addr93:
                                       while(true)
                                       {
                                          §§push(_loc4_);
                                          §§push(0);
                                          if(!_loc6_)
                                          {
                                             §§push(-(§§pop() - 99 + 1) - 3 + 1);
                                          }
                                          var /*UnknownSlot*/:* = §§pop();
                                          if(_loc7_)
                                          {
                                             addr112:
                                             while(true)
                                             {
                                                §§push(_loc4_);
                                                §§push(0);
                                                if(!_loc6_)
                                                {
                                                   §§push((§§pop() + 1 - 61) * 39 * 1 + 1 + 1);
                                                }
                                                var /*UnknownSlot*/:* = §§pop();
                                             }
                                          }
                                          else
                                          {
                                             break;
                                          }
                                       }
                                       continue loop1;
                                    }
                                    addr187:
                                    while(true)
                                    {
                                       var input:IDataInput = param1;
                                       if(_loc7_)
                                       {
                                          addr195:
                                          while(true)
                                          {
                                             var sigData:ByteArray = null;
                                          }
                                       }
                                       else
                                       {
                                          break;
                                       }
                                    }
                                    continue loop0;
                                 }
                                 addr208:
                                 while(true)
                                 {
                                    if(_loc7_)
                                    {
                                       break loop0;
                                    }
                                    loop9:
                                    while(true)
                                    {
                                       §§push(_loc4_);
                                       §§push(0);
                                       if(_loc7_)
                                       {
                                          §§push((-§§pop() + 1) * 97);
                                       }
                                       var /*UnknownSlot*/:* = §§pop();
                                       if(_loc7_)
                                       {
                                          break;
                                       }
                                       addr133:
                                       while(true)
                                       {
                                          §§push(_loc4_);
                                          §§push(0);
                                          if(!_loc6_)
                                          {
                                             §§push((§§pop() * 13 + 1 - 1 - 48) * 6);
                                          }
                                          var /*UnknownSlot*/:* = §§pop();
                                          if(_loc7_)
                                          {
                                             addr153:
                                             while(true)
                                             {
                                                var sigHash:String = null;
                                                if(_loc7_)
                                                {
                                                   break;
                                                }
                                                §§goto(addr93);
                                             }
                                             continue loop9;
                                          }
                                          §§goto(addr112);
                                       }
                                    }
                                 }
                              }
                           }
                        }
                        break;
                     }
                     while(true)
                     {
                        if(!_loc6_)
                        {
                           addr204:
                           while(true)
                           {
                              var sigHeader:String = null;
                              §§goto(addr208);
                           }
                        }
                        §§goto(addr58);
                     }
                  }
                  while(true)
                  {
                     if(_loc7_)
                     {
                        §§goto(addr133);
                     }
                     §§goto(addr153);
                  }
               }
               var headerPosition:int = param3;
               if(_loc6_)
               {
               }
               if(!this._keyV2)
               {
                  §§goto(addr221);
               }
               else
               {
                  try
                  {
                     §§push(input);
                     §§push("position");
                     §§push(headerPosition);
                     §§push(4);
                     if(!_loc6_)
                     {
                        §§push(§§pop() - 66 - 90 + 1 + 99);
                     }
                     §§pop()[§§pop()] = §§pop() - §§pop();
                     if(_loc6_)
                     {
                        var signedDataLenght:int = input.readShort();
                        if(!_loc6_)
                        {
                           loop15:
                           while(true)
                           {
                              §§push(sigData);
                              §§push(0);
                              if(_loc7_)
                              {
                                 §§push(§§pop() - 34 - 100 - 1 + 102);
                              }
                              §§pop().position = §§pop();
                              if(_loc7_)
                              {
                              }
                              sigHeader = sigData.readUTF();
                              if(_loc7_)
                              {
                                 addr286:
                                 while(true)
                                 {
                                    var cryptedData:ByteArray = new ByteArray();
                                    if(_loc7_)
                                    {
                                       addr297:
                                       while(true)
                                       {
                                          trace("Décryptage en " + (getTimer() - tsDecrypt) + " ms");
                                          if(!_loc7_)
                                          {
                                             break;
                                          }
                                       }
                                       continue loop15;
                                    }
                                    addr339:
                                    while(true)
                                    {
                                       §§push(input);
                                       §§push(cryptedData);
                                       §§push(0);
                                       if(!_loc6_)
                                       {
                                          §§push((§§pop() + 1) * 38 + 1);
                                       }
                                       §§pop().readBytes(§§pop(),§§pop(),signedDataLenght);
                                       if(!_loc7_)
                                       {
                                          if(_loc7_)
                                          {
                                             addr361:
                                             while(true)
                                             {
                                                this._keyV2.verify(cryptedData,sigData,cryptedData.length);
                                                if(!_loc7_)
                                                {
                                                   break;
                                                }
                                             }
                                             §§goto(addr297);
                                          }
                                          while(true)
                                          {
                                             sigData = new ByteArray();
                                             if(_loc7_)
                                             {
                                             }
                                             var tsDecrypt:uint = getTimer();
                                             if(!_loc7_)
                                             {
                                                if(!_loc6_)
                                                {
                                                   break loop15;
                                                }
                                                §§goto(addr361);
                                             }
                                             break;
                                          }
                                          if(_loc6_)
                                          {
                                             sigHash = sigData.readUTF();
                                             if(_loc7_)
                                             {
                                             }
                                             §§push(input);
                                             §§push("position");
                                             §§push(0);
                                             if(!_loc6_)
                                             {
                                                §§push(-(-((§§pop() + 82) * 115) + 1 + 1 + 1));
                                             }
                                             §§pop()[§§pop()] = §§pop();
                                             addr618:
                                             if(_loc6_)
                                             {
                                             }
                                             addr623:
                                             addr669:
                                             var tsHash:uint = getTimer();
                                             if(_loc6_)
                                             {
                                             }
                                             if(!_loc7_)
                                             {
                                                §§push(0);
                                                if(!_loc6_)
                                                {
                                                   §§push(§§pop() * 95 + 1 + 50 + 91 + 66);
                                                }
                                                if(!_loc7_)
                                                {
                                                   §§push(_loc5_);
                                                   if(_loc6_)
                                                   {
                                                      if(§§pop() === §§pop())
                                                      {
                                                         if(!_loc6_)
                                                         {
                                                            addr719:
                                                            §§push(1);
                                                            if(!_loc6_)
                                                            {
                                                               §§push(-(§§pop() + 48) - 1 - 86 - 1 - 1 + 68);
                                                            }
                                                            if(_loc7_)
                                                            {
                                                            }
                                                         }
                                                      }
                                                      else
                                                      {
                                                         §§push(1);
                                                         if(!_loc6_)
                                                         {
                                                            §§push(§§pop() * 49 - 62 + 1 + 106 + 1);
                                                         }
                                                         if(!_loc7_)
                                                         {
                                                            §§push(_loc5_);
                                                         }
                                                      }
                                                      addr756:
                                                      switch(§§pop())
                                                      {
                                                         case 0:
                                                            §§push(_loc4_);
                                                            §§push(MD5.hashBytes(output));
                                                            if(_loc6_)
                                                            {
                                                               §§push(§§pop());
                                                            }
                                                            var /*UnknownSlot*/:* = §§pop();
                                                            break;
                                                         case 1:
                                                            §§push(_loc4_);
                                                            §§push(SHA256.hashBytes(output));
                                                            if(_loc6_)
                                                            {
                                                               §§push(§§pop());
                                                            }
                                                            var /*UnknownSlot*/:* = §§pop();
                                                            break;
                                                         default:
                                                            §§push(false);
                                                            if(!_loc7_)
                                                            {
                                                               return §§pop();
                                                            }
                                                            addr842:
                                                            addr842:
                                                            return §§pop();
                                                      }
                                                   }
                                                   if(§§pop() === §§pop())
                                                   {
                                                      §§goto(addr719);
                                                   }
                                                   else
                                                   {
                                                      §§push(2);
                                                      if(!_loc6_)
                                                      {
                                                         §§push((§§pop() - 37 + 40 - 1 - 57 + 1) * 13 - 56);
                                                      }
                                                   }
                                                   §§goto(addr756);
                                                }
                                                addr702:
                                                §§goto(addr756);
                                             }
                                             §§push(0);
                                             if(!_loc6_)
                                             {
                                                §§push((§§pop() + 1 - 112) * 31);
                                             }
                                             §§goto(addr702);
                                          }
                                          §§push(input);
                                          §§push(output);
                                          §§push(0);
                                          if(!_loc6_)
                                          {
                                             §§push(((§§pop() - 1) * 18 + 1 + 1) * 76 + 1);
                                          }
                                          §§push(headerPosition);
                                          §§push(4);
                                          if(_loc7_)
                                          {
                                             §§push(§§pop() + 1 - 113 - 87 + 113);
                                          }
                                          §§pop().readBytes(§§pop(),§§pop(),§§pop() - §§pop() - signedDataLenght);
                                          if(_loc7_)
                                          {
                                             addr584:
                                             return false;
                                          }
                                          §§goto(addr623);
                                       }
                                       break;
                                    }
                                    if(_loc6_)
                                    {
                                    }
                                    trace("Header crypté de signature incorrect, " + SIGNATURE_HEADER + " attendu, lu :" + sigHeader);
                                    if(_loc7_)
                                    {
                                       loop21:
                                       while(true)
                                       {
                                          sigData.readInt();
                                          if(!_loc6_)
                                          {
                                             addr430:
                                             while(true)
                                             {
                                                var sigFileLenght:uint = sigData.readInt();
                                                if(!_loc6_)
                                                {
                                                   addr447:
                                                   while(true)
                                                   {
                                                      var sigVersion:uint = sigData.readByte();
                                                      if(_loc6_)
                                                      {
                                                         continue loop21;
                                                      }
                                                   }
                                                }
                                                else
                                                {
                                                   §§push(sigFileLenght);
                                                   if(!_loc7_)
                                                   {
                                                      §§push(headerPosition);
                                                      §§push(4);
                                                      if(!_loc6_)
                                                      {
                                                         §§push(--§§pop() + 1);
                                                      }
                                                      §§push(§§pop() - §§pop());
                                                      if(_loc6_)
                                                      {
                                                         §§push(§§pop() - signedDataLenght);
                                                      }
                                                      if(§§pop() != §§pop())
                                                      {
                                                         if(_loc7_)
                                                         {
                                                         }
                                                         §§push();
                                                         §§push("Longueur de fichier incorrect, " + sigFileLenght + " attendu, lu :");
                                                         §§push(headerPosition);
                                                         §§push(4);
                                                         if(_loc7_)
                                                         {
                                                            §§push((--(§§pop() - 1 - 1) - 54) * 78);
                                                         }
                                                         §§pop().trace(§§pop() + (§§pop() - §§pop() - signedDataLenght));
                                                         if(!_loc7_)
                                                         {
                                                            if(_loc7_)
                                                            {
                                                            }
                                                            §§goto(addr584);
                                                         }
                                                         §§goto(addr618);
                                                      }
                                                      var hashType:uint = sigData.readByte();
                                                      §§goto(addr541);
                                                   }
                                                   §§goto(addr669);
                                                }
                                             }
                                             §§goto(addr842);
                                          }
                                          while(true)
                                          {
                                             sigData.readInt();
                                             if(!_loc7_)
                                             {
                                                if(!_loc7_)
                                                {
                                                   §§goto(addr430);
                                                }
                                                §§goto(addr584);
                                             }
                                             break;
                                          }
                                       }
                                    }
                                    §§push(false);
                                    if(_loc6_)
                                    {
                                       return §§pop();
                                    }
                                    §§goto(addr584);
                                 }
                              }
                              break;
                           }
                           if(sigHeader != SIGNATURE_HEADER)
                           {
                              §§goto(addr404);
                           }
                           §§goto(addr447);
                        }
                        while(true)
                        {
                           §§push(input);
                           §§push("position");
                           §§push(headerPosition);
                           §§push(4);
                           if(!_loc6_)
                           {
                              §§push(-((§§pop() + 53) * 27 * 41));
                           }
                           §§pop()[§§pop()] = §§pop() - §§pop() - signedDataLenght;
                           if(!_loc6_)
                           {
                              §§goto(addr339);
                           }
                           §§goto(addr286);
                        }
                     }
                     §§push(output);
                     §§push(0);
                     if(_loc7_)
                     {
                        §§push(--(§§pop() + 27 - 13 + 51 - 1) + 1);
                     }
                     §§pop().position = §§pop();
                     if(_loc7_)
                     {
                        addr779:
                        while(true)
                        {
                           sigDate.setTime(sigData.readDouble());
                           if(_loc7_)
                           {
                           }
                           break;
                        }
                        trace(sigDate);
                        if(_loc6_)
                        {
                        }
                        if(sigHash != contentHash)
                        {
                           if(!_loc7_)
                           {
                              trace("Hash incorrect, " + sigHash + " attendu, lu :" + contentHash);
                           }
                           §§goto(addr842);
                           §§push(false);
                        }
                     }
                     while(true)
                     {
                        trace("Hash en " + (getTimer() - tsHash) + " ms");
                        if(_loc6_)
                        {
                        }
                        sigDate = new Date();
                        if(_loc6_)
                        {
                           §§goto(addr779);
                        }
                        §§goto(addr817);
                     }
                  }
                  catch(e:Error)
                  {
                     if(_loc6_)
                     {
                        trace(e.getStackTrace());
                     }
                     return false;
                  }
                  return true;
               }
            }
            while(true)
            {
               cryptedData = null;
               if(_loc7_)
               {
                  §§goto(addr187);
               }
               §§goto(addr195);
            }
         }
         while(true)
         {
            if(!_loc6_)
            {
               §§goto(addr81);
            }
            §§goto(addr204);
         }
      }
      
      public function verifySeparatedSignature(param1:IDataInput, param2:ByteArray, param3:ByteArray) : Boolean
      {
         var headerPosition:int = 0;
         var header:String = null;
         var signedDataLenght:int = 0;
         var cryptedData:ByteArray = null;
         var sigData:ByteArray = null;
         var tsDecrypt:uint = 0;
         var f:File = null;
         var fs:FileStream = null;
         var sigHeader:String = null;
         var sigVersion:uint = 0;
         var sigFileLenght:uint = 0;
         var hashType:uint = 0;
         var sigHash:String = null;
         var tsHash:uint = 0;
         var contentHash:String = null;
         var sigDate:Date = null;
         var swfContent:IDataInput = param1;
         var signatureFile:ByteArray = param2;
         var output:ByteArray = param3;
         if(!this._keyV2)
         {
            throw new SignatureError("No key for this signature version");
         }
         try
         {
            headerPosition = signatureFile.bytesAvailable - ANKAMA_SIGNED_FILE_HEADER.length;
            signatureFile["position"] = headerPosition;
            header = signatureFile.readUTFBytes(4);
            if(header != ANKAMA_SIGNED_FILE_HEADER)
            {
               return false;
            }
            signatureFile["position"] = headerPosition - 4;
            signedDataLenght = signatureFile.readShort();
            signatureFile["position"] = headerPosition - 4 - signedDataLenght;
            cryptedData = new ByteArray();
            signatureFile.readBytes(cryptedData,0,signedDataLenght);
            sigData = new ByteArray();
            tsDecrypt = getTimer();
            this._keyV2.verify(cryptedData,sigData,cryptedData.length);
            trace("Décryptage en " + (getTimer() - tsDecrypt) + " ms");
            f = new File(File.applicationDirectory.resolvePath("log.bin").nativePath);
            fs = new FileStream();
            fs.open(f,FileMode.WRITE);
            fs.writeBytes(sigData);
            fs.close();
            sigData.position = 0;
            sigHeader = sigData.readUTF();
            if(sigHeader != SIGNATURE_HEADER)
            {
               trace("Header crypté de signature incorrect, " + SIGNATURE_HEADER + " attendu, lu :" + sigHeader);
               return false;
            }
            sigVersion = sigData.readByte();
            sigData.readInt();
            sigData.readInt();
            sigFileLenght = sigData.readInt();
            if(sigFileLenght != (swfContent as ByteArray).length)
            {
               trace("Longueur de fichier incorrect, " + sigFileLenght + " attendu, lu :" + (swfContent as ByteArray).length);
               return false;
            }
            hashType = sigData.readByte();
            sigHash = sigData.readUTF();
            swfContent["position"] = 0;
            swfContent.readBytes(output,0,swfContent.bytesAvailable);
            tsHash = getTimer();
            switch(hashType)
            {
               case 0:
                  contentHash = MD5.hashBytes(output);
                  break;
               case 1:
                  contentHash = SHA256.hashBytes(output);
                  break;
               default:
                  return false;
            }
            output.position = 0;
            trace("Hash en " + (getTimer() - tsHash) + " ms");
            sigDate = new Date();
            sigDate.setTime(sigData.readDouble());
            trace(sigDate);
            if(sigHash != contentHash)
            {
               trace("Hash incorrect, " + sigHash + " attendu, lu :" + contentHash);
               return false;
            }
         }
         catch(e:Error)
         {
            trace(e.getStackTrace());
            return false;
         }
         return true;
      }
      
      private function traceData(param1:ByteArray) : void
      {
         var _loc4_:* = true;
         var _loc5_:* = false;
         §§push([]);
         if(!_loc5_)
         {
            §§push(§§pop());
         }
         var _loc2_:* = §§pop();
         §§push(0);
         if(_loc5_)
         {
            §§push(--((§§pop() + 36 - 1) * 97) + 1);
         }
         var _loc3_:uint = §§pop();
         if(_loc4_)
         {
            while(_loc3_ < param1.length)
            {
               _loc2_[_loc3_] = param1[_loc3_];
               if(_loc4_)
               {
                  §§push(_loc3_);
                  if(!_loc5_)
                  {
                     §§push(§§pop() + 1);
                  }
                  _loc3_ = §§pop();
               }
            }
            if(!_loc5_)
            {
               trace(_loc2_.join(","));
            }
         }
      }
   }
}
