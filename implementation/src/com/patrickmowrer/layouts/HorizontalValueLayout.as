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
        
        override public function pointToValue(x:Number, y:Number):Number
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

        private function getElementWidth(element:IVisualElement):Number
        {
            if(element.getLayoutBoundsWidth() > 0)
                return element.getLayoutBoundsWidth();
            else
                return element.getPreferredBoundsWidth();
        }
    }
}