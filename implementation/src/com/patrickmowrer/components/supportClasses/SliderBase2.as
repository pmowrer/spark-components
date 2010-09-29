package com.patrickmowrer.components.supportClasses
{
    import flash.utils.getQualifiedClassName;
    
    import mx.core.IFactory;
    
    import spark.components.SkinnableContainer;
    
    public class SliderBase2 extends SkinnableContainer
    {
        [SkinPart(required="false", type="com.patrickmowrer.components.supportClasses.Thumb")]
        public var thumb:IFactory;

        private const DEFAULT_VALUES:Array = [0, 100];

        private var thumbs:Vector.<Thumb>;
        
        private var _values:Array = DEFAULT_VALUES;

        private var valuesChanged:Boolean = false;
        
        public function SliderBase2()
        {
            super();
            
            thumbs = new Vector.<Thumb>();
        }
        
        public function get values():Array
        {
            return _values;
        }
        
        public function set values(value:Array):void
        {
            if(value != _values)
            {
                _values = value;
                valuesChanged = true;
                invalidateProperties();
            }  
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "thumb")
            {
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if(partName == "thumb")
            {
            }
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(valuesChanged)
            {
                removeAllThumbs();
                createThumbsFrom(values);
                
                valuesChanged = false;
            }
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            if(thumb)
                createThumbsFrom(_values);
        }
        
        private function createThumbsFrom(values:Array):void
        {
            var instance:Thumb;
            
            for(var index:int = 0; index < values.length; index++)
            {
                instance = Thumb(createDynamicPartInstance("thumb"));
                
                if(!instance)
                {
                    throw new ArgumentError("Thumb part must be of type " +
                        getQualifiedClassName(Thumb));
                }
                
                initializeThumb(instance, values[index]);
                
                addElement(instance);
                thumbs.push(instance);
            }
        }
        
        private function initializeThumb(thumb:Thumb, value:Number):void
        {
            thumb.value = value;
        }
        
        private function removeAllThumbs():void
        {
            for(var index:int = 0; index < thumbs.length; index++)
            {
                removeDynamicPartInstance("thumb", thumbs[index]);
                removeElement(thumbs[index]);
            }
            
            thumbs.splice(0, thumbs.length);
        }
    }
}