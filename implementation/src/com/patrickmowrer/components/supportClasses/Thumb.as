package com.patrickmowrer.components.supportClasses
{
    import spark.components.Button;
    
    public class Thumb extends Button implements Value
    {
        private var _value:Number;
        
        public function Thumb()
        {
            super();
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
            }
        }
    }
}