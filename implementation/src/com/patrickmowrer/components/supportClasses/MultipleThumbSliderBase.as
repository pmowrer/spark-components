package com.patrickmowrer.components.supportClasses
{
    import flash.events.Event;
    
    import mx.core.IFactory;
    import mx.core.IVisualElement;
    import mx.core.UIComponent;
    
    import spark.components.Button;
    import spark.components.Group;
    import spark.components.supportClasses.SkinnableComponent;
    
    public class MultipleThumbSliderBase extends SkinnableComponent
    {
        private const DEFAULT_MAXIMUM:Number = 100;
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_THUMB_COUNT:int = 2;
        
        [SkinPart(required="false", type="spark.components.Button")]
        public var thumbs:IFactory;
        
        [SkinPart(required="false")]
        public var track:Button;
        
        [SkinPart(required="true")]
        public var thumbsContainer:Group;
        
        private var thumbInstances:Array = [];
        
        private var thumbCount:int = DEFAULT_THUMB_COUNT;
        private var values:Array = [DEFAULT_MINIMUM, DEFAULT_MAXIMUM]; 
        private var _minimum:Number = DEFAULT_MINIMUM;
        private var _maximum:Number = DEFAULT_MAXIMUM;
       
        public function MultipleThumbSliderBase()
        {
            super();
            
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }
        
        public function get minimum():Number
        {
            return _minimum;
        }
        
        public function get maximum():Number
        {
            return _maximum;
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            var thumbInstance:Button;
            
            for(var count:int = 0; count < thumbCount; count++)
            {
                thumbInstance = createDynamicPartInstance("thumbs") as Button;
                
                thumbsContainer.addElement(thumbInstance);
                thumbInstances.push(thumbInstance);
            }
        }
        
        override protected function updateDisplayList(width:Number, height:Number):void
        {
            super.updateDisplayList(width, height);
            updateSkinDisplayList();
        }
        
        protected function updateSkinDisplayList():void
        {
            if (!thumbs || !track)
                return;
            
            var thumbInstance:IVisualElement;
            
            for(var index:int = 0; index < thumbInstances.length; index++)
            {
                thumbInstance = thumbInstances[index];
                
                positionThumb(thumbInstance, values[index]);                
            }
        }
        
        // To be overriden by sub-classes
        protected function positionThumb(thumbInstance:IVisualElement, value:Number):void {}
        
        private function addedToStageHandler(event:Event):void
        {
            updateSkinDisplayList();
        }
    }
}