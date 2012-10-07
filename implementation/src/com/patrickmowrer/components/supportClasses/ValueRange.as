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

package com.patrickmowrer.components.supportClasses
{
    public class ValueRange implements ValueBounding, ValueSnapping
    {
        private var _minimum:Number;
        private var _maximum:Number;
        private var _interval:Number;
        
        public function ValueRange(minimum:Number, maximum:Number, snapInterval:Number)
        {
            this.minimum = minimum;
            this.maximum = maximum;
            this.snapInterval = snapInterval;
        }

        public function get minimum():Number
        {
            return _minimum;
        }
        
        public function set minimum(value:Number):void
        {
            if(value != _minimum)
            {   
                if(value > maximum)
                    minimum = maximum;
                else
                {
                    _minimum = value;
                }
            }
        }
        
        public function get maximum():Number
        {
            return _maximum;
        }
        
        public function set maximum(value:Number):void
        {
            if(value != maximum)
            {   
                if(value < minimum)
                    maximum = minimum;
                else
                {
                    _maximum = value;
                }
            }
        }
        
        public function get snapInterval():Number
        {
            return _interval;
        }
        
        public function set snapInterval(value:Number):void
        {
            if(value != snapInterval)
            {
                _interval = value;
            }
        }
        
        public function get boundsDelta():Number
        {
            return maximum - minimum;
        }
        
        public function getNearestValidValueFromRatio(ratio:Number):Number
        {
            var value:Number = ratio * boundsDelta + minimum;
            
            return getNearestValidValueTo(value);
        }
        
        public function getNearestValidRatioFromValue(value:Number):Number
        {
            var divisor:Number = boundsDelta == 0 ? 1 : boundsDelta;
            
            return (getNearestValidValueTo(value) - minimum) / divisor;
        }
        
        public function getNearestValidValueTo(value:Number):Number
        { 
            if (snapInterval == 0)
                return Math.max(minimum, Math.min(maximum, value));
            
            var maxValue:Number = maximum - minimum;
            var scale:Number = 1;
            
            value -= minimum;
            
            // If interval isn't an integer, there's a possibility that the floating point 
            // approximation of value or value/interval will be slightly larger or smaller 
            // than the real value.  This can lead to errors in calculations like 
            // floor(value/interval)*interval, which one might expect to just equal value, 
            // when value is an exact multiple of interval.  Not so if value=0.58 and 
            // interval=0.01, in that case the calculation yields 0.57!  To avoid problems, 
            // we scale by the implicit precision of the interval and then round.  For 
            // example if interval=0.01, then we scale by 100.    
            
            if (snapInterval != Math.round(snapInterval)) 
            { 
                const parts:Array = (new String(1 + snapInterval)).split("."); 
                scale = Math.pow(10, parts[1].length);
                maxValue *= scale;
                value = Math.round(value * scale);
                snapInterval = Math.round(snapInterval * scale);
            }   
            
            var lower:Number = Math.max(0, Math.floor(value / snapInterval) * snapInterval);
            var upper:Number = Math.min(maxValue, Math.floor((value + snapInterval) / snapInterval) * snapInterval);
            var validValue:Number = ((value - lower) >= ((upper - lower) / 2)) ? upper : lower;
            
            return (validValue / scale) + minimum;
        }
        
        public function roundToNearestLesserInterval(value:Number):Number
        {
            if(snapInterval != 0 && !isMultipleOfInterval(value))
                return Math.floor((value - minimum) / snapInterval) * snapInterval + minimum;
            else
                return value;
        }
        
        public function roundToNearestGreaterInterval(value:Number):Number
        {
            if(snapInterval != 0 && !isMultipleOfInterval(value))
                return Math.ceil((value - minimum) / snapInterval) * snapInterval + minimum;
            else
                return value;
        }
        
        private function isMultipleOfInterval(value:Number):Boolean
        {
            if(Math.abs(value - minimum) % snapInterval == 0)
                return true
            else
                return false;
        }
    }
}