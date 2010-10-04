package com.patrickmowrer.components.supportClasses
{
    import spark.effects.animation.Animation;
    import spark.effects.animation.MotionPath;
    import spark.effects.animation.SimpleMotionPath;
    import spark.effects.easing.Sine;

    public class SimpleThumbAnimation implements ThumbAnimation
    {
        private var animation:Animation;
        private var thumb:Thumb;
        private var endValue:Number;
        private var afterHandler:Function;
        
        public function SimpleThumbAnimation(thumb:Thumb)
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