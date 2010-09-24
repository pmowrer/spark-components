package com.patrickmowrer.components.supportClasses
{
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    import mx.events.SandboxMouseEvent;
    
    import spark.components.Button;
    import spark.components.supportClasses.Range;
    import spark.components.supportClasses.SliderBase;

    [Style(name="slideDuration", type="Number", format="Time", inherit="no")]

    public class SlidersBase extends Ranges
    {
        [SkinPart(required="false")]
        public var track:SliderBase;
        
        private var thumbOverlapAllowed:Boolean = false;
        private var minimumChanged:Boolean = false;
        private var maximumChanged:Boolean = false;
        private var snapIntervalChanged:Boolean = false;
        
        private var currentTrackThumb:Range;
        
        public function SlidersBase()
        {
            super();
        }
        
        public function get allowThumbOverlap():Boolean
        {
            return thumbOverlapAllowed;
        }
        
        public function set allowThumbOverlap(value:Boolean):void
        {
        }
        
        override public function set minimum(value:Number):void
        {
            if(minimum != value)
            {
                super.minimum = value;
                minimumChanged = true;            
                invalidateProperties();
            }
        }
        
        override public function set maximum(value:Number):void
        {
            if(maximum != value)
            {
                super.maximum = value;
                maximumChanged = true;
                invalidateProperties();
            }
        }
        
        override public function set snapInterval(value:Number):void
        {
            if(snapInterval != value)
            {
                super.snapInterval = value;
                snapIntervalChanged = true;
                invalidateProperties();
            }
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(minimumChanged || maximumChanged || snapIntervalChanged)
            {
                if(track)
                {
                    track.minimum = minimum;
                    track.maximum = maximum;
                    track.snapInterval = snapInterval;
                }
                
                minimumChanged = false;
                maximumChanged = false;
            }
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "range" && track && instance is SliderBase)
            {
                var thumb:SliderBase = instance as SliderBase;
                
                thumb.track = track.track;
                thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
                track.addEventListener(Event.CHANGE, trackChangeHandler);
            }
            else if(partName == "track" && instance is SliderBase)
            {
                var track:SliderBase = track as SliderBase;
                
                track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler, true);
                track.setStyle("slideDuration", getStyle("slideDuration"));
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if(partName == "range" && track && instance is SliderBase)
            {
                var thumb:SliderBase = instance as SliderBase;
                
                thumb.track = null;
                thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler); 
            }
            else if(partName == "track" && instance is SliderBase)
            {
                var track:SliderBase = track as SliderBase;
                
                track.removeEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler, true);             
            }
        }
        
        private function trackMouseDownHandler(event:MouseEvent):void
        {
            var trackRelative:Point = track.globalToLocal(new Point(event.stageX, event.stageY));
            var trackPointValue:Number = trackPointToValue(trackRelative.x, trackRelative.y);
            var thumb:SliderBase = nearestThumbInstanceTo(trackPointValue);
            
            currentTrackThumb = thumb;
            
            // Let track figure out new value, if any, and play animation,
            // and then do more work on track's change event
            track.thumb = thumb.thumb;
            track.value = thumb.value;
            track.validateNow();
        }
       
        private function trackChangeHandler(event:Event):void
        {
            if(currentTrackThumb)
            {
                currentTrackThumb.value = track.value;
                currentTrackThumb = null;                  
                track.thumb = null;
            }
        }
        
        protected function trackPointToValue(x:Number, y:Number):Number
        {
            throw new IllegalOperationError("This method must be overriden in sub-classes.");
        }
        
        private function nearestThumbInstanceTo(value:Number):SliderBase
        {           
            var nearestValue:Number = maximum;
            var nearestThumb:SliderBase;
            
            for(var index:int = 0; index < numberOfRangeInstances; index++)
            {
                var thumbInstance:SliderBase = SliderBase(getRangeInstanceAt(index));
                var thumbValueDelta:Number = Math.abs(thumbInstance.value - value);
                
                if(thumbValueDelta < nearestValue)
                {
                    nearestValue = thumbValueDelta;
                    nearestThumb = thumbInstance;
                }
            } 

            return nearestThumb;
        }
        
        private function thumbMouseDownHandler(event:MouseEvent):void
        {
            visuallyMoveToFront(event.currentTarget as IVisualElement);
        }
        
        private function visuallyMoveToFront(instance:IVisualElement):void
        {
            setAllElementsToSameDepth(0);
            instance.depth = 1;
        }
        
        private function setAllElementsToSameDepth(value:Number):void
        {
            for(var index:int = 0; index < numElements; index++)
            {
                getElementAt(index).depth = value;
            }
        }
    }
}