package com.patrickmowrer.layouts
{
    import com.patrickmowrer.components.supportClasses.ValueBounding;
    import com.patrickmowrer.components.supportClasses.ValueCarrying;
    import com.patrickmowrer.components.supportClasses.ValueRange;
    import com.patrickmowrer.layouts.supportClasses.ValueBasedLayout;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    import mx.core.IVisualElement;
    
    import spark.layouts.supportClasses.LayoutBase;
    
    public class HorizontalValueLayout extends LayoutBase implements ValueBasedLayout
    {
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;

        private var valueRange:ValueRange;
        
        public function HorizontalValueLayout()
        {
            super();
            
            valueRange = new ValueRange(DEFAULT_MINIMUM, DEFAULT_MAXIMUM, 0);
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
            if(!target)
                return 0;
            
            var fractionOfTotalWidth:Number = x / target.getLayoutBoundsWidth();
            
            return valueRange.getNearestValidValueFromFraction(fractionOfTotalWidth);
        }
        
        override public function updateDisplayList(width:Number, height:Number):void
        {
            super.updateDisplayList(width, height);
            
            var element:IVisualElement;
            
            for(var index:int = 0; index < target.numElements; index++)
            {
                element = target.getElementAt(index);
                
                if(element is ValueCarrying)
                {
                    var value:Number = ValueCarrying(element).value;
                    var rangeFraction:Number = valueRange.getNearestValidFractionOfRange(value);
                    
                    var x:Number = (width * rangeFraction) - (getElementWidth(element) / 2);
                    var xMax:Number = width - getElementWidth(element);
                    x = Math.min(x, xMax);
                    
                    element.setLayoutBoundsSize(NaN, NaN);
                    element.setLayoutBoundsPosition(x, 0);
                }
            }
        }
        
        override public function measure():void
        {
            super.measure();
        }
        
        private function getElementWidth(element:IVisualElement):Number
        {
            if(element.getLayoutBoundsWidth() > 0)
                return element.getLayoutBoundsWidth();
            else
                return element.getPreferredBoundsWidth();
        }
        
        private function invalidateTargetDisplayList():void
        {
            if(target)
                target.invalidateDisplayList();
        }
    }
}