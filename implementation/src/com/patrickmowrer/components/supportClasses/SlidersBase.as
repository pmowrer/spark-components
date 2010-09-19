package com.patrickmowrer.components.supportClasses
{
    import flash.events.MouseEvent;
    
    import mx.core.IVisualElement;
    
    import spark.components.Button;
    import spark.components.supportClasses.Range;
    import spark.components.supportClasses.SliderBase;

    public class SlidersBase extends Ranges
    {
        [SkinPart(required="false")]
        public var track:SliderBase;
        
        public function SlidersBase()
        {
            super();
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "range" && track && instance is SliderBase)
            {
                var sliderBase:SliderBase = instance as SliderBase;
                
                // Injecting same track skinPart into each range instance
                sliderBase.track = track.track;
                
                sliderBase.addEventListener(MouseEvent.MOUSE_DOWN, sliderBaseMouseDownHandler);
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if(partName == "range" && track && instance is SliderBase)
            {
                var sliderBase:SliderBase = instance as SliderBase;
                
                // Injecting same track skinPart into each range instance
                sliderBase.track = null;
                
                sliderBase.removeEventListener(MouseEvent.MOUSE_DOWN, sliderBaseMouseDownHandler); 
            }
        }
        
        private function sliderBaseMouseDownHandler(event:MouseEvent):void
        {
            visuallyMoveToFront(event.currentTarget as IVisualElement);
        }
        
        private function visuallyMoveToFront(instance:IVisualElement):void
        {
            setAllElementsToSameDepth(0);
            instance.depth = 1;
        }
        
        private function setAllElementsToSameDepth(value:Number):void
        {
            for(var index:int = 0; index < numElements; index++)
            {
                getElementAt(index).depth = value;
            }
        }
    }
}