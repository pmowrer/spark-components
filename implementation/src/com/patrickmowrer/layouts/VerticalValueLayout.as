package com.patrickmowrer.layouts
{
    import com.patrickmowrer.components.supportClasses.ValueCarrying;
    import com.patrickmowrer.layouts.supportClasses.ValueLayoutBase;
    
    import mx.core.IVisualElement;
    
    public class VerticalValueLayout extends ValueLayoutBase
    {
        public function VerticalValueLayout()
        {
            super();
        }
        
        override public function pointToValue(x:Number, y:Number):Number
        {
            if(!target)
                return 0;
            
            var fractionOfTotalHeight:Number = 1 - (y / target.getLayoutBoundsHeight());
            
            return valueRange.getNearestValidValueFromFraction(fractionOfTotalHeight);
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
                    var y:Number = height;
                    
                    if(elementHeight <= height)
                    {
                        var value:Number = ValueCarrying(element).value;
                        var rangeFraction:Number = valueRange.getNearestValidFractionOfRange(value);
                        var yMax:Number = height - elementHeight;
                        
                        y -= (height * rangeFraction) + (elementHeight / 2);
                        y = Math.min(y, yMax);
                    }
                    
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