package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.SlidersBase;
    
    import flashx.textLayout.debug.assert;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.morefluent.integrations.flexunit4.*;
    
    import spark.components.supportClasses.Range;

    public class SlidersPropertySettingTest
    {		
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var sliders:SlidersBase;
        
        [Before(async, ui)]
        public function setUp():void
        {
            sliders = new SlidersBase();
            sliders.setStyle("skinClass", SlidersTestSkin);
            sliders.values = [0, 5, 10];
            sliders.minimum = 0;
            sliders.maximum = 10;
            
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
        public function slideDurationStylePropagatesToDynamicThumbSkinPart():void
        {
            sliders.setStyle("slideDuration", 2000);

            assertThat(sliders.getStyle("slideDuration"), equalTo(2000));
            
            for each(var range:Range in sliders.contentGroup)
            {
                assertThat(range.getStyle("slideDuration"), equalTo(2000));
            }
        }
        
        [Test(async)]
        public function minMaxAndSnapIntervalPropertiesAreAppliedToTrackSkinPart():void
        {
            sliders.minimum = 100;
            sliders.maximum = 10000;
            sliders.snapInterval = 100;
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders)
                .assert(sliders.track, "minimum").equals(100).and()
                .assert(sliders.track, "maximum").equals(10000).and()
                .assert(sliders.track, "snapInterval").equals(100);
        }
        
        [Test]
        public function ifNotAllowingOverlappingThumbsEachValueMustBeLimitedByNextIndexInValues():void
        {
            sliders.values[5, 10, 0];
            sliders.allowThumbOverlap = false;
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "values").equals([0, 1, 2]);
        }
        
        [Test]
        public function disallowingOverlappingThumbsAdjustsExistingValuesToBeLessThanNextIndex():void
        {
            
        }
    }
}