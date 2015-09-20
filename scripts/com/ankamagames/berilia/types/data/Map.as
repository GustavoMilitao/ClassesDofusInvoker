package com.ankamagames.berilia.types.data
{
   import flash.display.DisplayObjectContainer;
   import com.ankamagames.jerakine.resources.loaders.impl.ParallelRessourceLoader;
   import flash.geom.Rectangle;
   import com.ankamagames.jerakine.resources.events.ResourceLoadedEvent;
   import com.ankamagames.jerakine.types.Uri;
   
   public class Map extends Object
   {
       
      public var currentScale:Number;
      
      public var initialWidth:uint;
      
      public var initialHeight:uint;
      
      public var chunckWidth:uint;
      
      public var chunckHeight:uint;
      
      public var zoom:Number;
      
      private var _areas:Vector.<MapArea>;
      
      public var container:DisplayObjectContainer;
      
      public var numXChunck:uint;
      
      public var numYChunck:uint;
      
      private var _visibleAreas:Vector.<MapArea>;
      
      private var _loader:ParallelRessourceLoader;
      
      public function Map(param1:Number, param2:String, param3:DisplayObjectContainer, param4:uint, param5:uint, param6:uint, param7:uint)
      {
         var _loc8_:MapArea = null;
         var _loc11_:uint = 0;
         super();
         this.zoom = param1;
         this.container = param3;
         this.initialHeight = param5;
         this.initialWidth = param4;
         this.chunckHeight = param7;
         this.chunckWidth = param6;
         this._visibleAreas = new Vector.<MapArea>();
         this._loader = new ParallelRessourceLoader(10);
         this._loader.addEventListener(ResourceLoadedEvent.LOADED,this.onLoad);
         param3.doubleClickEnabled = true;
         this.numXChunck = Math.ceil(param4 * param1 / param6);
         this.numYChunck = Math.ceil(param5 * param1 / param7);
         this._areas = new Vector.<MapArea>(this.numXChunck * this.numYChunck,true);
         var _loc9_:uint = 1;
         var _loc10_:uint = 0;
         while(_loc10_ < this.numYChunck)
         {
            _loc11_ = 0;
            while(_loc11_ < this.numXChunck)
            {
               _loc8_ = new MapArea(new Uri(param2 + _loc9_ + ".jpg"),_loc11_ * param6 / param1,_loc10_ * param7 / param1,param6 / param1,param7 / param1,this);
               this.areas[_loc9_ - 1] = _loc8_;
               _loc9_++;
               _loc11_++;
            }
            _loc10_++;
         }
      }
      
      public function get areas() : Vector.<MapArea>
      {
         return this._areas;
      }
      
      public function loadAreas(param1:Rectangle) : Vector.<MapArea>
      {
         var _loc2_:MapArea = null;
         this._visibleAreas.length = 0;
         var _loc3_:Array = new Array();
         for each(_loc2_ in this._areas)
         {
            if(param1.intersects(_loc2_))
            {
               if(!_loc2_.isUsed)
               {
                  this.container.addChild(_loc2_.getBitmap());
                  _loc3_.push(_loc2_.src);
               }
               this._visibleAreas.push(_loc2_);
            }
            else if(_loc2_.isUsed)
            {
               _loc2_.free();
            }
         }
         if(_loc3_.length > 0)
         {
            this._loader.load(_loc3_,null,null,true);
         }
         return this._visibleAreas;
      }
      
      private function onLoad(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:MapArea = null;
         for each(_loc2_ in this._visibleAreas)
         {
            if(param1.uri == _loc2_.src)
            {
               _loc2_.setBitmap(param1.resource);
               break;
            }
         }
      }
   }
}
