package com.patrickmowrer.components.supportClasses
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.core.IFactory;
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    
    import spark.components.SkinnableContainer;
    import spark.components.supportClasses.Range;
    
    public class Ranges extends SkinnableContainer
    {   
        [SkinPart(required="true", type="spark.components.Range")]
        public var range:IFactory;
        
        private const DEFAULT_MINIMUM:Number = 0;
        private const DEFAULT_MAXIMUM:Number = 100;
        private const DEFAULT_SNAP_INTERVAL:Number = 1;
        private const DEFAULT_STEP_SIZE:Number = 1;
        private const DEFAULT_VALUES:Array = [0, 100];
        private const DEFAULT_ALLOW_OVERLAP:Boolean = false;
        
        private var rangeInstances:Vector.<Range>;
        
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
        
        public function Ranges()
        {
            super();
            
            rangeInstances = new Vector.<Range>();
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
                
                for(var index:int = 0; index < rangeInstances.length; index++)
                {
                    returnValues.push(rangeInstances[index].value);
                }
                
                return returnValues;
            }
        }
        
        public function set values(newValues:Array):void
        {
            if(rangeInstances.length == newValues.length)
            {
                var index:int = 0;
                
                while(index < newValues.length)
                {
                    if(rangeInstances[index].value != newValues[index])
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
            
            createRanges(DEFAULT_VALUES);
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "range")
            {
                var range:Range = Range(instance);
                
                range.addEventListener(FlexEvent.CREATION_COMPLETE, rangeCreationCompleteHandler);
                range.addEventListener(MouseEvent.MOUSE_DOWN, rangeMouseDownHandler);
            }
        }
        
        // Want to avoid dispatching multiple value_commit every time multiple Range values
        // are changed, including when they are created
        private function rangeCreationCompleteHandler(event:FlexEvent):void
        {
            var range:Range = event.target as Range;
            
            range.removeEventListener(FlexEvent.CREATION_COMPLETE, rangeCreationCompleteHandler);
            range.addEventListener(FlexEvent.VALUE_COMMIT, rangeValueCommitHandler);
        }
        
        private function rangeValueCommitHandler(event:FlexEvent):void
        {
/*            if(!allowOverlap)
            {
                var instance:Range = Range(event.currentTarget);
                var index:int = getIndexOf(instance);
                
                if(index != 0)
                {
                    getRangeInstanceAt(index - 1).maximum = instance.value;
                }
                
                if(index != numberOfRangeInstances - 1)
                {
                    getRangeInstanceAt(index + 1).minimum = instance.value;
                }
            }*/
            
            invalidateProperties();
            
            rangeValueChanged = true;
        }
        
        private function rangeMouseDownHandler(event:MouseEvent):void
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
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if(partName == "range")
            {
                var range:Range = Range(instance);
                
                range.removeEventListener(FlexEvent.CREATION_COMPLETE, rangeCreationCompleteHandler);
                range.removeEventListener(MouseEvent.MOUSE_DOWN, rangeMouseDownHandler);
            }
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
                if(!newValues)
                {
                    newValues = values;
                }
                
                removeAllRanges();
                createRanges(newValues);
                
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
        
        protected function getIndexOf(instance:Range):int
        {
            return rangeInstances.indexOf(instance);
        }
        
        protected function getRangeInstanceAt(index:uint):Range
        {
            return rangeInstances[index];
        }
        
        protected function get numberOfRangeInstances():uint
        {
            return rangeInstances.length;
        }
        
        protected function nearestInstanceTo(value:Number):Range
        {           
            var nearestValue:Number = maximum;
            var nearestInstance:Range;
            
            for(var index:int = 0; index < numberOfRangeInstances; index++)
            {
                var instance:Range = getRangeInstanceAt(index);
                var valueDelta:Number = Math.abs(instance.value - value);
                
                if(valueDelta < nearestValue)
                {
                    nearestValue = valueDelta;
                    nearestInstance = instance;
                }
            } 
            
            return nearestInstance;
        }
        
        private function createRanges(values:Array):void
        {
            var instance:Range;
            var lastIndex:int = values.length - 1;
            
            for(var index:int = 0; index <= lastIndex; index++)
            {
                instance = createDynamicPartInstance("range") as Range;
                
                initializeRange(instance, values[index]);
                
                addElement(instance);
                rangeInstances.push(instance);
            }
        }
        
        private function initializeRange(instance:Range, value:Number):void
        {
            instance.value = value;
            instance.minimum = minimum;
            instance.maximum = maximum;
            instance.snapInterval = _snapInterval;
        }
        
        private function removeAllRanges():void
        {
            for(var index:int = 0; index < rangeInstances.length; index++)
            {
                removeDynamicPartInstance("range", rangeInstances[index]);
                removeElement(rangeInstances[index]);
            }
            
            rangeInstances.splice(0, rangeInstances.length);
        }
    }
}