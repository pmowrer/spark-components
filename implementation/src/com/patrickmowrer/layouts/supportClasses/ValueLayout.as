package com.patrickmowrer.layouts.supportClasses
{
    import com.patrickmowrer.components.supportClasses.ValueBounding;

    public interface ValueLayout extends ValueBounding
    {
        function pointToValue(x:Number, y:Number):Number;
    }
}