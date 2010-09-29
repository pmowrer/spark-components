package com.patrickmowrer.layouts.supportClasses
{
    import com.patrickmowrer.components.supportClasses.ValueBounding;

    public interface ValueBasedLayout extends ValueBounding
    {
        function pointToValue(x:Number, y:Number):Number;
    }
}