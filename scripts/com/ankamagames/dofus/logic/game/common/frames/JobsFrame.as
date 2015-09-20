package com.ankamagames.dofus.logic.game.common.frames
{
   import com.ankamagames.jerakine.messages.Frame;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.dofus.network.types.game.context.roleplay.job.JobExperience;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.dofus.internalDatacenter.jobs.KnownJobWrapper;
   import com.ankamagames.dofus.network.types.game.context.roleplay.job.JobCrafterDirectorySettings;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.jerakine.types.enums.Priority;
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobDescriptionMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobCrafterDirectorySettingsMessage;
   import com.ankamagames.dofus.logic.game.common.actions.jobs.JobCrafterDirectoryDefineSettingsAction;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobCrafterDirectoryDefineSettingsMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobExperienceOtherPlayerUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobExperienceUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobExperienceMultiUpdateMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobLevelUpMessage;
   import com.ankamagames.dofus.logic.game.common.actions.craft.JobBookSubscribeRequestAction;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.JobBookSubscribeRequestMessage;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobBookSubscriptionMessage;
   import com.ankamagames.dofus.datacenter.jobs.Job;
   import com.ankamagames.dofus.logic.game.common.actions.jobs.JobCrafterDirectoryListRequestAction;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobCrafterDirectoryListRequestMessage;
   import com.ankamagames.dofus.logic.game.common.actions.jobs.JobCrafterDirectoryEntryRequestAction;
   import com.ankamagames.dofus.network.messages.game.context.roleplay.job.JobCrafterDirectoryEntryRequestMessage;
   import com.ankamagames.dofus.logic.game.common.actions.jobs.JobCrafterContactLookRequestAction;
   import com.ankamagames.dofus.network.messages.game.inventory.exchanges.ExchangeStartOkJobIndexMessage;
   import com.ankamagames.dofus.network.types.game.context.roleplay.job.JobDescription;
   import com.ankamagames.dofus.network.messages.game.social.ContactLookRequestByIdMessage;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.dofus.misc.lists.HookList;
   import com.ankamagames.dofus.misc.lists.CraftHookList;
   import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.dofus.misc.lists.ChatHookList;
   import com.ankamagames.dofus.network.enums.ChatActivableChannelsEnum;
   import com.ankamagames.dofus.logic.game.common.managers.TimeManager;
   import com.ankamagames.dofus.misc.EntityLookAdapter;
   import com.ankamagames.dofus.network.enums.SocialContactCategoryEnum;
   import com.ankamagames.dofus.kernel.Kernel;
   
   public class JobsFrame extends Object implements Frame
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(JobsFrame));
       
      private var _jobCrafterDirectoryListDialogFrame:JobCrafterDirectoryListDialogFrame;
      
      private var _settings:Array;
      
      public function JobsFrame()
      {
         this._settings = new Array();
         super();
      }
      
      private static function updateJobExperience(param1:JobExperience) : void
      {
         var _loc2_:KnownJobWrapper = PlayedCharacterManager.getInstance().jobs[param1.jobId];
         if(!_loc2_)
         {
            _loc2_ = KnownJobWrapper.create(param1.jobId);
            PlayedCharacterManager.getInstance().jobs[param1.jobId] = _loc2_;
         }
         _loc2_.jobLevel = param1.jobLevel;
         _loc2_.jobXP = param1.jobXP;
         _loc2_.jobXpLevelFloor = param1.jobXpLevelFloor;
         _loc2_.jobXpNextLevelFloor = param1.jobXpNextLevelFloor;
      }
      
      private static function createCrafterDirectorySettings(param1:JobCrafterDirectorySettings) : Object
      {
         var _loc2_:Object = new Object();
         _loc2_.jobId = param1.jobId;
         _loc2_.minLevel = param1.minLevel;
         _loc2_.free = param1.free;
         return _loc2_;
      }
      
      public function get priority() : int
      {
         return Priority.NORMAL;
      }
      
      public function get settings() : Array
      {
         return this._settings;
      }
      
      public function pushed() : Boolean
      {
         this._jobCrafterDirectoryListDialogFrame = new JobCrafterDirectoryListDialogFrame();
         return true;
      }
      
      public function process(param1:Message) : Boolean
      {
         var _loc2_:JobDescriptionMessage = null;
         var _loc3_:JobCrafterDirectorySettingsMessage = null;
         var _loc4_:JobCrafterDirectoryDefineSettingsAction = null;
         var _loc5_:JobCrafterDirectoryDefineSettingsMessage = null;
         var _loc6_:JobExperienceOtherPlayerUpdateMessage = null;
         var _loc7_:JobExperienceUpdateMessage = null;
         var _loc8_:JobExperienceMultiUpdateMessage = null;
         var _loc9_:JobLevelUpMessage = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:KnownJobWrapper = null;
         var _loc13_:JobBookSubscribeRequestAction = null;
         var _loc14_:JobBookSubscribeRequestMessage = null;
         var _loc15_:JobBookSubscriptionMessage = null;
         var _loc16_:String = null;
         var _loc17_:Job = null;
         var _loc18_:JobCrafterDirectoryListRequestAction = null;
         var _loc19_:JobCrafterDirectoryListRequestMessage = null;
         var _loc20_:JobCrafterDirectoryEntryRequestAction = null;
         var _loc21_:JobCrafterDirectoryEntryRequestMessage = null;
         var _loc22_:JobCrafterContactLookRequestAction = null;
         var _loc23_:ExchangeStartOkJobIndexMessage = null;
         var _loc24_:Array = null;
         var _loc25_:JobDescription = null;
         var _loc26_:JobCrafterDirectorySettings = null;
         var _loc27_:JobExperience = null;
         var _loc28_:ContactLookRequestByIdMessage = null;
         var _loc29_:uint = 0;
         switch(true)
         {
            case param1 is JobDescriptionMessage:
               _loc2_ = param1 as JobDescriptionMessage;
               PlayedCharacterManager.getInstance().jobs = new Array();
               for each(_loc25_ in _loc2_.jobsDescription)
               {
                  if(_loc25_)
                  {
                     _loc12_ = KnownJobWrapper.create(_loc25_.jobId);
                     _loc12_.jobDescription = _loc25_;
                     PlayedCharacterManager.getInstance().jobs[_loc25_.jobId] = _loc12_;
                  }
               }
               KernelEventsManager.getInstance().processCallback(HookList.JobsListUpdated);
               return true;
            case param1 is JobCrafterDirectorySettingsMessage:
               _loc3_ = param1 as JobCrafterDirectorySettingsMessage;
               for each(_loc26_ in _loc3_.craftersSettings)
               {
                  this._settings[_loc26_.jobId] = createCrafterDirectorySettings(_loc26_);
               }
               KernelEventsManager.getInstance().processCallback(CraftHookList.CrafterDirectorySettings,this._settings);
               return true;
            case param1 is JobCrafterDirectoryDefineSettingsAction:
               _loc4_ = param1 as JobCrafterDirectoryDefineSettingsAction;
               _loc5_ = new JobCrafterDirectoryDefineSettingsMessage();
               _loc5_.initJobCrafterDirectoryDefineSettingsMessage(_loc4_.settings);
               ConnectionsHandler.getConnection().send(_loc5_);
               return true;
            case param1 is JobExperienceOtherPlayerUpdateMessage:
               _loc6_ = param1 as JobExperienceOtherPlayerUpdateMessage;
               KernelEventsManager.getInstance().processCallback(CraftHookList.JobsExpOtherPlayerUpdated,_loc6_.playerId,_loc6_.experiencesUpdate);
               return true;
            case param1 is JobExperienceUpdateMessage:
               _loc7_ = param1 as JobExperienceUpdateMessage;
               updateJobExperience(_loc7_.experiencesUpdate);
               KernelEventsManager.getInstance().processCallback(CraftHookList.JobsExpUpdated,_loc7_.experiencesUpdate.jobId);
               return true;
            case param1 is JobExperienceMultiUpdateMessage:
               _loc8_ = param1 as JobExperienceMultiUpdateMessage;
               for each(_loc27_ in _loc8_.experiencesUpdate)
               {
                  updateJobExperience(_loc27_);
               }
               KernelEventsManager.getInstance().processCallback(CraftHookList.JobsExpUpdated,0);
               return true;
            case param1 is JobLevelUpMessage:
               _loc9_ = param1 as JobLevelUpMessage;
               _loc10_ = Job.getJobById(_loc9_.jobsDescription.jobId).name;
               _loc11_ = I18n.getUiText("ui.craft.newJobLevel",[_loc10_,_loc9_.newLevel]);
               KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,_loc11_,ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp());
               _loc12_ = PlayedCharacterManager.getInstance().jobs[_loc9_.jobsDescription.jobId];
               _loc12_.jobDescription = _loc9_.jobsDescription;
               _loc12_.jobLevel = _loc9_.newLevel;
               KernelEventsManager.getInstance().processCallback(CraftHookList.JobLevelUp,_loc9_.jobsDescription.jobId,_loc10_,_loc9_.newLevel);
               return true;
            case param1 is JobBookSubscribeRequestAction:
               _loc13_ = param1 as JobBookSubscribeRequestAction;
               _loc14_ = new JobBookSubscribeRequestMessage();
               _loc14_.initJobBookSubscribeRequestMessage(_loc13_.jobId);
               ConnectionsHandler.getConnection().send(_loc14_);
               return true;
            case param1 is JobBookSubscriptionMessage:
               _loc15_ = param1 as JobBookSubscriptionMessage;
               _loc17_ = Job.getJobById(_loc15_.jobId);
               if(_loc15_.addedOrDeleted)
               {
                  _loc16_ = I18n.getUiText("ui.craft.referenceAdd",[_loc17_.name]);
               }
               else
               {
                  _loc16_ = I18n.getUiText("ui.craft.referenceRemove",[_loc17_.name]);
               }
               KernelEventsManager.getInstance().processCallback(ChatHookList.TextInformation,_loc16_,ChatActivableChannelsEnum.PSEUDO_CHANNEL_INFO,TimeManager.getInstance().getTimestamp());
               PlayedCharacterManager.getInstance().jobs[_loc15_.jobId].jobBookSubscriber = _loc15_.addedOrDeleted;
               KernelEventsManager.getInstance().processCallback(CraftHookList.JobBookSubscription,_loc15_.jobId,_loc15_.addedOrDeleted);
               return true;
            case param1 is JobCrafterDirectoryListRequestAction:
               _loc18_ = param1 as JobCrafterDirectoryListRequestAction;
               _loc19_ = new JobCrafterDirectoryListRequestMessage();
               _loc19_.initJobCrafterDirectoryListRequestMessage(_loc18_.jobId);
               ConnectionsHandler.getConnection().send(_loc19_);
               return true;
            case param1 is JobCrafterDirectoryEntryRequestAction:
               _loc20_ = param1 as JobCrafterDirectoryEntryRequestAction;
               _loc21_ = new JobCrafterDirectoryEntryRequestMessage();
               _loc21_.initJobCrafterDirectoryEntryRequestMessage(_loc20_.playerId);
               ConnectionsHandler.getConnection().send(_loc5_);
               return true;
            case param1 is JobCrafterContactLookRequestAction:
               _loc22_ = param1 as JobCrafterContactLookRequestAction;
               if(_loc22_.crafterId == PlayedCharacterManager.getInstance().id)
               {
                  KernelEventsManager.getInstance().processCallback(CraftHookList.JobCrafterContactLook,_loc22_.crafterId,PlayedCharacterManager.getInstance().infos.name,EntityLookAdapter.fromNetwork(PlayedCharacterManager.getInstance().infos.entityLook));
               }
               else
               {
                  _loc28_ = new ContactLookRequestByIdMessage();
                  _loc28_.initContactLookRequestByIdMessage(0,SocialContactCategoryEnum.SOCIAL_CONTACT_CRAFTER,_loc22_.crafterId);
                  ConnectionsHandler.getConnection().send(_loc28_);
               }
               return true;
            case param1 is ExchangeStartOkJobIndexMessage:
               _loc23_ = param1 as ExchangeStartOkJobIndexMessage;
               _loc24_ = new Array();
               for each(_loc29_ in _loc23_.jobs)
               {
                  _loc24_.push(_loc29_);
               }
               Kernel.getWorker().addFrame(this._jobCrafterDirectoryListDialogFrame);
               KernelEventsManager.getInstance().processCallback(CraftHookList.ExchangeStartOkJobIndex,_loc24_);
               return true;
            default:
               return false;
         }
      }
      
      public function pulled() : Boolean
      {
         return true;
      }
   }
}
