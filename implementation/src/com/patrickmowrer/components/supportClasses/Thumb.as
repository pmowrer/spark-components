package com.patrickmowrer.components.supportClasses
{
    import com.patrickmowrer.events.ThumbEvent;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.events.FlexEvent;
    import mx.events.SandboxMouseEvent;
    
    import spark.components.Button;
    
    public class Thumb extends Button implements ValueCarrying, ValueBounding, ValueInterval
    {
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        private const DEFAULT_SNAP_INTERVAL:Number = 1;
        private const DEFAULT_VALUE:Number = 0;
        
        private var _value:Number;
        private var newValue:Number = DEFAULT_VALUE;
        private var valueChanged:Boolean = false;
        
        private var valueRange:ValueRange;
        private var clickOffset:Point;
        
        public function Thumb()
        {
            super();
            
            valueRange = new ValueRange(DEFAULT_MINIMUM, DEFAULT_MAXIMUM, DEFAULT_SNAP_INTERVAL);

            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
        }
        
        public function get minimum():Number
        {
            return valueRange.minimum;
        }

        public function set minimum(value:Number):void
        {
            if(value != minimum)
            {
                valueRange.minimum = value;
                invalidateProperties();
            }
        }
        
        public function get maximum():Number
        {
            return valueRange.maximum;
        }
        
        public function set maximum(value:Number):void
        {
            if(value != maximum)
            {
                valueRange.maximum = value;
                invalidateProperties();
            }
        }
            
        public function get snapInterval():Number
        {
            return valueRange.interval;
        }
        
        public function set snapInterval(value:Number):void
        {
            if(value != snapInterval)
            {
                valueRange.interval = value;
                invalidateProperties();
            }
        }

        public function get value():Number
        {
            if(valueChanged)
                return newValue;
            else
                return _value;
        }
        
        public function set value(value:Number):void
        {
            if(this.value != value)
            {
                newValue = value;
                valueChanged = true;
                invalidateProperties();
            }
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            newValue = valueRange.getNearestValidValueTo(newValue);
            
            if(newValue != _value)
            {
                _value = newValue;
                
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
            
            valueChanged = false;
        }

        private function mouseDownHandler(event:MouseEvent):void
        {
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            
            sandboxRoot.addEventListener(MouseEvent.MOUSE_MOVE, systemMouseMoveHandler, true);
            sandboxRoot.addEventListener(MouseEvent.MOUSE_UP, systemMouseUpHandler, true);
            sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemMouseUpHandler);  
            
            clickOffset = globalToLocal(new Point(event.stageX, event.stageY));
        }
        
        private function systemMouseMoveHandler(event:MouseEvent):void
        {
            var mouseMovedTo:Point = 
                new Point(event.stageX - clickOffset.x, event.stageY - clickOffset.y);
            
            var thumbEvent:ThumbEvent = new ThumbEvent(ThumbEvent.DRAG);
            thumbEvent.stageX = mouseMovedTo.x;
            thumbEvent.stageY = mouseMovedTo.y;
            
            trace(event.stageX, event.stageY);
            trace(thumbEvent.stageX, thumbEvent.stageY);
            
            dispatchEvent(thumbEvent);
        }
        
        private function systemMouseUpHandler(event:MouseEvent):void
        {
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, systemMouseMoveHandler, true);
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, systemMouseUpHandler, true);
            sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemMouseUpHandler); 
            
            clickOffset = null;
        }
    }
}