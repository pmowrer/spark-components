package com.patrickmowrer.layouts
{
    import com.patrickmowrer.components.supportClasses.Value;
    import com.patrickmowrer.components.supportClasses.ValueBounding;
    import com.patrickmowrer.layouts.supportClasses.ValueBasedLayout;
    
    import flash.display.DisplayObject;
    
    import mx.core.IVisualElement;
    
    import spark.layouts.supportClasses.LayoutBase;
    
    public class HorizontalValueLayout extends LayoutBase implements ValueBasedLayout
    {
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        
        private var _minimum:Number = DEFAULT_MINIMUM;
        private var _maximum:Number = DEFAULT_MAXIMUM;
        
        public function HorizontalValueLayout()
        {
            super();
        }
        
        public function get minimum():Number
        {
            return _minimum;
        }
        
        public function set minimum(value:Number):void
        {            
            if(_minimum != value)
            {
                _minimum = Math.min(value, _maximum);
                
                invalidateTargetDisplayList();
            }
        }
        
        public function get maximum():Number
        {
            return _maximum;
        }
        
        public function set maximum(value:Number):void
        {
            if(_maximum != value)
            {
                _maximum = Math.max(value, _minimum);

                invalidateTargetDisplayList();
            }
        }
        
        public function pointToValue(x:Number, y:Number):Number
        {
            if(!target)
                return 0;
            
            return (x / target.getLayoutBoundsWidth()) * minMaxDelta + minimum;
        }
        
        override public function updateDisplayList(width:Number, height:Number):void
        {
            super.updateDisplayList(width, height);
            
            var element:IVisualElement;
            
            for(var index:int = 0; index < target.numElements; index++)
            {
                element = target.getElementAt(index);
                
                if(element is Value)
                {
                    var x:Number = width * fractionOfRange(Value(element).value);
                    
                    element.setLayoutBoundsSize(NaN, NaN);
                    element.setLayoutBoundsPosition(x, 0);
                }
            }
        }
        
        override public function measure():void
        {
            super.measure();
        }
        
        private function fractionOfRange(value:Number):Number
        {
            if(value > maximum)
            {
                return 1;
            }
            else if(value < minimum)
            {
                return 0;
            }
            else
            {
                return Math.abs(value - minimum) / minMaxDelta;
            }
        }
        
        private function get minMaxDelta():Number
        {
            return maximum - minimum;
        }
        
        private function invalidateTargetDisplayList():void
        {
            if(target)
            {
                target.invalidateDisplayList();
            }
        }
    }
}