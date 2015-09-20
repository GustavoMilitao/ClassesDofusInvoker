package com.ankamagames.dofus.console.debug
{
   import com.ankamagames.jerakine.console.ConsoleInstructionHandler;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.jerakine.console.ConsoleHandler;
   import flash.utils.ByteArray;
   import com.ankamagames.jerakine.types.positions.WorldPoint;
   import flash.filesystem.File;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Rectangle;
   import flash.geom.Matrix;
   import flash.display.BitmapData;
   import mx.graphics.codec.PNGEncoder;
   import flash.filesystem.FileStream;
   import com.hurlant.util.Hex;
   import com.ankamagames.atouin.managers.MapDisplayManager;
   import com.ankamagames.atouin.utils.map.getWorldPointFromMapId;
   import com.ankamagames.atouin.utils.map.getMapIdFromCoord;
   import com.ankamagames.atouin.Atouin;
   import com.ankamagames.dofus.internalDatacenter.world.WorldPointWrapper;
   import com.ankamagames.atouin.managers.InteractiveCellManager;
   import com.ankamagames.atouin.types.DebugToolTip;
   import com.ankamagames.atouin.managers.SelectionManager;
   import com.ankamagames.atouin.managers.EntitiesManager;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.atouin.AtouinConstants;
   import flash.filesystem.FileMode;
   
   public class DisplayMapInstructionHandler extends Object implements ConsoleInstructionHandler
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(DisplayMapInstructionHandler));
       
      private var _console:ConsoleHandler;
      
      public function DisplayMapInstructionHandler()
      {
         super();
      }
      
      public function handle(param1:ConsoleHandler, param2:String, param3:Array) : void
      {
         var decryptionKey:ByteArray = null;
         var worldPoint:WorldPoint = null;
         var outputStr:String = null;
         var cacheMode:int = 0;
         var scale:int = 0;
         var crop:Boolean = false;
         var exportElements:Boolean = false;
         var currentMapId:int = 0;
         var f:File = null;
         var world:DisplayObjectContainer = null;
         var s:int = 0;
         var r:Rectangle = null;
         var m:Matrix = null;
         var bd:BitmapData = null;
         var pngEncoder:PNGEncoder = null;
         var ba:ByteArray = null;
         var fs:FileStream = null;
         var elementDir:File = null;
         var gfxList:Array = null;
         var gfxId:String = null;
         var console:ConsoleHandler = param1;
         var cmd:String = param2;
         var args:Array = param3;
         this._console = console;
         switch(cmd)
         {
            case "displaymapdebug":
            case "displaymap":
               if(!args[0])
               {
                  console.output("Error : need mapId or map location as first parameter");
                  return;
               }
               decryptionKey = args.length > 1?Hex.toArray(Hex.fromString(args[1])):null;
               if(decryptionKey)
               {
                  decryptionKey.position = 0;
               }
               if(args[0].indexOf(",") == -1)
               {
                  MapDisplayManager.getInstance().display(getWorldPointFromMapId(args[0]),false,decryptionKey);
               }
               else
               {
                  MapDisplayManager.getInstance().display(WorldPoint.fromCoords(0,args[0].split(",")[0],args[0].split(",")[1]),false,decryptionKey);
               }
               break;
            case "getmapcoord":
               console.output("Map world point for " + args[0] + " : " + getWorldPointFromMapId(int(args[0])).x + "/" + getWorldPointFromMapId(int(args[0])).y + " (world : " + WorldPoint.fromMapId(int(args[0])).worldId + ")");
               break;
            case "getmapid":
               console.output("Map id : " + getMapIdFromCoord(int(args[0]),parseInt(args[1]),parseInt(args[2])));
               break;
            case "testatouin":
               Atouin.getInstance().display(new WorldPoint());
               break;
            case "mapid":
               worldPoint = MapDisplayManager.getInstance().currentMapPoint;
               if(worldPoint is WorldPointWrapper)
               {
                  outputStr = "Current map : " + worldPoint.x + "/" + worldPoint.y + " (relative : " + WorldPointWrapper(worldPoint).outdoorX + "/" + WorldPointWrapper(worldPoint).outdoorY + "), map id : " + worldPoint.mapId;
               }
               else
               {
                  outputStr = "Current map : " + worldPoint.x + "/" + worldPoint.y + ", map id : " + worldPoint.mapId;
               }
               console.output(outputStr);
               break;
            case "showcellid":
               Atouin.getInstance().options.showCellIdOnOver = !Atouin.getInstance().options.showCellIdOnOver;
               console.output("showCellIdOnOver : " + Atouin.getInstance().options.showCellIdOnOver);
               InteractiveCellManager.getInstance().setInteraction(true,Atouin.getInstance().options.showCellIdOnOver,Atouin.getInstance().options.showCellIdOnOver);
               if(!Atouin.getInstance().options.showCellIdOnOver)
               {
                  if(DebugToolTip.getInstance().parent)
                  {
                     DebugToolTip.getInstance().parent.removeChild(DebugToolTip.getInstance());
                  }
                  SelectionManager.getInstance().getSelection("infoOverCell").remove();
               }
               break;
            case "playerjump":
               Atouin.getInstance().options.virtualPlayerJump = !Atouin.getInstance().options.virtualPlayerJump;
               console.output("playerJump : " + Atouin.getInstance().options.virtualPlayerJump);
               break;
            case "showtransitions":
               Atouin.getInstance().options.showTransitions = !Atouin.getInstance().options.showTransitions;
               break;
            case "groundcache":
               if(args.length)
               {
                  cacheMode = int(args[0]);
                  Atouin.getInstance().options.groundCacheMode = cacheMode;
               }
               else
               {
                  cacheMode = Atouin.getInstance().options.groundCacheMode;
               }
               if(cacheMode == 0)
               {
                  console.output("Ground cache : disabled");
               }
               else if(cacheMode == 1)
               {
                  console.output("Ground cache : High");
               }
               else if(cacheMode == 2)
               {
                  console.output("Ground cache : Medium");
               }
               else if(cacheMode == 3)
               {
                  console.output("Ground cache : Low");
               }
               break;
            case "removeblackbars":
               Atouin.getInstance().toggleWorldMask();
               break;
            case "setmaprenderscale":
               scale = 1;
               if(args.length)
               {
                  scale = parseInt(args[0]);
               }
               if(MapDisplayManager.getInstance().renderer.setRenderScale(scale))
               {
                  console.output("Map render scale set to : " + scale + " (will take effect from the next renderer)");
               }
               else
               {
                  console.output("Failed to set scale for the map rendering, your config.xml has no gfx.path.world.swf key defined!");
               }
               break;
            case "capturemap":
               crop = true;
               exportElements = true;
               if(args.length)
               {
                  crop = Boolean(String(args[0]).toLowerCase() == "true");
                  if(args.length > 1)
                  {
                     exportElements = Boolean(String(args[1]).toLowerCase() == "true");
                  }
               }
               try
               {
                  currentMapId = MapDisplayManager.getInstance().currentMapPoint.mapId;
                  f = File.desktopDirectory.resolvePath("maps/" + currentMapId + "/" + currentMapId + ".png");
                  world = Atouin.getInstance().worldContainer;
                  EntitiesManager.getInstance().setEntitiesVisibility(false);
                  s = MapDisplayManager.getInstance().renderer.renderScale;
                  r = world.getBounds(world);
                  m = new Matrix();
                  if(!crop)
                  {
                     m.translate(-r.x,-r.y);
                  }
                  m.scale(s,s);
                  if(!crop)
                  {
                     bd = new BitmapData(r.width * s,r.height * s);
                  }
                  else
                  {
                     bd = new BitmapData((StageShareManager.startWidth - Atouin.getInstance().worldContainer.x * 2) * s,(AtouinConstants.CELL_HEIGHT * AtouinConstants.MAP_HEIGHT + 15) * s);
                  }
                  bd.draw(world,m);
                  EntitiesManager.getInstance().setEntitiesVisibility(true);
                  pngEncoder = new PNGEncoder();
                  ba = pngEncoder.encode(bd);
                  fs = new FileStream();
                  fs.open(f,FileMode.WRITE);
                  fs.writeBytes(ba);
                  fs.close();
                  if(exportElements)
                  {
                     elementDir = f.parent.resolvePath("elements");
                     elementDir.createDirectory();
                     gfxList = MapDisplayManager.getInstance().renderer.getAllGfx();
                     for(gfxId in gfxList)
                     {
                        f = elementDir.resolvePath(gfxId + ".png");
                        fs.open(f,FileMode.WRITE);
                        ba = pngEncoder.encode(gfxList[gfxId]);
                        fs.writeBytes(ba);
                        fs.close();
                     }
                  }
                  console.output("Generated files are available in " + (elementDir?elementDir.parent.nativePath:f.parent.nativePath));
               }
               catch(error:Error)
               {
                  console.output("Failed to capture map! " + error.message);
               }
               break;
         }
      }
      
      public function getHelp(param1:String) : String
      {
         switch(param1)
         {
            case "displaymapdebug":
               return "Display a given map with debug filters activated. These filters apply a different color on every map layers.";
            case "displaymap":
               return "Display a given map.";
            case "getmapcoord":
               return "Get the world point for a given map id.";
            case "getmapid":
               return "Get the map id for a given world point.";
            case "showtransitions":
               return "Toggle map transitions highlighting";
            case "groundcache":
               return "Set ground cache.\n<li>0 --> Disabled</li><li>1 --> High</li><li>2 --> Medium</li><li>3 --> Low</li>";
            case "mapid":
               return "Get the current map id.";
            case "removeblackbars":
               return "Remove the black mask around the current game map. Execute the command a second time to put it back.";
            case "setmaprenderscale":
               return "Specify a scale to render maps. If it\'s different than 1, the game will need to load it all assets as SWF in order to rescale them properly. Insure that your config.xml has the key gfx.path.world.swf defined!. Will deactivate temporarily caching of floor bitmap.";
            case "capturemap":
               return "Save a PNG of the current map on the user\'s desktop. It will be scaled per the value defined by the command setmaprenderscale. Optional parameters : true/false if you want a cropped render as it is ingame, true/false will export all scaled elements of the maps in a separate folder as PNG as well.";
            default:
               return "No help for command \'" + param1 + "\'";
         }
      }
      
      public function getParamPossibilities(param1:String, param2:uint = 0, param3:Array = null) : Array
      {
         return [];
      }
   }
}
