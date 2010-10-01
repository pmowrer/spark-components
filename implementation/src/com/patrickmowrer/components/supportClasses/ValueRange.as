package com.patrickmowrer.components.supportClasses
{
    public class ValueRange implements ValueBounding
    {
        private var _minimum:Number;
        private var _maximum:Number;
        private var _interval:Number;
        
        public function ValueRange(minimum:Number, maximum:Number, interval:Number)
        {
            this.minimum = minimum;
            this.maximum = maximum;
            this.interval = interval;
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
        
        public function get interval():Number
        {
            return _interval;
        }
        
        public function set interval(value:Number):void
        {
            if(value != interval)
            {
                _interval = value;
            }
        }
        
        public function getNearestValidValueFromFraction(fraction:Number):Number
        {
            var valueFromFraction:Number = fraction * boundingDelta + minimum;
            
            return getNearestValidValueTo(valueFromFraction);
        }
        
        public function getNearestValidFractionOfRange(value:Number):Number
        {
            return (getNearestValidValueTo(value) - minimum) / boundingDelta;
        }
        
        public function getNearestValidValueTo(value:Number):Number
        { 
            if (interval == 0)
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
            
            if (interval != Math.round(interval)) 
            { 
                const parts:Array = (new String(1 + interval)).split("."); 
                scale = Math.pow(10, parts[1].length);
                maxValue *= scale;
                value = Math.round(value * scale);
                interval = Math.round(interval * scale);
            }   
            
            var lower:Number = Math.max(0, Math.floor(value / interval) * interval);
            var upper:Number = Math.min(maxValue, Math.floor((value + interval) / interval) * interval);
            var validValue:Number = ((value - lower) >= ((upper - lower) / 2)) ? upper : lower;
            
            return (validValue / scale) + minimum;
        }
        
        private function get boundingDelta():Number
        {
            return maximum - minimum;
        }
    }
}