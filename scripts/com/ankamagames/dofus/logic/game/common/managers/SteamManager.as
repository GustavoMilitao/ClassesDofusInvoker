package com.ankamagames.dofus.logic.game.common.managers
{
   import com.ankamagames.jerakine.logger.Logger;
   import flash.system.ApplicationDomain;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.utils.ByteArray;
   import flash.desktop.NativeApplication;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.net.URLRequestMethod;
   import flash.display.Stage;
   import flash.utils.setTimeout;
   import com.ankamagames.jerakine.json.JSONDecoder;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   
   public class SteamManager extends Object
   {
      
      public static const WEB_API_PUBLISHER_KEY:String = "20FE8C14BCF6AF6E106969EE3A02B718";
      
      private static var _self:SteamManager;
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(SteamManager));
       
      private var _steamWorks;
      
      private var _appId:uint;
      
      private var _serviceBaseUrl:String;
      
      public var steamUserId:String;
      
      public var steamUserLanguage:String;
      
      public var steamUserCountry:String;
      
      public var steamUserCurrency:String;
      
      private var _steamEmbed:Boolean = false;
      
      private var _leaderboard:String;
      
      private var _scoreDetails:int = 0;
      
      private var _authHandle:uint = 0;
      
      private var _publishedFile:String;
      
      private var _id:String;
      
      private var _ugcHandle:String;
      
      private var _authTicket:ByteArray = null;
      
      public function SteamManager()
      {
         super();
         if(_self)
         {
            throw new SingletonError();
         }
         this._steamWorks = new (getDefinitionByName("com.amanitadesign.steam::FRESteamWorks") as Class)();
      }
      
      public static function getInstance() : SteamManager
      {
         if(!_self)
         {
            _self = new SteamManager();
         }
         return _self;
      }
      
      public static function hasSteamApi() : Boolean
      {
         return ApplicationDomain.currentDomain.hasDefinition("com.amanitadesign.steam::FRESteamWorks");
      }
      
      public function init() : void
      {
         if(!this._steamWorks.init())
         {
            _log.error("Steamwork Failed to init");
            return;
         }
         NativeApplication.nativeApplication.addEventListener(Event.EXITING,this.onShutdown);
         this._steamEmbed = true;
         this._steamWorks.addEventListener(getDefinitionByName("com.amanitadesign.steam::SteamEvent").STEAM_RESPONSE,this.onSteamResponse);
         _log.debug("getEnv(\'HOME\') == " + this._steamWorks.getEnv("HOME"));
         this.steamUserId = this._steamWorks.getUserID();
         _log.debug("Steam User Id : " + this.steamUserId);
         this._appId = this._steamWorks.getAppID();
         this._serviceBaseUrl = "https://api.steampowered.com/ISteamMicroTxn/GetUserInfo/V0001/";
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.addEventListener(Event.COMPLETE,this.onUserInfos);
         var _loc2_:URLRequest = new URLRequest(this._serviceBaseUrl);
         var _loc3_:URLVariables = new URLVariables();
         _loc3_.key = WEB_API_PUBLISHER_KEY;
         _loc3_.steamid = this.steamUserId;
         _loc2_.method = URLRequestMethod.GET;
         _loc2_.data = _loc3_;
         _loc1_.load(_loc2_);
         this.getAuthSessionTicket();
      }
      
      public function addOverlayWorkaround(param1:Stage) : void
      {
         this._steamWorks.addOverlayWorkaround(param1,true);
      }
      
      private function getAuthSessionTicket(param1:Event = null) : void
      {
         var _loc2_:* = true;
         if(_loc2_)
         {
            if(!this._steamWorks.isReady)
            {
               if(!_loc3_)
               {
                  return;
               }
               addr80:
               while(true)
               {
                  if(!_loc2_)
                  {
                     break;
                  }
                  §§push(_log);
                  §§push("getAuthSessionTicket(ticket) == ");
                  if(_loc2_)
                  {
                     §§push(§§pop() + this._authHandle);
                  }
                  §§pop().debug(§§pop());
                  if(!_loc3_)
                  {
                     if(!_loc3_)
                     {
                        if(_loc2_)
                        {
                        }
                        addr60:
                        while(true)
                        {
                           this.logTicket(this._authTicket);
                        }
                     }
                     else
                     {
                        continue;
                     }
                  }
               }
               return;
            }
            while(true)
            {
               this._authTicket = new ByteArray();
               if(_loc2_)
               {
                  if(!_loc2_)
                  {
                     §§goto(addr60);
                  }
                  addr73:
                  while(true)
                  {
                     this._authHandle = this._steamWorks.getAuthSessionTicket(this._authTicket);
                  }
               }
               §§goto(addr80);
            }
         }
         while(true)
         {
            if(_loc3_)
            {
               §§goto(addr73);
            }
            §§goto(addr85);
         }
      }
      
      private function getUserScore(param1:Event = null) : void
      {
         var _loc2_:* = true;
         var _loc3_:* = false;
         if(!_loc3_)
         {
            §§push(this);
            §§push(param1);
            §§push(0);
            if(_loc3_)
            {
               §§push(§§pop() + 11 + 1 + 48);
            }
            §§pop().getScoresAroundUser(§§pop(),§§pop(),§§dup(§§pop()));
         }
      }
      
      private function getScoresAroundUser(param1:Event = null, param2:int = -4, param3:int = 5) : void
      {
         var _loc4_:* = true;
         var _loc5_:* = false;
         if(_loc4_)
         {
            if(!this._steamWorks.isReady)
            {
               if(_loc4_)
               {
                  return;
               }
            }
            else if(!this._leaderboard)
            {
               if(!_loc5_)
               {
                  _log.error("No Leaderboard handle set");
                  if(_loc4_)
                  {
                  }
                  addr66:
                  if(_loc5_)
                  {
                     addr71:
                     return;
                  }
                  return;
               }
            }
            addr45:
            §§push(_log);
            §§push("downloadLeaderboardEntries(...) == ");
            if(_loc4_)
            {
               §§push(§§pop() + this._steamWorks.downloadLeaderboardEntries(this._leaderboard,getDefinitionByName("com.amanitadesign.steam::UserStatsConstants").DATAREQUEST_GlobalAroundUser,param2,param3));
            }
            §§pop().debug(§§pop());
            §§goto(addr66);
         }
         if(_loc5_)
         {
            §§goto(addr45);
         }
         §§goto(addr71);
      }
      
      private function activateOverlay(param1:String) : void
      {
         var _loc3_:* = true;
         var _loc4_:* = false;
         if(!_loc4_)
         {
            var service:String = param1;
            if(_loc3_)
            {
            }
            addr58:
            return;
         }
         if(!this._steamWorks.isReady)
         {
            if(_loc3_)
            {
               return;
            }
         }
         else
         {
            §§push();
            §§push(function():void
            {
               var _loc1_:* = true;
               var _loc2_:* = false;
            });
            §§push(1000);
            if(_loc4_)
            {
               §§push((§§pop() * 78 + 42 - 67 + 1) * 87 - 17 + 63);
            }
            §§pop().setTimeout(§§pop(),§§pop());
         }
         §§goto(addr58);
      }
      
      private function logTicket(param1:ByteArray) : void
      {
         var _loc5_:* = true;
         var _loc6_:* = false;
         var _loc4_:String = null;
         var _loc2_:* = "";
         §§push(0);
         if(!_loc5_)
         {
            §§push(§§pop() + 89 - 1 + 1 - 1);
         }
         var _loc3_:* = §§pop();
         if(_loc5_)
         {
            while(_loc3_ < param1.length)
            {
               §§push(param1[_loc3_]);
               §§push(16);
               if(_loc6_)
               {
                  §§push(-(§§pop() * 9 - 1 - 109));
               }
               §§push(§§pop().toString(§§pop()));
               if(_loc5_)
               {
                  _loc4_ = §§pop();
                  if(_loc5_)
                  {
                     §§push(_loc2_);
                     if(_loc5_)
                     {
                        §§push(_loc4_.length);
                        §§push(2);
                        if(_loc6_)
                        {
                           §§push(§§pop() - 61 - 49 + 1 - 1);
                        }
                        if(§§pop() < §§pop())
                        {
                           if(_loc6_)
                           {
                           }
                        }
                        else
                        {
                           §§push("");
                        }
                        addr82:
                        §§push(§§pop() + (§§pop() + _loc4_));
                     }
                     _loc2_ = §§pop();
                     if(_loc6_)
                     {
                        continue;
                     }
                  }
                  _loc3_++;
                  continue;
               }
               §§push("0");
               if(!_loc6_)
               {
                  §§push(§§pop());
               }
               else
               {
                  §§goto(addr82);
               }
               §§goto(addr82);
            }
            if(_loc5_)
            {
            }
            return;
         }
         §§push(_log);
         §§push("Ticket: ");
         if(!_loc6_)
         {
            §§push(§§pop() + param1.bytesAvailable);
            if(_loc6_)
            {
            }
            addr128:
            §§pop().debug(§§pop());
            §§goto(addr129);
         }
         §§push("//");
         if(!_loc6_)
         {
            §§push(§§pop() + §§pop());
            if(_loc5_)
            {
               §§push(§§pop() + param1.length);
               if(_loc5_)
               {
               }
               §§goto(addr128);
            }
            §§push("\n");
         }
         §§push(§§pop() + §§pop());
         if(!_loc6_)
         {
            §§push(§§pop() + _loc2_);
         }
         §§goto(addr128);
      }
      
      private function onUserInfos(param1:Event) : void
      {
         var _loc4_:* = true;
         var _loc5_:* = false;
         var _loc2_:JSONDecoder = new JSONDecoder(param1.target.data,true);
         var _loc3_:* = _loc2_.getValue();
         if(!_loc5_)
         {
            this.steamUserCountry = _loc3_.response.params.country;
            if(!_loc5_)
            {
               this.steamUserCurrency = _loc3_.response.params.currency;
            }
         }
      }
      
      private function onSteamResponse(param1:*) : void
      {
         §§push(_loc2_);
         §§push(0);
         if(!_loc4_)
         {
            §§push(((§§pop() * 34 - 9 - 1) * 99 + 76) * 19 + 92);
         }
         var /*UnknownSlot*/:* = §§pop();
         if(_loc5_)
         {
            continue loop0;
         }
         continue loop21;
      }
      
      public function onShutdown(param1:Event) : void
      {
         this._steamWorks.endAuthSession(this.steamUserId);
         this._steamWorks.dispose();
      }
      
      public function isSteamEmbed() : Boolean
      {
         return this._steamEmbed;
      }
      
      public function get authTicket() : ByteArray
      {
         return this._authTicket;
      }
   }
}
