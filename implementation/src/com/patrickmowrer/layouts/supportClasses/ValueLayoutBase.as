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
    import com.patrickmowrer.components.supportClasses.ValueRange;
    
    import flash.errors.IllegalOperationError;
    import flash.geom.Point;
    
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
        
        public function pointToValue(point:Point):Number
        {
            throw new IllegalOperationError("pointToValue must be overriden in sub-class.");
        }
        
        public function valueToPoint(value:Number):Point
        {
            throw new IllegalOperationError("valueToPoint must be overriden in sub-class.");
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