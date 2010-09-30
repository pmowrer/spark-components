package com.patrickmowrer.components.supportClasses
{
    import com.patrickmowrer.events.ThumbEvent;
    
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.events.FlexEvent;
    import mx.events.SandboxMouseEvent;
    
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
        
        private var clickOffset:Point;
        
        public function Thumb()
        {
            super();
            
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
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
                if(minimum > maximum)
                    minimum = maximum;
                
                if(minimum > value || maximum < value)
                    valueChanged = true;
                
                minimumChanged = false;
                maximumChanged = false;
            }
            
            if(valueChanged)
            {
                _value = Math.min(Math.max(_value, _minimum), _maximum);
                
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
                
                valueChanged = false;
            }
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