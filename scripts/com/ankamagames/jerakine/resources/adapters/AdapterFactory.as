package com.ankamagames.jerakine.resources.adapters
{
   import flash.utils.Dictionary;
   import com.ankamagames.jerakine.types.Uri;
   import com.ankamagames.jerakine.resources.adapters.impl.XmlAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.BitmapAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.TxtAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.SwfAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.AdvancedSwfAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.SwlAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.DxAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.ZipAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.MP3Adapter;
   import com.ankamagames.jerakine.utils.files.FileUtils;
   import com.ankamagames.jerakine.resources.ResourceError;
   import com.ankamagames.jerakine.resources.adapters.impl.SignedFileAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.BinaryAdapter;
   
   public class AdapterFactory extends Object
   {
      
      private static var _customAdapters:Dictionary = new Dictionary();
       
      private var include_SimpleLoaderAdapter:SimpleLoaderAdapter = null;
      
      public function AdapterFactory()
      {
         super();
      }
      
      public static function getAdapter(param1:Uri) : IAdapter
      {
         var _loc3_:* = undefined;
         switch(param1.fileType)
         {
            case "xml":
            case "meta":
            case "dm":
            case "dt":
               return new XmlAdapter();
            case "png":
            case "gif":
            case "jpg":
            case "jpeg":
            case "wdp":
               return new BitmapAdapter();
            case "txt":
            case "css":
               return new TxtAdapter();
            case "swf":
               return new SwfAdapter();
            case "aswf":
               return new AdvancedSwfAdapter();
            case "swl":
               return new SwlAdapter();
            case "dx":
               return new DxAdapter();
            case "zip":
               return new ZipAdapter();
            case "mp3":
               return new MP3Adapter();
            default:
               if(param1.subPath)
               {
                  switch(FileUtils.getExtension(param1.path))
                  {
                     case "swf":
                        return new AdvancedSwfAdapter();
                     default:
                        §§goto(addr51);
                  }
               }
               var _loc2_:Class = _customAdapters[param1.fileType] as Class;
               if(_loc2_)
               {
                  _loc3_ = new _loc2_();
                  if(!(_loc3_ is IAdapter))
                  {
                     throw new ResourceError("Registered custom adapter for extension " + param1.fileType + " isn\'t an IAdapter class.");
                  }
                  return _loc3_;
               }
               if(param1.fileType.substr(-1) == "s")
               {
                  return new SignedFileAdapter();
               }
               return new BinaryAdapter();
         }
      }
      
      public static function addAdapter(param1:String, param2:Class) : void
      {
         _customAdapters[param1] = param2;
      }
      
      public static function removeAdapter(param1:String) : void
      {
         delete _customAdapters[param1];
      }
   }
}
