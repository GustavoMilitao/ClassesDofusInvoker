package com.ankamagames.dofus.datacenter.quest
{
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   import com.ankamagames.jerakine.data.GameData;
   
   public class QuestStepRewards extends Object implements IDataCenter
   {
      
      public static const MODULE:String = "QuestStepRewards";
       
      public var id:uint;
      
      public var stepId:uint;
      
      public var levelMin:int;
      
      public var levelMax:int;
      
      public var itemsReward:Vector.<Vector.<uint>>;
      
      public var emotesReward:Vector.<uint>;
      
      public var jobsReward:Vector.<uint>;
      
      public var spellsReward:Vector.<uint>;
      
      public function QuestStepRewards()
      {
         super();
      }
      
      public static function getQuestStepRewardsById(param1:int) : QuestStepRewards
      {
         return GameData.getObject(MODULE,param1) as QuestStepRewards;
      }
      
      public static function getQuestStepRewards() : Array
      {
         return GameData.getObjects(MODULE);
      }
   }
}
