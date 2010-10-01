package com.patrickmowrer.components.supportClasses
{
    import com.patrickmowrer.events.ThumbEvent;
    
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.events.FlexEvent;
    import mx.events.SandboxMouseEvent;
    
    import spark.components.Button;
    
    public class Thumb extends Button implements Value, ValueBounding, ValueSnapInterval
    {
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        private const DEFAULT_SNAP_INTERVAL:Number = 1;
        private const DEFAULT_VALUE:Number = 0;
        
        private var _minimum:Number = DEFAULT_MINIMUM;
        private var _maximum:Number = DEFAULT_MAXIMUM;
        private var _snapInterval:Number = DEFAULT_SNAP_INTERVAL;
        private var _value:Number = DEFAULT_VALUE;
        
        private var minimumChanged:Boolean = false;
        private var maximumChanged:Boolean = false;
        private var snapIntervalChanged:Boolean = false;
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
            
        public function get snapInterval():Number
        {
            return _snapInterval;
        }
        
        public function set snapInterval(value:Number):void
        {
            if(_snapInterval != value)
            {
                _snapInterval = value;
                snapIntervalChanged = true;
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
            
            if(valueChanged || snapIntervalChanged)
            {
                _value = nearestValidValue(_value, _snapInterval);
                
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
                
                valueChanged = false;
            }
        }
        
        protected function nearestValidValue(value:Number, interval:Number):Number
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