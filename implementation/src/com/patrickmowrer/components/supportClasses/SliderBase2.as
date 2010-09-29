package com.patrickmowrer.components.supportClasses
{
    import com.patrickmowrer.events.ThumbEvent;
    import com.patrickmowrer.layouts.supportClasses.ValueBasedLayout;
    
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Mouse;
    import flash.utils.getQualifiedClassName;
    
    import mx.core.IFactory;
    import mx.events.SandboxMouseEvent;
    
    import spark.components.Button;
    import spark.components.SkinnableContainer;
    
    public class SliderBase2 extends SkinnableContainer
    {
        [SkinPart(required="false", type="com.patrickmowrer.components.supportClasses.Thumb")]
        public var thumb:IFactory;
        
        [SkinPart(required="false")]
        public var track:Button;

        private const DEFAULT_VALUES:Array = [0, 100];

        private var thumbs:Vector.<Thumb>;
        private var thumbClickPoint:Point;
        
        private var _values:Array = DEFAULT_VALUES;

        private var valuesChanged:Boolean = false;
        
        public function SliderBase2()
        {
            super();
            
            thumbs = new Vector.<Thumb>();
        }
        
        public function get values():Array
        {
            return _values;
        }
        
        public function set values(value:Array):void
        {
            if(value != _values)
            {
                _values = value;
                valuesChanged = true;
                invalidateProperties();
            }  
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "thumb")
            {
                var thumb:Thumb = Thumb(instance);
                
                thumb.addEventListener(ThumbEvent.DRAG, thumbDragHandler);
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
                
                thumb.removeEventListener(ThumbEvent.DRAG, thumbDragHandler);
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
            
            if(valuesChanged)
            {
                removeAllThumbs();
                createThumbsFrom(values);
                
                valuesChanged = false;
            }
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            if(thumb)
                createThumbsFrom(_values);
        }
        
        private function createThumbsFrom(values:Array):void
        {
            var instance:Thumb;
            
            for(var index:int = 0; index < values.length; index++)
            {
                instance = Thumb(createDynamicPartInstance("thumb"));
                
                if(!instance)
                {
                    throw new ArgumentError("Thumb part must be of type " +
                        getQualifiedClassName(Thumb));
                }
                
                initializeThumb(instance, values[index]);
                
                addElement(instance);
                thumbs.push(instance);
            }
        }
        
        private function initializeThumb(thumb:Thumb, value:Number):void
        {
            thumb.value = value;
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
        
        private function get valueBasedLayout():ValueBasedLayout
        {
            return (layout as ValueBasedLayout);
        }
        
        private function get numberOfThumbs():int
        {
            return thumbs.length;
        }
        
        private function getThumbInstanceAt(index:int):Thumb
        {
            return thumbs[index];
        }
        
        private function thumbDragHandler(event:ThumbEvent):void
        {
            var thumb:Thumb = Thumb(event.currentTarget);
            
            if(valueBasedLayout)
            {
                var draggedTo:Point 
                    = contentGroup.globalToLocal(new Point(event.stageX, event.stageY));
                
                thumb.value = valueBasedLayout.pointToValue(draggedTo.x, draggedTo.y);
                
                contentGroup.invalidateDisplayList();
            }
        }
        
        private function trackMouseDownHandler(event:MouseEvent):void
        {
            if(valueBasedLayout)
            {
                var trackRelative:Point = track.globalToLocal(new Point(event.stageX, event.stageY));
                var trackClickValue:Number 
                    = valueBasedLayout.pointToValue(trackRelative.x, trackRelative.y);
                var nearestThumb:Thumb = nearestThumbTo(trackClickValue);
                
                nearestThumb.value = trackClickValue;
                
                contentGroup.invalidateDisplayList();
            }
        }
        
        protected function nearestThumbTo(value:Number):Thumb
        {           
            var nearestValue:Number = valueBasedLayout.maximum;
            var nearestThumb:Thumb;
            
            for(var index:int = 0; index < numberOfThumbs; index++)
            {
                var instance:Thumb = getThumbInstanceAt(index);
                var valueDelta:Number = Math.abs(instance.value - value);
                
                if(valueDelta < nearestValue)
                {
                    nearestValue = valueDelta;
                    nearestThumb = instance;
                }
            } 
            
            return nearestThumb;
        }
    }
}