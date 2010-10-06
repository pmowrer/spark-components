package com.patrickmowrer.events
{
    import flash.events.Event;
    import flash.geom.Point;
    
    public class ThumbEvent extends Event
    {
        public static const BEGIN_DRAG:String = "com.patricknowrer.events.ThumbEventBeginDrag";
        public static const DRAGGING:String = "com.patricknowrer.events.ThumbEventDragging";
        public static const END_DRAG:String = "com.patricknowrer.events.ThumbEventEndDrag";
        
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