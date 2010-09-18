package com.patrickmowrer.components.supportClasses
{
    import spark.components.Button;
    import spark.components.supportClasses.Range;
    import spark.components.supportClasses.SliderBase;

    public class SlidersBase extends Ranges
    {
        [SkinPart(required="false")]
        public var track:SliderBase;
        
        public function SlidersBase()
        {
            super();
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if(partName == "range" && track && instance is SliderBase)
            {
                (instance as SliderBase).track = track.track;
            }
        }
    }
}