package com.patrickmowrer.events
{
    import flash.events.Event;
    import flash.geom.Point;
    
    public class ThumbDragEvent extends Event
    {
        public static const BEGIN_DRAG:String = "com.patricknowrer.events.ThumbDragEventBeginDrag";
        public static const DRAGGING:String = "com.patricknowrer.events.ThumbDragEventDragging";
        public static const END_DRAG:String = "com.patricknowrer.events.ThumbDragEventEndDrag";
        
        public var stageX:Number;
        public var stageY:Number;
        
        public function ThumbDragEvent(type:String, stageX:Number, stageY:Number, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
            
            this.stageX = stageX;
            this.stageY = stageY;
        }
        
        override public function clone():Event
        {
            return new ThumbDragEvent(type, stageY, stageX, bubbles, cancelable);
        }
    }
}