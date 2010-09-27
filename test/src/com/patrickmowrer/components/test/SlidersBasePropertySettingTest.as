package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.SlidersBase;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.async.Async;
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasProperties;
    import org.morefluent.integrations.flexunit4.*;
    
    import spark.components.supportClasses.SliderBase;

    public class SlidersBasePropertySettingTest
    {		
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var sliders:SlidersBase;
        
        [Before(async, ui)]
        public function setUp():void
        {
            sliders = new SlidersBase();
            sliders.setStyle("skinClass", SlidersTestSkin);
            sliders.values = [-2, 3, 6, 9, 12];
            sliders.minimum = -2;
            sliders.maximum = 12;
            // Not explicitly setting snapInterval here because its a special case 
            
            UIImpersonator.addChild(sliders);
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(sliders);			
            sliders = null;
        }
        
        [Test(async)]
        public function setPropertiesCanBeRetrievedImmediately():void
        {
            sliders.values = [99, 999, 9999];
            sliders.minimum = 99;
            sliders.maximum = 9999;
            sliders.allowOverlap = true;
            
            assertThat(sliders, hasProperties(
                {
                    "values": array(99, 999, 9999),
                    "minimum": 99,
                    "maximum": 9999,
                    "allowOverlap": true
                }));
        }
        
        [Test(async)]
        public function valuesOutsideOfMinMaxRangeAreAdjustedToNearestValidValue():void
        {   
            sliders.values = [-4, 3, 15];
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "values").equals([-2, 3, 12]);
        }
        
        [Test(async)]
        public function changeToValuesCausesValueCommitEventToBeDispatchedOnce():void
        {
            observing(FlexEvent.VALUE_COMMIT).on(sliders);
            
            sliders.values = [1, 2, 3];

            after(FlexEvent.UPDATE_COMPLETE).on(sliders)
                .assert(sliders).observed(FlexEvent.VALUE_COMMIT, times(1));
        }
        
        [Test(async)]
        public function minChangeAdjustsAnyOutOfRangeValuesToNearestValidValue():void
        {
            sliders.minimum = 7;
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "values").equals([7, 7, 7, 9, 12]);
        }
        
        [Test(async)]
        public function maxChangeAdjustsAnyOutOfRangeValuesToNearestValidValue():void
        {
            sliders.maximum = 6;
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "values").equals([-2, 3, 6, 6, 6]);
        }
        
        [Test(async)]
        public function ifMaxIsSetSmallerThanMinFormerIsAdjustedEqualToLatter():void
        {
            sliders.maximum = -4;
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "maximum").equals(-2);
        }
        
        [Test(async)]
        public function ifMinIsSetLargerThanMaxFormerIsAdjustedEqualToLatter():void
        {
            sliders.minimum = 14;
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "minimum").equals(12);
        }
        
        [Test(async)]
        public function valuesAreAdjustedToBeMultiplesOfSnapIntervalUnlessTheyAreEitherMinOrMax():void
        {
            sliders.snapInterval = 3;
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "values").equals([-2, 4, 7, 10, 12]);
        }
        
        [Test(async)]
        public function overlappingValuesAreAdjustedWhenOverlapIsntAllowed():void
        {
            sliders.allowOverlap = false;
            sliders.values = [5, 10, 2];
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "values").equals([2, 2, 2]);
        }
        
        [Test]
        public function overlappingValuesCanBeAllowed():void
        {
            sliders.allowOverlap = true;
            sliders.values = [5, 10, 2];
            
            after(FlexEvent.UPDATE_COMPLETE).on(sliders).assert(sliders, "values").equals([5, 10, 2]);
        }
           
        [Test]
        public function slideDurationStylePropagatesToDynamicThumbSkinPart():void
        {
            sliders.setStyle("slideDuration", 2000);
            
            assertThat(sliders.getStyle("slideDuration"), equalTo(2000));
            
            for each(var slider:SliderBase in sliders.contentGroup)
            {
                assertThat(slider.getStyle("slideDuration"), equalTo(2000));
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
    }
}