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
    import com.patrickmowrer.layouts.supportClasses.ValueLayout;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.getQualifiedClassName;
    
    import mx.core.IFactory;
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    
    import spark.components.Button;
    import spark.components.SkinnableContainer;
    
    [Style(name="slideDuration", type="Number", format="Time", inherit="no")]
    [Style(name="liveDragging", type="Boolean", inherit="no")]
    [Style(name="dataTipOffsetX", type="Number", format="Length", inherit="yes")]
    [Style(name="dataTipOffsetY", type="Number", format="Length", inherit="yes")]
    
    public class SliderBase extends SkinnableContainer implements ValueBounding, ValueSnapping
    {
        [SkinPart(required="false", type="com.patrickmowrer.components.supportClasses.SliderThumb")]
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
        private var thumbPressOffset:Point;
        private var keyDownOnThumb:Boolean = false;
        
        private var thumbs:Vector.<SliderThumb>;
        private var focusedThumbIndex:uint = 0;
        private var animatedThumb:SliderThumb;
        
        public function SliderBase()
        {
            super();
            
            thumbs = new Vector.<SliderThumb>();
            
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
        
        public function nearestThumbTo(value:Number):SliderThumb
        {           
            var nearestValue:Number = NaN;
            var nearestThumb:SliderThumb;
            
            for(var index:int = 0; index < numberOfThumbs; index++)
            {
                var thumb:SliderThumb = getThumbAt(index);
                var valueDelta:Number = Math.abs(thumb.value - value);
                
                var valueInRange:Boolean 
                = allowOverlap || (thumb.minimum <= value && thumb.maximum >= value)
                
                if(isNaN(nearestValue) || (valueDelta < nearestValue && valueInRange))
                {
                    nearestValue = valueDelta;
                    nearestThumb = thumb;
                }
            } 
            
            return nearestThumb;
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "thumb")
            {
                var thumb:SliderThumb = SliderThumb(instance);
                var slideDuration:Number = getStyle("slideDuration");
               
                thumb.setStyle("slideDuration", slideDuration);
                
                thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
                thumb.addEventListener(ThumbMouseEvent.PRESS, thumbPressHandler);
                thumb.addEventListener(ThumbKeyEvent.KEY_DOWN, thumbKeyDownHandler);
                thumb.addEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
                
                thumb.focusEnabled = true;
            }
            else if(partName == "track")
            {
                track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
                
                track.focusEnabled = false;
            }
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if(partName == "thumb")
            {
                var thumb:SliderThumb = SliderThumb(instance);
                
                thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
                thumb.removeEventListener(ThumbMouseEvent.PRESS, thumbPressHandler);
                thumb.removeEventListener(ThumbKeyEvent.KEY_DOWN, thumbKeyDownHandler);
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
                    // The order in which min/max is set is important when
                    // the layout bounds the new value based on the other
                    // extreme, e.g. limiting a new maximum because it's
                    // smaller than the old minimum, even though the new
                    // minimum allows it.
                    if(valueBasedLayout.minimum > newMaximum)
                    {
                        if(minimumChanged)
                            valueBasedLayout.minimum = newMinimum;
                        
                        if(maximumChanged)
                            valueBasedLayout.maximum = newMaximum;
                    }
                    else
                    {
                        if(maximumChanged)
                            valueBasedLayout.maximum = newMaximum;
                        
                        if(minimumChanged)
                            valueBasedLayout.minimum = newMinimum;
                    }
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
                var thumb:SliderThumb = SliderThumb(createDynamicPartInstance("thumb"));
                
                if(!thumb)
                {
                    throw new ArgumentError("Thumb part must be of type " +
                        getQualifiedClassName(SliderThumb));
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
        
        private function getThumbAt(index:int):SliderThumb
        {
            return thumbs[index];
        }
        
        private function getIndexOf(thumb:SliderThumb):int
        {
            return thumbs.indexOf(thumb);
        }
        
        private function thumbMouseDownHandler(event:MouseEvent):void
        {                    
            visuallyMoveToFront(IVisualElement(event.currentTarget));
        }
        
        private function visuallyMoveToFront(instance:IVisualElement):void
        {
            var lastIndexElement:IVisualElement = getElementAt(numElements - 1);
            
            if(instance != lastIndexElement)
                swapElements(instance, lastIndexElement);
        }

        private function thumbPressHandler(event:ThumbMouseEvent):void
        {
            if(animating)
                animatedThumb.stopAnimation();
           
            var thumb:SliderThumb = SliderThumb(event.currentTarget);
            
            // Store the delta between mouse pointer's position on thumb down and the current value of the thumb.
            // On dragging, this value is used to offset the new value, making it appear as
            // if the mouse pointer stays in the same position over the thumb. Can't trust the thumb's
            // own measurements here since it doesn't know how the layout is positioning it relative to its value.
            var thumbPressPoint:Point = contentGroup.globalToLocal(new Point(event.stageX, event.stageY));
            var thumbPoint:Point = valueBasedLayout.valueToPoint(thumb.value);            
            thumbPressOffset = new Point(thumbPoint.x - thumbPressPoint.x, thumbPoint.y - thumbPressPoint.y);
            
            thumb.addEventListener(ThumbMouseEvent.DRAGGING, thumbDraggingHandler);
            thumb.addEventListener(ThumbMouseEvent.RELEASE, thumbReleaseHandler);
            
            draggingThumb = true;
            dispatchChangeStart();
        }
        
        private function thumbDraggingHandler(event:ThumbMouseEvent):void
        {
            var thumb:SliderThumb = SliderThumb(event.currentTarget);
            
            if(valueBasedLayout)
            {
                var draggedTo:Point 
                    = contentGroup.globalToLocal(new Point(event.stageX, event.stageY));
                draggedTo.offset(thumbPressOffset.x, thumbPressOffset.y);
                
                thumb.value = valueBasedLayout.pointToValue(draggedTo);
            }
        }
        
        private function thumbReleaseHandler(event:ThumbMouseEvent):void
        {
            var thumb:SliderThumb = SliderThumb(event.currentTarget);
            
            thumb.removeEventListener(ThumbMouseEvent.DRAGGING, thumbDraggingHandler);
            thumb.removeEventListener(ThumbMouseEvent.RELEASE, thumbReleaseHandler);            

            draggingThumb = false;
            dispatchChangeEnd();
            
            invalidateThumbValues();
        }
        
        private function thumbKeyDownHandler(event:ThumbKeyEvent):void
        {
            var thumb:SliderThumb = SliderThumb(event.currentTarget);
            
            if(animating)
                stopAnimation();
            
            if(!keyDownOnThumb)
            {
                dispatchChangeStart();
                keyDownOnThumb = true;
                thumb.addEventListener(ThumbKeyEvent.KEY_UP, thumbKeyUpHandler);
            }
            
            thumb.value = event.newValue;
        }
        
        private function thumbKeyUpHandler(event:ThumbKeyEvent):void
        {
            var thumb:SliderThumb = SliderThumb(event.currentTarget);
            
            dispatchChangeEnd();
            keyDownOnThumb = false;
            thumb.removeEventListener(ThumbKeyEvent.KEY_UP, thumbKeyUpHandler);
        }
        
        private function thumbValueCommitHandler(event:FlexEvent):void
        {
            if(!allowOverlap && numberOfThumbs > 1)
            {
                constrainThumb(SliderThumb(event.currentTarget));
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
        
        private function constrainThumb(thumb:SliderThumb):void
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
                var trackClickValue:Number = valueBasedLayout.pointToValue(trackRelative);
                var nearestThumb:SliderThumb = nearestThumbTo(trackClickValue);
                
                if(getStyle("slideDuration") != 0)
                    beginThumbAnimation(nearestThumb, trackClickValue);
                else
                    nearestThumb.value = trackClickValue;
            }
        }
        
        private function beginThumbAnimation(thumb:SliderThumb, value:Number):void
        {
            if(animating)
                animatedThumb.stopAnimation();
            
            animating = true;
            animatedThumb = thumb;
            animatedThumb.animateMovementTo(value, endAnimation);
            
            dispatchChangeStart();
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
            
            dispatchChangeEnd();
        }
        
        private function dispatchChangeStart():void
        {
            dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
        }
        
        private function dispatchChangeEnd():void
        {
            dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
        }
    }
}