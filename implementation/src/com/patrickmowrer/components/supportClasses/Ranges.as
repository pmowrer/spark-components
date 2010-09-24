package com.patrickmowrer.components.supportClasses
{
    import flash.events.Event;
    
    import mx.core.IFactory;
    import mx.events.FlexEvent;
    
    import spark.components.Group;
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
        
        private var rangeInstances:Vector.<Range>;
        
        private var _minimum:Number = DEFAULT_MINIMUM;
        private var _maximum:Number = DEFAULT_MAXIMUM;
        private var _snapInterval:Number = DEFAULT_SNAP_INTERVAL;
        private var newValues:Array;
         
        private var minimumChanged:Boolean = false;
        private var maximumChanged:Boolean = false;
        private var snapIntervalChanged:Boolean = false;
        private var valuesChanged:Boolean = false;
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
            var returnValues:Array = new Array();
            
            for(var index:int = 0; index < rangeInstances.length; index++)
            {
                returnValues.push(rangeInstances[index].value);
            }
            
            return returnValues;
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
                (instance as Range).addEventListener(FlexEvent.CREATION_COMPLETE, 
                    rangeCreationCompleteHandler);
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
            invalidateProperties();
            
            rangeValueChanged = true;
        }
        
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            
            if(partName == "range")
            {
                (instance as Range).removeEventListener(FlexEvent.VALUE_COMMIT, rangeValueCommitHandler);
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

            if(valuesChanged || minimumChanged || maximumChanged || snapIntervalChanged)
            {
                if(!newValues)
                {
                    newValues = values;
                }
                
                removeAllRanges();
                createRanges(newValues);
                
                newValues = null;                
                valuesChanged = false;
                minimumChanged = false;
                maximumChanged = false;
                snapIntervalChanged = false;
                
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
            
            if(rangeValueChanged)
            {
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
        }
        
        protected function getRangeInstanceAt(index:uint):Range
        {
            return rangeInstances[index];
        }
        
        protected function get numberOfRangeInstances():uint
        {
            return rangeInstances.length;
        }
        
        private function createRanges(values:Array):void
        {
            var rangeInstance:Range;
            
            for(var index:int = 0; index < values.length; index++)
            {
                rangeInstance = createDynamicPartInstance("range") as Range;
                
                initializeRange(rangeInstance, values[index]);
                
                addElement(rangeInstance);
                rangeInstances.push(rangeInstance);
            }
        }
        
        private function initializeRange(instance:Range, value:Number):void
        {
            instance.value = value;
            instance.minimum = _minimum;
            instance.maximum = _maximum;
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