package com.patrickmowrer.components
{   
    import com.patrickmowrer.components.supportClasses.SlidersBase;
    
    import spark.components.supportClasses.Range;
    import spark.components.supportClasses.SliderBase;

    public class HSliders extends SlidersBase
    {
        public function HSliders()
        {
            super();
        }
        
        override protected function trackPointToValue(x:Number, y:Number):Number
        {
            var thumbDummy:SliderBase = SliderBase(thumb.newInstance());
            var trackRange:Number = maximum - minimum;
            var thumbRange:Number = track.getLayoutBoundsWidth() - thumbDummy.getLayoutBoundsWidth();
            
            return minimum + ((thumbRange != 0) ? (x / thumbRange) * trackRange : 0);
        }
    }
}