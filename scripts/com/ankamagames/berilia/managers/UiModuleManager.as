package com.ankamagames.berilia.managers
{
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.jerakine.resources.loaders.IResourceLoader;
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   import flash.filesystem.File;
   import com.ankamagames.jerakine.types.Uri;
   import com.ankamagames.berilia.utils.web.HttpServer;
   import com.ankamagames.jerakine.resources.adapters.impl.AdvancedSwfAdapter;
   import com.ankamagames.jerakine.utils.display.FrameIdManager;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.jerakine.utils.display.EnterFrameDispatcher;
   import com.ankamagames.jerakine.utils.system.AirScanner;
   import com.ankamagames.jerakine.resources.protocols.ProtocolFactory;
   import com.ankamagames.berilia.utils.ModProtocol;
   import com.ankamagames.berilia.utils.ModFlashProtocol;
   import com.ankamagames.jerakine.managers.LangManager;
   import com.ankamagames.jerakine.managers.ErrorManager;
   import com.ankamagames.berilia.types.data.UiModule;
   import com.ankamagames.berilia.types.shortcut.Shortcut;
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.berilia.api.ApiBinder;
   import com.ankamagames.berilia.types.graphic.UiRootContainer;
   import com.ankamagames.berilia.types.data.UiGroup;
   import com.ankamagames.berilia.utils.errors.UntrustedApiCallError;
   import com.ankamagames.jerakine.utils.misc.DescribeTypeCache;
   import flash.events.Event;
   import flash.utils.getTimer;
   import com.ankamagames.berilia.types.messages.AllModulesLoadedMessage;
   import com.ankamagames.jerakine.resources.adapters.impl.TxtAdapter;
   import com.ankamagames.jerakine.newCache.ICache;
   import com.ankamagames.jerakine.utils.files.FileUtils;
   import com.ankamagames.berilia.utils.UriCacheFactory;
   import com.ankamagames.jerakine.newCache.impl.Cache;
   import com.ankamagames.jerakine.newCache.garbage.LruGarbageCollector;
   import com.ankamagames.jerakine.resources.events.ResourceErrorEvent;
   import com.ankamagames.berilia.types.messages.ModuleRessourceLoadFailedMessage;
   import flash.system.LoaderContext;
   import com.ankamagames.jerakine.resources.events.ResourceLoadedEvent;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   import com.ankamagames.jerakine.utils.crypto.Signature;
   import com.ankamagames.berilia.types.data.UiData;
   import com.ankamagames.jerakine.resources.ResourceType;
   import com.ankamagames.berilia.types.data.PreCompiledUiModule;
   import flash.filesystem.FileMode;
   import by.blooddy.crypto.MD5;
   import com.ankamagames.jerakine.resources.adapters.impl.SignedFileAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.BinaryAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.AdvancedSignedFileAdapter;
   import flash.events.IOErrorEvent;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import com.ankamagames.berilia.types.messages.ModuleLoadedMessage;
   import com.ankamagames.berilia.types.shortcut.ShortcutCategory;
   import com.ankamagames.jerakine.resources.events.ResourceLoaderProgressEvent;
   import com.ankamagames.berilia.uiRender.XmlParsor;
   import com.ankamagames.berilia.types.event.ParsingErrorEvent;
   import com.ankamagames.berilia.types.messages.AllUiXmlParsedMessage;
   import com.ankamagames.berilia.types.event.ParsorEvent;
   import com.ankamagames.berilia.types.messages.UiXmlParsedMessage;
   import com.ankamagames.berilia.types.messages.UiXmlParsedErrorMessage;
   import com.ankamagames.jerakine.types.ASwf;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import com.ankamagames.jerakine.resources.loaders.ResourceLoaderFactory;
   import com.ankamagames.jerakine.resources.loaders.ResourceLoaderType;
   
   public class UiModuleManager extends Object
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(UiModuleManager));
      
      private static const _lastModulesToUnload:Array = ["Ankama_GameUiCore","Ankama_Common","Ankama_Tooltips","Ankama_ContextMenu"];
      
      private static var _self:UiModuleManager;
       
      private var _sharedDefinitionLoader:IResourceLoader;
      
      private var _sharedDefinition:ApplicationDomain;
      
      private var _useSharedDefinition:Boolean;
      
      private var _loader:IResourceLoader;
      
      private var _uiLoader:IResourceLoader;
      
      private var _scriptNum:uint;
      
      private var _modules:Array;
      
      private var _preprocessorIndex:Dictionary;
      
      private var _uiFiles:Array;
      
      private var _regImport:RegExp;
      
      private var _versions:Array;
      
      private var _clearUi:Array;
      
      private var _uiFileToLoad:uint;
      
      private var _moduleCount:uint = 0;
      
      private var _cacheLoader:IResourceLoader;
      
      private var _unparsedXml:Array;
      
      private var _unparsedXmlCount:uint;
      
      private var _unparsedXmlTotalCount:uint;
      
      private var _modulesRoot:File;
      
      private var _modulesPaths:Dictionary;
      
      private var _modulesHashs:Dictionary;
      
      private var _resetState:Boolean;
      
      private var _parserAvaibleCount:uint = 2;
      
      private var _moduleLaunchWaitForSharedDefinition:Boolean;
      
      private var _unInitializedModules:Array;
      
      private var _useHttpServer:Boolean;
      
      private var _moduleLoaders:Dictionary;
      
      private var _loadingModule:Dictionary;
      
      private var _disabledModules:Array;
      
      private var _sharedDefinitionInstance:Object;
      
      private var _timeOutFrameNumber:int;
      
      private var _waitingInit:Boolean;
      
      private var _filter:Array;
      
      private var _filterInclude:Boolean;
      
      public var isDevMode:Boolean;
      
      private var _moduleScriptLoadedRef:Dictionary;
      
      private var _uiLoaded:Dictionary;
      
      private var _loadModuleFunction:Function;
      
      public function UiModuleManager(param1:Boolean = false)
      {
         this._regImport = new RegExp("<Import *url *= *\"([^\"]*)","g");
         this._modulesHashs = new Dictionary();
         this._moduleScriptLoadedRef = new Dictionary();
         this._uiLoaded = new Dictionary();
         super();
         if(_self)
         {
            throw new SingletonError();
         }
         this._loader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
         this._loader.addEventListener(ResourceErrorEvent.ERROR,this.onLoadError,false,0,true);
         this._loader.addEventListener(ResourceLoadedEvent.LOADED,this.onLoad,false,0,true);
         this._sharedDefinitionLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.SINGLE_LOADER);
         this._sharedDefinitionLoader.addEventListener(ResourceErrorEvent.ERROR,this.onLoadError,false,0,true);
         this._sharedDefinitionLoader.addEventListener(ResourceLoadedEvent.LOADED,this.onSharedDefinitionLoad,false,0,true);
         this._uiLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
         this._uiLoader.addEventListener(ResourceErrorEvent.ERROR,this.onUiLoadError,false,0,true);
         this._uiLoader.addEventListener(ResourceLoadedEvent.LOADED,this.onUiLoaded,false,0,true);
         this._cacheLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
         this._moduleLoaders = new Dictionary();
         this._useHttpServer = false;
         if(!param1 && ApplicationDomain.currentDomain.hasDefinition("flash.net.ServerSocket"))
         {
            this._useHttpServer = true;
         }
         if(this._useHttpServer)
         {
            HttpServer.getInstance().init(File.applicationDirectory);
         }
      }
      
      public static function getInstance(param1:Boolean = false) : UiModuleManager
      {
         if(!_self)
         {
            _self = new UiModuleManager(param1);
         }
         return _self;
      }
      
      public function get unInitializedModules() : Array
      {
         return this._unInitializedModules;
      }
      
      public function get moduleCount() : uint
      {
         return this._moduleCount;
      }
      
      public function get unparsedXmlCount() : uint
      {
         return this._unparsedXmlCount;
      }
      
      public function get unparsedXmlTotalCount() : uint
      {
         return this._unparsedXmlTotalCount;
      }
      
      public function set sharedDefinitionContainer(param1:Uri) : void
      {
         var _loc2_:String = null;
         var _loc3_:Uri = null;
         this._useSharedDefinition = param1 != null;
         if(param1)
         {
            if(this._useHttpServer)
            {
               _loc2_ = HttpServer.getInstance().getUrlTo(param1.fileName);
               _loc3_ = new Uri(_loc2_);
               _log.debug("sharedDefinition.swf location: " + param1.uri + " (" + _loc2_ + ")");
               this._sharedDefinitionLoader.load(_loc3_,null,param1.fileType == "swf"?AdvancedSwfAdapter:null);
               _log.info("trying to load sharedDefinition.swf throught an httpServer");
               FrameIdManager.frameId;
               this._timeOutFrameNumber = StageShareManager.stage.frameRate * 10;
               EnterFrameDispatcher.addEventListener(this.timeOutFrameCount,"frameCount");
            }
            else
            {
               this._sharedDefinitionLoader.load(param1,null,param1.fileType == "swf"?AdvancedSwfAdapter:null);
               _log.info("trying to load sharedDefinition.swf the good ol\' way");
            }
         }
      }
      
      public function get sharedDefinition() : ApplicationDomain
      {
         return this._sharedDefinition;
      }
      
      public function get ready() : Boolean
      {
         return this._sharedDefinition != null;
      }
      
      public function get sharedDefinitionInstance() : Object
      {
         return this._sharedDefinitionInstance;
      }
      
      public function get modulesHashs() : Dictionary
      {
         return this._modulesHashs;
      }
      
      public function init(param1:Array, param2:Boolean) : void
      {
         var _loc4_:Uri = null;
         var _loc5_:File = null;
         this._filter = param1;
         this._filterInclude = param2;
         if(!this._sharedDefinition)
         {
            this._waitingInit = true;
            return;
         }
         this._moduleLaunchWaitForSharedDefinition = false;
         this._resetState = false;
         this._modules = new Array();
         this._preprocessorIndex = new Dictionary(true);
         this._scriptNum = 0;
         this._moduleCount = 0;
         this._versions = new Array();
         this._clearUi = new Array();
         this._uiFiles = new Array();
         this._modulesPaths = new Dictionary();
         this._unInitializedModules = new Array();
         this._loadingModule = new Dictionary();
         this._disabledModules = [];
         if(AirScanner.hasAir())
         {
            ProtocolFactory.addProtocol("mod",ModProtocol);
         }
         else
         {
            ProtocolFactory.addProtocol("mod",ModFlashProtocol);
         }
         var _loc3_:String = LangManager.getInstance().getEntry("config.mod.path");
         if(_loc3_.substr(0,2) != "\\\\" && _loc3_.substr(1,2) != ":/")
         {
            this._modulesRoot = new File(File.applicationDirectory.nativePath + File.separator + _loc3_);
         }
         else
         {
            this._modulesRoot = new File(_loc3_);
         }
         _loc4_ = new Uri(this._modulesRoot.nativePath + "/hash.metas");
         this._loader.load(_loc4_);
         BindsManager.getInstance().initialize();
         if(this._modulesRoot.exists)
         {
            for each(_loc5_ in this._modulesRoot.getDirectoryListing())
            {
               if(!(!_loc5_.isDirectory || _loc5_.name.charAt(0) == "."))
               {
                  if(param1.indexOf(_loc5_.name) != -1 == param2)
                  {
                     this.loadModule(_loc5_.name);
                  }
               }
            }
            return;
         }
         ErrorManager.addError("Impossible de trouver le dossier contenant les modules (url: " + LangManager.getInstance().getEntry("config.mod.path") + ")");
      }
      
      public function lightInit(param1:Vector.<UiModule>) : void
      {
         var _loc2_:UiModule = null;
         this._resetState = false;
         this._modules = new Array();
         this._modulesPaths = new Dictionary();
         for each(this._modules[_loc2_.id] in param1)
         {
            this._modulesPaths[_loc2_.id] = _loc2_.rootPath;
         }
      }
      
      public function getModules() : Array
      {
         return this._modules;
      }
      
      public function getModule(param1:String, param2:Boolean = false) : UiModule
      {
         var _loc3_:UiModule = null;
         if(this._modules)
         {
            _loc3_ = this._modules[param1];
         }
         if(!_loc3_ && param2 && this._unInitializedModules)
         {
            _loc3_ = this._unInitializedModules[param1];
         }
         return _loc3_;
      }
      
      public function get disabledModules() : Array
      {
         return this._disabledModules;
      }
      
      public function reset() : void
      {
         var _loc1_:UiModule = null;
         var _loc2_:* = 0;
         _log.warn("Reset des modules");
         this._resetState = true;
         if(this._loader)
         {
            this._loader.cancel();
         }
         if(this._cacheLoader)
         {
            this._cacheLoader.cancel();
         }
         if(this._uiLoader)
         {
            this._uiLoader.cancel();
         }
         TooltipManager.clearCache();
         for each(_loc1_ in this._modules)
         {
            if(_lastModulesToUnload.indexOf(_loc1_.id) == -1)
            {
               this.unloadModule(_loc1_.id);
            }
         }
         _loc2_ = 0;
         while(_loc2_ < _lastModulesToUnload.length)
         {
            if(this._modules[_lastModulesToUnload[_loc2_]])
            {
               this.unloadModule(_lastModulesToUnload[_loc2_]);
            }
            _loc2_++;
         }
         Shortcut.reset();
         Berilia.getInstance().reset();
         ApiBinder.reset();
         KernelEventsManager.getInstance().initialize();
         this._modules = [];
         this._uiFileToLoad = 0;
         this._scriptNum = 0;
         this._moduleCount = 0;
         this._parserAvaibleCount = 2;
         this._modulesPaths = new Dictionary();
      }
      
      public function getModulePath(param1:String) : String
      {
         return this._modulesPaths[param1];
      }
      
      public function loadModule(param1:String) : void
      {
         var _loc3_:File = null;
         var _loc4_:Uri = null;
         var _loc5_:String = null;
         var _loc6_:* = 0;
         var _loc7_:String = null;
         this.unloadModule(param1);
         var _loc2_:File = this._modulesRoot.resolvePath(param1);
         if(_loc2_.exists)
         {
            _loc3_ = this.searchDmFile(_loc2_);
            if(_loc3_)
            {
               this._moduleCount++;
               this._scriptNum++;
               if(_loc3_.nativePath.indexOf("app:/") == 0)
               {
                  _loc6_ = "app:/".length;
                  _loc7_ = _loc3_.nativePath.substring(_loc6_,_loc3_.url.length);
                  _loc4_ = new Uri(_loc7_);
                  _loc5_ = _loc7_.substr(0,_loc7_.lastIndexOf("/"));
               }
               else
               {
                  _loc4_ = new Uri(_loc3_.nativePath);
                  _loc5_ = _loc3_.parent.nativePath;
               }
               _loc4_.tag = _loc3_;
               this._modulesPaths[param1] = _loc5_;
               this._loader.load(_loc4_);
            }
            else
            {
               _log.error("Cannot found .dm or .d2ui file in " + _loc2_.url);
            }
         }
      }
      
      public function unloadModule(param1:String) : void
      {
         var uiCtr:UiRootContainer = null;
         var ui:String = null;
         var group:UiGroup = null;
         var variables:Array = null;
         var varName:String = null;
         var apiList:Vector.<Object> = null;
         var api:Object = null;
         var id:String = param1;
         if(this._modules == null)
         {
            return;
         }
         var m:UiModule = this._modules[id];
         if(!m)
         {
            return;
         }
         var moduleUiInstances:Array = [];
         for each(uiCtr in Berilia.getInstance().uiList)
         {
            if(uiCtr.uiModule == m)
            {
               moduleUiInstances.push(uiCtr.name);
            }
         }
         for each(ui in moduleUiInstances)
         {
            Berilia.getInstance().unloadUi(ui);
         }
         for each(group in m.groups)
         {
            UiGroupManager.getInstance().removeGroup(group.name);
         }
         variables = DescribeTypeCache.getVariables(m.mainClass,true);
         for each(varName in variables)
         {
            if(m.mainClass[varName] is Object)
            {
               m.mainClass[varName] = null;
            }
         }
         m.destroy();
         apiList = m.apiList;
         while(apiList.length)
         {
            api = apiList.shift();
            if(api && api.hasOwnProperty("destroy"))
            {
               try
               {
                  api["destroy"]();
               }
               catch(e:UntrustedApiCallError)
               {
                  api["destroy"](SecureCenter.ACCESS_KEY);
                  continue;
               }
            }
         }
         if(m.mainClass && m.mainClass.hasOwnProperty("unload"))
         {
            m.mainClass["unload"]();
         }
         BindsManager.getInstance().removeAllEventListeners("__module_" + m.id);
         KernelEventsManager.getInstance().removeAllEventListeners("__module_" + m.id);
         delete this._modules[id];
         this._disabledModules[id] = m;
      }
      
      public function checkSharedDefinitionHash(param1:String) : void
      {
         var _loc2_:Uri = new Uri(param1);
      }
      
      private function onTimeOut() : void
      {
         if(!_loc1_)
         {
            _log.error("SharedDefinition load Timeout");
            if(_loc2_)
            {
               if(_loc1_)
               {
                  addr31:
                  while(true)
                  {
                     EnterFrameDispatcher.removeEventListener(this.timeOutFrameCount);
                     if(_loc2_)
                     {
                     }
                  }
               }
               addr48:
               while(true)
               {
                  this.switchToNoHttpMode();
               }
            }
            while(!_loc2_)
            {
               §§goto(addr48);
            }
            return;
         }
         while(true)
         {
            if(!_loc1_)
            {
               §§goto(addr31);
            }
            §§goto(addr55);
         }
      }
      
      private function timeOutFrameCount(param1:Event) : void
      {
         var _loc4_:* = true;
         var _loc5_:* = false;
         if(_loc4_)
         {
            §§push(_loc2_._timeOutFrameNumber);
            if(!_loc5_)
            {
               §§push(§§pop() - 1);
            }
            if(!_loc5_)
            {
               _loc2_._timeOutFrameNumber = _loc3_;
            }
            if(_loc4_)
            {
               §§push(this._timeOutFrameNumber);
               §§push(0);
               if(_loc5_)
               {
                  §§push(-(§§pop() + 1 - 1 + 1));
               }
               if(§§pop() <= §§pop())
               {
                  if(_loc4_)
                  {
                     this.onTimeOut();
                  }
               }
            }
         }
      }
      
      private function launchModule() : void
      {
         var _loc10_:* = true;
         var _loc11_:* = false;
         var _loc4_:UiModule = null;
         var _loc5_:Array = null;
         §§push(0);
         if(_loc11_)
         {
            §§push(--§§pop() - 82);
         }
         var _loc7_:uint = §§pop();
         if(_loc10_)
         {
            this._moduleLaunchWaitForSharedDefinition = false;
         }
         §§push(new Array());
         if(!_loc11_)
         {
            §§push(§§pop());
         }
         var _loc1_:* = §§pop();
         if(_loc10_)
         {
            §§push(0);
            if(_loc11_)
            {
               §§push((§§pop() - 45 + 1) * 119 + 1);
            }
            if(_loc10_)
            {
               if(_loc10_)
               {
                  for each(var _loc2_ in this._unInitializedModules)
                  {
                     if(!_loc11_)
                     {
                        if(_loc2_.trusted)
                        {
                           if(_loc10_)
                           {
                              §§push(_loc1_);
                              if(_loc10_)
                              {
                                 §§pop().unshift(_loc2_);
                                 if(_loc11_)
                                 {
                                    continue;
                                 }
                              }
                           }
                           else
                           {
                              continue;
                           }
                        }
                        else
                        {
                           §§push(_loc1_);
                        }
                        §§pop().push(_loc2_);
                        continue;
                     }
                  }
               }
            }
            if(_loc11_)
            {
            }
            addr311:
            return;
         }
         while(true)
         {
            §§push(_loc1_.length);
            §§push(0);
            if(!_loc10_)
            {
               §§push(--(-(§§pop() * 57 - 24) + 1));
            }
            if(§§pop() <= §§pop())
            {
               break;
            }
            §§push(new Array());
            if(_loc10_)
            {
               §§push(§§pop());
            }
            _loc5_ = §§pop();
            if(_loc10_)
            {
               §§push(0);
               if(_loc11_)
               {
                  §§push((-(§§pop() - 74) - 1) * 35);
               }
               if(_loc10_)
               {
                  if(_loc10_)
                  {
                     while(§§hasnext(_loc1_,_loc8_))
                     {
                        if(!_loc10_)
                        {
                           addr140:
                           while(true)
                           {
                              ApiBinder.addApiData("currentUi",null);
                              if(_loc10_)
                              {
                              }
                              break;
                           }
                           §§push(ApiBinder.initApi(_loc6_.mainClass,_loc6_,this._sharedDefinition));
                           if(_loc10_)
                           {
                              §§push(§§pop());
                              if(!_loc11_)
                              {
                                 if(_loc11_)
                                 {
                                 }
                                 §§push(_loc3_);
                              }
                           }
                           if(§§pop())
                           {
                              _loc4_ = _loc6_;
                              if(!_loc11_)
                              {
                                 _loc5_.push(_loc6_);
                              }
                              continue;
                           }
                           if(_loc6_.mainClass)
                           {
                              delete this._unInitializedModules[_loc6_.id];
                              if(_loc11_)
                              {
                                 addr205:
                                 while(true)
                                 {
                                    ErrorManager.tryFunction(_loc6_.mainClass.main,null,"Une erreur est survenue lors de l\'appel à la fonction main() du module " + _loc6_.id);
                                    if(_loc10_)
                                    {
                                    }
                                    break;
                                 }
                                 continue;
                              }
                              while(true)
                              {
                                 _loc7_ = getTimer();
                                 if(_loc10_)
                                 {
                                    §§goto(addr205);
                                 }
                                 §§goto(addr230);
                              }
                           }
                           else
                           {
                              §§push(_log);
                              §§push("Impossible d\'instancier la classe principale du module ");
                              if(!_loc11_)
                              {
                                 §§push(§§pop() + _loc6_.id);
                              }
                              §§pop().error(§§pop());
                              continue;
                           }
                        }
                        while(true)
                        {
                           if(_loc10_)
                           {
                              §§goto(addr140);
                           }
                           §§goto(addr164);
                        }
                     }
                  }
               }
               if(!_loc11_)
               {
                  §§push(_loc5_);
                  if(_loc10_)
                  {
                     if(§§pop().length == _loc1_.length)
                     {
                        if(_loc10_)
                        {
                           §§push(ErrorManager);
                           §§push("Le module ");
                           if(_loc10_)
                           {
                              §§push(_loc4_.id);
                              if(!_loc11_)
                              {
                                 §§push(§§pop() + §§pop());
                                 if(!_loc11_)
                                 {
                                    §§push(§§pop() + " demande une référence vers un module inexistant : ");
                                    if(_loc11_)
                                    {
                                    }
                                 }
                                 §§push(_loc3_);
                              }
                              §§push(§§pop() + §§pop());
                           }
                           §§pop().addError(§§pop());
                           if(_loc11_)
                           {
                              continue;
                           }
                        }
                     }
                     §§push(_loc5_);
                     if(!_loc11_)
                     {
                        §§push(§§pop());
                     }
                  }
                  _loc1_ = §§pop();
               }
            }
         }
         if(!_loc11_)
         {
            Berilia.getInstance().handler.process(new AllModulesLoadedMessage());
         }
         §§goto(addr311);
      }
      
      private function launchUiCheck() : void
      {
         var _loc1_:* = true;
         var _loc2_:* = false;
         if(!_loc2_)
         {
            this._uiFileToLoad = this._uiFiles.length;
            if(_loc1_)
            {
            }
            addr34:
            this._uiLoader.load(this._uiFiles,null,TxtAdapter);
            addr47:
            if(_loc2_)
            {
            }
            return;
         }
         if(this._uiFiles.length)
         {
            if(_loc1_)
            {
               §§goto(addr34);
            }
         }
         else
         {
            this.onAllUiChecked(null);
         }
         §§goto(addr47);
      }
      
      private function processCachedFiles(param1:Array) : void
      {
         var _loc8_:* = false;
         var _loc9_:* = true;
         var _loc2_:Uri = null;
         var _loc3_:Uri = null;
         var _loc4_:ICache = null;
         if(_loc9_)
         {
            §§push(0);
            if(_loc8_)
            {
               §§push(-(§§pop() + 1 - 1) - 1 - 117 + 1 - 1);
            }
            if(!_loc8_)
            {
               if(_loc9_)
               {
                  for each(_loc3_ in param1)
                  {
                     if(!_loc8_)
                     {
                        if(!_loc8_)
                        {
                           §§push("css");
                           if(!_loc8_)
                           {
                              if(§§pop() === _loc7_)
                              {
                                 if(!_loc8_)
                                 {
                                    §§push(0);
                                    if(_loc8_)
                                    {
                                       §§push(--(-§§pop() + 86) + 6);
                                    }
                                 }
                                 addr202:
                                 switch(§§pop())
                                 {
                                    case 0:
                                       CssManager.getInstance().load(_loc3_.uri);
                                       if(_loc9_)
                                       {
                                          addr64:
                                       }
                                       continue;
                                    case 1:
                                    case 2:
                                       _loc2_ = new Uri(FileUtils.getFilePath(_loc3_.normalizedUri));
                                       _loc4_ = UriCacheFactory.getCacheFromUri(_loc2_);
                                       if(!_loc4_)
                                       {
                                          if(!_loc8_)
                                          {
                                             _loc4_ = UriCacheFactory.init(_loc2_.uri,new Cache(param1.length,new LruGarbageCollector()));
                                          }
                                          addr106:
                                          continue;
                                       }
                                       this._cacheLoader.load(_loc3_,_loc4_);
                                       if(!_loc8_)
                                       {
                                          §§goto(addr106);
                                       }
                                       else
                                       {
                                          break;
                                       }
                                    default:
                                       §§push(ErrorManager);
                                       §§push("Impossible de mettre en cache le fichier ");
                                       if(!_loc8_)
                                       {
                                          §§push(§§pop() + _loc3_.uri);
                                          if(_loc9_)
                                          {
                                             §§push(§§pop() + ", le type n\'est pas supporté (uniquement css, jpg et png)");
                                          }
                                       }
                                       §§pop().addError(§§pop());
                                 }
                                 continue;
                              }
                              §§push("jpg");
                              if(!_loc8_)
                              {
                                 if(§§pop() === _loc7_)
                                 {
                                    if(_loc9_)
                                    {
                                       §§push(1);
                                       if(!_loc9_)
                                       {
                                          §§push(-((§§pop() + 1 + 84) * 100 - 6) - 39 + 1);
                                       }
                                    }
                                    §§goto(addr202);
                                 }
                                 else
                                 {
                                    §§push("png");
                                 }
                              }
                           }
                           if(§§pop() !== _loc7_)
                           {
                              §§push(3);
                              if(_loc8_)
                              {
                                 §§push(-(§§pop() * 82 * 86));
                              }
                           }
                           §§goto(addr202);
                        }
                        §§push(2);
                        if(!_loc9_)
                        {
                           §§push((§§pop() + 59 - 95 - 1 - 1) * 55);
                        }
                        §§goto(addr202);
                     }
                     §§goto(addr64);
                  }
               }
            }
         }
      }
      
      private function onLoadError(param1:ResourceErrorEvent) : void
      {
         var _loc5_:* = true;
         var _loc6_:* = false;
         if(_loc5_)
         {
            §§push(_log);
            §§push("onLoadError() - ");
            if(!_loc6_)
            {
               §§push(§§pop() + param1.errorMsg);
            }
            §§pop().error(§§pop());
         }
         var _loc2_:Uri = new Uri(HttpServer.getInstance().getUrlTo("SharedDefinitions.swf"));
         if(!_loc6_)
         {
            if(param1.uri == _loc2_)
            {
               if(!_loc6_)
               {
                  this.switchToNoHttpMode();
                  if(_loc6_)
                  {
                     addr68:
                     §§push(param1.uri.fileType);
                  }
                  addr234:
                  return;
               }
            }
            else
            {
               §§push(param1.uri.fileType);
               if(!_loc6_)
               {
                  if(§§pop() != "metas")
                  {
                     if(!_loc6_)
                     {
                        Berilia.getInstance().handler.process(new ModuleRessourceLoadFailedMessage(param1.uri.tag,param1.uri));
                        if(_loc6_)
                        {
                        }
                        §§goto(addr234);
                     }
                  }
                  §§goto(addr68);
               }
            }
            if(_loc5_)
            {
               §§push("swfs");
               if(_loc5_)
               {
                  if(§§pop() === _loc3_)
                  {
                     if(_loc6_)
                     {
                     }
                     addr232:
                     switch(§§pop())
                     {
                        case 0:
                           §§push(ErrorManager);
                           §§push("Impossible de charger le fichier ");
                           if(!_loc6_)
                           {
                              §§push(§§pop() + param1.uri);
                              if(!_loc6_)
                              {
                                 §§push(" (");
                                 if(!_loc6_)
                                 {
                                    §§push(§§pop() + §§pop());
                                    if(!_loc6_)
                                    {
                                       §§push(§§pop() + param1.errorMsg);
                                       if(!_loc6_)
                                       {
                                          §§push(")");
                                       }
                                    }
                                 }
                                 §§push(§§pop() + §§pop());
                              }
                           }
                           §§pop().addError(§§pop());
                           if(_loc5_)
                           {
                              §§push(_loc3_._scriptNum - 1);
                              if(_loc5_)
                              {
                                 §§push(_loc4_);
                                 if(!_loc6_)
                                 {
                                    _loc3_._scriptNum = _loc4_;
                                 }
                              }
                              if(!§§pop())
                              {
                                 if(_loc6_)
                                 {
                                 }
                              }
                              addr127:
                              §§goto(addr234);
                           }
                           this.launchUiCheck();
                           if(!_loc6_)
                           {
                              §§goto(addr127);
                           }
                           else
                           {
                              break;
                           }
                        case 1:
                           §§goto(addr234);
                        default:
                           §§push(ErrorManager);
                           §§push("Impossible de charger le fichier ");
                           if(_loc5_)
                           {
                              §§push(§§pop() + param1.uri);
                              if(_loc6_)
                              {
                              }
                              addr156:
                              §§pop().addError(§§pop());
                              break;
                           }
                           §§push(" (");
                           if(_loc5_)
                           {
                              §§push(§§pop() + §§pop());
                              if(!_loc6_)
                              {
                                 §§push(§§pop() + param1.errorMsg);
                                 if(!_loc6_)
                                 {
                                    §§push(")");
                                 }
                              }
                              §§goto(addr156);
                           }
                           §§goto(addr156);
                           §§push(§§pop() + §§pop());
                     }
                     §§goto(addr234);
                  }
                  else
                  {
                     §§push("metas");
                  }
                  addr192:
                  §§push(1);
                  if(!_loc5_)
                  {
                     §§push(-(-(§§pop() * 5) - 1 + 1 + 26) * 64);
                  }
                  if(!_loc6_)
                  {
                     addr207:
                  }
                  §§goto(addr232);
               }
               if(§§pop() === _loc3_)
               {
                  §§goto(addr192);
               }
               else
               {
                  §§push(2);
                  if(!_loc5_)
                  {
                     §§push(-((§§pop() + 25) * 98 - 34 + 23) + 107);
                  }
               }
               §§goto(addr232);
            }
            §§push(0);
            if(_loc6_)
            {
               §§push(((-§§pop() - 34 + 1) * 82 - 1) * 52);
            }
            if(!_loc5_)
            {
               §§goto(addr207);
            }
            §§goto(addr232);
         }
         §§goto(addr234);
      }
      
      private function switchToNoHttpMode() : void
      {
         var _loc2_:* = false;
         var _loc3_:* = true;
         if(_loc3_)
         {
            this._useHttpServer = false;
            if(_loc2_)
            {
            }
            addr30:
            addr33:
            this._sharedDefinitionLoader.cancel();
            var _loc1_:Uri = new Uri("SharedDefinitions.swf");
            if(_loc3_)
            {
               _loc1_.loaderContext = new LoaderContext(false,new ApplicationDomain());
               if(!_loc2_)
               {
                  this.sharedDefinitionContainer = _loc1_;
               }
            }
            return;
         }
         _log.fatal("Failed Loading SharedDefinitions, Going no HttpServer Style !");
         if(!_loc2_)
         {
            §§goto(addr30);
         }
         §§goto(addr33);
      }
      
      private function onUiLoadError(param1:ResourceErrorEvent) : void
      {
         var _loc4_:* = false;
         var _loc5_:* = true;
         if(!_loc4_)
         {
            §§push(ErrorManager);
            §§push("Impossible de charger le fichier d\'interface ");
            if(_loc5_)
            {
               §§push(§§pop() + param1.uri);
               if(_loc5_)
               {
               }
               addr41:
               §§pop().addError(§§pop() + ")");
               if(_loc5_)
               {
                  Berilia.getInstance().handler.process(new ModuleRessourceLoadFailedMessage(param1.uri.tag,param1.uri));
                  if(_loc4_)
                  {
                  }
                  addr78:
                  return;
               }
            }
            §§push(" (");
            if(_loc5_)
            {
               §§push(§§pop() + §§pop());
               if(_loc5_)
               {
                  §§push(§§pop() + param1.errorMsg);
                  if(!_loc4_)
                  {
                     §§goto(addr41);
                  }
               }
               §§goto(addr41);
            }
            §§goto(addr41);
         }
         if(_loc5_)
         {
            _loc2_._uiFileToLoad = _loc3_;
         }
         §§goto(addr78);
      }
      
      private function onLoad(param1:ResourceLoadedEvent) : void
      {
         var _loc3_:* = false;
         var _loc4_:* = true;
         if(!_loc3_)
         {
            if(this._resetState)
            {
               if(_loc4_)
               {
               }
            }
            else
            {
               §§push("swf");
               if(!_loc3_)
               {
                  if(§§pop() === _loc2_)
                  {
                     if(!_loc3_)
                     {
                        §§push(0);
                        if(_loc3_)
                        {
                           §§push(-((§§pop() - 94 - 1 - 1 - 89) * 100) - 56);
                        }
                     }
                     else
                     {
                        addr106:
                        §§push(2);
                        if(!_loc4_)
                        {
                           §§push(§§pop() - 1 + 1 + 2);
                        }
                     }
                  }
                  else
                  {
                     §§push("swfs");
                     if(_loc4_)
                     {
                        if(§§pop() === _loc2_)
                        {
                           §§push(1);
                           if(!_loc4_)
                           {
                              §§push((§§pop() + 1 + 4 - 1) * 55 - 1);
                           }
                        }
                        else
                        {
                           §§push("d2ui");
                           if(_loc4_)
                           {
                           }
                        }
                     }
                     addr135:
                     if(§§pop() === _loc2_)
                     {
                        addr137:
                        §§push(4);
                        if(!_loc4_)
                        {
                           §§push(-(§§pop() - 1 + 1 - 87 + 1) + 111 + 1);
                        }
                     }
                     else
                     {
                        addr151:
                        if("metas" === _loc2_)
                        {
                           §§push(5);
                           if(_loc3_)
                           {
                              §§push(-§§pop() * 99 * 41 * 67 - 1 - 1);
                           }
                        }
                        else
                        {
                           §§push(6);
                           if(!_loc4_)
                           {
                              §§push(-(--(-§§pop() + 45) * 94) - 18);
                           }
                        }
                     }
                  }
                  addr189:
                  switch(§§pop())
                  {
                     case 0:
                     case 1:
                        this.onScriptLoad(param1);
                        if(!_loc3_)
                        {
                           §§goto(addr191);
                        }
                        else
                        {
                           break;
                        }
                     case 2:
                     case 3:
                        this.onDMLoad(param1);
                        if(_loc4_)
                        {
                           §§goto(addr191);
                        }
                        else
                        {
                           break;
                        }
                     case 4:
                        this.onShortcutLoad(param1);
                        if(_loc4_)
                        {
                           break;
                        }
                        addr47:
                        §§goto(addr191);
                     case 5:
                        this.onHashLoaded(param1);
                        §§goto(addr47);
                     default:
                        addr191:
                        return;
                  }
               }
               if(§§pop() === _loc2_)
               {
                  if(_loc4_)
                  {
                     §§goto(addr106);
                  }
                  §§goto(addr189);
               }
               else
               {
                  §§push("dm");
                  if(_loc4_)
                  {
                     if(§§pop() === _loc2_)
                     {
                        §§push(3);
                        if(_loc3_)
                        {
                           §§push(-(-(§§pop() - 1 - 1) * 23) + 1 - 1);
                        }
                     }
                     else
                     {
                        §§push("xml");
                        if(_loc3_)
                        {
                        }
                        §§goto(addr151);
                     }
                     §§goto(addr189);
                  }
                  §§goto(addr135);
               }
               §§goto(addr137);
            }
            §§goto(addr191);
         }
      }
      
      private function onDMLoad(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:UiModule = null;
         var _loc13_:ByteArray = null;
         var _loc14_:Signature = null;
         var _loc15_:Uri = null;
         var _loc16_:String = null;
         var _loc17_:UiData = null;
         var _loc18_:Array = null;
         var _loc19_:File = null;
         if(!_loc25_)
         {
            if(param1.resourceType != ResourceType.RESOURCE_XML)
            {
               _loc2_ = PreCompiledUiModule.fromRaw(param1.resource,FileUtils.getFilePath(param1.uri.path),File(param1.uri.tag).parent.name);
            }
            addr109:
            this._unInitializedModules[_loc2_.id] = _loc2_;
            if(_loc24_)
            {
               addr118:
               §§push(_loc2_.script);
               if(_loc24_)
               {
                  if(§§pop())
                  {
                     if(!_loc25_)
                     {
                        §§push(unescape(_loc2_.script));
                     }
                  }
                  addr701:
                  §§push(new Array());
                  if(_loc24_)
                  {
                     §§push(§§pop());
                  }
                  if(!_loc25_)
                  {
                     if(!(_loc2_ is PreCompiledUiModule))
                     {
                        if(_loc24_)
                        {
                        }
                     }
                     addr791:
                     var _loc5_:File = this._modulesRoot.resolvePath(_loc2_.id);
                     if(_loc24_)
                     {
                        §§push(new Array());
                        if(_loc24_)
                        {
                           §§push(§§pop());
                        }
                        if(_loc24_)
                        {
                           §§push(0);
                           if(!_loc24_)
                           {
                              §§push((§§pop() + 1 - 15 + 117) * 22 - 7);
                           }
                           if(!_loc25_)
                           {
                              if(_loc24_)
                              {
                                 for each(var _loc7_ in _loc2_.cachedFiles)
                                 {
                                    if(_loc5_.resolvePath(_loc7_).exists)
                                    {
                                       if(!_loc25_)
                                       {
                                          if(!_loc6_.isDirectory)
                                          {
                                             if(_loc24_)
                                             {
                                                §§push(_loc4_);
                                                if(_loc24_)
                                                {
                                                   §§push();
                                                   §§push("mod://");
                                                   if(!_loc25_)
                                                   {
                                                      §§push(_loc2_.id);
                                                      if(_loc24_)
                                                      {
                                                         §§push(§§pop() + §§pop());
                                                         if(_loc25_)
                                                         {
                                                         }
                                                         addr876:
                                                         §§pop().push(new §§pop().Uri(§§pop()));
                                                         if(_loc24_)
                                                         {
                                                            continue;
                                                         }
                                                      }
                                                      addr875:
                                                      §§goto(addr876);
                                                      §§push(§§pop() + §§pop());
                                                   }
                                                   §§push(§§pop() + "/");
                                                   if(!_loc25_)
                                                   {
                                                      §§goto(addr875);
                                                      §§push(_loc7_);
                                                   }
                                                   §§goto(addr876);
                                                }
                                             }
                                          }
                                          else
                                          {
                                             §§push(_loc6_.getDirectoryListing());
                                          }
                                          _loc18_ = §§pop();
                                          if(!_loc24_)
                                          {
                                             continue;
                                          }
                                       }
                                       §§push(0);
                                       if(_loc25_)
                                       {
                                          §§push(-§§pop() + 1 - 1 + 53 + 1);
                                       }
                                       if(_loc24_)
                                       {
                                          if(!_loc25_)
                                          {
                                             for each(_loc19_ in _loc18_)
                                             {
                                                if(!_loc19_.isDirectory)
                                                {
                                                   if(!_loc24_)
                                                   {
                                                      continue;
                                                   }
                                                }
                                                §§push(_loc4_);
                                                §§push();
                                                §§push("mod://");
                                                if(!_loc25_)
                                                {
                                                   §§push(_loc2_.id);
                                                   if(_loc24_)
                                                   {
                                                      §§push(§§pop() + §§pop());
                                                      if(_loc24_)
                                                      {
                                                         §§push("/");
                                                         if(!_loc25_)
                                                         {
                                                            §§push(§§pop() + §§pop());
                                                            if(!_loc25_)
                                                            {
                                                               §§push(_loc7_);
                                                               if(_loc24_)
                                                               {
                                                                  §§push(§§pop() + §§pop());
                                                                  if(!_loc25_)
                                                                  {
                                                                     §§push("/");
                                                                  }
                                                               }
                                                            }
                                                         }
                                                         §§push(§§pop() + §§pop());
                                                         if(_loc24_)
                                                         {
                                                         }
                                                      }
                                                      addr961:
                                                      §§pop().push(new §§pop().Uri(§§pop()));
                                                      continue;
                                                   }
                                                   addr960:
                                                   §§goto(addr961);
                                                   §§push(§§pop() + §§pop());
                                                }
                                                §§goto(addr960);
                                                §§push(FileUtils.getFileName(_loc19_.url));
                                             }
                                          }
                                       }
                                    }
                                 }
                              }
                           }
                           if(!_loc25_)
                           {
                              this.processCachedFiles(_loc4_);
                           }
                        }
                     }
                     return;
                  }
                  §§push(0);
                  if(_loc25_)
                  {
                     §§push(-(§§pop() - 114 + 1) - 57);
                  }
                  if(_loc24_)
                  {
                     if(_loc24_)
                     {
                        for each(_loc17_ in _loc2_.uis)
                        {
                           if(_loc17_.file)
                           {
                              if(!_loc25_)
                              {
                                 if(!_loc24_)
                                 {
                                    addr758:
                                    while(true)
                                    {
                                       this._uiFiles.push(_loc3_);
                                       if(!_loc25_)
                                       {
                                          if(!_loc25_)
                                          {
                                             break;
                                          }
                                       }
                                    }
                                    continue;
                                 }
                                 while(true)
                                 {
                                    _loc3_.tag = {
                                       "mod":_loc2_.id,
                                       "base":_loc17_.file
                                    };
                                 }
                              }
                              while(!_loc25_)
                              {
                                 §§goto(addr758);
                              }
                              continue;
                           }
                        }
                     }
                     if(_loc25_)
                     {
                     }
                  }
                  §§goto(addr791);
               }
            }
            if(_loc24_)
            {
               if(Berilia.getInstance().checkModuleAuthority)
               {
                  if(!_loc25_)
                  {
                     §§push(_log);
                     §§push("hash ");
                     if(_loc24_)
                     {
                        §§push(§§pop() + _loc9_);
                     }
                     §§pop().debug(§§pop());
                     if(_loc10_.exists)
                     {
                        _loc11_.open(_loc10_,FileMode.READ);
                        if(_loc25_)
                        {
                           addr174:
                           while(true)
                           {
                              _loc11_.close();
                              if(_loc25_)
                              {
                              }
                              break;
                           }
                           §§push(_loc9_.fileType);
                           if(!_loc25_)
                           {
                              §§push("swf");
                              if(_loc24_)
                              {
                                 if(§§pop() == §§pop())
                                 {
                                    if(_loc24_)
                                    {
                                       if(_loc24_)
                                       {
                                       }
                                       _loc2_.trusted = MD5.hashBytes(_loc12_) == this._modulesHashs[_loc9_.fileName];
                                       §§push(_loc2_.trusted);
                                       if(_loc24_)
                                       {
                                          if(!§§pop())
                                          {
                                             §§push(_log);
                                             §§push("Hash incorrect pour le module ");
                                             if(!_loc25_)
                                             {
                                                §§push(§§pop() + _loc2_.id);
                                             }
                                             §§pop().error(§§pop());
                                          }
                                          addr315:
                                       }
                                       addr463:
                                       addr700:
                                       if(!§§pop())
                                       {
                                          §§push(File.applicationDirectory.nativePath.split("\\").join("/"));
                                          if(!_loc25_)
                                          {
                                             _loc16_ = §§pop();
                                             §§push(_loc8_);
                                             if(_loc24_)
                                             {
                                                §§push(_loc16_);
                                                if(_loc24_)
                                                {
                                                   §§push(§§pop().indexOf(§§pop()));
                                                   §§push(-1);
                                                   if(_loc25_)
                                                   {
                                                      §§push(-(§§pop() * 48 - 55 + 1 - 24) + 111);
                                                   }
                                                   if(§§pop() != §§pop())
                                                   {
                                                      §§push(_loc8_);
                                                      if(!_loc25_)
                                                      {
                                                         §§push(_loc8_);
                                                      }
                                                   }
                                                   addr520:
                                                   §§push(HttpServer.getInstance().getUrlTo(_loc8_));
                                                }
                                                §§push(§§pop().substr(§§pop().indexOf(_loc16_) + _loc16_.length));
                                             }
                                          }
                                          if(_loc25_)
                                          {
                                          }
                                          §§goto(addr520);
                                       }
                                       else
                                       {
                                          if(_loc2_.trusted)
                                          {
                                             _loc9_.tag = _loc2_.id;
                                             if(_loc24_)
                                             {
                                                if(_loc25_)
                                                {
                                                }
                                                _loc9_.loaderContext = new LoaderContext();
                                             }
                                             if(_loc25_)
                                             {
                                                while(true)
                                                {
                                                   §§push(_log);
                                                   §§push("[Classic] Load ");
                                                   if(_loc24_)
                                                   {
                                                      §§push(§§pop() + _loc9_);
                                                   }
                                                   §§pop().trace(§§pop());
                                                   if(_loc24_)
                                                   {
                                                      if(_loc25_)
                                                      {
                                                         addr602:
                                                         while(true)
                                                         {
                                                            this._loadingModule[_loc2_] = _loc2_.id;
                                                            if(!_loc25_)
                                                            {
                                                               break;
                                                            }
                                                         }
                                                         continue;
                                                      }
                                                      addr626:
                                                      §§push(this._loader);
                                                      §§push(_loc9_);
                                                      §§push(null);
                                                      if(_loc24_)
                                                      {
                                                         if(_loc9_.fileType == "swfs")
                                                         {
                                                            §§push(AdvancedSignedFileAdapter);
                                                         }
                                                         addr641:
                                                         §§pop().load(§§pop(),§§pop(),§§pop());
                                                         if(_loc25_)
                                                         {
                                                         }
                                                         §§goto(addr701);
                                                      }
                                                      §§goto(addr641);
                                                      §§push(BinaryAdapter);
                                                   }
                                                   else
                                                   {
                                                      break;
                                                   }
                                                }
                                             }
                                             while(true)
                                             {
                                                _loc9_.loaderContext.applicationDomain = new ApplicationDomain(this._sharedDefinition);
                                                if(_loc24_)
                                                {
                                                   §§goto(addr602);
                                                }
                                                §§goto(addr626);
                                             }
                                          }
                                          else if(!_loc25_)
                                          {
                                             this._moduleCount--;
                                          }
                                          if(_loc24_)
                                          {
                                             this._scriptNum--;
                                          }
                                          §§push(ErrorManager);
                                          §§push("Failed to load custom module ");
                                          if(!_loc25_)
                                          {
                                             §§push(_loc2_.author);
                                             if(!_loc25_)
                                             {
                                                §§push(§§pop() + §§pop());
                                                if(!_loc25_)
                                                {
                                                   §§push("_");
                                                   if(!_loc25_)
                                                   {
                                                      §§push(§§pop() + §§pop());
                                                      if(_loc25_)
                                                      {
                                                      }
                                                   }
                                                   addr698:
                                                   §§pop().addError(§§pop() + §§pop());
                                                }
                                                addr697:
                                                §§goto(addr698);
                                                §§push(", because the local HTTP server is not available.");
                                             }
                                             addr693:
                                             §§push(§§pop() + §§pop());
                                             if(!_loc25_)
                                             {
                                                §§goto(addr697);
                                             }
                                             §§goto(addr698);
                                          }
                                          §§goto(addr693);
                                          §§push(_loc2_.name);
                                       }
                                       return;
                                    }
                                    addr428:
                                    return;
                                 }
                                 §§push(_loc9_.fileType);
                                 §§push("swfs");
                                 if(_loc25_)
                                 {
                                 }
                                 addr462:
                                 §§goto(addr463);
                                 §§push(§§pop() == §§pop());
                              }
                              if(§§pop() == §§pop())
                              {
                                 _loc13_ = new ByteArray();
                                 _loc14_ = new Signature(SignedFileAdapter.defaultSignatureKey);
                                 if(!_loc14_.verify(_loc12_,_loc13_))
                                 {
                                    if(!_loc25_)
                                    {
                                       §§push(_log);
                                       §§push("Invalid signature in ");
                                       if(!_loc25_)
                                       {
                                          §§push(§§pop() + _loc10_.nativePath);
                                       }
                                       §§pop().fatal(§§pop());
                                       if(_loc24_)
                                       {
                                       }
                                       addr311:
                                       return;
                                    }
                                    if(_loc24_)
                                    {
                                       _loc20_._moduleCount = _loc21_;
                                    }
                                    if(_loc24_)
                                    {
                                       if(_loc24_)
                                       {
                                          _loc20_._scriptNum = _loc21_;
                                       }
                                       if(_loc24_)
                                       {
                                          _loc2_.trusted = false;
                                          if(_loc25_)
                                          {
                                          }
                                       }
                                       §§goto(addr311);
                                    }
                                 }
                                 else
                                 {
                                    _loc2_.trusted = true;
                                 }
                              }
                              §§goto(addr315);
                           }
                           if(_loc24_)
                           {
                              if(_loc25_)
                              {
                                 addr533:
                                 while(true)
                                 {
                                    this._loadModuleFunction(_loc8_,this.onModuleScriptLoaded,this.onScriptLoadFail,_loc2_);
                                    if(_loc24_)
                                    {
                                    }
                                    break;
                                 }
                                 §§goto(addr701);
                              }
                              while(true)
                              {
                                 §§push(_log);
                                 §§push("[WebServer] Load ");
                                 if(!_loc25_)
                                 {
                                    §§push(§§pop() + _loc8_);
                                 }
                                 §§pop().trace(§§pop());
                                 if(_loc24_)
                                 {
                                    §§goto(addr533);
                                 }
                                 §§goto(addr559);
                              }
                           }
                           else
                           {
                              §§goto(addr700);
                           }
                        }
                        while(true)
                        {
                           if(_loc25_)
                           {
                           }
                           _loc11_.readBytes(_loc12_);
                           if(!_loc25_)
                           {
                              §§goto(addr174);
                           }
                           §§goto(addr199);
                        }
                     }
                     else
                     {
                        §§push(ErrorManager);
                        §§push("Le script du module ");
                        if(_loc24_)
                        {
                           §§push(§§pop() + _loc2_.id);
                           if(_loc24_)
                           {
                           }
                           addr332:
                           §§push(§§pop() + _loc10_.nativePath);
                           if(_loc24_)
                           {
                              addr338:
                              §§push(§§pop() + ")");
                           }
                           §§pop().addError(§§pop());
                           if(_loc24_)
                           {
                              _loc20_._moduleCount = _loc21_;
                           }
                           if(_loc24_)
                           {
                              _loc20_._scriptNum = _loc21_;
                           }
                           if(_loc24_)
                           {
                              _loc2_.trusted = false;
                           }
                           return;
                        }
                        §§push(" est introuvable (url: ");
                        if(!_loc25_)
                        {
                           §§push(§§pop() + §§pop());
                           if(_loc24_)
                           {
                              §§goto(addr332);
                           }
                           §§goto(addr338);
                        }
                        §§goto(addr338);
                     }
                  }
               }
               else
               {
                  _loc2_.trusted = true;
               }
            }
            if(!_loc2_.enable)
            {
               §§push(_log);
               §§push("Le module ");
               if(!_loc25_)
               {
                  §§push(§§pop() + _loc2_.id);
                  if(_loc24_)
                  {
                  }
                  addr394:
                  §§pop().fatal(§§pop());
                  if(_loc24_)
                  {
                     _loc20_._moduleCount = _loc21_;
                  }
                  if(_loc24_)
                  {
                     _loc20_._scriptNum = _loc21_;
                  }
                  this._disabledModules[_loc2_.id] = _loc2_;
                  §§goto(addr428);
               }
               §§goto(addr394);
               §§push(§§pop() + " est désactivé");
            }
            else
            {
               if(_loc2_.shortcuts)
               {
                  _loc15_ = new Uri(_loc2_.shortcuts);
                  _loc15_.tag = _loc2_.id;
                  if(_loc24_)
                  {
                     this._loader.load(_loc15_);
                  }
               }
               §§push(this._useHttpServer);
               if(_loc24_)
               {
                  if(§§dup(§§pop()))
                  {
                     if(_loc24_)
                     {
                        §§pop();
                        §§goto(addr462);
                        §§push(_loc9_.fileType);
                        §§push("swfs");
                     }
                  }
                  §§goto(addr463);
               }
               §§goto(addr463);
            }
         }
         _loc2_ = UiModule.createFromXml(param1.resource as XML,FileUtils.getFilePath(param1.uri.path),File(param1.uri.tag).parent.name);
         if(_loc24_)
         {
            §§goto(addr109);
         }
         §§goto(addr118);
      }
      
      private function onScriptLoadFail(param1:IOErrorEvent, param2:UiModule) : void
      {
         var _loc5_:* = true;
         var _loc6_:* = false;
         if(!_loc6_)
         {
            §§push(_log);
            §§push("Le script du module ");
            if(!_loc6_)
            {
               §§push(§§pop() + param2.id);
               if(_loc5_)
               {
               }
               addr32:
               §§pop().error(§§pop());
               addr59:
               addr61:
               if(_loc6_)
               {
               }
               this.launchUiCheck();
               return;
            }
            §§goto(addr32);
            §§push(§§pop() + " est introuvable");
         }
         §§push(_loc3_._scriptNum - 1);
         if(_loc5_)
         {
            §§push(_loc4_);
            if(!_loc6_)
            {
               _loc3_._scriptNum = _loc4_;
            }
         }
         if(!§§pop())
         {
            if(_loc5_)
            {
               §§goto(addr59);
            }
         }
         §§goto(addr61);
      }
      
      private function onScriptLoad(param1:ResourceLoadedEvent) : void
      {
         var _loc5_:* = true;
         var _loc6_:* = false;
         if(!_loc6_)
         {
            this._moduleScriptLoadedRef[_loc3_] = _loc2_;
         }
         var _loc4_:LoaderContext = new LoaderContext(false,new ApplicationDomain(this._sharedDefinition));
         if(_loc5_)
         {
            AirScanner.allowByteCodeExecution(_loc4_,true);
            if(!_loc6_)
            {
               if(!_loc5_)
               {
                  loop0:
                  while(true)
                  {
                     _loc3_.loadBytes(param1.resource as ByteArray,_loc4_);
                     if(_loc6_)
                     {
                     }
                     addr84:
                     while(true)
                     {
                        if(_loc6_)
                        {
                           break loop0;
                        }
                        continue loop0;
                     }
                     return;
                  }
                  §§goto(addr89);
               }
               addr77:
               while(true)
               {
                  _loc3_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onModuleScriptLoaded);
                  §§goto(addr84);
               }
            }
         }
         while(true)
         {
            if(!_loc5_)
            {
               §§goto(addr77);
            }
            §§goto(addr89);
         }
      }
      
      private function onModuleScriptLoaded(param1:Event, param2:UiModule = null) : void
      {
         var _loc7_:* = true;
         if(!_loc6_)
         {
            _loc3_.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onModuleScriptLoaded);
            if(!param2)
            {
               if(!_loc7_)
               {
                  addr42:
                  while(true)
                  {
                     §§push(this._modules);
                     if(!_loc6_)
                     {
                        §§push(param2.id);
                        if(!_loc6_)
                        {
                           §§pop()[§§pop()] = param2;
                           if(!_loc7_)
                           {
                              addr59:
                              while(true)
                              {
                                 param2.mainClass = _loc3_.content;
                              }
                           }
                           addr100:
                           while(true)
                           {
                           }
                        }
                        addr108:
                        while(true)
                        {
                           addr109:
                           while(true)
                           {
                              §§pop();
                              if(_loc7_)
                              {
                                 if(_loc6_)
                                 {
                                    addr117:
                                    while(true)
                                    {
                                       §§push(_log);
                                       §§push("Load script ");
                                       if(!_loc6_)
                                       {
                                          §§push(§§pop() + param2.id);
                                          if(_loc7_)
                                          {
                                             §§push(", ");
                                             if(_loc7_)
                                             {
                                                §§push(§§pop() + §§pop());
                                                if(_loc7_)
                                                {
                                                }
                                                addr160:
                                                §§push("/");
                                             }
                                             §§push(§§pop() + §§pop());
                                             if(_loc7_)
                                             {
                                                addr165:
                                                §§push(§§pop() + this._moduleCount);
                                             }
                                          }
                                          §§pop().trace(§§pop());
                                          if(!_loc7_)
                                          {
                                             break;
                                          }
                                          addr69:
                                          loop6:
                                          while(true)
                                          {
                                             param2.loader = _loc3_;
                                             if(_loc6_)
                                             {
                                             }
                                             addr90:
                                             while(true)
                                             {
                                                param2.applicationDomain = _loc3_.contentLoaderInfo.applicationDomain;
                                                if(!_loc7_)
                                                {
                                                   break loop6;
                                                }
                                                §§goto(addr59);
                                             }
                                          }
                                          §§goto(addr100);
                                       }
                                       §§push(this._moduleCount);
                                       if(!_loc6_)
                                       {
                                          §§push(§§pop() - this._scriptNum);
                                          if(!_loc6_)
                                          {
                                             §§push(1);
                                             if(!_loc7_)
                                             {
                                                §§push((§§pop() - 54) * 27 + 1 - 55 - 56);
                                             }
                                             §§push(§§pop() + §§pop());
                                          }
                                          §§push(§§pop() + §§pop());
                                          if(_loc7_)
                                          {
                                             §§goto(addr160);
                                          }
                                          §§goto(addr165);
                                       }
                                       §§goto(addr165);
                                    }
                                 }
                                 Berilia.getInstance().handler.process(new ModuleLoadedMessage(param2.id));
                                 if(_loc7_)
                                 {
                                 }
                                 §§push(this._scriptNum - 1);
                                 if(_loc7_)
                                 {
                                    §§push(_loc5_);
                                    if(!_loc6_)
                                    {
                                       _loc4_._scriptNum = _loc5_;
                                    }
                                 }
                                 if(!§§pop())
                                 {
                                    this.launchUiCheck();
                                    break;
                                 }
                                 break;
                              }
                              break;
                           }
                           return;
                        }
                     }
                     addr106:
                     while(true)
                     {
                        §§goto(addr108);
                     }
                  }
               }
            }
            while(true)
            {
               §§push(delete this._loadingModule[param2]);
               if(_loc7_)
               {
                  §§pop();
                  if(_loc6_)
                  {
                     §§goto(addr90);
                  }
                  §§goto(addr117);
               }
               §§goto(addr109);
            }
         }
         while(true)
         {
            if(_loc6_)
            {
               §§goto(addr69);
            }
            else
            {
               §§goto(addr42);
            }
            §§goto(addr106);
         }
      }
      
      private function onShortcutLoad(param1:ResourceLoadedEvent) : void
      {
         var _loc14_:* = false;
         var _loc15_:* = true;
         var _loc3_:XML = null;
         var _loc4_:ShortcutCategory = null;
         var _loc6_:* = false;
         var _loc7_:* = false;
         var _loc9_:XML = null;
         var _loc2_:XML = param1.resource;
         if(!_loc14_)
         {
            §§push(0);
            if(!_loc15_)
            {
               §§push(-(§§pop() * 71 + 58) + 65 + 21);
            }
            if(_loc15_)
            {
               if(!_loc14_)
               {
                  for each(_loc3_ in _loc2_..category)
                  {
                     _loc4_ = ShortcutCategory.create(_loc3_.@name,LangManager.getInstance().replaceKey(_loc3_.@description));
                     if(!_loc14_)
                     {
                        §§push(0);
                        if(!_loc15_)
                        {
                           §§push(§§pop() + 1 - 1 + 114 + 1 - 53);
                        }
                        if(!_loc14_)
                        {
                           if(!_loc14_)
                           {
                              for each(_loc9_ in _loc3_..shortcut)
                              {
                                 §§push(!_loc9_.@name);
                                 if(_loc15_)
                                 {
                                    §§push(§§dup(§§pop()));
                                    if(_loc15_)
                                    {
                                       if(!§§pop())
                                       {
                                          §§pop();
                                          §§push(!_loc9_.@name.toString().length);
                                       }
                                    }
                                    addr183:
                                    if(§§pop())
                                    {
                                       §§pop();
                                       §§push(_loc9_.@visible == "false");
                                    }
                                    if(§§pop())
                                    {
                                       §§push(false);
                                       if(_loc15_)
                                       {
                                          _loc6_ = §§pop();
                                          if(_loc14_)
                                          {
                                          }
                                          addr248:
                                          new Shortcut(_loc9_.@name,_loc9_.@textfieldEnabled == "true",LangManager.getInstance().replaceKey(_loc9_.toString()),_loc4_,!_loc5_,_loc6_,_loc7_,_loc8_,LangManager.getInstance().replaceKey(_loc9_.@tooltipContent));
                                          continue;
                                       }
                                       addr226:
                                       addr227:
                                       addr233:
                                       _loc7_ = §§pop();
                                       addr232:
                                       §§push(_loc9_.@holdKeys);
                                       if(§§dup(_loc9_.@holdKeys))
                                       {
                                          if(_loc15_)
                                          {
                                             §§pop();
                                             if(_loc15_)
                                             {
                                                §§push(_loc9_.@holdKeys == "true");
                                             }
                                             else
                                             {
                                                continue;
                                             }
                                          }
                                          addr247:
                                          §§goto(addr248);
                                       }
                                       if(§§pop())
                                       {
                                          §§goto(addr247);
                                          §§push(true);
                                       }
                                       §§goto(addr248);
                                    }
                                    §§push(false);
                                    if(!_loc14_)
                                    {
                                       _loc7_ = §§pop();
                                       if(!_loc14_)
                                       {
                                          §§push(_loc9_.@required);
                                          if(!_loc14_)
                                          {
                                             §§push(§§dup(§§pop()));
                                             if(!_loc14_)
                                             {
                                                addr214:
                                                if(§§pop())
                                                {
                                                   §§pop();
                                                }
                                                addr222:
                                                if(§§pop())
                                                {
                                                   §§push(true);
                                                   if(!_loc14_)
                                                   {
                                                      §§goto(addr226);
                                                   }
                                                   §§goto(addr232);
                                                }
                                                §§goto(addr227);
                                             }
                                             §§goto(addr233);
                                          }
                                          §§goto(addr232);
                                       }
                                       addr216:
                                       §§push(_loc9_.@required == "true");
                                       if(!_loc14_)
                                       {
                                          §§goto(addr222);
                                       }
                                       §§goto(addr232);
                                    }
                                    §§goto(addr247);
                                 }
                                 if(§§pop())
                                 {
                                    §§push(ErrorManager);
                                    §§push("Le fichier de raccourci est mal formé, il manque la priopriété name dans le fichier ");
                                    if(_loc15_)
                                    {
                                       §§push(§§pop() + param1.uri);
                                    }
                                    §§pop().addError(§§pop());
                                    if(_loc15_)
                                    {
                                    }
                                    addr148:
                                    return;
                                 }
                                 if(!_loc15_)
                                 {
                                    §§goto(addr148);
                                 }
                                 else
                                 {
                                    §§push(_loc9_.@permanent);
                                    §§push(§§dup(_loc9_.@permanent));
                                    if(_loc15_)
                                    {
                                       if(§§pop())
                                       {
                                          §§pop();
                                          if(!_loc14_)
                                          {
                                             if(_loc15_)
                                             {
                                             }
                                             §§push(_loc9_.@permanent == "true");
                                          }
                                          §§goto(addr216);
                                       }
                                       if(§§pop())
                                       {
                                       }
                                       _loc6_ = true;
                                       §§push(_loc9_.@visible);
                                       §§push(§§dup(_loc9_.@visible));
                                       if(_loc15_)
                                       {
                                       }
                                       §§goto(addr214);
                                    }
                                    §§goto(addr183);
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function onHashLoaded(param1:ResourceLoadedEvent) : void
      {
         var _loc5_:* = true;
         var _loc6_:* = false;
         var _loc2_:XML = null;
         if(_loc5_)
         {
            §§push(0);
            if(!_loc5_)
            {
               §§push(§§pop() - 72 + 1 + 1 + 1 - 40);
            }
            if(_loc5_)
            {
               if(!_loc6_)
               {
                  for each(_loc2_ in param1.resource..file)
                  {
                     if(_loc5_)
                     {
                        this._modulesHashs[_loc2_.@name.toString()] = _loc2_.toString();
                     }
                  }
               }
            }
         }
      }
      
      private function onAllUiChecked(param1:ResourceLoaderProgressEvent) : void
      {
         var _loc10_:* = false;
         var _loc11_:* = true;
         var _loc3_:UiModule = null;
         var _loc5_:UiData = null;
         §§push(new Array());
         if(_loc11_)
         {
            §§push(§§pop());
         }
         var _loc2_:* = §§pop();
         if(_loc11_)
         {
            §§push(0);
            if(_loc10_)
            {
               §§push(§§pop() - 1 - 26 - 46 - 1 - 1 + 15);
            }
            if(!_loc10_)
            {
               if(!_loc10_)
               {
                  §§push(this._unInitializedModules);
                  if(!_loc10_)
                  {
                     if(_loc11_)
                     {
                        for each(_loc3_ in §§pop())
                        {
                           if(_loc11_)
                           {
                              §§push(0);
                              if(_loc10_)
                              {
                                 §§push((§§pop() + 1) * 109 + 1);
                              }
                              if(_loc11_)
                              {
                                 if(_loc11_)
                                 {
                                    for each(_loc5_ in _loc3_.uis)
                                    {
                                       if(!_loc10_)
                                       {
                                          _loc2_[UiData(_loc5_).file] = _loc5_;
                                       }
                                    }
                                 }
                              }
                           }
                        }
                     }
                     if(!_loc10_)
                     {
                        if(_loc11_)
                        {
                           this._unparsedXml = [];
                           if(!_loc10_)
                           {
                              §§push(0);
                              if(_loc10_)
                              {
                                 §§push(§§pop() + 1 + 100 + 111);
                              }
                           }
                        }
                        addr212:
                        this._unparsedXmlCount = this._unparsedXmlTotalCount = this._unparsedXml.length;
                        if(_loc11_)
                        {
                           this.parseNextXml();
                        }
                     }
                  }
                  addr138:
                  addr205:
                  if(_loc11_)
                  {
                     loop2:
                     while(§§hasnext(§§pop(),_loc6_))
                     {
                        if(!_loc11_)
                        {
                           addr149:
                           while(true)
                           {
                              UiRenderManager.getInstance().clearCacheFromId(_loc4_);
                              if(_loc11_)
                              {
                                 if(_loc11_)
                                 {
                                 }
                                 addr174:
                                 UiRenderManager.getInstance().setUiVersion(_loc4_,this._clearUi[_loc4_]);
                                 if(!_loc10_)
                                 {
                                    addr184:
                                    if(_loc11_)
                                    {
                                    }
                                    §§push(_loc2_);
                                    if(_loc11_)
                                    {
                                       if(§§pop()[_loc4_])
                                       {
                                          if(!_loc10_)
                                          {
                                             break;
                                          }
                                       }
                                       continue loop2;
                                    }
                                    addr198:
                                    §§pop().push(_loc2_[_loc4_]);
                                 }
                                 continue loop2;
                              }
                              break;
                           }
                           §§goto(addr198);
                           §§push(this._unparsedXml);
                        }
                        while(true)
                        {
                           if(!_loc10_)
                           {
                              if(_loc11_)
                              {
                                 §§goto(addr149);
                              }
                              §§goto(addr174);
                           }
                           break;
                        }
                        §§goto(addr184);
                     }
                  }
                  if(_loc11_)
                  {
                     §§goto(addr212);
                  }
               }
               addr136:
               §§goto(addr138);
               §§push(this._clearUi);
            }
            if(!_loc10_)
            {
               §§goto(addr136);
            }
            §§goto(addr205);
         }
      }
      
      private function parseNextXml() : void
      {
         var _loc5_:* = true;
         var _loc1_:UiData = null;
         this._unparsedXmlCount = this._unparsedXml.length;
         §§push(this._unparsedXml);
         if(!_loc6_)
         {
            if(§§pop().length)
            {
               if(this._parserAvaibleCount)
               {
                  if(_loc5_)
                  {
                     _loc3_._parserAvaibleCount = _loc4_;
                  }
                  §§push(this._unparsedXml);
               }
               addr134:
            }
            else
            {
               BindsManager.getInstance().checkBinds();
               if(!_loc6_)
               {
                  Berilia.getInstance().handler.process(new AllUiXmlParsedMessage());
                  §§push(this._useSharedDefinition);
                  if(_loc5_)
                  {
                     §§push(!§§pop());
                     if(_loc5_)
                     {
                        if(!§§dup(§§pop()))
                        {
                           if(_loc5_)
                           {
                           }
                        }
                        addr167:
                        if(§§pop())
                        {
                           this.launchModule();
                           if(_loc6_)
                           {
                           }
                        }
                        else
                        {
                           this._moduleLaunchWaitForSharedDefinition = true;
                        }
                     }
                  }
                  §§pop();
               }
               §§goto(addr167);
               §§push(this._sharedDefinition);
            }
            return;
         }
         _loc1_ = §§pop().shift() as UiData;
         if(_loc6_)
         {
            loop0:
            while(true)
            {
               _loc2_.rootPath = _loc1_.module.rootPath;
               if(_loc5_)
               {
                  if(_loc6_)
                  {
                  }
                  §§push(_loc2_);
                  §§push(Event.COMPLETE);
                  §§push(this.onXmlParsed);
                  §§push(false);
                  §§push(0);
                  if(!_loc5_)
                  {
                     §§push(-(-(§§pop() + 1 + 1) - 1 + 1 - 1));
                  }
                  §§pop().addEventListener(§§pop(),§§pop(),§§pop(),§§pop(),true);
                  if(_loc5_)
                  {
                     if(_loc5_)
                     {
                        if(_loc6_)
                        {
                        }
                        _loc2_.addEventListener(ParsingErrorEvent.ERROR,this.onXmlParsingError);
                        if(_loc6_)
                        {
                        }
                        break;
                     }
                     addr123:
                     while(true)
                     {
                        if(!_loc5_)
                        {
                           break;
                        }
                        continue loop0;
                     }
                     _loc2_.processFile(_loc1_.file);
                     break;
                  }
                  if(_loc6_)
                  {
                  }
                  §§goto(addr128);
               }
               break;
            }
            if(_loc6_)
            {
            }
            §§goto(addr134);
         }
         while(true)
         {
            §§goto(addr123);
         }
      }
      
      private function onXmlParsed(param1:ParsorEvent) : void
      {
         var _loc4_:* = true;
         var _loc5_:* = false;
         if(param1.uiDefinition)
         {
            param1.uiDefinition.name = XmlParsor(param1.target).url;
            if(_loc4_)
            {
               UiRenderManager.getInstance().setUiDefinition(param1.uiDefinition);
               Berilia.getInstance().handler.process(new UiXmlParsedMessage(param1.uiDefinition.name));
            }
            addr62:
            return;
         }
         if(_loc4_)
         {
            _loc2_._parserAvaibleCount = _loc3_;
         }
         this.parseNextXml();
         §§goto(addr62);
      }
      
      private function onXmlParsingError(param1:ParsingErrorEvent) : void
      {
         var _loc2_:* = false;
         var _loc3_:* = true;
         if(!_loc2_)
         {
            Berilia.getInstance().handler.process(new UiXmlParsedErrorMessage(param1.url,param1.msg));
         }
      }
      
      private function onUiLoaded(param1:ResourceLoadedEvent) : void
      {
         var _loc14_:* = false;
         var _loc15_:* = true;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Uri = null;
         if(!_loc14_)
         {
            if(!this._resetState)
            {
               var _loc2_:int = this._uiFiles.indexOf(param1.uri);
               if(!_loc14_)
               {
                  §§push(this._uiFiles);
                  if(_loc15_)
                  {
                     §§push(this._uiFiles.indexOf(param1.uri));
                     §§push(1);
                     if(_loc14_)
                     {
                        §§push(-(§§pop() * 73 + 22 - 1 - 1 - 1 + 71));
                     }
                     §§pop().splice(§§pop(),§§pop());
                  }
                  addr66:
                  var _loc3_:UiModule = §§pop()[param1.uri.tag.mod];
                  var _loc4_:String = param1.uri.tag.base;
                  if(!_loc14_)
                  {
                     §§push(this._versions);
                     if(_loc15_)
                     {
                        §§push(param1.uri.uri);
                        if(_loc15_)
                        {
                           if(§§pop()[§§pop()] == null)
                           {
                              §§push(MD5.hash(param1.resource as String));
                              if(_loc15_)
                              {
                                 §§push(§§pop());
                                 if(!_loc14_)
                                 {
                                    addr117:
                                    §§push(§§pop());
                                 }
                              }
                           }
                           var _loc5_:* = §§pop();
                           var _loc6_:* = _loc5_ == UiRenderManager.getInstance().getUiVersion(param1.uri.uri);
                           if(!_loc6_)
                           {
                              if(_loc15_)
                              {
                                 §§push(this._clearUi);
                                 if(!_loc14_)
                                 {
                                    §§push(param1.uri.uri);
                                    if(!_loc14_)
                                    {
                                       §§push(_loc5_);
                                       if(!_loc14_)
                                       {
                                          §§pop()[§§pop()] = §§pop();
                                          if(!_loc14_)
                                          {
                                             if(param1.uri.tag.template)
                                             {
                                                if(!_loc14_)
                                                {
                                                   §§push(this._clearUi);
                                                   if(_loc14_)
                                                   {
                                                   }
                                                   addr175:
                                                   §§push(param1.uri.uri);
                                                }
                                             }
                                          }
                                       }
                                       addr179:
                                       §§pop()[§§pop()] = §§pop();
                                    }
                                    §§goto(addr179);
                                    §§push(_loc5_);
                                 }
                                 §§pop()[param1.uri.tag.base] = this._versions[param1.uri.tag.base];
                                 if(_loc14_)
                                 {
                                 }
                              }
                              §§push(param1.resource as String);
                              if(!_loc14_)
                              {
                                 §§push(§§pop());
                              }
                              var _loc7_:* = §§pop();
                              if(_loc15_)
                              {
                                 while(_loc8_ = this._regImport.exec(_loc7_))
                                 {
                                    §§push(LangManager.getInstance());
                                    §§push(_loc8_);
                                    §§push(1);
                                    if(!_loc15_)
                                    {
                                       §§push(§§pop() * 114 + 1 - 57);
                                    }
                                    §§push(§§pop().replaceKey(§§pop()[§§pop()]));
                                    if(_loc15_)
                                    {
                                       §§push(§§dup(§§pop()));
                                       if(!_loc14_)
                                       {
                                          _loc9_ = §§pop();
                                          §§push("mod://");
                                          if(!_loc14_)
                                          {
                                             §§push(§§pop().indexOf(§§pop()));
                                             §§push(-1);
                                             if(!_loc15_)
                                             {
                                                §§push(§§pop() * 70 + 1 + 1);
                                             }
                                             if(§§pop() != §§pop())
                                             {
                                                §§push(_loc9_);
                                             }
                                             else
                                             {
                                                §§push(_loc9_);
                                                §§push(":");
                                                if(_loc15_)
                                                {
                                                }
                                                addr323:
                                                §§push(§§pop().indexOf(§§pop()));
                                                §§push(-1);
                                                addr336:
                                                if(!_loc15_)
                                                {
                                                   §§push(-(-§§pop() - 65) - 47 - 84);
                                                }
                                                if(§§pop() == §§pop())
                                                {
                                                   §§push(_loc3_.rootPath);
                                                   §§push(_loc9_);
                                                }
                                             }
                                             addr343:
                                             §§push(this._clearUi);
                                             if(!_loc14_)
                                             {
                                                §§push(_loc9_);
                                                if(_loc15_)
                                                {
                                                   if(§§pop()[§§pop()])
                                                   {
                                                      if(_loc15_)
                                                      {
                                                         §§push(this._clearUi);
                                                         if(!_loc14_)
                                                         {
                                                            §§push(param1.uri.uri);
                                                            if(!_loc14_)
                                                            {
                                                               §§pop()[§§pop()] = _loc5_;
                                                               §§push(this._clearUi);
                                                            }
                                                         }
                                                      }
                                                   }
                                                   else if(this._uiLoaded[_loc9_])
                                                   {
                                                      continue;
                                                   }
                                                   this._uiLoaded[_loc9_] = true;
                                                   if(!_loc14_)
                                                   {
                                                      _loc12_._uiFileToLoad = _loc13_;
                                                   }
                                                   _loc11_ = new Uri(_loc9_);
                                                   _loc11_.tag = {
                                                      "mod":_loc3_.id,
                                                      "base":_loc4_,
                                                      "template":true
                                                   };
                                                   if(!_loc14_)
                                                   {
                                                      this._uiLoader.load(_loc11_,null,TxtAdapter);
                                                   }
                                                   continue;
                                                }
                                                addr370:
                                                §§pop()[§§pop()] = this._versions[_loc4_];
                                                continue;
                                             }
                                             §§goto(addr370);
                                             §§push(_loc4_);
                                          }
                                          §§push(§§pop().indexOf(§§pop()));
                                          §§push(-1);
                                          if(_loc14_)
                                          {
                                             §§push(-(§§pop() - 1 - 1) - 1 + 107);
                                          }
                                          §§push(§§pop() == §§pop());
                                          if(_loc15_)
                                          {
                                             if(§§dup(§§pop()))
                                             {
                                                if(_loc15_)
                                                {
                                                   §§pop();
                                                   §§goto(addr323);
                                                   §§push(_loc9_);
                                                   §§push("ui/Ankama_Common");
                                                }
                                             }
                                          }
                                          §§goto(addr336);
                                       }
                                       _loc9_ = §§pop() + §§pop();
                                       §§goto(addr343);
                                    }
                                    §§push(6);
                                    if(_loc14_)
                                    {
                                       §§push(-§§pop() - 49 - 74 - 92);
                                    }
                                    §§push(_loc9_);
                                    §§push("/");
                                    §§push(6);
                                    if(!_loc15_)
                                    {
                                       §§push(-(§§pop() - 64 - 119) + 33 - 1 - 80);
                                    }
                                    §§push(§§pop().indexOf(§§pop(),§§pop()));
                                    §§push(6);
                                    if(!_loc15_)
                                    {
                                       §§push(-(-(§§pop() - 11 + 44) - 85 - 1 + 1));
                                    }
                                    _loc10_ = §§pop().substr(§§pop(),§§pop() - §§pop());
                                    §§push(this._modulesPaths[_loc10_]);
                                    §§push(_loc9_);
                                    §§push(6);
                                    if(_loc14_)
                                    {
                                       §§push(-((§§pop() * 117 - 9 - 1) * 35) * 85);
                                    }
                                    _loc9_ = §§pop() + §§pop().substr(§§pop() + _loc10_.length);
                                    §§goto(addr343);
                                 }
                                 if(_loc14_)
                                 {
                                 }
                                 this.onAllUiChecked(null);
                                 return;
                              }
                              §§push(this._uiFileToLoad - 1);
                              if(_loc15_)
                              {
                                 if(!_loc14_)
                                 {
                                    _loc12_._uiFileToLoad = _loc13_;
                                 }
                              }
                              if(!§§pop())
                              {
                                 if(_loc15_)
                                 {
                                    §§goto(addr461);
                                 }
                              }
                              §§goto(addr464);
                           }
                           §§goto(addr175);
                           §§push(this._versions);
                        }
                        addr99:
                        §§push(§§pop()[§§pop()]);
                        if(_loc14_)
                        {
                        }
                        §§goto(addr117);
                     }
                     addr96:
                     §§goto(addr99);
                     §§push(param1.uri.uri);
                  }
                  §§goto(addr96);
                  §§push(this._versions);
               }
               §§goto(addr66);
               §§push(this._unInitializedModules);
            }
         }
      }
      
      private function searchDmFile(param1:File) : File
      {
         var _loc7_:* = true;
         var _loc8_:* = false;
         var _loc3_:File = null;
         var _loc4_:File = null;
         if(_loc7_)
         {
            §§push(param1.nativePath.indexOf(".svn"));
            §§push(-1);
            if(!_loc7_)
            {
               §§push((§§pop() + 98) * 24 + 43);
            }
            if(§§pop() == §§pop())
            {
               var _loc2_:Array = param1.getDirectoryListing();
               if(_loc7_)
               {
                  §§push(0);
                  if(_loc8_)
                  {
                     §§push(§§pop() - 1 + 104 - 1 + 1 - 53);
                  }
                  if(_loc7_)
                  {
                     if(_loc7_)
                     {
                        §§push(_loc2_);
                        if(_loc7_)
                        {
                           if(_loc7_)
                           {
                              while(true)
                              {
                                 for each(_loc3_ in §§pop())
                                 {
                                    if(!_loc8_)
                                    {
                                       §§push(!_loc3_.isDirectory);
                                       if(!_loc8_)
                                       {
                                          §§push(§§dup(§§pop()));
                                          if(!_loc8_)
                                          {
                                             if(§§pop())
                                             {
                                                if(!_loc8_)
                                                {
                                                   §§pop();
                                                   if(!_loc8_)
                                                   {
                                                      §§push(_loc3_.extension);
                                                      if(_loc7_)
                                                      {
                                                      }
                                                   }
                                                   addr136:
                                                   if(_loc3_.extension.toLowerCase() == "dm")
                                                   {
                                                      addr137:
                                                      _loc4_ = _loc3_;
                                                   }
                                                   continue;
                                                }
                                             }
                                             if(§§pop())
                                             {
                                                if(_loc7_)
                                                {
                                                   if(_loc3_.extension.toLowerCase() == "d2ui")
                                                   {
                                                      if(_loc7_)
                                                      {
                                                         break;
                                                      }
                                                   }
                                                   else
                                                   {
                                                      §§push(!_loc4_);
                                                      if(_loc7_)
                                                      {
                                                         §§push(§§dup(§§pop()));
                                                      }
                                                   }
                                                   §§goto(addr137);
                                                }
                                                break;
                                             }
                                             continue;
                                          }
                                          if(§§pop())
                                          {
                                             if(_loc8_)
                                             {
                                             }
                                          }
                                          §§goto(addr136);
                                       }
                                       §§pop();
                                       if(!_loc8_)
                                       {
                                          §§goto(addr136);
                                       }
                                       §§goto(addr137);
                                    }
                                    break;
                                 }
                              }
                              return _loc3_;
                           }
                           if(!_loc8_)
                           {
                              if(_loc8_)
                              {
                              }
                              addr152:
                              return _loc4_;
                           }
                        }
                        addr164:
                        if(_loc7_)
                        {
                           for each(_loc3_ in §§pop())
                           {
                              if(!_loc8_)
                              {
                                 if(!_loc3_.isDirectory)
                                 {
                                    continue;
                                 }
                              }
                              _loc4_ = this.searchDmFile(_loc3_);
                              if(_loc4_)
                              {
                                 break;
                              }
                           }
                        }
                        return _loc4_;
                     }
                     addr163:
                     §§goto(addr164);
                     §§push(_loc2_);
                  }
                  addr162:
                  §§goto(addr163);
               }
               if(_loc4_)
               {
                  §§goto(addr152);
               }
               else
               {
                  §§push(0);
                  if(_loc8_)
                  {
                     §§push((-§§pop() + 93) * 11);
                  }
                  §§goto(addr162);
               }
            }
         }
         return null;
      }
      
      private function onSharedDefinitionLoad(param1:ResourceLoadedEvent) : void
      {
         var _loc6_:* = true;
         var _loc7_:* = false;
         if(!_loc7_)
         {
            EnterFrameDispatcher.removeEventListener(this.timeOutFrameCount);
         }
         var _loc2_:ASwf = param1.resource as ASwf;
         if(_loc6_)
         {
            this._sharedDefinition = _loc2_.applicationDomain;
         }
         var _loc3_:Object = this._sharedDefinition.getDefinition("d2components::SecureComponent");
         if(!_loc7_)
         {
            _loc3_.init(SecureCenter.ACCESS_KEY,SecureCenter.unsecureContent,SecureCenter.secure,SecureCenter.unsecure,DescribeTypeCache.getVariables);
         }
         var _loc4_:Object = this._sharedDefinition.getDefinition("utils::ReadOnlyData");
         _loc4_.init(SecureCenter.ACCESS_KEY,SecureCenter.unsecureContent,SecureCenter.secure,SecureCenter.unsecure);
         var _loc5_:Object = this._sharedDefinition.getDefinition("utils::DirectAccessObject");
         _loc5_.init(SecureCenter.ACCESS_KEY);
         SecureCenter.init(_loc3_,_loc4_,_loc5_);
         this._sharedDefinitionInstance = Object(_loc2_.content);
         this._loadModuleFunction = Object(_loc2_.content).loadModule;
         §§push(this._waitingInit);
         if(!_loc7_)
         {
            if(§§pop())
            {
               this.init(this._filter,this._filterInclude);
            }
            §§push(this._moduleLaunchWaitForSharedDefinition);
         }
         if(§§pop())
         {
            if(_loc6_)
            {
               this.launchModule();
            }
         }
      }
   }
}
