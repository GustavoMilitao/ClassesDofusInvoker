package com.ankamagames.atouin.data.map.elements
{
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.atouin.data.map.Cell;
   import com.ankamagames.atouin.enums.ElementTypesEnum;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import flash.utils.IDataInput;
   
   public class BasicElement extends Object
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(BasicElement));
       
      private var _cell:Cell;
      // Construtora recebe uma Cell como início.
      public function BasicElement(param1:Cell)
      {
         super();
         this._cell = param1;
      }
      // função estática. Passa-se 1 ID (2 - graphical, 33 - sound) e um Cell e é retornado um BasicElement.
      public static function getElementFromType(param1:int, param2:Cell) : BasicElement
      {
         switch(param1)
         {
            case ElementTypesEnum.GRAPHICAL:
               return new GraphicalElement(param2);
            case ElementTypesEnum.SOUND:
               return new SoundElement(param2);
            default:
               throw new UnknownElementError("Un élément de type inconnu " + param1 + " a été trouvé sur la cellule " + param2.cellId + "!");
         }
      }
      
      public function get cell() : Cell
      {
         return this._cell;
      }
      
      public function get elementType() : int
      {
         return -1;
      }
      
      public function fromRaw(param1:IDataInput, param2:int) : void
      {
         throw new Error("Cette méthode doit être surchargée !");
      }
   }
}
