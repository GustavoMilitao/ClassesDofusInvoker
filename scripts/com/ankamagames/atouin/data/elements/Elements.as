package com.ankamagames.atouin.data.elements
{
	// Classe para definir Elements. Possui coleções para definir elementos do mapa e se é jpg ou não.
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.utils.Dictionary;
   import flash.utils.IDataInput;
   import com.ankamagames.atouin.data.DataFormatError;
   import com.ankamagames.atouin.AtouinConstants;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   
   public class Elements extends Object
   {
      // referência recursiva para Elements
      private static var _self:Elements;
      // Constante provavelmente pega o nome de uma classe em String e cria um objeto com ela.
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(Elements));
       
      public var fileVersion:uint;
      
      public var elementsCount:uint;
      
      private var _parsed:Boolean;
      
      private var _failed:Boolean;
      // Coleção com informações dos elementos do mapa. (Uma Key int (object) e um value em GraphicalElementData (object)).
      private var _elementsMap:Dictionary;
      // Coleção com : (key uint e um value em boolean. Verifica se elemento mapa[i] é jpg ou não (true/false)).
      private var _jpgMap:Dictionary;
      // Coleção com : (key int e um value em (TODO: Verificar RETORNO DE IDATAINPUT["Position"])).
      private var _elementsIndex:Dictionary;
      // Interface de entrada de dados.
      private var _rawData:IDataInput;
      
      public function Elements()
      {
         super();
         if(_self)
         {
            throw new SingletonError();
         }
      }
      
      public static function getInstance() : Elements
      {
         if(!_self)
         {
            _self = new Elements();
         }
         return _self;
      }
      
      public function get parsed() : Boolean
      {
         return this._parsed;
      }
      
      public function get failed() : Boolean
      {
         return this._failed;
      }
      
      public function getElementData(param1:int) : GraphicalElementData
      {
         return this._elementsMap[param1]?GraphicalElementData(this._elementsMap[param1]):this.readElement(param1);
      }
      
      public function isJpg(param1:uint) : Boolean
      {
         return this._jpgMap[param1] == true;
      }
      
      public function fromRaw(param1:IDataInput) : void
      {
         var header:int = 0;
         var skypLen:uint = 0;
         var i:int = 0;
         var edId:int = 0;
         var gfxCount:int = 0;
         var gfxId:int = 0;
         var raw:IDataInput = param1;
         try
         {
            header = raw.readByte();
            if(header != 69)
            {
               throw new DataFormatError("Unknown file format");
            }
            this._rawData = raw;
            this.fileVersion = raw.readByte();
            if(AtouinConstants.DEBUG_FILES_PARSING_ELEMENTS)
            {
               _log.debug("File version : " + this.fileVersion);
            }
            this.elementsCount = raw.readUnsignedInt();
            if(AtouinConstants.DEBUG_FILES_PARSING_ELEMENTS)
            {
               _log.debug("Elements count : " + this.elementsCount);
            }
            this._elementsMap = new Dictionary();
            this._elementsIndex = new Dictionary();
            skypLen = 0;
            i = 0;
            while(i < this.elementsCount)
            {
               if(this.fileVersion >= 9)
               {
                  skypLen = raw.readUnsignedShort();
               }
               edId = raw.readInt();
               if(this.fileVersion <= 8)
               {
                  this._elementsIndex[edId] = raw["position"];
                  this.readElement(edId);
               }
               else
               {
                  this._elementsIndex[edId] = raw["position"];
                  raw["position"] = raw["position"] + (skypLen - 4);
               }
               i++;
            }
            if(this.fileVersion >= 8)
            {
               gfxCount = raw.readInt();
               this._jpgMap = new Dictionary();
               i = 0;
               while(i < gfxCount)
               {
                  gfxId = raw.readInt();
                  this._jpgMap[gfxId] = true;
                  i++;
               }
            }
            this._parsed = true;
            return;
         }
         catch(e:*)
         {
            _failed = true;
            throw e;
         }
      }
      
      private function readElement(param1:uint) : GraphicalElementData
      {
         this._rawData["position"] = this._elementsIndex[param1];
         var _loc2_:int = this._rawData.readByte();
         var _loc3_:GraphicalElementData = GraphicalElementFactory.getGraphicalElementData(param1,_loc2_);
         if(!_loc3_)
         {
            return null;
         }
         _loc3_.fromRaw(this._rawData,this.fileVersion);
         this._elementsMap[param1] = _loc3_;
         return _loc3_;
      }
   }
}
