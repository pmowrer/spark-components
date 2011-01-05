/**
 * The MIT License
 *
 * Copyright (c) 2011 Patrick Mowrer
 *  
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

package com.patrickmowrer.components.supportClasses
{
    import spark.effects.animation.Animation;
    import spark.effects.animation.MotionPath;
    import spark.effects.animation.SimpleMotionPath;
    import spark.effects.easing.Sine;

    public class SimpleSliderThumbAnimation implements SliderThumbAnimation
    {
        private var animation:Animation;
        private var thumb:SliderThumb;
        private var endValue:Number;
        private var afterHandler:Function;
        private var originalSnapInterval:Number;
        
        public function SimpleSliderThumbAnimation(thumb:SliderThumb)
        {
            this.thumb = thumb;
  
            var target:AnimationTarget = new AnimationTarget(animationUpdateHandler);
            target.endFunction = animationEndHandler;
                
            animation = new Animation();
            animation.animationTarget = target;
            animation.easer = new Sine(0);
        }
        
        public function play(duration:Number, endValue:Number, afterHandler:Function):void
        {
            this.afterHandler = afterHandler;
            this.endValue = endValue;
            
            originalSnapInterval = thumb.snapInterval;
            thumb.snapInterval = 0;
            
            var startValue:Number = thumb.value;
            
            if(isPlaying())
                stop();
            
            animation.duration = duration * 
                (Math.abs(startValue - endValue) / (thumb.maximum - thumb.minimum));
            
            animation.motionPaths = 
                new <MotionPath>[new SimpleMotionPath("value", startValue, endValue)];
            
            animation.play();
        }
        
        public function stop():void
        {
            animation.stop();
            finish();
        }
        
        public function isPlaying():Boolean
        {
            return animation.isPlaying;
        }
        
        private function animationEndHandler(animation:Animation):void
        {
            thumb.value = endValue;
            finish();
        }
        
        private function finish():void
        {
            thumb.snapInterval = originalSnapInterval;
            afterHandler();
        }
        
        /**
         *  @private
         *  Handles events from the Animation that runs the animated slide.
         *  We just call setValue() with the current animated value
         */
        private function animationUpdateHandler(animation:Animation):void
        {
            thumb.value = animation.currentValue["value"];
        }
    }
}