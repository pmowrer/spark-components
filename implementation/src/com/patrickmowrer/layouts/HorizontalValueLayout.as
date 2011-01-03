package com.patrickmowrer.layouts
{
    import com.patrickmowrer.layouts.supportClasses.LinearValueLayout;
    
    import flash.geom.Point;
    
    public class HorizontalValueLayout extends LinearValueLayout
    {
        public function HorizontalValueLayout()
        {
            super(new Point(0, 0), new Point(1, 0));
        }
    }
}