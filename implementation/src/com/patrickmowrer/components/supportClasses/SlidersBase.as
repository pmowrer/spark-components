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
            if(partName == "range" && instance is SliderBase)
            {
                (instance as SliderBase).track = track.track;
            }
        }
    }
}