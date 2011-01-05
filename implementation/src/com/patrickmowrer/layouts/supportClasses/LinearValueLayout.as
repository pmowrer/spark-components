package com.patrickmowrer.layouts.supportClasses
{
    import com.patrickmowrer.components.supportClasses.ValueCarrying;
    
    import flash.geom.Point;
    
    import mx.core.IVisualElement;

    public class LinearValueLayout extends ValueLayoutBase
    {
        private var start:Point;
        private var end:Point;
        private var deltaX:Number;
        private var deltaY:Number;
        
        public function LinearValueLayout(start:Point, end:Point)
        {
            super();
            
            this.start = start;
            this.end = end;
            
            deltaX = end.x - start.x;
            deltaY = end.y - start.y;
        }
        
        override public function pointToValue(point:Point):Number
        {
            if(!target)
                return 0;
    
            var ratio:Number;
            
            if(deltaX != 0)
            {
                ratio = (point.x - (start.x * target.getLayoutBoundsWidth())) / 
                    (deltaX * target.getLayoutBoundsWidth());
            }
            else
            {
                ratio = (point.y - (start.y * target.getLayoutBoundsHeight())) / 
                    (deltaY * target.getLayoutBoundsHeight());
            }
            
            return valueRange.getNearestValidValueFromRatio(ratio);
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
                    var ratio:Number = valueRange.getNearestValidRatioFromValue(value);
                    var x:Number = (start.x * width) + deltaX * width * ratio;
                    var y:Number = (start.y * height) + deltaY * height * ratio;

                    element.setLayoutBoundsSize(NaN, NaN);
                    element.setLayoutBoundsPosition(x, y);
                }
            }
        }
        
        private function horizontalMovementRangeFor(element:IVisualElement, width:Number):Number
        {
            var delta:Number = width - getElementWidth(element);
            
            if(delta > 0)
                return delta;
            else
                return 0;
        }
        
        private function verticalMovementRangeFor(element:IVisualElement, height:Number):Number
        {
            var delta:Number = height - getElementHeight(element);
            
            if(delta > 0)
                return delta;
            else
                return 0;
        }
        
        private function getElementWidth(element:IVisualElement):Number
        {
            if(element.getLayoutBoundsWidth() > 0)
                return element.getLayoutBoundsWidth();
            else
                return element.getPreferredBoundsWidth();
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