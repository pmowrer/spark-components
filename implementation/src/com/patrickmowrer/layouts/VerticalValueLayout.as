package com.patrickmowrer.layouts
{
    import com.patrickmowrer.layouts.supportClasses.LinearValueLayout;
    
    import flash.geom.Point;
    
    public class VerticalValueLayout extends LinearValueLayout
    {
        public function VerticalValueLayout()
        {
            super(new Point(0, 0), new Point(0, 1));
        }
    }
}