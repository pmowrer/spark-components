package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.Thumb;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.morefluent.integrations.flexunit4.*;

    public class ThumbPropertySettingTest
    {	
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var thumb:Thumb;
        
        private const DEFAULT_VALUE:Number = 0;
        private const DEFAULT_MIN:Number = 0;
        private const DEFAULT_MAX:Number = 100;
        private const ARBITRARY_VALUE_BETWEEN_DEF_MINMAX:Number = 42;
        private const ARBITRARY_VALUE_LESS_THAN_DEF_MIN:Number = -10;
        private const ARBITRARY_VALUE_LESS_THAN_DEF_MAX:Number = 110;
        private const ARBITRARY_VALUE_GREATER_THAN_DEF_VALUE:Number = 20;
        private const ARBITRARY_VALUE_LESS_THAN_DEF_VALUE:Number = -5;
        
        [Before(async, ui)]
        public function setUp():void
        {
            thumb = new Thumb();
            
            UIImpersonator.addChild(thumb);
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(thumb);
            thumb = null;
        }
        
        [Test(async)]
        public function defaultValueIs0():void
        {
            assertThat(thumb.value, equalTo(DEFAULT_VALUE));
        }
        
        [Test(async)]
        public function newValueIsAvailableImmediatelyAndInvalidatesProperties():void
        {
            thumb.value = ARBITRARY_VALUE_BETWEEN_DEF_MINMAX;
            
            assertThat(thumb.value, equalTo(ARBITRARY_VALUE_BETWEEN_DEF_MINMAX));
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb).pass();
        }
        
        [Test(async)]
        public function newValueTriggersValueCommit():void
        {
            observing(FlexEvent.VALUE_COMMIT).on(thumb);
            
            thumb.value = ARBITRARY_VALUE_BETWEEN_DEF_MINMAX;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb).
                assert(thumb).observed(FlexEvent.VALUE_COMMIT, times(1));          
        }
        
        [Test(async)]
        public function defaultMinimumIs0():void
        {
            assertThat(thumb.minimum, equalTo(DEFAULT_MIN));
        }
        
        [Test(async)]
        public function newMinimumIsAvailableImmediatelyAndInvalidatesProperties():void
        {
            thumb.minimum = -10;
            
            assertThat(thumb.minimum, equalTo(-10));
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb).pass();
        }
        
        [Test(async)]
        public function valueIsBoundedByMinimum():void
        {
            thumb.value = ARBITRARY_VALUE_LESS_THAN_DEF_MIN;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb)
                .assert(thumb, "value").equals(DEFAULT_MIN);
        }
        
        [Test(async)]
        public function settingMinimumHigherThanValueAdjustsLatterToFormer():void
        {
            thumb.minimum = ARBITRARY_VALUE_GREATER_THAN_DEF_VALUE;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb)
                .assert(thumb, "value").equals(ARBITRARY_VALUE_GREATER_THAN_DEF_VALUE);
        }
        
        [Test(async)]
        public function defaultMaximumIs0():void
        {
            assertThat(thumb.maximum, equalTo(DEFAULT_MAX));
        }
        
        [Test(async)]
        public function newMaximumIsAvailableImmediatelyAndInvalidatesProperties():void
        {
            thumb.maximum = 50;
            
            assertThat(thumb.maximum, equalTo(50));
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb).pass();
        }
        
        [Test(async)]
        public function valueIsBoundedByMaximum():void
        {
            thumb.value = ARBITRARY_VALUE_LESS_THAN_DEF_MAX;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb)
                .assert(thumb, "value").equals(DEFAULT_MAX);
        }
        
        [Test(async)]
        public function settingMaximumLowerThanValueAdjustsLatterToFormer():void
        {
            thumb.maximum = ARBITRARY_VALUE_LESS_THAN_DEF_VALUE;
            thumb.minimum = thumb.maximum - 10;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb)
                .assert(thumb, "value").equals(ARBITRARY_VALUE_LESS_THAN_DEF_VALUE);
        }
        
        [Test(async)]
        public function settingMinimumHigherThanMaximumAdjustsFormerToLatter():void
        {
            thumb.minimum = ARBITRARY_VALUE_GREATER_THAN_DEF_VALUE;
            thumb.maximum = ARBITRARY_VALUE_LESS_THAN_DEF_VALUE;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb)
                .assert(thumb, "minimum").equals(ARBITRARY_VALUE_LESS_THAN_DEF_VALUE);
        }
        
        [Test(async)]
        public function defaultSnapIntervalIs1():void
        {
            assertThat(thumb.snapInterval, equalTo(1));
        }
        
        [Test(async)]
        public function valueIsAdjustedToNearestMultipleOfSnapIntervalExceptWhenLatterIs0():void
        {
            thumb.snapInterval = 3;
            thumb.value = 4;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb)
                .assert(thumb, "value").equals(3);
        }
        
        [Test(async)]
        public function snapIntervalDoesNotAffectValueAtMinimum():void
        {
            thumb.minimum = 4;
            thumb.value = 4;
            thumb.snapInterval = 3;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb)
                .assert(thumb, "value").equals(4);
        }
        
        [Test(async)]
        public function snapIntervalDoesNotAffectValueAtMaximum():void
        {
            thumb.minimum = 0;
            thumb.maximum = 4;
            thumb.value = 4;
            thumb.snapInterval = 3;
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb)
                .assert(thumb, "value").equals(4);
        }
    }
}