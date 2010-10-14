package com.patrickmowrer.components.supportClasses
{
    import com.patrickmowrer.events.ThumbEvent;
    import com.patrickmowrer.layouts.supportClasses.ValueLayout;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Mouse;
    import flash.utils.getQualifiedClassName;
    
    import mx.core.IFactory;
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    import mx.events.SandboxMouseEvent;
    
    import spark.components.Button;
    import spark.components.SkinnableContainer;
    
    [Style(name="slideDuration", type="Number", format="Time", inherit="no")]
    
    [Style(name="liveDragging", type="Boolean", inherit="no")]
    
    public class SliderBase extends SkinnableContainer implements ValueBounding, ValueSnapping
    {
        [SkinPart(required="false", type="com.patrickmowrer.components.supportClasses.Thumb")]
        public var thumb:IFactory;
        
        [SkinPart(required="false")]
        public var track:Button;

        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        private const DEFAULT_SNAP_INTERVAL:Number = 1;
        private const DEFAULT_VALUES:Array = [0, 100];
        private const DEFAULT_ALLOW_OVERLAP:Boolean = false;
        
        private var newMinimum:Number;
        private var newMaximum:Number;
        private var _snapInterval:Number = DEFAULT_SNAP_INTERVAL;
        private var newValues:Array;
        private var _allowOverlap:Boolean = DEFAULT_ALLOW_OVERLAP;

        private var minimumChanged:Boolean = false;
        private var maximumChanged:Boolean = false;
        private var valuesChanged:Boolean = false;
        private var allowOverlapChanged:Boolean = false;
        private var snapIntervalChanged:Boolean = false;
        private var thumbValueChanged:Boolean = false;
        
        private var animating:Boolean = false;
        private var draggingThumb:Boolean = false;
        
        private var thumbs:Vector.<Thumb>;
        private var animatedThumb:Thumb;
        
        public function SliderBase()
        {
            super();
            
            thumbs = new Vector.<Thumb>();
            
            if(!newMinimum)
                minimum = DEFAULT_MINIMUM;
            if(!newMaximum)
                maximum = DEFAULT_MAXIMUM;
            if(!newValues)
                values = DEFAULT_VALUES;
        }
        
        public function get minimum():Number
        {
            if(minimumChanged)
                return newMinimum;
            else if(valueBasedLayout)
                 return valueBasedLayout.minimum;
            else
                return 0;
        }
        
        public function set minimum(value:Number):void
        {
            if(value != minimum)
            {
                newMinimum = value;
                minimumChanged = true;
                invalidateProperties();
            }
        }

        public function get maximum():Number
        {
            if(maximumChanged)
                return newMaximum;
            if(valueBasedLayout)
                return valueBasedLayout.maximum;
            else
                return 0;
        }
        
        public function set maximum(value:Number):void
        {
            if(value != maximum)
            {
                newMaximum = value;
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

        [Bindable(event = "valueCommit")]
        [Bindable(event = "change")]
        public function get values():Array
        {
            if(valuesChanged)
            {
                return newValues;
            }
            else
            {
                var thumbValues:Array = [];
                
                if(thumb)
                {
                    for(var index:int = 0; index < numberOfThumbs; index++)
                    {
                        var value:Number = getThumbAt(index).value;
                        
                        thumbValues.push(value);
                    }
                }
                
                return thumbValues;
            }
        }
        
        public function set values(value:Array):void
        {
            if(value != values)
            {
                newValues = value;
                valuesChanged = true;
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
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "thumb")
            {
                var thumb:Thumb = Thumb(instance);
                var slideDuration:Number = getStyle("slideDuration");
               
                thumb.setStyle("slideDuration", slideDuration);
                
                thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
                thumb.addEventListener(ThumbEvent.BEGIN_DRAG, thumbBeginDragHandler);
                thumb.addEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
            }
            else if(partName == "track")
            {
                var track:Button = Button(instance);
                
                track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if(partName == "thumb")
            {
                var thumb:Thumb = Thumb(instance);
                
                thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
                thumb.removeEventListener(ThumbEvent.BEGIN_DRAG, thumbBeginDragHandler);
                thumb.removeEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
            }
            else if(partName == "track")
            {
                var track:Button = Button(instance);
                
                track.removeEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
            }
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(valuesChanged || minimumChanged || maximumChanged || snapIntervalChanged || allowOverlapChanged)
            {
                if(valueBasedLayout)
                {
                    if(minimumChanged)
                        valueBasedLayout.minimum = newMinimum;
                    if(maximumChanged)
                        valueBasedLayout.maximum = newMaximum;
                }

                if(thumb)
                {
                    if(!valuesChanged)
                        newValues = values;
                    
                    if(!allowOverlap)
                        newValues = newValues.sort(Array.NUMERIC);
                        
                    removeAllThumbs();
                    createThumbsFrom(newValues);
                    
                    dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
                }
                
                minimumChanged = false;
                maximumChanged = false;
                snapIntervalChanged = false;
                valuesChanged = false;
                allowOverlapChanged = false;
            }
            
            if(thumbValueChanged && !animating && !isDraggingThumbWithLiveDraggingDisabled)
            {
                dispatchEvent(new Event(Event.CHANGE));
                
                thumbValueChanged = false;
            }
        }
        
        private function createThumbsFrom(values:Array):void
        {   
            for(var index:int = 0; index < values.length; index++)
            {
                var thumb:Thumb = Thumb(createDynamicPartInstance("thumb"));
                
                if(!thumb)
                {
                    throw new ArgumentError("Thumb part must be of type " +
                        getQualifiedClassName(Thumb));
                }
                
                thumb.minimum = minimum;
                thumb.maximum = maximum;
                thumb.snapInterval = snapInterval;
                thumb.value = values[index];
                
                addElement(thumb);
                thumbs.push(thumb);
            }
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
        
        private function get valueBasedLayout():ValueLayout
        {
            return (layout as ValueLayout);
        }
        
        private function get numberOfThumbs():int
        {
            return thumbs.length;
        }
        
        private function getThumbAt(index:int):Thumb
        {
            return thumbs[index];
        }
        
        private function getIndexOf(thumb:Thumb):int
        {
            return thumbs.indexOf(thumb);
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
        
        private function thumbBeginDragHandler(event:ThumbEvent):void
        {
            if(animating)
                animatedThumb.stopAnimation();
           
            var thumb:Thumb = Thumb(event.currentTarget);
            
            thumb.addEventListener(ThumbEvent.DRAGGING, thumbDraggingHandler);
            thumb.addEventListener(ThumbEvent.END_DRAG, thumbEndDragHandler);
            
            draggingThumb = true;
        }
        
        private function thumbDraggingHandler(event:ThumbEvent):void
        {
            var thumb:Thumb = Thumb(event.currentTarget);
            
            if(valueBasedLayout)
            {
                var draggedTo:Point 
                    = contentGroup.globalToLocal(new Point(event.stageX, event.stageY));
                
                thumb.value = valueBasedLayout.pointToValue(draggedTo.x, draggedTo.y);
            }
        }
        
        private function thumbEndDragHandler(event:ThumbEvent):void
        {
            var thumb:Thumb = Thumb(event.currentTarget);
            
            thumb.removeEventListener(ThumbEvent.DRAGGING, thumbDraggingHandler);
            thumb.removeEventListener(ThumbEvent.END_DRAG, thumbEndDragHandler);            

            draggingThumb = false;
            
            invalidateThumbValues();
        }
        
        private function thumbValueCommitHandler(event:FlexEvent):void
        {
            if(!allowOverlap && numberOfThumbs > 1)
            {
                constrainThumb(Thumb(event.currentTarget));
            }
            
            if(!animating && !isDraggingThumbWithLiveDraggingDisabled)
            {
                invalidateThumbValues();
            }
            
            contentGroup.invalidateDisplayList();
        }
        
        private function invalidateThumbValues():void
        {
            if(!thumbValueChanged)
            {
                thumbValueChanged = true;
                invalidateProperties();
            }            
        }
        
        private function get isDraggingThumbWithLiveDraggingDisabled():Boolean
        {
            return draggingThumb && !getStyle("liveDragging");    
        }
        
        private function constrainThumb(thumb:Thumb):void
        {
            var thumbIndex:int = getIndexOf(thumb);
            
            if(thumbIndex != 0)
                getThumbAt(thumbIndex - 1).constrainMaximumTo(thumb);
            
            if(thumbIndex != numberOfThumbs - 1)
                getThumbAt(thumbIndex + 1).constrainMinimumTo(thumb);           
        }
        
        private function trackMouseDownHandler(event:MouseEvent):void
        {
            if(valueBasedLayout)
            {
                var trackRelative:Point = track.globalToLocal(new Point(event.stageX, event.stageY));
                var trackClickValue:Number 
                    = valueBasedLayout.pointToValue(trackRelative.x, trackRelative.y);
                var nearestThumb:Thumb = nearestThumbTo(trackClickValue);
                
                if(true)
                {
                    beginThumbAnimation(nearestThumb, trackClickValue);
                }
                else
                {
                    nearestThumb.value = trackClickValue;
                }
            }
        }
        
        private function nearestThumbTo(value:Number):Thumb
        {           
            var nearestValue:Number = valueBasedLayout.maximum;
            var nearestThumb:Thumb;
            
            for(var index:int = 0; index < numberOfThumbs; index++)
            {
                var thumb:Thumb = getThumbAt(index);
                var valueDelta:Number = Math.abs(thumb.value - value);
                
                var valueInRange:Boolean 
                    = allowOverlap || (thumb.minimum <= value && thumb.maximum >= value)
                
                if(valueDelta < nearestValue && valueInRange)
                {
                    nearestValue = valueDelta;
                    nearestThumb = thumb;
                }
            } 
            
            return nearestThumb;
        }
        
        private function beginThumbAnimation(thumb:Thumb, value:Number):void
        {
            if(animating)
                animatedThumb.stopAnimation();
            
            animating = true;
            animatedThumb = thumb;
            animatedThumb.animateMovementTo(value, endAnimation);
        }
        
        private function stopAnimation():void
        {
            animatedThumb.stopAnimation();
            
            endAnimation();
        }
        
        private function endAnimation():void
        {
            animatedThumb = null;
            
            animating = false;            
        }
    }
}