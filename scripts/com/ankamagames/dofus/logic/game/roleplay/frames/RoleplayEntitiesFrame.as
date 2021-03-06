package com.ankamagames.dofus.logic.game.roleplay.frames
{
   import com.ankamagames.dofus.logic.game.common.frames.AbstractEntitiesFrame;
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.data.XmlConfig;
   import flash.utils.Dictionary;
   import com.ankamagames.jerakine.resources.loaders.IResourceLoader;
   import com.ankamagames.jerakine.newCache.ICache;
   import com.ankamagames.dofus.logic.game.common.frames.AllianceFrame;
   import flash.utils.Timer;
   import com.ankamagames.dofus.types.entities.AnimatedCharacter;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.MapInformationsRequestMessage;
   import com.ankamagames.jerakine.managers.OptionManager;
   import com.ankamagames.jerakine.enum.OptionEnum;
   import flash.events.TimerEvent;
   import com.ankamagames.atouin.managers.MapDisplayManager;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.jerakine.resources.loaders.ResourceLoaderFactory;
   import com.ankamagames.jerakine.resources.loaders.ResourceLoaderType;
   import com.ankamagames.jerakine.resources.events.ResourceLoadedEvent;
   import com.ankamagames.jerakine.resources.events.ResourceErrorEvent;
   import com.ankamagames.dofus.network.types.game.interactive.InteractiveElement;
   import com.ankamagames.jerakine.types.events.PropertyChangeEvent;
   import com.ankamagames.tiphon.engine.Tiphon;
   import com.ankamagames.atouin.Atouin;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.jerakine.utils.display.EnterFrameDispatcher;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.MapComplementaryInformationsDataMessage;
   import com.ankamagames.dofus.network.messages.game.interactive.InteractiveMapUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.interactive.StatedMapUpdateMessage;
   import com.ankamagames.dofus.network.types.game.house.HouseInformations;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.GameRolePlayShowActorMessage;
   import com.ankamagames.dofus.network.messages.game.context.GameContextRefreshEntityLookMessage;
   import com.ankamagames.dofus.network.messages.game.context.GameMapChangeOrientationMessage;
   import com.ankamagames.dofus.network.messages.game.context.GameMapChangeOrientationsMessage;
   import com.ankamagames.dofus.logic.game.roleplay.messages.GameRolePlaySetAnimationMessage;
   import com.ankamagames.atouin.messages.EntityMovementCompleteMessage;
   import com.ankamagames.atouin.messages.EntityMovementStoppedMessage;
   import com.ankamagames.dofus.logic.game.roleplay.messages.CharacterMovementStoppedMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.fight.GameRolePlayShowChallengeMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightOptionStateUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightUpdateTeamMessage;
   import com.ankamagames.dofus.network.messages.game.context.fight.GameFightRemoveTeamMemberMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.fight.GameRolePlayRemoveChallengeMessage;
   import com.ankamagames.dofus.network.messages.game.context.GameContextRemoveElementMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.MapFightCountMessage;
   import com.ankamagames.dofus.network.messages.game.pvp.UpdateMapPlayersAgressableStatusMessage;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayHumanoidInformations;
   import com.ankamagames.dofus.network.messages.game.pvp.UpdateSelfAgressableStatusMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.objects.ObjectGroundAddedMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.objects.ObjectGroundRemovedMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.objects.ObjectGroundRemovedMultipleMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.objects.ObjectGroundListAddedMessage;
   import com.ankamagames.dofus.logic.game.common.actions.mount.PaddockRemoveItemRequestAction;
   import com.ankamagames.dofus.network.messages.game.context.mount.PaddockRemoveItemRequestMessage;
   import com.ankamagames.dofus.logic.game.common.actions.mount.PaddockMoveItemRequestAction;
   import com.ankamagames.berilia.components.Texture;
   import com.ankamagames.dofus.internalDatacenter.items.ItemWrapper;
   import com.ankamagames.dofus.network.messages.game.context.mount.GameDataPaddockObjectRemoveMessage;
   import com.ankamagames.dofus.network.messages.game.context.mount.GameDataPaddockObjectAddMessage;
   import com.ankamagames.dofus.network.messages.game.context.mount.GameDataPaddockObjectListAddMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.paddock.GameDataPlayFarmObjectAnimationMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.npc.MapNpcsQuestStatusUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.context.ShowCellMessage;
   import com.ankamagames.dofus.logic.game.common.actions.StartZoomAction;
   import flash.display.DisplayObject;
   import com.ankamagames.dofus.logic.game.common.actions.roleplay.SwitchCreatureModeAction;
   import com.ankamagames.dofus.datacenter.world.SubArea;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayActorInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.FightCommonInformations;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.MapComplementaryInformationsWithCoordsMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.MapComplementaryInformationsDataInHouseMessage;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayCharacterInformations;
   import com.ankamagames.dofus.logic.game.roleplay.messages.DelayedActionMessage;
   import com.ankamagames.dofus.datacenter.communication.Emoticon;
   import com.ankamagames.tiphon.types.look.TiphonEntityLook;
   import com.ankamagames.dofus.internalDatacenter.house.HouseWrapper;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.houses.HousePropertiesMessage;
   import com.ankamagames.dofus.network.types.game.interactive.MapObstacle;
   import com.ankamagames.dofus.network.types.game.context.roleplay.HumanInformations;
   import com.ankamagames.dofus.network.types.game.context.ActorOrientation;
   import com.ankamagames.dofus.logic.game.common.frames.EmoticonFrame;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.emote.EmotePlayRequestMessage;
   import com.ankamagames.dofus.network.types.game.paddock.PaddockItem;
   import com.ankamagames.tiphon.display.TiphonSprite;
   import flash.display.Sprite;
   import com.ankamagames.dofus.datacenter.quest.Quest;
   import flash.geom.Rectangle;
   import com.ankamagames.dofus.logic.game.roleplay.types.FightTeam;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.dofus.internalDatacenter.world.WorldPointWrapper;
   import com.ankamagames.dofus.logic.common.managers.PlayerManager;
   import com.ankamagames.berilia.managers.TooltipManager;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayGroupMonsterInformations;
   import com.ankamagames.tiphon.events.TiphonEvent;
   import com.ankamagames.dofus.network.types.game.context.roleplay.HumanOptionEmote;
   import com.ankamagames.dofus.network.types.game.context.roleplay.HumanOptionObjectUse;
   import com.ankamagames.dofus.misc.EntityLookAdapter;
   import com.ankamagames.dofus.misc.lists.TriggerHookList;
   import com.ankamagames.dofus.logic.game.common.managers.ChatAutocompleteNameManager;
   import com.ankamagames.atouin.managers.InteractiveCellManager;
   import com.ankamagames.dofus.network.enums.MapObstacleStateEnum;
   import com.ankamagames.dofus.logic.game.roleplay.managers.AnimFunManager;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.dofus.types.enums.AnimationEnum;
   import com.ankamagames.dofus.network.enums.AggressableStatusEnum;
   import com.ankamagames.dofus.logic.game.common.managers.SpeakingItemManager;
   import com.ankamagames.dofus.network.types.game.context.GameContextActorInformations;
   import com.ankamagames.jerakine.types.enums.DirectionsEnum;
   import com.ankamagames.dofus.network.enums.PlayerLifeStatusEnum;
   import com.ankamagames.dofus.network.types.game.context.roleplay.HumanOptionAlliance;
   import com.ankamagames.dofus.misc.lists.PrismHookList;
   import com.ankamagames.dofus.misc.utils.EmbedAssets;
   import com.ankamagames.dofus.logic.common.managers.HyperlinkShowCellManager;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.dofus.misc.lists.ChatHookList;
   import com.ankamagames.dofus.network.enums.ChatActivableChannelsEnum;
   import com.ankamagames.dofus.logic.game.common.managers.TimeManager;
   import com.ankamagames.atouin.messages.MapLoadedMessage;
   import com.ankamagames.atouin.messages.MapZoomMessage;
   import com.ankamagames.dofus.types.data.Follower;
   import com.ankamagames.dofus.network.enums.SubEntityBindingPointCategoryEnum;
   import com.ankamagames.dofus.types.entities.AnimStatiqueSubEntityBehavior;
   import com.ankamagames.jerakine.entities.interfaces.IDisplayable;
   import com.ankamagames.dofus.logic.game.roleplay.types.Fight;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.dofus.logic.game.roleplay.types.GameContextPaddockItemInformations;
   import com.ankamagames.dofus.network.types.game.context.roleplay.MonsterInGroupLightInformations;
   import com.ankamagames.dofus.datacenter.monsters.Monster;
   import com.ankamagames.dofus.network.types.game.look.EntityLook;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GroupMonsterStaticInformations;
   import com.ankamagames.dofus.logic.game.common.frames.PartyManagementFrame;
   import com.ankamagames.dofus.internalDatacenter.people.PartyMemberWrapper;
   import com.ankamagames.dofus.network.types.game.context.roleplay.AlternativeMonstersInGroupLightInformations;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GroupMonsterStaticInformationsWithAlternatives;
   import com.ankamagames.tiphon.types.IAnimationModifier;
   import com.ankamagames.dofus.network.types.game.context.roleplay.MonsterInGroupInformations;
   import com.ankamagames.dofus.network.types.game.look.IndexedEntityLook;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayNpcWithQuestInformations;
   import com.ankamagames.dofus.network.types.game.context.roleplay.HumanOptionFollowers;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayMerchantInformations;
   import com.ankamagames.dofus.network.types.game.context.GameRolePlayTaxCollectorInformations;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayPrismInformations;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayPortalInformations;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayNpcInformations;
   import com.ankamagames.tiphon.types.TiphonUtility;
   import com.ankamagames.dofus.network.types.game.context.fight.FightTeamInformations;
   import com.ankamagames.jerakine.entities.interfaces.IEntity;
   import com.ankamagames.dofus.factories.RolePlayEntitiesFactory;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.jerakine.types.Uri;
   import com.ankamagames.jerakine.managers.LangManager;
   import com.ankamagames.dofus.datacenter.items.Item;
   import com.ankamagames.dofus.types.entities.RoleplayObjectEntity;
   import com.ankamagames.jerakine.entities.interfaces.IInteractive;
   import com.ankamagames.dofus.logic.game.roleplay.types.GroundObject;
   import com.ankamagames.dofus.network.types.game.context.fight.FightTeamMemberInformations;
   import com.ankamagames.jerakine.entities.messages.EntityMouseOutMessage;
   import com.ankamagames.jerakine.sequencer.SerialSequencer;
   import com.ankamagames.tiphon.sequence.PlayAnimationStep;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.berilia.types.LocationEnum;
   import com.ankamagames.atouin.utils.DataMapProvider;
   import com.ankamagames.tiphon.engine.TiphonMultiBonesManager;
   import com.ankamagames.jerakine.types.Callback;
   import com.ankamagames.dofus.internalDatacenter.communication.EmoteWrapper;
   import com.ankamagames.dofus.internalDatacenter.items.ShortcutWrapper;
   import com.ankamagames.dofus.logic.game.common.managers.InventoryManager;
   import com.ankamagames.dofus.misc.lists.RoleplayHookList;
   import com.ankamagames.dofus.misc.lists.InventoryHookList;
   import com.ankamagames.dofus.datacenter.sounds.SoundAnimation;
   import com.ankamagames.tiphon.display.TiphonAnimation;
   import com.ankamagames.dofus.datacenter.sounds.SoundBones;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.tiphon.engine.TiphonEventsManager;
   import com.ankamagames.jerakine.types.ASwf;
   import flash.display.MovieClip;
   import flash.utils.clearTimeout;
   import com.ankamagames.dofus.network.messages.game.context.mount.PaddockMoveItemRequestMessage;
   import com.ankamagames.dofus.internalDatacenter.conquest.PrismSubAreaWrapper;
   import com.ankamagames.dofus.network.enums.PrismStateEnum;
   import com.ankamagames.dofus.types.enums.EntityIconEnum;
   import flash.events.Event;
   import com.ankamagames.jerakine.interfaces.IRectangle;
   import com.ankamagames.jerakine.utils.display.Rectangle2;
   import com.ankamagames.dofus.logic.game.roleplay.types.EntityIcon;
   import flash.geom.Point;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.jerakine.newCache.impl.Cache;
   import com.ankamagames.jerakine.newCache.garbage.LruGarbageCollector;
   
   public class RoleplayEntitiesFrame extends AbstractEntitiesFrame implements Frame
   {
      
      private static const ICONS_FILEPATH:String = XmlConfig.getInstance().getEntry("config.content.path") + "gfx/icons/conquestIcon.swf";
       
      private var _fights:Dictionary;
      
      private var _objects:Dictionary;
      
      private var _objectsByCellId:Dictionary;
      
      private var _paddockItem:Dictionary;
      
      private var _fightNumber:uint = 0;
      
      private var _timeout:Number;
      
      private var _loader:IResourceLoader;
      
      private var _groundObjectCache:ICache;
      
      private var _currentPaddockItemCellId:uint;
      
      private var _usableEmotes:Array;
      
      private var _currentEmoticon:uint = 0;
      
      private var _playersId:Array;
      
      private var _npcList:Dictionary;
      
      private var _housesList:Dictionary;
      
      private var _emoteTimesBySprite:Dictionary;
      
      private var _waitForMap:Boolean;
      
      private var _monstersIds:Vector.<int>;
      
      private var _allianceFrame:AllianceFrame;
      
      private var _lastStaticAnimations:Dictionary;
      
      private var _entitiesIconsNames:Dictionary;
      
      private var _entitiesIcons:Dictionary;
      
      private var _updateAllIcons:Boolean;
      
      private var _waitingEmotesAnims:Dictionary;
      
      private var _auraCycleTimer:Timer;
      
      private var _auraCycleIndex:int;
      
      private var _lastEntityWithAura:AnimatedCharacter;
      
      private var _dispatchPlayerNewLook:Boolean;
      
      public function RoleplayEntitiesFrame()
      {
         this._paddockItem = new Dictionary();
         this._groundObjectCache = new Cache(20,new LruGarbageCollector());
         this._usableEmotes = new Array();
         this._npcList = new Dictionary(true);
         this._lastStaticAnimations = new Dictionary();
         this._entitiesIconsNames = new Dictionary();
         this._entitiesIcons = new Dictionary();
         this._waitingEmotesAnims = new Dictionary();
         super();
      }
      
      public function get currentEmoticon() : uint
      {
         return this._currentEmoticon;
      }
      
      public function set currentEmoticon(param1:uint) : void
      {
         this._currentEmoticon = param1;
      }
      
      public function get dispatchPlayerNewLook() : Boolean
      {
         return this._dispatchPlayerNewLook;
      }
      
      public function set dispatchPlayerNewLook(param1:Boolean) : void
      {
         this._dispatchPlayerNewLook = param1;
      }
      
      public function get fightNumber() : uint
      {
         return this._fightNumber;
      }
      
      public function get currentSubAreaId() : uint
      {
         return _currentSubAreaId;
      }
      
      public function get playersId() : Array
      {
         return this._playersId;
      }
      
      public function get housesInformations() : Dictionary
      {
         return this._housesList;
      }
      
      public function get fights() : Dictionary
      {
         return this._fights;
      }
      
      public function get isCreatureMode() : Boolean
      {
         return _creaturesMode;
      }
      
      public function get monstersIds() : Vector.<int>
      {
         return this._monstersIds;
      }
      
      public function get lastStaticAnimations() : Dictionary
      {
         return this._lastStaticAnimations;
      }
      
      override public function pushed() : Boolean
      {
         var _loc1_:MapInformationsRequestMessage = null;
         this.initNewMap();
         this._playersId = new Array();
         this._monstersIds = new Vector.<int>();
         this._emoteTimesBySprite = new Dictionary();
         _entitiesVisibleNumber = 0;
         this._auraCycleIndex = 0;
         this._auraCycleTimer = new Timer(1800);
         if(OptionManager.getOptionManager("tiphon").auraMode == OptionEnum.AURA_CYCLE)
         {
            this._auraCycleTimer.addEventListener(TimerEvent.TIMER,this.onAuraCycleTimer);
            this._auraCycleTimer.start();
         }
         if(MapDisplayManager.getInstance().currentMapRendered)
         {
            _loc1_ = new MapInformationsRequestMessage();
            _loc1_.initMapInformationsRequestMessage(MapDisplayManager.getInstance().currentMapPoint.mapId);
            ConnectionsHandler.getConnection().send(_loc1_);
         }
         else
         {
            this._waitForMap = true;
         }
         this._loader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
         this._loader.addEventListener(ResourceLoadedEvent.LOADED,this.onGroundObjectLoaded);
         this._loader.addEventListener(ResourceErrorEvent.ERROR,this.onGroundObjectLoadFailed);
         _interactiveElements = new Vector.<InteractiveElement>();
         Dofus.getInstance().options.addEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onPropertyChanged);
         Tiphon.getInstance().options.addEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onTiphonPropertyChanged);
         Atouin.getInstance().options.addEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onAtouinPropertyChanged);
         this._allianceFrame = Kernel.getWorker().getFrame(AllianceFrame) as AllianceFrame;
         EnterFrameDispatcher.addEventListener(this.showIcons,"showIcons",25);
         return super.pushed();
      }
      
      override public function process(param1:Message) : Boolean
      {
         var _loc2_:AnimatedCharacter = null;
         var _loc3_:MapComplementaryInformationsDataMessage = null;
         var _loc4_:* = false;
         var _loc5_:RoleplayInteractivesFrame = null;
         var _loc6_:InteractiveMapUpdateMessage = null;
         var _loc7_:StatedMapUpdateMessage = null;
         var _loc8_:HouseInformations = null;
         var _loc9_:GameRolePlayShowActorMessage = null;
         var _loc10_:GameContextRefreshEntityLookMessage = null;
         var _loc11_:GameMapChangeOrientationMessage = null;
         var _loc12_:GameMapChangeOrientationsMessage = null;
         var _loc13_:* = 0;
         var _loc14_:GameRolePlaySetAnimationMessage = null;
         var _loc15_:AnimatedCharacter = null;
         var _loc16_:EntityMovementCompleteMessage = null;
         var _loc17_:AnimatedCharacter = null;
         var _loc18_:EntityMovementStoppedMessage = null;
         var _loc19_:CharacterMovementStoppedMessage = null;
         var _loc20_:AnimatedCharacter = null;
         var _loc21_:GameRolePlayShowChallengeMessage = null;
         var _loc22_:GameFightOptionStateUpdateMessage = null;
         var _loc23_:GameFightUpdateTeamMessage = null;
         var _loc24_:GameFightRemoveTeamMemberMessage = null;
         var _loc25_:GameRolePlayRemoveChallengeMessage = null;
         var _loc26_:GameContextRemoveElementMessage = null;
         var _loc27_:uint = 0;
         var _loc28_:* = 0;
         var _loc29_:MapFightCountMessage = null;
         var _loc30_:UpdateMapPlayersAgressableStatusMessage = null;
         var _loc31_:* = 0;
         var _loc32_:* = 0;
         var _loc33_:GameRolePlayHumanoidInformations = null;
         var _loc34_:* = undefined;
         var _loc35_:UpdateSelfAgressableStatusMessage = null;
         var _loc36_:GameRolePlayHumanoidInformations = null;
         var _loc37_:* = undefined;
         var _loc38_:ObjectGroundAddedMessage = null;
         var _loc39_:ObjectGroundRemovedMessage = null;
         var _loc40_:ObjectGroundRemovedMultipleMessage = null;
         var _loc41_:ObjectGroundListAddedMessage = null;
         var _loc42_:uint = 0;
         var _loc43_:PaddockRemoveItemRequestAction = null;
         var _loc44_:PaddockRemoveItemRequestMessage = null;
         var _loc45_:PaddockMoveItemRequestAction = null;
         var _loc46_:Texture = null;
         var _loc47_:ItemWrapper = null;
         var _loc48_:GameDataPaddockObjectRemoveMessage = null;
         var _loc49_:RoleplayContextFrame = null;
         var _loc50_:GameDataPaddockObjectAddMessage = null;
         var _loc51_:GameDataPaddockObjectListAddMessage = null;
         var _loc52_:GameDataPlayFarmObjectAnimationMessage = null;
         var _loc53_:MapNpcsQuestStatusUpdateMessage = null;
         var _loc54_:ShowCellMessage = null;
         var _loc55_:RoleplayContextFrame = null;
         var _loc56_:String = null;
         var _loc57_:String = null;
         var _loc58_:StartZoomAction = null;
         var _loc59_:DisplayObject = null;
         var _loc60_:SwitchCreatureModeAction = null;
         var _loc61_:MapInformationsRequestMessage = null;
         var _loc62_:SubArea = null;
         var _loc63_:GameRolePlayActorInformations = null;
         var _loc64_:* = false;
         var _loc65_:* = 0;
         var _loc66_:* = NaN;
         var _loc67_:GameRolePlayActorInformations = null;
         var _loc68_:FightCommonInformations = null;
         var _loc69_:MapComplementaryInformationsWithCoordsMessage = null;
         var _loc70_:MapComplementaryInformationsDataInHouseMessage = null;
         var _loc71_:* = false;
         var _loc72_:AnimatedCharacter = null;
         var _loc73_:GameRolePlayCharacterInformations = null;
         var _loc74_:* = undefined;
         var _loc75_:DelayedActionMessage = null;
         var _loc76_:Emoticon = null;
         var _loc77_:* = false;
         var _loc78_:Date = null;
         var _loc79_:TiphonEntityLook = null;
         var _loc80_:GameRolePlaySetAnimationMessage = null;
         var _loc81_:HouseInformations = null;
         var _loc82_:HouseWrapper = null;
         var _loc83_:* = 0;
         var _loc84_:* = 0;
         var _loc85_:HousePropertiesMessage = null;
         var _loc86_:MapObstacle = null;
         var _loc87_:HumanInformations = null;
         var _loc88_:GameRolePlayHumanoidInformations = null;
         var _loc89_:GameRolePlayCharacterInformations = null;
         var _loc90_:* = 0;
         var _loc91_:ActorOrientation = null;
         var _loc92_:Emoticon = null;
         var _loc93_:EmoticonFrame = null;
         var _loc94_:uint = 0;
         var _loc95_:Emoticon = null;
         var _loc96_:EmotePlayRequestMessage = null;
         var _loc97_:uint = 0;
         var _loc98_:uint = 0;
         var _loc99_:uint = 0;
         var _loc100_:PaddockItem = null;
         var _loc101_:uint = 0;
         var _loc102_:TiphonSprite = null;
         var _loc103_:Sprite = null;
         var _loc104_:* = 0;
         var _loc105_:* = 0;
         var _loc106_:Quest = null;
         var _loc107_:Rectangle = null;
         var _loc108_:* = undefined;
         var _loc109_:* = undefined;
         var _loc110_:FightTeam = null;
         switch(true)
         {
            case param1 is MapLoadedMessage:
               if(this._waitForMap)
               {
                  _loc61_ = new MapInformationsRequestMessage();
                  _loc61_.initMapInformationsRequestMessage(MapDisplayManager.getInstance().currentMapPoint.mapId);
                  ConnectionsHandler.getConnection().send(_loc61_);
                  this._waitForMap = false;
               }
               return false;
            case param1 is MapComplementaryInformationsDataMessage:
               _loc3_ = param1 as MapComplementaryInformationsDataMessage;
               _loc4_ = false;
               if(_worldPoint && _worldPoint.mapId == _loc3_.mapId && !(param1 is MapComplementaryInformationsWithCoordsMessage))
               {
                  _loc4_ = true;
               }
               _interactiveElements = _loc3_.interactiveElements;
               this._fightNumber = _loc3_.fights.length;
               if(!_loc4_)
               {
                  this.initNewMap();
                  if(param1 is MapComplementaryInformationsWithCoordsMessage)
                  {
                     _loc69_ = param1 as MapComplementaryInformationsWithCoordsMessage;
                     if(PlayedCharacterManager.getInstance().isInHouse)
                     {
                        KernelEventsManager.getInstance().processCallback(HookList.HouseExit);
                     }
                     PlayedCharacterManager.getInstance().isInHouse = false;
                     PlayedCharacterManager.getInstance().isInHisHouse = false;
                     PlayedCharacterManager.getInstance().currentMap.setOutdoorCoords(_loc69_.worldX,_loc69_.worldY);
                     _worldPoint = new WorldPointWrapper(_loc69_.mapId,true,_loc69_.worldX,_loc69_.worldY);
                  }
                  else if(param1 is MapComplementaryInformationsDataInHouseMessage)
                  {
                     _loc70_ = param1 as MapComplementaryInformationsDataInHouseMessage;
                     _loc71_ = PlayerManager.getInstance().nickname == _loc70_.currentHouse.ownerName;
                     PlayedCharacterManager.getInstance().isInHouse = true;
                     if(_loc71_)
                     {
                        PlayedCharacterManager.getInstance().isInHisHouse = true;
                     }
                     PlayedCharacterManager.getInstance().currentMap.setOutdoorCoords(_loc70_.currentHouse.worldX,_loc70_.currentHouse.worldY);
                     KernelEventsManager.getInstance().processCallback(HookList.HouseEntered,_loc71_,_loc70_.currentHouse.ownerId,_loc70_.currentHouse.ownerName,_loc70_.currentHouse.price,_loc70_.currentHouse.isLocked,_loc70_.currentHouse.worldX,_loc70_.currentHouse.worldY,HouseWrapper.manualCreate(_loc70_.currentHouse.modelId,-1,_loc70_.currentHouse.ownerName,_loc70_.currentHouse.price != 0));
                     _worldPoint = new WorldPointWrapper(_loc70_.mapId,true,_loc70_.currentHouse.worldX,_loc70_.currentHouse.worldY);
                  }
                  else
                  {
                     _worldPoint = new WorldPointWrapper(_loc3_.mapId);
                     if(PlayedCharacterManager.getInstance().isInHouse)
                     {
                        KernelEventsManager.getInstance().processCallback(HookList.HouseExit);
                     }
                     PlayedCharacterManager.getInstance().isInHouse = false;
                     PlayedCharacterManager.getInstance().isInHisHouse = false;
                  }
                  _currentSubAreaId = _loc3_.subAreaId;
                  _loc62_ = SubArea.getSubAreaById(_currentSubAreaId);
                  PlayedCharacterManager.getInstance().currentMap = _worldPoint;
                  PlayedCharacterManager.getInstance().currentSubArea = _loc62_;
                  TooltipManager.hide();
                  updateCreaturesLimit();
                  if(!this._playersId)
                  {
                     this._playersId = new Array();
                  }
                  for each(_loc63_ in _loc3_.actors)
                  {
                     if(_loc63_.contextualId > 0 && this._playersId.indexOf(_loc63_.contextualId) == -1)
                     {
                        this._playersId.push(_loc63_.contextualId);
                     }
                     if(_loc63_ is GameRolePlayGroupMonsterInformations && this._monstersIds.indexOf(_loc63_.contextualId) == -1)
                     {
                        this._monstersIds.push(_loc63_.contextualId);
                     }
                  }
                  _entitiesVisibleNumber = this._playersId.length + this._monstersIds.length;
                  if(_creaturesLimit == 0 || _creaturesLimit < 50 && _entitiesVisibleNumber >= _creaturesLimit)
                  {
                     _creaturesMode = true;
                  }
                  else
                  {
                     _creaturesMode = false;
                  }
                  _loc64_ = true;
                  _loc65_ = 0;
                  _loc66_ = 0;
                  for each(_loc67_ in _loc3_.actors)
                  {
                     _loc72_ = this.addOrUpdateActor(_loc67_) as AnimatedCharacter;
                     if(_loc72_)
                     {
                        if(_loc72_.id == PlayedCharacterManager.getInstance().id)
                        {
                           if(_loc72_.libraryIsAvaible)
                           {
                              this.updateUsableEmotesListInit(_loc72_.look);
                           }
                           else
                           {
                              _loc72_.addEventListener(TiphonEvent.SPRITE_INIT,this.onPlayerSpriteInit);
                           }
                           if(this.dispatchPlayerNewLook)
                           {
                              KernelEventsManager.getInstance().processCallback(HookList.PlayedCharacterLookChange,_loc72_.look);
                              this.dispatchPlayerNewLook = false;
                           }
                        }
                        _loc73_ = _loc67_ as GameRolePlayCharacterInformations;
                        if(_loc73_)
                        {
                           _loc65_ = 0;
                           _loc66_ = 0;
                           for each(_loc74_ in _loc73_.humanoidInfo.options)
                           {
                              if(_loc74_ is HumanOptionEmote)
                              {
                                 _loc65_ = _loc74_.emoteId;
                                 _loc66_ = _loc74_.emoteStartTime;
                              }
                              else if(_loc74_ is HumanOptionObjectUse)
                              {
                                 _loc75_ = new DelayedActionMessage(_loc73_.contextualId,_loc74_.objectGID,_loc74_.delayEndTime);
                                 Kernel.getWorker().process(_loc75_);
                              }
                           }
                           if(_loc65_ > 0)
                           {
                              _loc76_ = Emoticon.getEmoticonById(_loc65_);
                              if(_loc76_ && _loc76_.persistancy)
                              {
                                 this._currentEmoticon = _loc76_.id;
                                 if(!_loc76_.aura)
                                 {
                                    _loc77_ = false;
                                    _loc78_ = new Date();
                                    if(_loc78_.getTime() - _loc66_ >= _loc76_.duration)
                                    {
                                       _loc77_ = true;
                                    }
                                    _loc79_ = EntityLookAdapter.fromNetwork(_loc73_.look);
                                    _loc80_ = new GameRolePlaySetAnimationMessage(_loc67_,_loc76_.getAnimName(_loc79_),_loc66_,!_loc76_.persistancy,_loc76_.eight_directions,_loc77_);
                                    if(_loc72_.rendered)
                                    {
                                       this.process(_loc80_);
                                    }
                                    else
                                    {
                                       if(_loc80_.playStaticOnly)
                                       {
                                          _loc72_.visible = false;
                                       }
                                       this._waitingEmotesAnims[_loc72_.id] = _loc80_;
                                       _loc72_.removeEventListener(TiphonEvent.RENDER_SUCCEED,this.onEntityReadyForEmote);
                                       _loc72_.addEventListener(TiphonEvent.RENDER_SUCCEED,this.onEntityReadyForEmote);
                                    }
                                 }
                              }
                           }
                        }
                     }
                     if(_loc64_)
                     {
                        if(_loc67_ is GameRolePlayGroupMonsterInformations)
                        {
                           _loc64_ = false;
                           KernelEventsManager.getInstance().processCallback(TriggerHookList.MapWithMonsters);
                        }
                     }
                     if(_loc67_ is GameRolePlayCharacterInformations)
                     {
                        ChatAutocompleteNameManager.getInstance().addEntry((_loc67_ as GameRolePlayCharacterInformations).name,0);
                     }
                  }
                  for each(_loc68_ in _loc3_.fights)
                  {
                     this.addFight(_loc68_);
                  }
               }
               this._housesList = new Dictionary();
               for each(_loc81_ in _loc3_.houses)
               {
                  _loc82_ = HouseWrapper.create(_loc81_);
                  _loc83_ = _loc81_.doorsOnMap.length;
                  _loc84_ = 0;
                  while(_loc84_ < _loc83_)
                  {
                     this._housesList[_loc81_.doorsOnMap[_loc84_]] = _loc82_;
                     _loc84_++;
                  }
                  _loc85_ = new HousePropertiesMessage();
                  _loc85_.initHousePropertiesMessage(_loc81_);
                  Kernel.getWorker().process(_loc85_);
               }
               for each(_loc86_ in _loc3_.obstacles)
               {
                  InteractiveCellManager.getInstance().updateCell(_loc86_.obstacleCellId,_loc86_.state == MapObstacleStateEnum.OBSTACLE_OPENED);
               }
               _loc5_ = Kernel.getWorker().getFrame(RoleplayInteractivesFrame) as RoleplayInteractivesFrame;
               _loc6_ = new InteractiveMapUpdateMessage();
               _loc6_.initInteractiveMapUpdateMessage(_loc3_.interactiveElements);
               _loc5_.process(_loc6_);
               _loc7_ = new StatedMapUpdateMessage();
               _loc7_.initStatedMapUpdateMessage(_loc3_.statedElements);
               _loc5_.process(_loc7_);
               if(!_loc4_)
               {
                  KernelEventsManager.getInstance().processCallback(HookList.MapComplementaryInformationsData,PlayedCharacterManager.getInstance().currentMap,_currentSubAreaId,Dofus.getInstance().options.mapCoordinates);
                  if(OptionManager.getOptionManager("dofus")["allowAnimsFun"] == true)
                  {
                     AnimFunManager.getInstance().initializeByMap(_loc3_.mapId);
                  }
                  this.switchPokemonMode();
                  if(Kernel.getWorker().contains(MonstersInfoFrame))
                  {
                     (Kernel.getWorker().getFrame(MonstersInfoFrame) as MonstersInfoFrame).update();
                  }
                  if(Kernel.getWorker().contains(InfoEntitiesFrame))
                  {
                     (Kernel.getWorker().getFrame(InfoEntitiesFrame) as InfoEntitiesFrame).update();
                  }
               }
               return false;
            case param1 is HousePropertiesMessage:
               _loc8_ = (param1 as HousePropertiesMessage).properties;
               _loc82_ = HouseWrapper.create(_loc8_);
               _loc83_ = _loc8_.doorsOnMap.length;
               _loc84_ = 0;
               while(_loc84_ < _loc83_)
               {
                  this._housesList[_loc8_.doorsOnMap[_loc84_]] = _loc82_;
                  _loc84_++;
               }
               KernelEventsManager.getInstance().processCallback(HookList.HouseProperties,_loc8_.houseId,_loc8_.doorsOnMap,_loc8_.ownerName,_loc8_.isOnSale,_loc8_.modelId);
               return true;
            case param1 is GameRolePlayShowActorMessage:
               _loc9_ = param1 as GameRolePlayShowActorMessage;
               if(_loc9_.informations.contextualId == PlayedCharacterManager.getInstance().id)
               {
                  _loc87_ = (_loc9_.informations as GameRolePlayHumanoidInformations).humanoidInfo as HumanInformations;
                  PlayedCharacterManager.getInstance().restrictions = _loc87_.restrictions;
                  _loc88_ = getEntityInfos(PlayedCharacterManager.getInstance().id) as GameRolePlayHumanoidInformations;
                  if(_loc88_)
                  {
                     _loc88_.humanoidInfo.restrictions = PlayedCharacterManager.getInstance().restrictions;
                  }
               }
               _loc2_ = DofusEntities.getEntity(_loc9_.informations.contextualId) as AnimatedCharacter;
               if(_loc2_ && _loc2_.getAnimation().indexOf(AnimationEnum.ANIM_STATIQUE) == -1)
               {
                  _loc2_.visibleAura = false;
               }
               if(!_loc2_)
               {
                  updateCreaturesLimit();
               }
               _loc2_ = this.addOrUpdateActor(_loc9_.informations);
               if(_loc2_ && _loc9_.informations.contextualId == PlayedCharacterManager.getInstance().id)
               {
                  if(_loc2_.libraryIsAvaible)
                  {
                     this.updateUsableEmotesListInit(_loc2_.look);
                  }
                  else
                  {
                     _loc2_.addEventListener(TiphonEvent.SPRITE_INIT,this.onPlayerSpriteInit);
                  }
               }
               if(this.switchPokemonMode())
               {
                  return true;
               }
               if(_loc9_.informations is GameRolePlayCharacterInformations)
               {
                  ChatAutocompleteNameManager.getInstance().addEntry((_loc9_.informations as GameRolePlayCharacterInformations).name,0);
               }
               if(_loc9_.informations is GameRolePlayCharacterInformations && PlayedCharacterManager.getInstance().characteristics.alignmentInfos.aggressable == AggressableStatusEnum.PvP_ENABLED_AGGRESSABLE)
               {
                  _loc89_ = _loc9_.informations as GameRolePlayCharacterInformations;
                  switch(PlayedCharacterManager.getInstance().levelDiff(_loc89_.alignmentInfos.characterPower - _loc9_.informations.contextualId))
                  {
                     case -1:
                        SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_NEW_ENEMY_WEAK);
                        break;
                     case 1:
                        SpeakingItemManager.getInstance().triggerEvent(SpeakingItemManager.SPEAK_TRIGGER_NEW_ENEMY_STRONG);
                        break;
                  }
               }
               if(OptionManager.getOptionManager("dofus")["allowAnimsFun"] == true && _loc9_.informations is GameRolePlayGroupMonsterInformations)
               {
                  AnimFunManager.getInstance().restart();
               }
               return true;
            case param1 is GameContextRefreshEntityLookMessage:
               _loc10_ = param1 as GameContextRefreshEntityLookMessage;
               _loc2_ = this.updateActorLook(_loc10_.id,_loc10_.look,true);
               if(_loc2_ && _loc10_.id == PlayedCharacterManager.getInstance().id)
               {
                  if(_loc2_.libraryIsAvaible)
                  {
                     this.updateUsableEmotesListInit(_loc2_.look);
                  }
                  else
                  {
                     _loc2_.addEventListener(TiphonEvent.SPRITE_INIT,this.onPlayerSpriteInit);
                  }
               }
               return true;
            case param1 is GameMapChangeOrientationMessage:
               _loc11_ = param1 as GameMapChangeOrientationMessage;
               updateActorOrientation(_loc11_.orientation.id,_loc11_.orientation.direction);
               return true;
            case param1 is GameMapChangeOrientationsMessage:
               _loc12_ = param1 as GameMapChangeOrientationsMessage;
               _loc13_ = _loc12_.orientations.length;
               _loc90_ = 0;
               while(_loc90_ < _loc13_)
               {
                  _loc91_ = _loc12_.orientations[_loc90_];
                  updateActorOrientation(_loc91_.id,_loc91_.direction);
                  _loc90_++;
               }
               return true;
            case param1 is GameRolePlaySetAnimationMessage:
               _loc14_ = param1 as GameRolePlaySetAnimationMessage;
               _loc15_ = DofusEntities.getEntity(_loc14_.informations.contextualId) as AnimatedCharacter;
               if(!_loc15_)
               {
                  _log.error("GameRolePlaySetAnimationMessage : l\'entitée " + _loc14_.informations.contextualId + " n\'a pas ete trouvee");
                  return true;
               }
               this.playAnimationOnEntity(_loc15_,_loc14_.animation,_loc14_.directions8,_loc14_.duration,_loc14_.playStaticOnly);
               return true;
            case param1 is EntityMovementCompleteMessage:
               _loc16_ = param1 as EntityMovementCompleteMessage;
               _loc17_ = _loc16_.entity as AnimatedCharacter;
               if(_entities[_loc17_.getRootEntity().id])
               {
                  (_entities[_loc17_.getRootEntity().id] as GameContextActorInformations).disposition.cellId = _loc17_.position.cellId;
               }
               if(this._entitiesIcons[_loc16_.entity.id])
               {
                  this._entitiesIcons[_loc16_.entity.id].needUpdate = true;
               }
               return false;
            case param1 is EntityMovementStoppedMessage:
               _loc18_ = param1 as EntityMovementStoppedMessage;
               if(this._entitiesIcons[_loc18_.entity.id])
               {
                  this._entitiesIcons[_loc18_.entity.id].needUpdate = true;
               }
               return false;
            case param1 is CharacterMovementStoppedMessage:
               _loc19_ = param1 as CharacterMovementStoppedMessage;
               _loc20_ = DofusEntities.getEntity(PlayedCharacterManager.getInstance().id) as AnimatedCharacter;
               if(OptionManager.getOptionManager("tiphon").auraMode > OptionEnum.AURA_NONE && OptionManager.getOptionManager("tiphon").alwaysShowAuraOnFront && _loc20_.getDirection() == DirectionsEnum.DOWN && _loc20_.getAnimation().indexOf(AnimationEnum.ANIM_STATIQUE) != -1 && PlayedCharacterManager.getInstance().state == PlayerLifeStatusEnum.STATUS_ALIVE_AND_KICKING)
               {
                  _loc93_ = Kernel.getWorker().getFrame(EmoticonFrame) as EmoticonFrame;
                  for each(_loc94_ in _loc93_.emotes)
                  {
                     _loc95_ = Emoticon.getEmoticonById(_loc94_);
                     if(_loc95_ && _loc95_.aura)
                     {
                        if(!_loc92_ || _loc95_.weight > _loc92_.weight)
                        {
                           _loc92_ = _loc95_;
                        }
                     }
                  }
                  if(_loc92_)
                  {
                     _loc96_ = new EmotePlayRequestMessage();
                     _loc96_.initEmotePlayRequestMessage(_loc92_.id);
                     ConnectionsHandler.getConnection().send(_loc96_);
                  }
               }
               return true;
            case param1 is GameRolePlayShowChallengeMessage:
               _loc21_ = param1 as GameRolePlayShowChallengeMessage;
               this.addFight(_loc21_.commonsInfos);
               return true;
            case param1 is GameFightOptionStateUpdateMessage:
               _loc22_ = param1 as GameFightOptionStateUpdateMessage;
               this.updateSwordOptions(_loc22_.fightId,_loc22_.teamId,_loc22_.option,_loc22_.state);
               KernelEventsManager.getInstance().processCallback(HookList.GameFightOptionStateUpdate,_loc22_.fightId,_loc22_.teamId,_loc22_.option,_loc22_.state);
               return true;
            case param1 is GameFightUpdateTeamMessage:
               _loc23_ = param1 as GameFightUpdateTeamMessage;
               this.updateFight(_loc23_.fightId,_loc23_.team);
               return true;
            case param1 is GameFightRemoveTeamMemberMessage:
               _loc24_ = param1 as GameFightRemoveTeamMemberMessage;
               this.removeFighter(_loc24_.fightId,_loc24_.teamId,_loc24_.charId);
               return true;
            case param1 is GameRolePlayRemoveChallengeMessage:
               _loc25_ = param1 as GameRolePlayRemoveChallengeMessage;
               KernelEventsManager.getInstance().processCallback(HookList.GameRolePlayRemoveFight,_loc25_.fightId);
               this.removeFight(_loc25_.fightId);
               return true;
            case param1 is GameContextRemoveElementMessage:
               _loc26_ = param1 as GameContextRemoveElementMessage;
               delete this._lastStaticAnimations[_loc26_.id];
               _loc27_ = 0;
               for each(_loc97_ in this._playersId)
               {
                  if(_loc97_ == _loc26_.id)
                  {
                     this._playersId.splice(_loc27_,1);
                  }
                  else
                  {
                     _loc27_++;
                  }
               }
               _loc28_ = this._monstersIds.indexOf(_loc26_.id);
               if(_loc28_ != -1)
               {
                  this._monstersIds.splice(_loc28_,1);
               }
               if(this._entitiesIconsNames[_loc26_.id])
               {
                  delete this._entitiesIconsNames[_loc26_.id];
               }
               if(this._entitiesIcons[_loc26_.id])
               {
                  this.removeIcon(_loc26_.id);
               }
               delete this._waitingEmotesAnims[_loc26_.id];
               this.removeEntityListeners(_loc26_.id);
               removeActor(_loc26_.id);
               if(OptionManager.getOptionManager("dofus")["allowAnimsFun"] == true && _loc28_ != -1)
               {
                  AnimFunManager.getInstance().restart();
               }
               return true;
            case param1 is MapFightCountMessage:
               _loc29_ = param1 as MapFightCountMessage;
               KernelEventsManager.getInstance().processCallback(HookList.MapFightCount,_loc29_.fightCount);
               return true;
            case param1 is UpdateMapPlayersAgressableStatusMessage:
               _loc30_ = param1 as UpdateMapPlayersAgressableStatusMessage;
               _loc32_ = _loc30_.playerIds.length;
               _loc31_ = 0;
               while(_loc31_ < _loc32_)
               {
                  _loc33_ = getEntityInfos(_loc30_.playerIds[_loc31_]) as GameRolePlayHumanoidInformations;
                  if(_loc33_)
                  {
                     for each(_loc34_ in _loc33_.humanoidInfo.options)
                     {
                        if(_loc34_ is HumanOptionAlliance)
                        {
                           (_loc34_ as HumanOptionAlliance).aggressable = _loc30_.enable[_loc31_];
                           break;
                        }
                     }
                  }
                  if(_loc30_.playerIds[_loc31_] == PlayedCharacterManager.getInstance().id)
                  {
                     PlayedCharacterManager.getInstance().characteristics.alignmentInfos.aggressable = _loc30_.enable[_loc31_];
                     KernelEventsManager.getInstance().processCallback(PrismHookList.PvpAvaStateChange,_loc30_.enable[_loc31_],0);
                  }
                  _loc31_++;
               }
               this.updateConquestIcons(_loc30_.playerIds);
               return true;
            case param1 is UpdateSelfAgressableStatusMessage:
               _loc35_ = param1 as UpdateSelfAgressableStatusMessage;
               _loc36_ = getEntityInfos(PlayedCharacterManager.getInstance().id) as GameRolePlayHumanoidInformations;
               if(_loc36_)
               {
                  for each(_loc37_ in _loc36_.humanoidInfo.options)
                  {
                     if(_loc37_ is HumanOptionAlliance)
                     {
                        (_loc37_ as HumanOptionAlliance).aggressable = _loc35_.status;
                        break;
                     }
                  }
               }
               if(PlayedCharacterManager.getInstance().characteristics)
               {
                  PlayedCharacterManager.getInstance().characteristics.alignmentInfos.aggressable = _loc35_.status;
               }
               KernelEventsManager.getInstance().processCallback(PrismHookList.PvpAvaStateChange,_loc35_.status,_loc35_.probationTime);
               this.updateConquestIcons(PlayedCharacterManager.getInstance().id);
               return true;
            case param1 is ObjectGroundAddedMessage:
               _loc38_ = param1 as ObjectGroundAddedMessage;
               this.addObject(_loc38_.objectGID,_loc38_.cellId);
               return true;
            case param1 is ObjectGroundRemovedMessage:
               _loc39_ = param1 as ObjectGroundRemovedMessage;
               this.removeObject(_loc39_.cell);
               return true;
            case param1 is ObjectGroundRemovedMultipleMessage:
               _loc40_ = param1 as ObjectGroundRemovedMultipleMessage;
               for each(_loc98_ in _loc40_.cells)
               {
                  this.removeObject(_loc98_);
               }
               return true;
            case param1 is ObjectGroundListAddedMessage:
               _loc41_ = param1 as ObjectGroundListAddedMessage;
               _loc42_ = 0;
               for each(_loc99_ in _loc41_.referenceIds)
               {
                  this.addObject(_loc99_,_loc41_.cells[_loc42_]);
                  _loc42_++;
               }
               return true;
            case param1 is PaddockRemoveItemRequestAction:
               _loc43_ = param1 as PaddockRemoveItemRequestAction;
               _loc44_ = new PaddockRemoveItemRequestMessage();
               _loc44_.initPaddockRemoveItemRequestMessage(_loc43_.cellId);
               ConnectionsHandler.getConnection().send(_loc44_);
               return true;
            case param1 is PaddockMoveItemRequestAction:
               _loc45_ = param1 as PaddockMoveItemRequestAction;
               this._currentPaddockItemCellId = _loc45_.object.disposition.cellId;
               _loc46_ = new Texture();
               _loc47_ = ItemWrapper.create(0,0,_loc45_.object.item.id,0,null,false);
               _loc46_.uri = _loc47_.iconUri;
               _loc46_.finalize();
               Kernel.getWorker().addFrame(new RoleplayPointCellFrame(this.onCellPointed,_loc46_,true,this.paddockCellValidator,true));
               return true;
            case param1 is GameDataPaddockObjectRemoveMessage:
               _loc48_ = param1 as GameDataPaddockObjectRemoveMessage;
               _loc49_ = Kernel.getWorker().getFrame(RoleplayContextFrame) as RoleplayContextFrame;
               this.removePaddockItem(_loc48_.cellId);
               return true;
            case param1 is GameDataPaddockObjectAddMessage:
               _loc50_ = param1 as GameDataPaddockObjectAddMessage;
               this.addPaddockItem(_loc50_.paddockItemDescription);
               return true;
            case param1 is GameDataPaddockObjectListAddMessage:
               _loc51_ = param1 as GameDataPaddockObjectListAddMessage;
               for each(_loc100_ in _loc51_.paddockItemDescription)
               {
                  this.addPaddockItem(_loc100_);
               }
               return true;
            case param1 is GameDataPlayFarmObjectAnimationMessage:
               _loc52_ = param1 as GameDataPlayFarmObjectAnimationMessage;
               for each(_loc101_ in _loc52_.cellId)
               {
                  this.activatePaddockItem(_loc101_);
               }
               return true;
            case param1 is MapNpcsQuestStatusUpdateMessage:
               _loc53_ = param1 as MapNpcsQuestStatusUpdateMessage;
               if(MapDisplayManager.getInstance().currentMapPoint.mapId == _loc53_.mapId)
               {
                  for each(_loc102_ in this._npcList)
                  {
                     this.removeBackground(_loc102_);
                  }
                  _loc105_ = _loc53_.npcsIdsWithQuest.length;
                  _loc104_ = 0;
                  while(_loc104_ < _loc105_)
                  {
                     _loc102_ = this._npcList[_loc53_.npcsIdsWithQuest[_loc104_]];
                     if(_loc102_)
                     {
                        _loc106_ = Quest.getFirstValidQuest(_loc53_.questFlags[_loc104_]);
                        if(_loc106_ != null)
                        {
                           if(_loc53_.questFlags[_loc104_].questsToStartId.indexOf(_loc106_.id) != -1)
                           {
                              if(_loc106_.repeatType == 0)
                              {
                                 _loc103_ = EmbedAssets.getSprite("QUEST_CLIP");
                                 _loc102_.addBackground("questClip",_loc103_,true);
                              }
                              else
                              {
                                 _loc103_ = EmbedAssets.getSprite("QUEST_REPEATABLE_CLIP");
                                 _loc102_.addBackground("questRepeatableClip",_loc103_,true);
                              }
                           }
                           else if(_loc106_.repeatType == 0)
                           {
                              _loc103_ = EmbedAssets.getSprite("QUEST_OBJECTIVE_CLIP");
                              _loc102_.addBackground("questObjectiveClip",_loc103_,true);
                           }
                           else
                           {
                              _loc103_ = EmbedAssets.getSprite("QUEST_REPEATABLE_OBJECTIVE_CLIP");
                              _loc102_.addBackground("questRepeatableObjectiveClip",_loc103_,true);
                           }
                        }
                     }
                     _loc104_++;
                  }
               }
               return true;
            case param1 is ShowCellMessage:
               _loc54_ = param1 as ShowCellMessage;
               HyperlinkShowCellManager.showCell(_loc54_.cellId);
               _loc55_ = Kernel.getWorker().getFrame(RoleplayContextFrame) as RoleplayContextFrame;
               _loc56_ = _loc55_.getActorName(_loc54_.sourceId);
               _loc57_ = I18n.getUiText("ui.fight.showCell",[_loc56_,"{cell," + _loc54_.cellId + "::" + _loc54_.cellId + "}"]);
               KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,_loc57_,ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp());
               return true;
            case param1 is StartZoomAction:
               _loc58_ = param1 as StartZoomAction;
               if(Atouin.getInstance().currentZoom != 1)
               {
                  Atouin.getInstance().cancelZoom();
                  KernelEventsManager.getInstance().processCallback(HookList.StartZoom,false);
                  this.updateAllIcons();
                  return true;
               }
               _loc59_ = DofusEntities.getEntity(_loc58_.playerId) as DisplayObject;
               if(_loc59_ && _loc59_.stage)
               {
                  _loc107_ = _loc59_.getRect(Atouin.getInstance().worldContainer);
                  Atouin.getInstance().zoom(_loc58_.value,_loc107_.x + _loc107_.width / 2,_loc107_.y + _loc107_.height / 2);
                  KernelEventsManager.getInstance().processCallback(HookList.StartZoom,true);
                  this.updateAllIcons();
               }
               return true;
            case param1 is SwitchCreatureModeAction:
               _loc60_ = param1 as SwitchCreatureModeAction;
               if(_creaturesMode != _loc60_.isActivated)
               {
                  _creaturesMode = _loc60_.isActivated;
                  for(_loc108_ in _entities)
                  {
                     this.updateActorLook(_loc108_,(_entities[_loc108_] as GameContextActorInformations).look);
                  }
               }
               return true;
            case param1 is MapZoomMessage:
               for each(_loc109_ in _entities)
               {
                  _loc110_ = _loc109_ as FightTeam;
                  if(_loc110_ && _loc110_.fight && _loc110_.teamInfos)
                  {
                     this.updateSwordOptions(_loc110_.fight.fightId,_loc110_.teamInfos.teamId);
                  }
               }
               return true;
            default:
               return false;
         }
      }
      
      private function playAnimationOnEntity(param1:AnimatedCharacter, param2:String, param3:Boolean, param4:uint, param5:Boolean) : void
      {
         var _loc6_:Follower = null;
         var _loc7_:TiphonSprite = null;
         if(param2 == AnimationEnum.ANIM_STATIQUE)
         {
            this._currentEmoticon = 0;
            param1.setAnimation(param2);
            this._emoteTimesBySprite[param1.name] = 0;
         }
         else
         {
            if(!param3)
            {
               if(param1.getDirection() % 2 == 0)
               {
                  param1.setDirection(param1.getDirection() + 1);
               }
            }
            if(_creaturesMode || !param1.hasAnimation(param2,param1.getDirection()))
            {
               _log.error("L\'animation " + param2 + "_" + param1.getDirection() + " est introuvable.");
               param1.visible = true;
            }
            else if(!_creaturesMode)
            {
               this._emoteTimesBySprite[param1.name] = param4;
               param1.removeEventListener(TiphonEvent.ANIMATION_END,this.onAnimationEnd);
               param1.addEventListener(TiphonEvent.ANIMATION_END,this.onAnimationEnd);
               _loc7_ = param1.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0) as TiphonSprite;
               if(_loc7_)
               {
                  _loc7_.removeEventListener(TiphonEvent.ANIMATION_ADDED,this.onAnimationAdded);
                  _loc7_.addEventListener(TiphonEvent.ANIMATION_ADDED,this.onAnimationAdded);
               }
               param1.setAnimation(param2);
               if(param5)
               {
                  if(param1.look.getSubEntitiesFromCategory(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET) && param1.look.getSubEntitiesFromCategory(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET).length)
                  {
                     param1.setSubEntityBehaviour(1,new AnimStatiqueSubEntityBehavior());
                  }
                  param1.stopAnimationAtLastFrame();
                  if(_loc7_)
                  {
                     _loc7_.stopAnimationAtLastFrame();
                  }
               }
            }
         }
         for each(_loc6_ in param1.followers)
         {
            if(_loc6_.type == Follower.TYPE_PET && _loc6_.entity is AnimatedCharacter)
            {
               this.playAnimationOnEntity(_loc6_.entity as AnimatedCharacter,param2,param3,param4,param5);
            }
         }
      }
      
      private function initNewMap() : void
      {
         var _loc1_:* = undefined;
         for each(_loc1_ in this._objectsByCellId)
         {
            (_loc1_ as IDisplayable).remove();
         }
         this._npcList = new Dictionary();
         this._fights = new Dictionary();
         this._objects = new Dictionary();
         this._objectsByCellId = new Dictionary();
         this._paddockItem = new Dictionary();
      }
      
      override protected function switchPokemonMode() : Boolean
      {
         if(super.switchPokemonMode())
         {
            KernelEventsManager.getInstance().processCallback(TriggerHookList.CreaturesMode);
            return true;
         }
         return false;
      }
      
      override public function pulled() : Boolean
      {
         var _loc1_:Fight = null;
         var _loc2_:* = undefined;
         var _loc3_:AnimatedCharacter = null;
         var _loc4_:FightTeam = null;
         for each(_loc1_ in this._fights)
         {
            for each(_loc4_ in _loc1_.teams)
            {
               (_loc4_.teamEntity as TiphonSprite).removeEventListener(TiphonEvent.RENDER_SUCCEED,this.onFightEntityRendered);
               TooltipManager.hide("fightOptions_" + _loc1_.fightId + "_" + _loc4_.teamInfos.teamId);
            }
         }
         if(this._loader)
         {
            this._loader.removeEventListener(ResourceLoadedEvent.LOADED,this.onGroundObjectLoaded);
            this._loader.removeEventListener(ResourceErrorEvent.ERROR,this.onGroundObjectLoadFailed);
            this._loader = null;
         }
         if(OptionManager.getOptionManager("dofus")["allowAnimsFun"] == true)
         {
            AnimFunManager.getInstance().stop();
         }
         this._fights = null;
         this._objects = null;
         this._npcList = null;
         Dofus.getInstance().options.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onPropertyChanged);
         Tiphon.getInstance().options.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onTiphonPropertyChanged);
         Atouin.getInstance().options.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGED,this.onAtouinPropertyChanged);
         EnterFrameDispatcher.removeEventListener(this.showIcons);
         this.removeAllIcons();
         if(OptionManager.getOptionManager("tiphon").auraMode == OptionEnum.AURA_CYCLE)
         {
            this._auraCycleTimer.removeEventListener(TimerEvent.TIMER,this.onAuraCycleTimer);
            this._auraCycleTimer.stop();
         }
         this._lastEntityWithAura = null;
         for(_loc2_ in _entities)
         {
            _loc3_ = EntitiesManager.getInstance().getEntity(_loc2_) as AnimatedCharacter;
            if(_loc3_)
            {
               _loc3_.removeEventListener(TiphonEvent.SPRITE_INIT,this.onPlayerSpriteInit);
            }
         }
         return super.pulled();
      }
      
      public function isFight(param1:int) : Boolean
      {
         if(!_entities)
         {
            return false;
         }
         return _entities[param1] is FightTeam;
      }
      
      public function isPaddockItem(param1:int) : Boolean
      {
         return _entities[param1] is GameContextPaddockItemInformations;
      }
      
      public function getFightTeam(param1:int) : FightTeam
      {
         return _entities[param1] as FightTeam;
      }
      
      public function getFightId(param1:int) : uint
      {
         return (_entities[param1] as FightTeam).fight.fightId;
      }
      
      public function getFightLeaderId(param1:int) : uint
      {
         return (_entities[param1] as FightTeam).teamInfos.leaderId;
      }
      
      public function getFightTeamType(param1:int) : uint
      {
         return (_entities[param1] as FightTeam).teamType;
      }
      
      public function updateMonstersGroups() : void
      {
         var _loc2_:GameContextActorInformations = null;
         var _loc1_:Dictionary = getEntitiesDictionnary();
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_ is GameRolePlayGroupMonsterInformations)
            {
               this.updateMonstersGroup(_loc2_ as GameRolePlayGroupMonsterInformations);
            }
         }
      }
      
      private function updateMonstersGroup(param1:GameRolePlayGroupMonsterInformations) : void
      {
         var _loc3_:MonsterInGroupLightInformations = null;
         var _loc5_:uint = 0;
         var _loc6_:MonsterInGroupLightInformations = null;
         var _loc7_:Monster = null;
         var _loc8_:* = 0;
         var _loc11_:* = 0;
         var _loc2_:Vector.<MonsterInGroupLightInformations> = this.getMonsterGroup(param1.staticInfos);
         var _loc4_:Boolean = Monster.getMonsterById(param1.staticInfos.mainCreatureLightInfos.creatureGenericId).isMiniBoss;
         if(_loc2_)
         {
            for each(_loc3_ in _loc2_)
            {
               if(_loc3_.creatureGenericId == param1.staticInfos.mainCreatureLightInfos.creatureGenericId)
               {
                  _loc2_.splice(_loc2_.indexOf(_loc3_),1);
                  break;
               }
            }
         }
         var _loc9_:Vector.<EntityLook> = null;
         var _loc10_:Vector.<Number> = null;
         if(Dofus.getInstance().options.showEveryMonsters)
         {
            if(_loc2_)
            {
               _loc11_ = _loc2_.length;
            }
            else
            {
               _loc11_ = param1.staticInfos.underlings.length;
            }
            _loc9_ = new Vector.<EntityLook>(_loc11_,true);
            _loc10_ = new Vector.<Number>(_loc9_.length,true);
         }
         for each(_loc6_ in param1.staticInfos.underlings)
         {
            if(_loc9_)
            {
               _loc7_ = Monster.getMonsterById(_loc6_.creatureGenericId);
               _loc8_ = -1;
               if(!_loc2_)
               {
                  _loc8_ = 0;
               }
               else
               {
                  for each(_loc3_ in _loc2_)
                  {
                     if(_loc3_.creatureGenericId == _loc6_.creatureGenericId)
                     {
                        _loc2_.splice(_loc2_.indexOf(_loc3_),1);
                        _loc8_ = _loc3_.grade;
                        break;
                     }
                  }
               }
               if(_loc8_ >= 0)
               {
                  _loc10_[_loc5_] = _loc7_.speedAdjust;
                  _loc9_[_loc5_] = EntityLookAdapter.toNetwork(TiphonEntityLook.fromString(_loc7_.look));
                  _loc5_++;
               }
            }
            if(!_loc4_ && Monster.getMonsterById(_loc6_.creatureGenericId).isMiniBoss)
            {
               _loc4_ = true;
               if(!_loc9_)
               {
                  break;
               }
            }
         }
         if(_loc9_)
         {
            this.manageFollowers(DofusEntities.getEntity(param1.contextualId) as AnimatedCharacter,_loc9_,_loc10_,null,true);
         }
      }
      
      private function getMonsterGroup(param1:GroupMonsterStaticInformations) : Vector.<MonsterInGroupLightInformations>
      {
         var _loc2_:Vector.<MonsterInGroupLightInformations> = null;
         var _loc4_:PartyManagementFrame = null;
         var _loc5_:Vector.<PartyMemberWrapper> = null;
         var _loc6_:* = 0;
         var _loc7_:AlternativeMonstersInGroupLightInformations = null;
         var _loc8_:PartyMemberWrapper = null;
         var _loc3_:GroupMonsterStaticInformationsWithAlternatives = param1 as GroupMonsterStaticInformationsWithAlternatives;
         if(_loc3_)
         {
            _loc4_ = Kernel.getWorker().getFrame(PartyManagementFrame) as PartyManagementFrame;
            _loc5_ = _loc4_.partyMembers;
            _loc6_ = _loc5_.length;
            if(_loc6_ == 0 && PlayedCharacterManager.getInstance().hasCompanion)
            {
               _loc6_ = 2;
            }
            else
            {
               for each(_loc8_ in _loc5_)
               {
                  _loc6_ = _loc6_ + _loc8_.companions.length;
               }
            }
            for each(_loc7_ in _loc3_.alternatives)
            {
               if(!_loc2_ || _loc7_.playerCount <= _loc6_)
               {
                  _loc2_ = _loc7_.monsters;
               }
            }
         }
         return _loc2_?_loc2_.concat():null;
      }
      
      override public function addOrUpdateActor(param1:GameContextActorInformations, param2:IAnimationModifier = null) : AnimatedCharacter
      {
         var _loc3_:AnimatedCharacter = null;
         var _loc4_:Sprite = null;
         var _loc5_:Quest = null;
         var _loc6_:GameRolePlayGroupMonsterInformations = null;
         var _loc7_:* = false;
         var _loc8_:Vector.<EntityLook> = null;
         var _loc9_:Vector.<uint> = null;
         var _loc10_:Array = null;
         var _loc11_:MonsterInGroupInformations = null;
         var _loc12_:* = undefined;
         var _loc13_:Array = null;
         var _loc14_:IndexedEntityLook = null;
         var _loc15_:IndexedEntityLook = null;
         var _loc16_:TiphonEntityLook = null;
         _loc3_ = super.addOrUpdateActor(param1);
         switch(true)
         {
            case param1 is GameRolePlayNpcWithQuestInformations:
               this._npcList[param1.contextualId] = _loc3_;
               _loc5_ = Quest.getFirstValidQuest((param1 as GameRolePlayNpcWithQuestInformations).questFlag);
               this.removeBackground(_loc3_);
               if(_loc5_ != null)
               {
                  if((param1 as GameRolePlayNpcWithQuestInformations).questFlag.questsToStartId.indexOf(_loc5_.id) != -1)
                  {
                     if(_loc5_.repeatType == 0)
                     {
                        _loc4_ = EmbedAssets.getSprite("QUEST_CLIP");
                        _loc3_.addBackground("questClip",_loc4_,true);
                     }
                     else
                     {
                        _loc4_ = EmbedAssets.getSprite("QUEST_REPEATABLE_CLIP");
                        _loc3_.addBackground("questRepeatableClip",_loc4_,true);
                     }
                  }
                  else if(_loc5_.repeatType == 0)
                  {
                     _loc4_ = EmbedAssets.getSprite("QUEST_OBJECTIVE_CLIP");
                     _loc3_.addBackground("questObjectiveClip",_loc4_,true);
                  }
                  else
                  {
                     _loc4_ = EmbedAssets.getSprite("QUEST_REPEATABLE_OBJECTIVE_CLIP");
                     _loc3_.addBackground("questRepeatableObjectiveClip",_loc4_,true);
                  }
               }
               if(_loc3_.look.getBone() == 1)
               {
                  _loc3_.addAnimationModifier(_customAnimModifier);
               }
               if(_creaturesMode || _loc3_.getAnimation() == AnimationEnum.ANIM_STATIQUE)
               {
                  _loc3_.setAnimation(AnimationEnum.ANIM_STATIQUE);
               }
               break;
            case param1 is GameRolePlayGroupMonsterInformations:
               _loc6_ = param1 as GameRolePlayGroupMonsterInformations;
               _loc7_ = Monster.getMonsterById(_loc6_.staticInfos.mainCreatureLightInfos.creatureGenericId).isMiniBoss;
               if(!_loc7_ && _loc6_.staticInfos.underlings && _loc6_.staticInfos.underlings.length > 0)
               {
                  for each(_loc11_ in _loc6_.staticInfos.underlings)
                  {
                     _loc7_ = Monster.getMonsterById(_loc11_.creatureGenericId).isMiniBoss;
                     if(_loc7_)
                     {
                        break;
                     }
                  }
               }
               this.updateMonstersGroup(_loc6_);
               if(this._monstersIds.indexOf(param1.contextualId) == -1)
               {
                  this._monstersIds.push(param1.contextualId);
               }
               if(Kernel.getWorker().contains(MonstersInfoFrame))
               {
                  (Kernel.getWorker().getFrame(MonstersInfoFrame) as MonstersInfoFrame).update();
               }
               if(PlayerManager.getInstance().serverGameType != 0 && _loc6_.hasHardcoreDrop)
               {
                  this.addEntityIcon(_loc6_.contextualId,"treasure");
               }
               if(_loc7_)
               {
                  this.addEntityIcon(_loc6_.contextualId,"archmonsters");
               }
               if(_loc6_.hasAVARewardToken)
               {
                  this.addEntityIcon(_loc6_.contextualId,"nugget");
               }
               break;
            case param1 is GameRolePlayHumanoidInformations:
               if(param1.contextualId > 0 && this._playersId && this._playersId.indexOf(param1.contextualId) == -1)
               {
                  this._playersId.push(param1.contextualId);
               }
               _loc8_ = new Vector.<EntityLook>();
               _loc9_ = new Vector.<uint>();
               for each(_loc12_ in (param1 as GameRolePlayHumanoidInformations).humanoidInfo.options)
               {
                  switch(true)
                  {
                     case _loc12_ is HumanOptionFollowers:
                        _loc13_ = new Array();
                        for each(_loc14_ in _loc12_.followingCharactersLook)
                        {
                           _loc13_.push(_loc14_);
                        }
                        _loc13_.sortOn("index");
                        for each(_loc15_ in _loc13_)
                        {
                           _loc8_.push(_loc15_.look);
                           _loc9_.push(Follower.TYPE_NETWORK);
                        }
                        continue;
                     case _loc12_ is HumanOptionAlliance:
                        this.addConquestIcon(param1.contextualId,_loc12_ as HumanOptionAlliance);
                        continue;
                     default:
                        continue;
                  }
               }
               _loc10_ = _loc3_.look.getSubEntitiesFromCategory(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET_FOLLOWER);
               for each(_loc16_ in _loc10_)
               {
                  _loc8_.push(EntityLookAdapter.toNetwork(_loc16_));
                  _loc9_.push(Follower.TYPE_PET);
               }
               this.manageFollowers(_loc3_,_loc8_,null,_loc9_);
               if(_loc3_.look.getBone() == 1)
               {
                  _loc3_.addAnimationModifier(_customAnimModifier);
               }
               if(_creaturesMode || _loc3_.getAnimation() == AnimationEnum.ANIM_STATIQUE)
               {
                  _loc3_.setAnimation(AnimationEnum.ANIM_STATIQUE);
               }
               break;
            case param1 is GameRolePlayMerchantInformations:
               if(_loc3_.look.getBone() == 1)
               {
                  _loc3_.addAnimationModifier(_customAnimModifier);
               }
               if(_creaturesMode || _loc3_.getAnimation() == AnimationEnum.ANIM_STATIQUE)
               {
                  _loc3_.setAnimation(AnimationEnum.ANIM_STATIQUE);
               }
               break;
            case param1 is GameRolePlayTaxCollectorInformations:
            case param1 is GameRolePlayPrismInformations:
            case param1 is GameRolePlayPortalInformations:
               _loc3_.allowMovementThrough = true;
               break;
            case param1 is GameRolePlayNpcInformations:
               this._npcList[param1.contextualId] = _loc3_;
            case param1 is GameContextPaddockItemInformations:
               break;
            default:
               _log.warn("Unknown GameRolePlayActorInformations type : " + param1 + ".");
         }
         return _loc3_;
      }
      
      override protected function updateActorLook(param1:int, param2:EntityLook, param3:Boolean = false) : AnimatedCharacter
      {
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:* = false;
         var _loc10_:TiphonEntityLook = null;
         var _loc11_:Follower = null;
         var _loc4_:AnimatedCharacter = DofusEntities.getEntity(param1) as AnimatedCharacter;
         if(_loc4_)
         {
            _loc5_ = (TiphonUtility.getEntityWithoutMount(_loc4_) as TiphonSprite).getAnimation();
            if(!_creaturesMode)
            {
               _loc7_ = EntityLookAdapter.fromNetwork(param2).getSubEntitiesFromCategory(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET_FOLLOWER);
               _loc8_ = [];
               _loc9_ = false;
               for each(_loc10_ in _loc7_)
               {
                  _loc9_ = false;
                  for each(_loc11_ in _loc4_.followers)
                  {
                     if(_loc11_.type == Follower.TYPE_PET && _loc11_.entity is TiphonSprite && (_loc11_.entity as TiphonSprite).look.equals(_loc10_))
                     {
                        _loc9_ = true;
                        break;
                     }
                  }
                  if(!_loc9_)
                  {
                     _loc8_.push(_loc10_);
                  }
               }
               for each(_loc10_ in _loc8_)
               {
                  _loc4_.addFollower(this.createFollower(_loc10_,_loc4_,Follower.TYPE_PET),true);
               }
            }
            _loc6_ = [];
            for each(_loc11_ in _loc4_.followers)
            {
               _loc9_ = false;
               if(_loc11_.type == Follower.TYPE_PET)
               {
                  for each(_loc10_ in _loc7_)
                  {
                     if(_loc11_.entity is TiphonSprite && (_loc11_.entity as TiphonSprite).look.equals(_loc10_))
                     {
                        _loc9_ = true;
                        break;
                     }
                  }
                  if(!_loc9_)
                  {
                     _loc6_.push(_loc11_);
                  }
               }
            }
            for each(_loc11_ in _loc6_)
            {
               _loc4_.removeFollower(_loc11_);
            }
            if(_loc5_.indexOf("_Statique_") != -1 && (!this._lastStaticAnimations[param1] || this._lastStaticAnimations[param1] != _loc5_))
            {
               this._lastStaticAnimations[param1] = {"anim":_loc5_};
            }
            if(_loc4_.look.getBone() != param2.bonesId && this._lastStaticAnimations[param1])
            {
               this._lastStaticAnimations[param1].targetBone = param2.bonesId;
               _loc4_.removeEventListener(TiphonEvent.RENDER_SUCCEED,this.onEntityRendered);
               _loc4_.addEventListener(TiphonEvent.RENDER_SUCCEED,this.onEntityRendered);
               _loc4_.setAnimation(AnimationEnum.ANIM_STATIQUE);
            }
         }
         return super.updateActorLook(param1,param2,param3);
      }
      
      private function onEntityRendered(param1:TiphonEvent) : void
      {
         var _loc2_:AnimatedCharacter = param1.currentTarget as AnimatedCharacter;
         if(_loc2_ && this._lastStaticAnimations[_loc2_.id] && _loc2_.look && this._lastStaticAnimations[_loc2_.id].targetBone == _loc2_.look.getBone() && _loc2_.rendered)
         {
            _loc2_.removeEventListener(TiphonEvent.RENDER_SUCCEED,this.onEntityRendered);
            _loc2_.setAnimation(this._lastStaticAnimations[_loc2_.id].anim);
            delete this._lastStaticAnimations[_loc2_.id];
         }
      }
      
      private function removeBackground(param1:TiphonSprite) : void
      {
         if(!param1)
         {
            return;
         }
         param1.removeBackground("questClip");
         param1.removeBackground("questObjectiveClip");
         param1.removeBackground("questRepeatableClip");
         param1.removeBackground("questRepeatableObjectiveClip");
      }
      
      private function manageFollowers(param1:AnimatedCharacter, param2:Vector.<EntityLook>, param3:Vector.<Number> = null, param4:Vector.<uint> = null, param5:Boolean = false) : void
      {
         var _loc6_:* = 0;
         var _loc7_:* = 0;
         var _loc8_:EntityLook = null;
         var _loc9_:TiphonEntityLook = null;
         if(_creaturesMode && !param5)
         {
            return;
         }
         if(!param1.followersEqual(param2))
         {
            param1.removeAllFollowers();
            _loc6_ = param2.length;
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc8_ = param2[_loc7_];
               _loc9_ = EntityLookAdapter.fromNetwork(_loc8_);
               param1.addFollower(this.createFollower(_loc9_,param1,param4?param4[_loc7_]:param5?Follower.TYPE_MONSTER:Follower.TYPE_NETWORK,param3 != null?param3[_loc7_]:null));
               _loc7_++;
            }
         }
      }
      
      private function createFollower(param1:TiphonEntityLook, param2:AnimatedCharacter, param3:uint, param4:Number = 0) : Follower
      {
         var _loc5_:AnimatedCharacter = new AnimatedCharacter(EntitiesManager.getInstance().getFreeEntityId(),param1,param2);
         if(param4)
         {
            _loc5_.speedAdjust = param4;
         }
         return new Follower(_loc5_,param3);
      }
      
      private function addFight(param1:FightCommonInformations) : void
      {
         var _loc5_:FightTeamInformations = null;
         var _loc6_:IEntity = null;
         var _loc7_:FightTeam = null;
         var _loc2_:Vector.<FightTeam> = new Vector.<FightTeam>(0,false);
         var _loc3_:Fight = new Fight(param1.fightId,_loc2_);
         var _loc4_:uint = 0;
         for each(_loc5_ in param1.fightTeams)
         {
            _loc6_ = RolePlayEntitiesFactory.createFightEntity(param1,_loc5_,MapPoint.fromCellId(param1.fightTeamsPositions[_loc4_]));
            (_loc6_ as IDisplayable).display();
            _loc7_ = new FightTeam(_loc3_,_loc5_.teamTypeId,_loc6_,_loc5_,param1.fightTeamsOptions[_loc5_.teamId]);
            _entities[_loc6_.id] = _loc7_;
            _loc2_.push(_loc7_);
            _loc4_++;
            (_loc6_ as TiphonSprite).addEventListener(TiphonEvent.RENDER_SUCCEED,this.onFightEntityRendered,false,0,true);
         }
         this._fights[param1.fightId] = _loc3_;
      }
      
      private function addObject(param1:uint, param2:uint) : void
      {
         if(this._objectsByCellId && this._objectsByCellId[param2])
         {
            _log.error("To add an object on the ground, the destination cell must be empty.");
            return;
         }
         var _loc3_:Uri = new Uri(LangManager.getInstance().getEntry("config.gfx.path.item.vector") + Item.getItemById(param1).iconId + ".swf");
         var _loc4_:IInteractive = new RoleplayObjectEntity(param1,MapPoint.fromCellId(param2));
         (_loc4_ as IDisplayable).display();
         var _loc5_:GameContextActorInformations = new GroundObject(Item.getItemById(param1));
         _loc5_.contextualId = _loc4_.id;
         _loc5_.disposition.cellId = param2;
         _loc5_.disposition.direction = DirectionsEnum.DOWN_RIGHT;
         if(this._objects == null)
         {
            this._objects = new Dictionary();
         }
         this._objects[_loc3_] = _loc4_;
         this._objectsByCellId[param2] = this._objects[_loc3_];
         _entities[_loc4_.id] = _loc5_;
         this._loader.load(_loc3_,null,null,true);
      }
      
      private function removeObject(param1:uint) : void
      {
         if(this._objectsByCellId[param1] != null)
         {
            if(this._objects[this._objectsByCellId[param1]] != null)
            {
               delete this._objects[this._objectsByCellId[param1]];
            }
            if(_entities[this._objectsByCellId[param1].id] != null)
            {
               delete _entities[this._objectsByCellId[param1].id];
            }
            (this._objectsByCellId[param1] as IDisplayable).remove();
            delete this._objectsByCellId[param1];
         }
      }
      
      private function updateFight(param1:uint, param2:FightTeamInformations) : void
      {
         var _loc6_:FightTeamMemberInformations = null;
         var _loc7_:* = false;
         var _loc8_:FightTeamMemberInformations = null;
         var _loc3_:Fight = this._fights[param1];
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:FightTeam = _loc3_.getTeamById(param2.teamId);
         var _loc5_:FightTeamInformations = (_entities[_loc4_.teamEntity.id] as FightTeam).teamInfos;
         if(_loc5_.teamMembers == param2.teamMembers)
         {
            return;
         }
         for each(_loc6_ in param2.teamMembers)
         {
            _loc7_ = false;
            for each(_loc8_ in _loc5_.teamMembers)
            {
               if(_loc8_.id == _loc6_.id)
               {
                  _loc7_ = true;
               }
            }
            if(!_loc7_)
            {
               _loc5_.teamMembers.push(_loc6_);
            }
         }
      }
      
      private function removeFighter(param1:uint, param2:uint, param3:int) : void
      {
         var _loc5_:FightTeam = null;
         var _loc6_:FightTeamInformations = null;
         var _loc7_:Vector.<FightTeamMemberInformations> = null;
         var _loc8_:FightTeamMemberInformations = null;
         var _loc4_:Fight = this._fights[param1];
         if(_loc4_)
         {
            _loc5_ = _loc4_.teams[param2];
            _loc6_ = _loc5_.teamInfos;
            _loc7_ = new Vector.<FightTeamMemberInformations>(0,false);
            for each(_loc8_ in _loc6_.teamMembers)
            {
               if(_loc8_.id != param3)
               {
                  _loc7_.push(_loc8_);
               }
            }
            _loc6_.teamMembers = _loc7_;
         }
      }
      
      private function removeFight(param1:uint) : void
      {
         var _loc3_:FightTeam = null;
         var _loc4_:Object = null;
         var _loc2_:Fight = this._fights[param1];
         if(_loc2_ == null)
         {
            return;
         }
         for each(_loc3_ in _loc2_.teams)
         {
            _loc4_ = _entities[_loc3_.teamEntity.id];
            Kernel.getWorker().process(new EntityMouseOutMessage(_loc3_.teamEntity as IInteractive));
            (_loc3_.teamEntity as IDisplayable).remove();
            TooltipManager.hide("fightOptions_" + param1 + "_" + _loc3_.teamInfos.teamId);
            delete _entities[_loc3_.teamEntity.id];
         }
         delete this._fights[param1];
      }
      
      private function addPaddockItem(param1:PaddockItem) : void
      {
         var _loc3_:* = 0;
         var _loc2_:Item = Item.getItemById(param1.objectGID);
         if(this._paddockItem[param1.cellId])
         {
            _loc3_ = (this._paddockItem[param1.cellId] as IEntity).id;
         }
         else
         {
            _loc3_ = EntitiesManager.getInstance().getFreeEntityId();
         }
         var _loc4_:GameContextPaddockItemInformations = new GameContextPaddockItemInformations(_loc3_,_loc2_.appearance,param1.cellId,param1.durability,_loc2_);
         var _loc5_:IEntity = this.addOrUpdateActor(_loc4_);
         this._paddockItem[param1.cellId] = _loc5_;
      }
      
      private function removePaddockItem(param1:uint) : void
      {
         var _loc2_:IEntity = this._paddockItem[param1];
         if(!_loc2_)
         {
            return;
         }
         (_loc2_ as IDisplayable).remove();
         delete this._paddockItem[param1];
      }
      
      private function activatePaddockItem(param1:uint) : void
      {
         var _loc3_:SerialSequencer = null;
         var _loc2_:TiphonSprite = this._paddockItem[param1];
         if(_loc2_)
         {
            _loc3_ = new SerialSequencer();
            _loc3_.addStep(new PlayAnimationStep(_loc2_,AnimationEnum.ANIM_HIT));
            _loc3_.addStep(new PlayAnimationStep(_loc2_,AnimationEnum.ANIM_STATIQUE));
            _loc3_.start();
         }
      }
      
      private function onFightEntityRendered(param1:TiphonEvent) : void
      {
         if(!_entities || !param1.target)
         {
            return;
         }
         var _loc2_:FightTeam = _entities[param1.target.id];
         if(_loc2_ && _loc2_.fight && _loc2_.teamInfos)
         {
            this.updateSwordOptions(_loc2_.fight.fightId,_loc2_.teamInfos.teamId);
         }
      }
      
      private function updateSwordOptions(param1:uint, param2:uint, param3:int = -1, param4:Boolean = false) : void
      {
         var _loc8_:* = undefined;
         var _loc5_:Fight = this._fights[param1];
         if(_loc5_ == null)
         {
            return;
         }
         var _loc6_:FightTeam = _loc5_.teams[param2];
         if(_loc6_ == null)
         {
            return;
         }
         if(param3 != -1)
         {
            _loc6_.teamOptions[param3] = param4;
         }
         var _loc7_:Vector.<String> = new Vector.<String>();
         for(_loc8_ in _loc6_.teamOptions)
         {
            if(_loc6_.teamOptions[_loc8_])
            {
               _loc7_.push("fightOption" + _loc8_);
            }
         }
         if(_loc6_.hasGroupMember())
         {
            _loc7_.push("fightOption4");
         }
         TooltipManager.show(_loc7_,(_loc6_.teamEntity as IDisplayable).absoluteBounds,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),false,"fightOptions_" + param1 + "_" + param2,LocationEnum.POINT_BOTTOM,LocationEnum.POINT_TOP,0,true,"texturesList",null,null,null,false,0,Atouin.getInstance().currentZoom,false);
      }
      
      private function paddockCellValidator(param1:int) : Boolean
      {
         var _loc3_:GameContextActorInformations = null;
         var _loc2_:IEntity = EntitiesManager.getInstance().getEntityOnCell(param1);
         if(_loc2_)
         {
            _loc3_ = getEntityInfos(_loc2_.id);
            if(_loc3_ is GameContextPaddockItemInformations)
            {
               return false;
            }
         }
         return DataMapProvider.getInstance().farmCell(MapPoint.fromCellId(param1).x,MapPoint.fromCellId(param1).y) && DataMapProvider.getInstance().pointMov(MapPoint.fromCellId(param1).x,MapPoint.fromCellId(param1).y,true);
      }
      
      private function removeEntityListeners(param1:int) : void
      {
         var _loc3_:TiphonSprite = null;
         var _loc2_:TiphonSprite = DofusEntities.getEntity(param1) as TiphonSprite;
         if(_loc2_)
         {
            _loc2_.removeEventListener(TiphonEvent.ANIMATION_END,this.onAnimationEnd);
            _loc3_ = _loc2_.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0) as TiphonSprite;
            if(_loc3_)
            {
               _loc3_.removeEventListener(TiphonEvent.ANIMATION_ADDED,this.onAnimationAdded);
            }
            _loc2_.removeEventListener(TiphonEvent.RENDER_SUCCEED,this.onEntityReadyForEmote);
         }
      }
      
      private function updateUsableEmotesListInit(param1:TiphonEntityLook) : void
      {
         var _loc2_:TiphonEntityLook = null;
         var _loc4_:GameContextActorInformations = null;
         var _loc5_:Array = null;
         if(_entities && _entities[PlayedCharacterManager.getInstance().id])
         {
            _loc4_ = _entities[PlayedCharacterManager.getInstance().id] as GameContextActorInformations;
            _loc2_ = EntityLookAdapter.fromNetwork(_loc4_.look);
         }
         var _loc3_:Array = _loc2_.getSubEntitiesFromCategory(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_PET_FOLLOWER);
         if((_creaturesMode || _creaturesFightMode || _loc3_ && _loc3_.length != 0) && _loc2_)
         {
            _loc5_ = TiphonMultiBonesManager.getInstance().getAllBonesFromLook(_loc2_);
            TiphonMultiBonesManager.getInstance().forceBonesLoading(_loc5_,new Callback(this.updateUsableEmotesList,_loc2_));
         }
         else
         {
            this.updateUsableEmotesList(param1);
         }
      }
      
      private function updateUsableEmotesList(param1:TiphonEntityLook) : void
      {
         var _loc5_:EmoteWrapper = null;
         var _loc6_:String = null;
         var _loc8_:* = false;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc12_:ShortcutWrapper = null;
         var _loc14_:* = 0;
         var _loc2_:Boolean = PlayedCharacterManager.getInstance().isGhost;
         var _loc3_:EmoticonFrame = Kernel.getWorker().getFrame(EmoticonFrame) as EmoticonFrame;
         var _loc4_:Array = _loc3_.emotesList;
         var _loc7_:Array = param1.getSubEntities();
         var _loc11_:* = false;
         this._usableEmotes = new Array();
         var _loc13_:uint = param1.getBone();
         for each(_loc5_ in _loc4_)
         {
            _loc8_ = false;
            if(_loc5_ && _loc5_.emote)
            {
               _loc6_ = _loc5_.emote.getAnimName(param1);
               if(_loc5_.emote.aura && !_loc2_ || Tiphon.skullLibrary.hasAnim(param1.getBone(),_loc6_))
               {
                  _loc8_ = true;
               }
               else if(_loc7_)
               {
                  for(_loc9_ in _loc7_)
                  {
                     for(_loc10_ in _loc7_[_loc9_])
                     {
                        if(Tiphon.skullLibrary.hasAnim(_loc7_[_loc9_][_loc10_].getBone(),_loc6_))
                        {
                           _loc8_ = true;
                           break;
                        }
                     }
                     if(_loc8_)
                     {
                        break;
                     }
                  }
               }
               _loc14_ = _loc3_.emotes.indexOf(_loc5_.id);
               for each(_loc12_ in InventoryManager.getInstance().shortcutBarItems)
               {
                  if(_loc12_ && _loc12_.type == 4 && _loc12_.id == _loc5_.id && _loc12_.active != _loc8_)
                  {
                     _loc12_.active = _loc8_;
                     _loc11_ = true;
                     break;
                  }
               }
               if(_loc8_)
               {
                  this._usableEmotes.push(_loc5_.id);
                  if(_loc14_ == -1)
                  {
                     _loc3_.emotes.push(_loc5_.id);
                  }
               }
               else if(_loc14_ != -1)
               {
                  _loc3_.emotes.splice(_loc14_,1);
               }
            }
         }
         KernelEventsManager.getInstance().processCallback(RoleplayHookList.EmoteEnabledListUpdated,this._usableEmotes);
         if(_loc11_)
         {
            KernelEventsManager.getInstance().processCallback(InventoryHookList.ShortcutBarViewContent,0);
         }
      }
      
      private function onEntityReadyForEmote(param1:TiphonEvent) : void
      {
         var _loc2_:AnimatedCharacter = param1.currentTarget as AnimatedCharacter;
         _loc2_.removeEventListener(TiphonEvent.RENDER_SUCCEED,this.onEntityReadyForEmote);
         if(this._playersId.indexOf(_loc2_.id) != -1)
         {
            this.process(this._waitingEmotesAnims[_loc2_.id]);
         }
         delete this._waitingEmotesAnims[_loc2_.id];
      }
      
      private function onAnimationAdded(param1:TiphonEvent) : void
      {
         var _loc5_:String = null;
         var _loc6_:Vector.<SoundAnimation> = null;
         var _loc7_:SoundAnimation = null;
         var _loc8_:String = null;
         var _loc2_:TiphonSprite = param1.currentTarget as TiphonSprite;
         _loc2_.removeEventListener(TiphonEvent.ANIMATION_ADDED,this.onAnimationAdded);
         var _loc3_:TiphonAnimation = _loc2_.rawAnimation;
         var _loc4_:SoundBones = SoundBones.getSoundBonesById(_loc2_.look.getBone());
         if(_loc4_)
         {
            _loc5_ = getQualifiedClassName(_loc3_);
            _loc6_ = _loc4_.getSoundAnimations(_loc5_);
            _loc3_.spriteHandler.tiphonEventManager.removeEvents(TiphonEventsManager.BALISE_SOUND,_loc5_);
            for each(_loc7_ in _loc6_)
            {
               _loc8_ = TiphonEventsManager.BALISE_DATASOUND + TiphonEventsManager.BALISE_PARAM_BEGIN + (_loc7_.label != null && _loc7_.label != "null"?_loc7_.label:"") + TiphonEventsManager.BALISE_PARAM_END;
               _loc3_.spriteHandler.tiphonEventManager.addEvent(_loc8_,_loc7_.startFrame,_loc5_);
            }
         }
      }
      
      private function onGroundObjectLoaded(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:MovieClip = param1.resource is ASwf?param1.resource.content:param1.resource;
         _loc2_.width = 34;
         _loc2_.height = 34;
         _loc2_.x = _loc2_.x - _loc2_.width / 2;
         _loc2_.y = _loc2_.y - _loc2_.height / 2;
         if(this._objects[param1.uri])
         {
            this._objects[param1.uri].addChild(_loc2_);
         }
      }
      
      private function onGroundObjectLoadFailed(param1:ResourceErrorEvent) : void
      {
      }
      
      public function timeoutStop(param1:AnimatedCharacter) : void
      {
         clearTimeout(this._timeout);
         param1.setAnimation(AnimationEnum.ANIM_STATIQUE);
         this._currentEmoticon = 0;
      }
      
      override public function onPlayAnim(param1:TiphonEvent) : void
      {
         var _loc2_:Array = new Array();
         var _loc3_:String = param1.params.substring(6,param1.params.length - 1);
         _loc2_ = _loc3_.split(",");
         var _loc4_:int = this._emoteTimesBySprite[(param1.currentTarget as TiphonSprite).name] % _loc2_.length;
         param1.sprite.setAnimation(_loc2_[_loc4_]);
      }
      
      private function onAnimationEnd(param1:TiphonEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:TiphonSprite = param1.currentTarget as TiphonSprite;
         _loc2_.removeEventListener(TiphonEvent.ANIMATION_END,this.onAnimationEnd);
         var _loc5_:Object = _loc2_.getSubEntitySlot(SubEntityBindingPointCategoryEnum.HOOK_POINT_CATEGORY_MOUNT_DRIVER,0);
         if(_loc5_ != null)
         {
            _loc4_ = _loc5_.getAnimation();
            if(_loc4_.indexOf("_") == -1)
            {
               _loc4_ = _loc2_.getAnimation();
            }
         }
         else
         {
            _loc4_ = _loc2_.getAnimation();
         }
         if(_loc4_.indexOf("_Statique_") == -1)
         {
            _loc3_ = _loc4_.replace("_","_Statique_");
         }
         else
         {
            _loc3_ = _loc4_;
         }
         if(_loc2_.hasAnimation(_loc3_,_loc2_.getDirection()) || _loc5_ && _loc5_ is TiphonSprite && TiphonSprite(_loc5_).hasAnimation(_loc3_,TiphonSprite(_loc5_).getDirection()))
         {
            _loc2_.setAnimation(_loc3_);
         }
         else
         {
            _loc2_.setAnimation(AnimationEnum.ANIM_STATIQUE);
            this._currentEmoticon = 0;
         }
      }
      
      private function onPlayerSpriteInit(param1:TiphonEvent) : void
      {
         var _loc2_:TiphonEntityLook = (param1.sprite as TiphonSprite).look;
         if(param1.params == _loc2_.getBone())
         {
            param1.sprite.removeEventListener(TiphonEvent.SPRITE_INIT,this.onPlayerSpriteInit);
            this.updateUsableEmotesListInit(_loc2_);
         }
      }
      
      private function onCellPointed(param1:Boolean, param2:uint, param3:int) : void
      {
         var _loc4_:PaddockMoveItemRequestMessage = null;
         if(param1)
         {
            _loc4_ = new PaddockMoveItemRequestMessage();
            _loc4_.initPaddockMoveItemRequestMessage(this._currentPaddockItemCellId,param2);
            ConnectionsHandler.getConnection().send(_loc4_);
         }
      }
      
      private function updateConquestIcons(param1:*) : void
      {
         var _loc2_:* = 0;
         var _loc3_:GameRolePlayHumanoidInformations = null;
         var _loc4_:* = undefined;
         if(param1 is Vector.<uint> && (param1 as Vector.<uint>).length > 0)
         {
            for each(_loc2_ in param1)
            {
               _loc3_ = getEntityInfos(_loc2_) as GameRolePlayHumanoidInformations;
               if(_loc3_)
               {
                  for each(_loc4_ in _loc3_.humanoidInfo.options)
                  {
                     if(_loc4_ is HumanOptionAlliance)
                     {
                        this.addConquestIcon(_loc3_.contextualId,_loc4_ as HumanOptionAlliance);
                        break;
                     }
                  }
               }
            }
         }
         else if(param1 is int)
         {
            _loc3_ = getEntityInfos(param1) as GameRolePlayHumanoidInformations;
            if(_loc3_)
            {
               for each(_loc4_ in _loc3_.humanoidInfo.options)
               {
                  if(_loc4_ is HumanOptionAlliance)
                  {
                     this.addConquestIcon(_loc3_.contextualId,_loc4_ as HumanOptionAlliance);
                     break;
                  }
               }
            }
         }
      }
      
      private function addConquestIcon(param1:int, param2:HumanOptionAlliance) : void
      {
         var _loc3_:PrismSubAreaWrapper = null;
         var _loc4_:String = null;
         var _loc5_:Vector.<String> = null;
         var _loc6_:String = null;
         if(PlayedCharacterManager.getInstance().characteristics.alignmentInfos.aggressable != AggressableStatusEnum.NON_AGGRESSABLE && this._allianceFrame && this._allianceFrame.hasAlliance && param2.aggressable != AggressableStatusEnum.NON_AGGRESSABLE && param2.aggressable != AggressableStatusEnum.PvP_ENABLED_AGGRESSABLE && param2.aggressable != AggressableStatusEnum.PvP_ENABLED_NON_AGGRESSABLE)
         {
            _loc3_ = this._allianceFrame.getPrismSubAreaById(PlayedCharacterManager.getInstance().currentSubArea.id);
            if(_loc3_ && _loc3_.state == PrismStateEnum.PRISM_STATE_VULNERABLE)
            {
               switch(param2.aggressable)
               {
                  case AggressableStatusEnum.AvA_DISQUALIFIED:
                     if(param1 == PlayedCharacterManager.getInstance().id)
                     {
                        _loc4_ = "neutral";
                     }
                     break;
                  case AggressableStatusEnum.AvA_PREQUALIFIED_AGGRESSABLE:
                     if(param1 == PlayedCharacterManager.getInstance().id)
                     {
                        _loc4_ = "clock";
                     }
                     else
                     {
                        _loc4_ = this.getPlayerConquestStatus(param1,param2.allianceInformations.allianceId,_loc3_.alliance.allianceId);
                     }
                     break;
                  case AggressableStatusEnum.AvA_ENABLED_AGGRESSABLE:
                     _loc4_ = this.getPlayerConquestStatus(param1,param2.allianceInformations.allianceId,_loc3_.alliance.allianceId);
                     break;
               }
               if(_loc4_)
               {
                  _loc5_ = this.getIconNamesByCategory(param1,EntityIconEnum.AVA_CATEGORY);
                  if(_loc5_ && _loc5_[0] != _loc4_)
                  {
                     _loc6_ = _loc5_[0];
                     _loc5_.length = 0;
                     this.removeIcon(param1,_loc6_);
                  }
                  this.addEntityIcon(param1,_loc4_,EntityIconEnum.AVA_CATEGORY);
               }
            }
         }
         if(!_loc4_ && this._entitiesIconsNames[param1] && this._entitiesIconsNames[param1][EntityIconEnum.AVA_CATEGORY])
         {
            this.removeIconsCategory(param1,EntityIconEnum.AVA_CATEGORY);
         }
      }
      
      private function getPlayerConquestStatus(param1:int, param2:int, param3:int) : String
      {
         var _loc4_:String = null;
         if(param1 == PlayedCharacterManager.getInstance().id || this._allianceFrame.alliance.allianceId == param2)
         {
            _loc4_ = "ownTeam";
         }
         else if(param2 == param3)
         {
            _loc4_ = "defender";
         }
         else
         {
            _loc4_ = "forward";
         }
         return _loc4_;
      }
      
      public function addEntityIcon(param1:int, param2:String, param3:int = 0) : void
      {
         if(!this._entitiesIconsNames[param1])
         {
            this._entitiesIconsNames[param1] = new Dictionary();
         }
         if(!this._entitiesIconsNames[param1][param3])
         {
            this._entitiesIconsNames[param1][param3] = new Vector.<String>(0);
         }
         if(this._entitiesIconsNames[param1][param3].indexOf(param2) == -1)
         {
            this._entitiesIconsNames[param1][param3].push(param2);
         }
         if(this._entitiesIcons[param1])
         {
            this._entitiesIcons[param1].needUpdate = true;
         }
      }
      
      public function updateAllIcons() : void
      {
         this._updateAllIcons = true;
         this.showIcons();
      }
      
      public function forceIconUpdate(param1:int) : void
      {
         this._entitiesIcons[param1].needUpdate = true;
      }
      
      private function removeAllIcons() : void
      {
         var _loc1_:* = undefined;
         for(_loc1_ in this._entitiesIconsNames)
         {
            delete this._entitiesIconsNames[_loc1_];
            this.removeIcon(_loc1_);
         }
      }
      
      public function removeIcon(param1:int, param2:String = null) : void
      {
         var _loc3_:AnimatedCharacter = DofusEntities.getEntity(param1) as AnimatedCharacter;
         if(_loc3_)
         {
            _loc3_.removeEventListener(TiphonEvent.RENDER_SUCCEED,this.updateIconAfterRender);
         }
         if(this._entitiesIcons[param1])
         {
            if(!param2)
            {
               this._entitiesIcons[param1].remove();
               delete this._entitiesIcons[param1];
            }
            else
            {
               this._entitiesIcons[param1].removeIcon(param2);
            }
         }
      }
      
      public function getIconNamesByCategory(param1:int, param2:int) : Vector.<String>
      {
         var _loc3_:Vector.<String> = null;
         if(this._entitiesIconsNames[param1] && this._entitiesIconsNames[param1][param2])
         {
            _loc3_ = this._entitiesIconsNames[param1][param2];
         }
         return _loc3_;
      }
      
      public function removeIconsCategory(param1:int, param2:int) : void
      {
         var _loc3_:String = null;
         if(this._entitiesIconsNames[param1] && this._entitiesIconsNames[param1][param2])
         {
            if(this._entitiesIcons[param1])
            {
               for each(_loc3_ in this._entitiesIconsNames[param1][param2])
               {
                  this._entitiesIcons[param1].removeIcon(_loc3_);
               }
            }
            delete this._entitiesIconsNames[param1][param2];
            if(this._entitiesIcons[param1] && this._entitiesIcons[param1].length == 0)
            {
               delete this._entitiesIconsNames[param1];
               this.removeIcon(param1);
            }
         }
      }
      
      public function hasIcon(param1:int, param2:String = null) : Boolean
      {
         return this._entitiesIcons[param1]?param2?this._entitiesIcons[param1].hasIcon(param2):true:false;
      }
      
      private function showIcons(param1:Event = null) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:DisplayObject = null;
         var _loc4_:AnimatedCharacter = null;
         var _loc5_:IRectangle = null;
         var _loc6_:Rectangle = null;
         var _loc7_:Rectangle2 = null;
         var _loc8_:EntityIcon = null;
         var _loc9_:Texture = null;
         var _loc10_:TiphonSprite = null;
         var _loc11_:DisplayObject = null;
         var _loc12_:* = undefined;
         var _loc13_:String = null;
         var _loc14_:* = false;
         var _loc15_:Point = null;
         var _loc16_:Point = null;
         for(_loc2_ in this._entitiesIconsNames)
         {
            _loc4_ = DofusEntities.getEntity(_loc2_) as AnimatedCharacter;
            if(!_loc4_)
            {
               delete this._entitiesIconsNames[_loc2_];
               if(this._entitiesIcons[_loc2_])
               {
                  this.removeIcon(_loc2_);
               }
            }
            else
            {
               _loc5_ = null;
               if(this._updateAllIcons || _loc4_.isMoving || !this._entitiesIcons[_loc2_] || this._entitiesIcons[_loc2_].needUpdate)
               {
                  if(this._entitiesIcons[_loc2_] && this._entitiesIcons[_loc2_].rendering)
                  {
                     continue;
                  }
                  _loc10_ = _loc4_ as TiphonSprite;
                  if(_loc4_.getSubEntitySlot(2,0) && !this.isCreatureMode)
                  {
                     _loc10_ = _loc4_.getSubEntitySlot(2,0) as TiphonSprite;
                  }
                  _loc3_ = _loc10_.getSlot("Tete");
                  if(_loc3_)
                  {
                     _loc6_ = _loc3_.getBounds(StageShareManager.stage);
                     _loc7_ = new Rectangle2(_loc6_.x,_loc6_.y,_loc6_.width,_loc6_.height);
                     _loc5_ = _loc7_;
                     if(_loc5_.y - 30 - 10 < 0)
                     {
                        _loc11_ = _loc10_.getSlot("Pied");
                        if(_loc11_)
                        {
                           _loc6_ = _loc11_.getBounds(StageShareManager.stage);
                           _loc7_ = new Rectangle2(_loc6_.x,_loc6_.y + _loc5_.height + 30,_loc6_.width,_loc6_.height);
                           _loc5_ = _loc7_;
                        }
                     }
                  }
                  else
                  {
                     if(_loc10_ is IDisplayable)
                     {
                        _loc5_ = (_loc10_ as IDisplayable).absoluteBounds;
                     }
                     else
                     {
                        _loc6_ = _loc10_.getBounds(StageShareManager.stage);
                        _loc7_ = new Rectangle2(_loc6_.x,_loc6_.y,_loc6_.width,_loc6_.height);
                        _loc5_ = _loc7_;
                     }
                     if(_loc5_.y - 30 - 10 < 0)
                     {
                        _loc5_.y = _loc5_.y + (_loc5_.height + 30);
                     }
                  }
               }
               if(_loc5_)
               {
                  _loc8_ = this._entitiesIcons[_loc2_];
                  if(!_loc8_)
                  {
                     this._entitiesIcons[_loc2_] = new EntityIcon();
                     _loc8_ = this._entitiesIcons[_loc2_];
                  }
                  _loc14_ = false;
                  for(_loc12_ in this._entitiesIconsNames[_loc2_])
                  {
                     for each(_loc13_ in this._entitiesIconsNames[_loc2_][_loc12_])
                     {
                        if(!_loc8_.hasIcon(_loc13_))
                        {
                           _loc14_ = true;
                           _loc8_.addIcon(ICONS_FILEPATH + "|" + _loc13_,_loc13_);
                        }
                     }
                  }
                  if(!_loc14_)
                  {
                     if(this._entitiesIcons[_loc2_].needUpdate && !_loc4_.isMoving && _loc4_.getAnimation().indexOf(AnimationEnum.ANIM_STATIQUE) == 0)
                     {
                        this._entitiesIcons[_loc2_].needUpdate = false;
                     }
                     _loc4_.parent.addChildAt(_loc8_,_loc4_.parent.getChildIndex(_loc4_));
                     if(_loc4_.rendered)
                     {
                        _loc15_ = new Point(_loc5_.x + _loc5_.width / 2 - _loc8_.width / 2,_loc5_.y - 10);
                        _loc16_ = _loc4_.parent.globalToLocal(_loc15_);
                        _loc8_.x = _loc16_.x;
                        _loc8_.y = _loc16_.y;
                     }
                     else
                     {
                        _loc8_.rendering = true;
                        _loc4_.removeEventListener(TiphonEvent.RENDER_SUCCEED,this.updateIconAfterRender);
                        _loc4_.addEventListener(TiphonEvent.RENDER_SUCCEED,this.updateIconAfterRender);
                     }
                  }
               }
            }
         }
         this._updateAllIcons = false;
      }
      
      private function updateIconAfterRender(param1:TiphonEvent) : void
      {
         var _loc2_:AnimatedCharacter = param1.currentTarget as AnimatedCharacter;
         _loc2_.removeEventListener(TiphonEvent.RENDER_SUCCEED,this.updateIconAfterRender);
         if(this._entitiesIcons[_loc2_.id])
         {
            this._entitiesIcons[_loc2_.id].rendering = false;
            this._entitiesIcons[_loc2_.id].needUpdate = true;
         }
      }
      
      private function onTiphonPropertyChanged(param1:PropertyChangeEvent) : void
      {
         if(param1.propertyName == "auraMode" && param1.propertyOldValue != param1.propertyValue)
         {
            if(this._auraCycleTimer.running)
            {
               this._auraCycleTimer.removeEventListener(TimerEvent.TIMER,this.onAuraCycleTimer);
               this._auraCycleTimer.stop();
            }
            switch(param1.propertyValue)
            {
               case OptionEnum.AURA_CYCLE:
                  this._auraCycleTimer.addEventListener(TimerEvent.TIMER,this.onAuraCycleTimer);
                  this._auraCycleTimer.start();
                  this.setEntitiesAura(false);
                  break;
               case OptionEnum.AURA_ON_ROLLOVER:
               case OptionEnum.AURA_NONE:
                  this.setEntitiesAura(false);
                  break;
               case OptionEnum.AURA_ALWAYS:
               default:
                  this.setEntitiesAura(true);
            }
         }
      }
      
      private function onAuraCycleTimer(param1:TimerEvent) : void
      {
         var _loc3_:* = 0;
         var _loc4_:AnimatedCharacter = null;
         var _loc5_:AnimatedCharacter = null;
         var _loc6_:AnimatedCharacter = null;
         var _loc2_:Vector.<int> = getEntitiesIdsList();
         if(this._auraCycleIndex >= _loc2_.length)
         {
            this._auraCycleIndex = 0;
         }
         var _loc7_:int = _loc2_.length;
         var _loc8_:* = 0;
         while(_loc8_ < _loc7_)
         {
            _loc6_ = DofusEntities.getEntity(_loc2_[_loc8_]) as AnimatedCharacter;
            if(_loc6_)
            {
               if(!_loc4_ && _loc6_.hasAura && _loc6_.getDirection() == DirectionsEnum.DOWN)
               {
                  _loc4_ = _loc6_;
                  _loc3_ = _loc8_;
               }
               if(_loc8_ == this._auraCycleIndex && _loc6_.hasAura && _loc6_.getDirection() == DirectionsEnum.DOWN)
               {
                  _loc5_ = _loc6_;
                  break;
               }
               if(!_loc6_.hasAura)
               {
                  this._auraCycleIndex++;
               }
            }
            _loc8_++;
         }
         if(this._lastEntityWithAura)
         {
            this._lastEntityWithAura.visibleAura = false;
         }
         if(_loc5_)
         {
            _loc5_.visibleAura = true;
            this._lastEntityWithAura = _loc5_;
         }
         else if(!_loc5_ && _loc4_)
         {
            _loc4_.visibleAura = true;
            this._lastEntityWithAura = _loc4_;
            this._auraCycleIndex = _loc3_;
         }
         this._auraCycleIndex++;
      }
      
      private function setEntitiesAura(param1:Boolean) : void
      {
         var _loc3_:AnimatedCharacter = null;
         var _loc2_:Vector.<int> = getEntitiesIdsList();
         var _loc4_:* = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = DofusEntities.getEntity(_loc2_[_loc4_]) as AnimatedCharacter;
            if(_loc3_)
            {
               _loc3_.visibleAura = param1;
            }
            _loc4_++;
         }
      }
      
      override protected function onPropertyChanged(param1:PropertyChangeEvent) : void
      {
         super.onPropertyChanged(param1);
         if(param1.propertyName == "allowAnimsFun")
         {
            AnimFunManager.getInstance().stop();
            if(param1.propertyValue == true)
            {
               AnimFunManager.getInstance().initializeByMap(PlayedCharacterManager.getInstance().currentMap.mapId);
            }
         }
      }
      
      private function onAtouinPropertyChanged(param1:PropertyChangeEvent) : void
      {
         var _loc2_:* = undefined;
         if(param1.propertyName == "transparentOverlayMode")
         {
            for(_loc2_ in this._entitiesIconsNames)
            {
               this.forceIconUpdate(_loc2_);
            }
         }
      }
   }
}
