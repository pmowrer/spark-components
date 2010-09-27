package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.SlidersBase;
    
    import flash.events.Event;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.isFalse;
    import org.morefluent.integrations.flexunit4.*;

    public class SlidersDefaultsTest
    {		
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var sliders:SlidersBase;
        
        [Before(async, ui)]
        public function setUp():void
        {
            sliders = new SlidersBase();
            sliders.setStyle("skinClass", SlidersTestSkin);
            
            UIImpersonator.addChild(sliders);
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(sliders);			
            sliders = null;
        }
        
        [Test]
        public function defaultValuesAre0And100():void
        {
            assertThat(sliders.values, array(0, 100));
        }
        
        [Test]
        public function defaultMinimumIs0():void
        {
            assertThat(sliders.minimum, equalTo(0));
        }
        
        [Test]
        public function defaultMaximumIs100():void
        {
            assertThat(sliders.maximum, equalTo(100));
        }
        
        [Test]
        public function defaultSnapIntervalIs1():void
        {
            assertThat(sliders.snapInterval, equalTo(1));
        }
        
        [Test]
        public function defaultAllowOverlapIsFalse():void
        {
            assertThat(sliders.allowOverlap, isFalse());
        }
    }
}
