package com.patrickmowrer.components.supportClasses
{
    import com.patrickmowrer.events.ThumbEvent;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.core.IDataRenderer;
    import mx.core.IFactory;
    import mx.core.IVisualElement;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.events.MoveEvent;
    import mx.events.SandboxMouseEvent;
    
    import spark.components.Button;
    import spark.components.DataRenderer;
    import spark.components.SkinnableContainer;
    import spark.effects.animation.MotionPath;
    import spark.effects.animation.SimpleMotionPath;
    import spark.effects.easing.Sine;
    
    [Style(name="slideDuration", type="Number", format="Time", inherit="no")]
    [Style(name="dataTipOffsetX", type="Number", format="Length", inherit="no")]
    [Style(name="dataTipOffsetY", type="Number", format="Length", inherit="no")]
    
    public class SliderThumb extends SkinnableContainer implements ValueCarrying, ValueBounding, ValueSnapping
    {
        [SkinPart(required="false")]
        public var button:Button;
        
        [SkinPart(required="true", type="spark.components.DataRenderer")]
        public var dataTip:IFactory;
        
        private var dataTipInstance:IDataRenderer;
        
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        private const DEFAULT_SNAP_INTERVAL:Number = 1;
        private const DEFAULT_VALUE:Number = 0;
        
        private var _value:Number;
        private var newValue:Number = DEFAULT_VALUE;
        private var valueChanged:Boolean = false;
        
        private var valueRange:ValueRange;
        private var clickOffsetFromCenter:Point;
        private var animation:SliderThumbAnimation;
        
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
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            if(partName == "button")
            {
                button.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
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
            
            var globalClick:Point = new Point(event.stageX, event.stageY);
            var localClick:Point = globalToLocal(globalClick);
            var xOffsetFromCenter:Number = localClick.x - (getLayoutBoundsWidth() / 2);
            var yOffsetFromCenter:Number = localClick.y - (getLayoutBoundsHeight() / 2);
            
            clickOffsetFromCenter = new Point(xOffsetFromCenter, yOffsetFromCenter);
            
            dispatchThumbEvent(ThumbEvent.BEGIN_DRAG, globalClick);     
            
            if(dataTip)
            {
                dataTipInstance = IDataRenderer(createDynamicPartInstance("dataTip"));
                systemManager.toolTipChildren.addChild(DisplayObject(dataTipInstance));
                updateDataTip();
                addEventListener(MoveEvent.MOVE, moveHandler);
            }
        }
        
        private function systemMouseMoveHandler(event:MouseEvent):void
        {
            var mouseMovedTo:Point = 
                new Point(event.stageX - clickOffsetFromCenter.x, event.stageY - clickOffsetFromCenter.y);
          
            dispatchThumbEvent(ThumbEvent.DRAGGING, mouseMovedTo);
        }
        
        private function systemMouseUpHandler(event:MouseEvent):void
        {
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, systemMouseMoveHandler, true);
            sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, systemMouseUpHandler, true);
            sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemMouseUpHandler); 
            
            clickOffsetFromCenter = null;
            
            dispatchThumbEvent(ThumbEvent.END_DRAG, new Point(event.stageX, event.stageY));
            
            if(dataTip)
            {
                removeDynamicPartInstance("dataTip", dataTipInstance);
                systemManager.toolTipChildren.removeChild(DisplayObject(dataTipInstance));
                dataTipInstance = null;
                removeEventListener(MoveEvent.MOVE, moveHandler);
            }
        }
        
        private function dispatchThumbEvent(type:String, point:Point):void
        {
            var thumbEvent:ThumbEvent = new ThumbEvent(type);
            thumbEvent.stageX = point.x;
            thumbEvent.stageY = point.y;
            
            dispatchEvent(thumbEvent);            
        }
        
        private function moveHandler(event:MoveEvent):void
        {
            if(dataTipInstance && !animationIsPlaying)
                updateDataTip();
        }
        
        private function updateDataTip():void
        {
            var dataTipAsUIComponent:UIComponent = dataTipInstance as UIComponent;
            
            if(dataTipAsUIComponent)
            {
                // Force the dataTip to render to calculate proper offset
                dataTipAsUIComponent.validateNow();
                dataTipAsUIComponent.setActualSize(dataTipAsUIComponent.getExplicitOrMeasuredWidth(),
                    dataTipAsUIComponent.getExplicitOrMeasuredHeight());
            
                var thumbCenter:Point = getCenterPointCoordinatesOf(this);
                            
                var dataTipPosition:Point = parent.localToGlobal(new Point(thumbCenter.x, thumbCenter.y));
                
                dataTipPosition.offset(-dataTipAsUIComponent.getExplicitOrMeasuredWidth() / 2, 
                    -dataTipAsUIComponent.getExplicitOrMeasuredHeight() / 2);
                
                trace(getStyle("dataTipOffsetX"), getStyle("dataTipOffsetY"));
                
                dataTipPosition.offset(getStyle("dataTipOffsetX"), getStyle("dataTipOffsetY"));
                            
                dataTipAsUIComponent.setLayoutBoundsPosition(dataTipPosition.x, dataTipPosition.y);
            }
            
            dataTipInstance.data = value;
        }
        
        private function getCenterPointCoordinatesOf(component:UIComponent):Point
        {
            var x:Number = component.getLayoutBoundsX() + (component.getLayoutBoundsWidth() / 2);
            var y:Number = component.getLayoutBoundsY() + (component.getLayoutBoundsHeight() / 2);
            
            return new Point(x, y);
        }
    }
}