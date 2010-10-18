package com.patrickmowrer.events
{
    import flash.events.Event;
    import flash.geom.Point;
    
    public class ThumbKeyEvent extends Event
    {
        public static const KEY_DOWN:String = "com.patricknowrer.events.ThumbKeyEventKeyDown";
        public static const KEY_UP:String = "com.patricknowrer.events.ThumbKeyEventKeyUp";
        
        public var newValue:Number;
        
        public function ThumbKeyEvent(type:String, newValue:Number, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
            
            this.newValue = newValue;
        }
        
        override public function clone():Event
        {
            return new ThumbKeyEvent(type, newValue, bubbles, cancelable);
        }
    }
}