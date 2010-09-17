package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.Ranges;
    
    import flash.events.Event;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;
    
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.object.equalTo;

    public class RangesDefaultsTest
    {		
        private var ranges:Ranges;
        
        [Before(async, ui)]
        public function setUp():void
        {
            ranges = new Ranges();
            ranges.setStyle("skinClass", RangesTestSkin);
            
            Async.proceedOnEvent(this, ranges, FlexEvent.CREATION_COMPLETE, 25);
            Async.proceedOnEvent(this, ranges, FlexEvent.UPDATE_COMPLETE, 50);
            UIImpersonator.addChild(ranges);
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(ranges);			
            ranges = null;
        }
        
        [Test(async)]
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
    }
}
