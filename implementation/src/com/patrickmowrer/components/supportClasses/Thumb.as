package com.patrickmowrer.components.supportClasses
{
    import spark.components.Button;
    
    public class Thumb extends Button implements Value, ValueBounding
    {
        private const DEFAULT_VALUE:Number = 0;
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        
        private var _minimum:Number = DEFAULT_MINIMUM;
        private var _maximum:Number = DEFAULT_MAXIMUM;
        private var _value:Number = DEFAULT_VALUE;
        
        private var minimumChanged:Boolean = false;
        private var maximumChanged:Boolean = false;
        private var valueChanged:Boolean = false;
        
        public function Thumb()
        {
            super();
        }
        
        public function get minimum():Number
        {
            return _minimum;
        }

        public function set minimum(value:Number):void
        {
            if(_minimum != value)
            {
                _minimum = value;
                minimumChanged = true;
                invalidateProperties();
            }
        }
        
        public function get maximum():Number
        {
            return _maximum;
        }
        
        public function set maximum(value:Number):void
        {
            if(_maximum != value)
            {
                _maximum = value;
                maximumChanged = true;
                invalidateProperties();
            }
        }

        public function get value():Number
        {
            return _value;
        }
        
        public function set value(value:Number):void
        {
            if(_value != value)
            {
                _value = value;
                valueChanged = true;
                invalidateProperties();
            }
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(minimumChanged || maximumChanged) 
            {
                if(minimum > value || maximum < value)
                    valueChanged = true;
                
                minimumChanged = false;
                maximumChanged = false;
            }
            
            if(valueChanged)
            {
                _value = Math.min(Math.max(_value, _minimum), _maximum);
                
                valueChanged = false;
            }
        }
    }
}