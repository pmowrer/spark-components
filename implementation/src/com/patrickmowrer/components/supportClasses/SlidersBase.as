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
        
        private var minimumChanged:Boolean = false;
        private var maximumChanged:Boolean = false;
        private var snapIntervalChanged:Boolean = false;
        
        private var currentTrackThumb:Range;
        
        public function SlidersBase()
        {
            super();
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
                snapIntervalChanged = false;
            }
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "range" && track && instance is SliderBase)
            {
                var thumb:SliderBase = instance as SliderBase;
                
                thumb.track = track.track;
                
            }
            else if(partName == "track" && instance is SliderBase)
            {
                var track:SliderBase = track as SliderBase;
                
                track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler, true);
                track.addEventListener(Event.CHANGE, trackChangeHandler);
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
            }
            else if(partName == "track" && instance is SliderBase)
            {
                var track:SliderBase = track as SliderBase;
                
                track.removeEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler, true);             
                track.removeEventListener(Event.CHANGE, trackChangeHandler);
            }
        }
        
        private function trackMouseDownHandler(event:MouseEvent):void
        {
            var trackRelative:Point = track.globalToLocal(new Point(event.stageX, event.stageY));
            var trackPointValue:Number = trackPointToValue(trackRelative.x, trackRelative.y);
            var thumb:SliderBase = SliderBase(nearestInstanceTo(trackPointValue));
            
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
    }
}