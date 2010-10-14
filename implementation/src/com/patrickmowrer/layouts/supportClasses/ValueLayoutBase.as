package com.patrickmowrer.layouts.supportClasses
{
    import com.patrickmowrer.components.supportClasses.ValueBounding;
    import com.patrickmowrer.components.supportClasses.ValueCarrying;
    import com.patrickmowrer.components.supportClasses.ValueRange;
    import com.patrickmowrer.layouts.supportClasses.ValueLayout;
    
    import flash.display.DisplayObject;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    
    import mx.core.IVisualElement;
    
    import spark.layouts.supportClasses.LayoutBase;
    
    public class ValueLayoutBase extends LayoutBase implements ValueLayout
    {
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;

        private var _valueRange:ValueRange;
        
        public function ValueLayoutBase(minimum:Number = DEFAULT_MINIMUM, maximum:Number = DEFAULT_MAXIMUM)
        {
            super();
            
            _valueRange = new ValueRange(minimum, maximum, 0);
        }
        
        public function get minimum():Number
        {
            return valueRange.minimum;
        }
        
        public function set minimum(value:Number):void
        {    
            valueRange.minimum = value;            
            invalidateTargetDisplayList();
        }
        
        public function get maximum():Number
        {
            return valueRange.maximum;
        }
        
        public function set maximum(value:Number):void
        {
            valueRange.maximum = value;
            invalidateTargetDisplayList();
        }
        
        public function pointToValue(x:Number, y:Number):Number
        {
            throw new IllegalOperationError("pointToValue must be overriden in sub-class.");
        }
        
        protected function get valueRange():ValueRange
        {
            return _valueRange;
        }
        
        protected function invalidateTargetDisplayList():void
        {
            if(target)
                target.invalidateDisplayList();
        }
    }
}