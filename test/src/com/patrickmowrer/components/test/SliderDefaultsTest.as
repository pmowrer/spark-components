package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.SliderBase;
    
    import flash.events.Event;
    
    import mx.events.FlexEvent;
    
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.flexunit.rules.IMethodRule;
    import org.morefluent.integrations.flexunit4.*;
    
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.isFalse;

    public class SliderDefaultsTest
    {		
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var slider:SliderBase;
        
        [Before(async, ui)]
        public function setUp():void
        {
            slider = new SliderBase();
            
            UIImpersonator.addChild(slider);
            after(FlexEvent.UPDATE_COMPLETE).on(slider).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(slider);			
            slider = null;
        }
        
        [Test]
        public function defaultValuesAre0And100():void
        {
            assertThat(slider.values, array(0, 100));
        }
        
        [Test]
        public function defaultMinimumIs0():void
        {
            assertThat(slider.minimum, equalTo(0));
        }
        
        [Test]
        public function defaultMaximumIs100():void
        {
            assertThat(slider.maximum, equalTo(100));
        }
        
        [Test]
        public function defaultSnapIntervalIs1():void
        {
            assertThat(slider.snapInterval, equalTo(1));
        }
        
        [Test]
        public function defaultAllowOverlapIsFalse():void
        {
            assertThat(slider.allowOverlap, isFalse());
        }
    }
}
