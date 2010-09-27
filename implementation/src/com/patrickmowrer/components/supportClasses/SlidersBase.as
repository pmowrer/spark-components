package com.patrickmowrer.components.supportClasses
{
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.core.IFactory;
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    import mx.events.SandboxMouseEvent;
    
    import spark.components.Button;
    import spark.components.SkinnableContainer;
    import spark.components.supportClasses.Range;
    import spark.components.supportClasses.SliderBase;

    [Style(name="slideDuration", type="Number", format="Time", inherit="no")]

    public class SlidersBase extends SkinnableContainer
    {
        [SkinPart(required="false")]
        public var track:SliderBase;
        
        [SkinPart(required="false", type="spark.components.SliderBase")]
        public var thumb:IFactory;
        
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        private const DEFAULT_SNAP_INTERVAL:Number = 1;
        private const DEFAULT_STEP_SIZE:Number = 1;
        private const DEFAULT_VALUES:Array = [0, 100];
        private const DEFAULT_ALLOW_OVERLAP:Boolean = false;
        
        private var thumbs:Vector.<SliderBase>;
        
        private var _minimum:Number = DEFAULT_MINIMUM;
        private var _maximum:Number = DEFAULT_MAXIMUM;
        private var _snapInterval:Number = DEFAULT_SNAP_INTERVAL;
        private var newValues:Array;
        private var _allowOverlap:Boolean = DEFAULT_ALLOW_OVERLAP;
        
        private var minimumChanged:Boolean = false;
        private var maximumChanged:Boolean = false;
        private var snapIntervalChanged:Boolean = false;
        private var valuesChanged:Boolean = false;
        private var allowOverlapChanged:Boolean = false;
        private var rangeValueChanged:Boolean = false;
        
        private var currentTrackThumb:Range;
        
        public function SlidersBase()
        {
            super();
            
            thumbs = new Vector.<SliderBase>();
        }
        
        public function get minimum():Number
        {
            return _minimum;
        }
        
        public function set minimum(value:Number):void
        {
            if(value != _minimum)
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
            if(value != _maximum)
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
            if(value != _snapInterval)
            {
                _snapInterval = value;
                snapIntervalChanged = true;
                
                invalidateProperties();
            }
        }
        
        [Bindable(event="valueCommit")]
        public function get values():Array
        {
            if(valuesChanged)
            {
                return newValues;
            }
            else
            {
                var returnValues:Array = new Array();
                
                for(var index:int = 0; index < thumbs.length; index++)
                {
                    returnValues.push(thumbs[index].value);
                }
                
                return returnValues;
            }
        }
        
        public function set values(newValues:Array):void
        {
            if(thumbs.length == newValues.length)
            {
                var index:int = 0;
                
                while(index < newValues.length)
                {
                    if(thumbs[index].value != newValues[index])
                    {
                        valuesChanged = true;
                    }
                    
                    index++;
                }
            }
            else
            {
                valuesChanged = true;
            }
            
            if(valuesChanged)
            {
                this.newValues = newValues;
                invalidateProperties();
            }
        }
        
        public function get allowOverlap():Boolean
        {
            return _allowOverlap;
        }
        
        public function set allowOverlap(value:Boolean):void
        {
            if(value != _allowOverlap)
            {
                _allowOverlap = value;
                allowOverlapChanged = true;
                invalidateProperties();
            }
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            createThumbsFrom(DEFAULT_VALUES);
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(minimum > maximum)
            {
                if(!maximumChanged)
                    _minimum = _maximum;
                else
                    _maximum = _minimum;
            }
            
            if(valuesChanged || minimumChanged || maximumChanged 
                || snapIntervalChanged || allowOverlapChanged)
            {
                if(track)
                {
                    track.minimum = minimum;
                    track.maximum = maximum;
                    track.snapInterval = snapInterval;
                }
                
                if(!newValues)
                {
                    newValues = values;
                }
                
                removeAllThumbs();
                createThumbsFrom(newValues);
                
                newValues = null;                
                minimumChanged = false;
                maximumChanged = false;
                snapIntervalChanged = false;
                valuesChanged = false;
                allowOverlapChanged = false;
                
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
            
            if(rangeValueChanged)
            {
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "thumb" && track)
            {
                var thumb:SliderBase = SliderBase(instance);
                
                thumb.track = track.track;
                thumb.addEventListener(FlexEvent.CREATION_COMPLETE, thumbCreationCompleteHandler);
                thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
                
            }
            else if(partName == "track")
            {
                var track:SliderBase = SliderBase(track);
                
                track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler, true);
                track.addEventListener(Event.CHANGE, trackChangeHandler);
                track.setStyle("slideDuration", getStyle("slideDuration"));
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if(partName == "thumb" && track)
            {
                var thumb:SliderBase = SliderBase(instance);
                
                thumb.track = null;
                thumb.removeEventListener(FlexEvent.CREATION_COMPLETE, thumbCreationCompleteHandler);
                thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
                thumb.removeEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
            }
            else if(partName == "track")
            {
                var track:SliderBase = SliderBase(instance);
                
                track.thumb = null;
                track.removeEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler, true);             
                track.removeEventListener(Event.CHANGE, trackChangeHandler);
            }
        }
        
        // Want to avoid dispatching multiple value_commit every time multiple Range values
        // are changed, including when they are created
        private function thumbCreationCompleteHandler(event:FlexEvent):void
        {
            var thumb:SliderBase = SliderBase(event.target);
            
            thumb.removeEventListener(FlexEvent.CREATION_COMPLETE, thumbCreationCompleteHandler);
            thumb.addEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
        }
        
        private function thumbValueCommitHandler(event:FlexEvent):void
        {
            invalidateProperties();
            
            rangeValueChanged = true;
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
        
        private function trackMouseDownHandler(event:MouseEvent):void
        {
            var trackRelative:Point = track.globalToLocal(new Point(event.stageX, event.stageY));
            var trackPointValue:Number = trackPointToValue(trackRelative.x, trackRelative.y);
            var thumb:SliderBase = SliderBase(nearestThumbInstanceTo(trackPointValue));
            
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
        
        protected function getIndexOfThumb(instance:SliderBase):int
        {
            return thumbs.indexOf(instance);
        }
        
        protected function getThumbInstanceAt(index:uint):SliderBase
        {
            return thumbs[index];
        }
        
        protected function get numberOfThumbs():uint
        {
            return thumbs.length;
        }
        
        protected function nearestThumbInstanceTo(value:Number):Range
        {           
            var nearestValue:Number = maximum;
            var nearestThumb:SliderBase;
            
            for(var index:int = 0; index < numberOfThumbs; index++)
            {
                var instance:SliderBase = getThumbInstanceAt(index);
                var valueDelta:Number = Math.abs(instance.value - value);
                
                if(valueDelta < nearestValue)
                {
                    nearestValue = valueDelta;
                    nearestThumb = instance;
                }
            } 
            
            return nearestThumb;
        }
        
        private function createThumbsFrom(values:Array):void
        {
            var instance:SliderBase;
            
            for(var index:int = 0; index < values.length; index++)
            {
                instance = SliderBase(createDynamicPartInstance("thumb"));
                
                if(!instance)
                    throw new ArgumentError("Thumb part must be of type SliderBase.");
                
                initializeThumb(instance, values[index]);
                
                addElement(instance);
                thumbs.push(instance);
            }
        }
        
        private function initializeThumb(instance:SliderBase, value:Number):void
        {
            instance.value = value;
            instance.minimum = minimum;
            instance.maximum = maximum;
            instance.snapInterval = _snapInterval;
        }
        
        private function removeAllThumbs():void
        {
            for(var index:int = 0; index < thumbs.length; index++)
            {
                removeDynamicPartInstance("thumb", thumbs[index]);
                removeElement(thumbs[index]);
            }
            
            thumbs.splice(0, thumbs.length);
        }
    }
}