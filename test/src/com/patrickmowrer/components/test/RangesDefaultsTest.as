package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.Ranges;
    
    import flash.events.Event;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.isFalse;
    import org.morefluent.integrations.flexunit4.*;

    public class RangesDefaultsTest
    {		
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var ranges:Ranges;
        
        [Before(async, ui)]
        public function setUp():void
        {
            ranges = new Ranges();
            ranges.setStyle("skinClass", RangesTestSkin);
            
            UIImpersonator.addChild(ranges);
            after(FlexEvent.UPDATE_COMPLETE).on(ranges).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(ranges);			
            ranges = null;
        }
        
        [Test]
        public function defaultValuesAre0And100():void
        {
            assertThat(ranges.values, array(0, 100));
        }
        
        [Test]
        public function defaultMinimumIs0():void
        {
            assertThat(ranges.minimum, equalTo(0));
        }
        
        [Test]
        public function defaultMaximumIs100():void
        {
            assertThat(ranges.maximum, equalTo(100));
        }
        
        [Test]
        public function defaultSnapIntervalIs1():void
        {
            assertThat(ranges.snapInterval, equalTo(1));
        }
        
        [Test]
        public function defaultAllowOverlapIsFalse():void
        {
            assertThat(ranges.allowOverlap, isFalse());
        }
    }
}
