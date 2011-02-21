/**
 * The MIT License
 *
 * Copyright (c) 2011 Patrick Mowrer
 *  
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

package com.patrickmowrer.components.supportClasses
{
    import com.patrickmowrer.events.ThumbKeyEvent;
    import com.patrickmowrer.events.ThumbMouseEvent;
    
    import flash.display.DisplayObject;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;
    
    import mx.core.IFactory;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;
    import mx.events.MoveEvent;
    import mx.events.SandboxMouseEvent;
    import mx.managers.IFocusManagerComponent;
    
    import spark.components.Button;
    import spark.components.DataRenderer;
    import spark.components.supportClasses.SkinnableComponent;
    
    use namespace mx_internal;
    
    [Style(name="focusAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]
    [Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]
    
    [Style(name="slideDuration", type="Number", format="Time", inherit="no")]
    
    public class SliderThumb extends SkinnableComponent implements ValueCarrying, ValueBounding, ValueSnapping, IFocusManagerComponent
    {
        [SkinPart(required="false")]
        public var button:Button;
        
        [SkinPart(required="false", type="spark.components.DataRenderer")]
        public var dataTip:IFactory;
        
        private var dataTipInstance:DataRenderer;
        
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        private const DEFAULT_SNAP_INTERVAL:Number = 1;
        private const DEFAULT_VALUE:Number = 0;
        
        private var _value:Number;
        private var newValue:Number = DEFAULT_VALUE;
        private var valueChanged:Boolean = false;
        
        private var valueRange:ValueRange;
        private var animation:SliderThumbAnimation;
        
        private var isDragging:Boolean;
        
        public function SliderThumb()
        {
            super();
            
            valueRange = new ValueRange(DEFAULT_MINIMUM, DEFAULT_MAXIMUM, DEFAULT_SNAP_INTERVAL);
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
            return valueRange.snapInterval;
        }
        
        public function set snapInterval(value:Number):void
        {
            if(value != snapInterval)
            {
                valueRange.snapInterval = value;
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
        
        public function constrainMinimumTo(thumb:SliderThumb):void
        {
            var nearestGreaterInterval:Number = valueRange.roundToNearestGreaterInterval(thumb.value);
            
            minimum = nearestGreaterInterval;
        }
        
        public function constrainMaximumTo(thumb:SliderThumb):void
        {
            var nearestLesserInterval:Number = valueRange.roundToNearestLesserInterval(thumb.value);
            
            maximum = nearestLesserInterval;
        }
        
        public function animateMovementTo(value:Number, endHandler:Function):void
        {
            var slideDuration:Number = getStyle("slideDuration");
            
            animation = new SimpleSliderThumbAnimation(this);
            animation.play(slideDuration, valueRange.getNearestValidValueTo(value), endHandler);
        }
        
        public function stopAnimation():void
        {
            if(animationIsPlaying)
                animation.stop();
        }
        
        private function get animationIsPlaying():Boolean
        {
            return animation && animation.isPlaying();
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            if(partName == "button")
            {
                button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            }
            else if(partName == "dataTip")
            {
                systemManager.toolTipChildren.addChild(DisplayObject(instance));
                addEventListener(MoveEvent.MOVE, moveHandler);
                dataTipInstance = DataRenderer(instance);
                updateDataTip();
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            if(partName == "button")
            {
                button.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            }
            else if(partName == "dataTip")
            {
                systemManager.toolTipChildren.removeChild(DisplayObject(instance));
                removeEventListener(MoveEvent.MOVE, moveHandler);
                dataTipInstance = null;
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

        override public function drawFocus(isFocused:Boolean):void
        {
            if(button)
            {
                button.drawFocusAnyway = true;
                button.drawFocus(isFocused);
            }
        }
        
        private function mouseDownHandler(event:MouseEvent):void
        {
            if(isDragging)
                return;
            
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            
            sandboxRoot.addEventListener(MouseEvent.MOUSE_MOVE, systemMouseMoveHandler, true);
            sandboxRoot.addEventListener(MouseEvent.MOUSE_UP, systemMouseUpHandler, true);
            sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemMouseUpHandler);  
            
            var globalClick:Point = new Point(event.stageX, event.stageY);
            isDragging = true;
            
            dispatchThumbEvent(ThumbMouseEvent.PRESS, globalClick);     
            
            if(dataTip)
                createDynamicPartInstance("dataTip");
        }
        
        private function systemMouseMoveHandler(event:MouseEvent):void
        {
            dispatchThumbEvent(ThumbMouseEvent.DRAGGING,  new Point(event.stageX, event.stageY));
        }
        
        private function systemMouseUpHandler(event:MouseEvent):void
        {
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, systemMouseMoveHandler, true);
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, systemMouseUpHandler, true);
            sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemMouseUpHandler); 
            
            isDragging = false;    
        
            dispatchThumbEvent(ThumbMouseEvent.RELEASE, new Point(event.stageX, event.stageY));
            
            if(dataTip)
                removeDynamicPartInstance("dataTip", dataTipInstance);
        }
        
        private function dispatchThumbEvent(type:String, point:Point):void
        {
            dispatchEvent(new ThumbMouseEvent(type, point.x, point.y));            
        }
        
        private function moveHandler(event:MoveEvent):void
        {
            if(dataTipInstance && !animationIsPlaying)
                updateDataTip();
        }
        
        private function updateDataTip():void
        {
            var dataTipPosition:Point = parent.localToGlobal(getCenterPointCoordinatesOf(this));
            dataTipPosition.offset(getStyle("dataTipOffsetX"), getStyle("dataTipOffsetY"));
            
            dataTipInstance.setLayoutBoundsPosition(dataTipPosition.x, dataTipPosition.y);
            dataTipInstance.data = value;
        }
        
        private function getCenterPointCoordinatesOf(component:UIComponent):Point
        {
            var x:Number = component.getLayoutBoundsX() + (component.getLayoutBoundsWidth() / 2);
            var y:Number = component.getLayoutBoundsY() + (component.getLayoutBoundsHeight() / 2);
            
            return new Point(x, y);
        }
        
        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            super.keyDownHandler(event);
            
            if(event.isDefaultPrevented())
                return;
            
            var newValue:Number = value;
            var thumbKeyEvent:ThumbKeyEvent;

            switch(event.keyCode)
            {
                case Keyboard.DOWN:
                case Keyboard.LEFT:
                {
                    newValue = valueRange.getNearestValidValueTo(value - snapInterval);
                    break;
                }
            
                case Keyboard.UP:
                case Keyboard.RIGHT:
                {
                    newValue = valueRange.getNearestValidValueTo(value + snapInterval);
                    break;
                }
            }
            
            event.preventDefault();
            
            if(newValue != value)
            {            
                thumbKeyEvent = new ThumbKeyEvent(ThumbKeyEvent.KEY_DOWN, newValue);
                dispatchEvent(thumbKeyEvent);
            }
        }
        
        override protected function keyUpHandler(event:KeyboardEvent):void
        {
            var thumbKeyEvent:ThumbKeyEvent;
            
            switch(event.keyCode)
            {
                case Keyboard.DOWN:
                case Keyboard.LEFT:
                case Keyboard.UP:
                case Keyboard.RIGHT:
                {
                    thumbKeyEvent = new ThumbKeyEvent(ThumbKeyEvent.KEY_UP, value);
                    dispatchEvent(thumbKeyEvent);
                    
                    event.preventDefault();
                    break;
                }
            }
        }
    }
}