package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.Thumb;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;

    import org.morefluent.integrations.flexunit4.*;

    public class ThumbConstraintTest
    {
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var thumb1:Thumb;
        private var thumb2:Thumb;
        
        [Before(async, ui)]
        public function setUp():void
        {
            thumb1 = new Thumb();
            thumb2 = new Thumb();
            
            UIImpersonator.addChild(thumb1);
            UIImpersonator.addChild(thumb2);
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb1).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(thumb1);
            UIImpersonator.removeChild(thumb2);
            thumb1 = null;
            thumb2 = null;
        }
        
        [Test(async)]
        public function shouldConstrainMinimumToNearestMultipleOfSnapIntervalEqualOrGreaterThanOtherThumbsValue():void
        {
            thumb1.minimum = 7;
            thumb1.maximum = 13;
            thumb1.snapInterval = 4;
            thumb1.value = 11;
            
            thumb2.minimum = 0;
            thumb2.maximum = 6;
            thumb2.value = 2;
            
            thumb1.constrainMinimumTo(thumb2);
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb1)
                .assert(thumb1, "minimum").equals(3);
        }
        
        [Test(async)]
        public function shouldConstrainMaximumToNearestMultipleOfSnapIntervalEqualOrLessThanOtherThumbsValue():void
        {
            thumb1.minimum = -7;
            thumb1.maximum = 13;
            thumb1.snapInterval = 4.5;
            thumb1.value = 2;
            
            thumb2.minimum = 0;
            thumb2.maximum = 6;
            thumb2.value = 5;
            
            thumb1.constrainMaximumTo(thumb2);
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb1)
                .assert(thumb1, "maximum").equals(2);
        }
    }
}