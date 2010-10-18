package com.patrickmowrer.layouts
{
    import com.patrickmowrer.components.supportClasses.ValueBounding;
    import com.patrickmowrer.components.supportClasses.ValueCarrying;
    import com.patrickmowrer.components.supportClasses.ValueRange;
    import com.patrickmowrer.layouts.supportClasses.ValueLayoutBase;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.geom.Point;
    
    import mx.core.IVisualElement;
    
    public class HorizontalValueLayout extends ValueLayoutBase
    {        
        public function HorizontalValueLayout()
        {
            super();
        }
        
        override public function pointToValue(point:Point, relativeTo:IVisualElement = null):Number
        {
            if(!target)
                return 0;
            
            var elementWidth:Number = relativeTo != null ? relativeTo.width : 0;
            var availableWidth:Number = target.getLayoutBoundsWidth() - elementWidth;
                        
            var fractionOfAvailableWidth:Number = point.x / availableWidth;
            
            return valueRange.getNearestValidValueFromFraction(fractionOfAvailableWidth);
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
                    var elementWidth:Number = getElementWidth(element);
                    var availableWidth:Number = width - elementWidth;
                    var x:Number = 0;
                    
                    if(elementWidth <= availableWidth)
                    {
                        var value:Number = ValueCarrying(element).value;
                        var rangeFraction:Number = valueRange.getNearestValidFractionOfRange(value);
                        
                        x += (availableWidth * rangeFraction);
                        x = Math.min(x, availableWidth);
                    }
                    else
                        x = 0;
                    
                    element.setLayoutBoundsSize(NaN, NaN);
                    element.setLayoutBoundsPosition(x, 0);
                }
            }
        }

        private function getElementWidth(element:IVisualElement):Number
        {
            if(element.getLayoutBoundsWidth() > 0)
                return element.getLayoutBoundsWidth();
            else
                return element.getPreferredBoundsWidth();
        }
    }
}