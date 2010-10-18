package com.patrickmowrer.layouts
{
    import com.patrickmowrer.components.supportClasses.ValueCarrying;
    import com.patrickmowrer.layouts.supportClasses.ValueLayoutBase;
    
    import flash.geom.Point;
    
    import mx.core.IVisualElement;
    
    public class VerticalValueLayout extends ValueLayoutBase
    {
        public function VerticalValueLayout()
        {
            super();
        }
        
        override public function pointToValue(point:Point, relativeTo:IVisualElement = null):Number
        {
            if(!target)
                return 0;
            
            var elementHeight:Number = relativeTo != null ? relativeTo.height : 0;
            var availableHeight:Number = target.getLayoutBoundsHeight() - elementHeight;
            
            var fractionOfAvailableHeight:Number = 1 - (point.y / availableHeight);
            
            return valueRange.getNearestValidValueFromFraction(fractionOfAvailableHeight);
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
                    var elementHeight:Number = getElementHeight(element);
                    var availableHeight:Number = height - elementHeight;
                    var y:Number = availableHeight;
                    
                    if(elementHeight <= availableHeight)
                    {
                        var value:Number = ValueCarrying(element).value;
                        var rangeFraction:Number = valueRange.getNearestValidFractionOfRange(value);
                        
                        y -= (availableHeight * rangeFraction);
                        y = Math.min(y, availableHeight);
                    }
                    else
                        y = 0;
                    
                    element.setLayoutBoundsSize(NaN, NaN);
                    element.setLayoutBoundsPosition(0, y);
                }
            }
        }
        
        private function getElementHeight(element:IVisualElement):Number
        {
            if(element.getLayoutBoundsHeight() > 0)
                return element.getLayoutBoundsHeight();
            else
                return element.getPreferredBoundsHeight();
        }
    }
}