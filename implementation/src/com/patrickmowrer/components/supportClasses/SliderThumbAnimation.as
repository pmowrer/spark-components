package com.patrickmowrer.components.supportClasses
{
    public interface SliderThumbAnimation
    {
        function play(duration:Number, endValue:Number, afterHandler:Function):void;
        function stop():void;
        function isPlaying():Boolean;
    }
}