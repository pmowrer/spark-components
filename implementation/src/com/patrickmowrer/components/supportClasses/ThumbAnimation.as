package com.patrickmowrer.components.supportClasses
{
    public interface ThumbAnimation
    {
        function play(duration:Number, endValue:Number, afterHandler:Function):void;
        function stop():void;
        function isPlaying():Boolean;
    }
}