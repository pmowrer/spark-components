package com.patrickmowrer.layouts.supportClasses
{
    import com.patrickmowrer.components.supportClasses.ValueBounding;
    
    import flash.geom.Point;
    
    import mx.core.IVisualElement;

    public interface ValueLayout extends ValueBounding
    {
        function pointToValue(point:Point, relativeTo:IVisualElement = null):Number;
    }
}