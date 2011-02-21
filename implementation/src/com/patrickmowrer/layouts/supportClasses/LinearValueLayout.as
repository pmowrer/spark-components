/**
 * The MIT License
 *
 * Copyright (c) 2011 Patrick Mowrer
 *  
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

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
        private var elementOffsetRatio:Point;
        
        public function LinearValueLayout(start:Point, end:Point)
        {
            super();
            
            this.start = start;
            this.end = end;
            
            deltaX = end.x - start.x;
            deltaY = end.y - start.y;
            
            elementOffsetRatio = new Point();
        }
        
        public function set elementAlignment(value:Point):void
        {
            elementOffsetRatio = value;
        }
        
        override public function pointToValue(point:Point):Number
        {
            if(!target)
                return 0;
    
            var ratio:Number;
            
            // Is straight horiz line? Else x-based calculation will do just as well as y-based.
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
        
        override public function valueToPoint(value:Number):Point
        {
            if(!target)
                return new Point();
            
            return calculatePointFromValue(value, target.getLayoutBoundsWidth(), target.getLayoutBoundsHeight());
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
                    var elementXOffset:Number = getElementWidth(element) * elementOffsetRatio.x;
                    var elementYOffset:Number = getElementHeight(element) * elementOffsetRatio.y;
                    var elementPosition:Point = calculatePointFromValue(value, width, height);
                    elementPosition.offset(elementXOffset, elementYOffset);

                    element.setLayoutBoundsSize(NaN, NaN);
                    element.setLayoutBoundsPosition(elementPosition.x, elementPosition.y);
                }
            }
        }
        
        protected function calculatePointFromValue(value:Number, width:Number, height:Number):Point
        {
            var ratio:Number = valueRange.getNearestValidRatioFromValue(value);
            var x:Number = (start.x * width) + deltaX * width * ratio;
            var y:Number = (start.y * height) + deltaY * height * ratio;

            return new Point(x, y);
        }        

        protected function getElementWidth(element:IVisualElement):Number
        {
            if(element.getLayoutBoundsWidth() > 0)
                return element.getLayoutBoundsWidth();
            else
                return element.getPreferredBoundsWidth();
        }
        
        protected function getElementHeight(element:IVisualElement):Number
        {
            if(element.getLayoutBoundsHeight() > 0)
                return element.getLayoutBoundsHeight();
            else
                return element.getPreferredBoundsHeight();
        }
    }
}