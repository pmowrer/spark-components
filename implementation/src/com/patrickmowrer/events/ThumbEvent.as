package com.patrickmowrer.events
{
    import flash.events.Event;
    import flash.geom.Point;
    
    public class ThumbEvent extends Event
    {
        public static const DRAG:String = "com.patricknowrer.events.ThumbEventDrag";
        
        public var stageX:Number;
        public var stageY:Number;
        
        public function ThumbEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
        }
        
        override public function clone():Event
        {
            return new ThumbEvent(type, bubbles, cancelable);
        }
    }
}