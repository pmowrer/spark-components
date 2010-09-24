package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.Ranges;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.async.Async;
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.*;
    import org.hamcrest.collection.array;
    import org.hamcrest.object.hasProperties;
    import org.morefluent.integrations.flexunit4.*;

    public class RangesPropertySettingTest
    {		
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var ranges:Ranges;
        
        [Before(async, ui)]
        public function setUp():void
        {
            ranges = new Ranges();
            ranges.setStyle("skinClass", RangesTestSkin);
            ranges.values = [-2, 3, 6, 9, 12];
            ranges.minimum = -2;
            ranges.maximum = 12;
            // Not explicitly setting snapInterval here because its a special case 
            
            UIImpersonator.addChild(ranges);
            after(FlexEvent.UPDATE_COMPLETE).on(ranges).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(ranges);			
            ranges = null;
        }
        
        [Test(async)]
        public function setPropertiesCanBeRetrievedImmediately():void
        {
            ranges.values = [99, 999, 9999];
            ranges.minimum = 99;
            ranges.maximum = 9999;
            
            assertThat(ranges, hasProperties(
                {
                    "values": array(99, 999, 9999),
                    "minimum": 99,
                    "maximum": 9999
                }));
        }
        
        [Test(async)]
        public function valuesOutsideOfMinMaxRangeAreAdjustedToNearestValidValue():void
        {   
            ranges.values = [-4, 3, 15];
            
            after(FlexEvent.UPDATE_COMPLETE).on(ranges).assert(ranges, "values").equals([-2, 3, 12]);
        }
        
        [Test(async)]
        public function changeToValuesCausesValueCommitEventToBeDispatchedOnce():void
        {
            observing(FlexEvent.VALUE_COMMIT).on(ranges);
            
            ranges.values = [1, 2, 3];

            after(FlexEvent.UPDATE_COMPLETE).on(ranges)
                .assert(ranges).observed(FlexEvent.VALUE_COMMIT, times(1));
        }
        
        [Test(async)]
        public function minChangeAdjustsAnyOutOfRangeValuesToNearestValidValue():void
        {
            ranges.minimum = 7;
            
            after(FlexEvent.UPDATE_COMPLETE).on(ranges).assert(ranges, "values").equals([7, 7, 7, 9, 12]);
        }
        
        [Test(async)]
        public function maxChangeAdjustsAnyOutOfRangeValuesToNearestValidValue():void
        {
            ranges.maximum = 6;
            
            after(FlexEvent.UPDATE_COMPLETE).on(ranges).assert(ranges, "values").equals([-2, 3, 6, 6, 6]);
        }
        
        [Test(async)]
        public function ifMaxIsSetSmallerThanMinFormerIsAdjustedEqualToLatter():void
        {
            ranges.maximum = -4;
            
            after(FlexEvent.UPDATE_COMPLETE).on(ranges).assert(ranges, "maximum").equals(-2);
        }
        
        [Test(async)]
        public function ifMinIsSetLargerThanMaxFormerIsAdjustedEqualToLatter():void
        {
            ranges.minimum = 14;
            
            after(FlexEvent.UPDATE_COMPLETE).on(ranges).assert(ranges, "minimum").equals(12);
        }
        
        [Test(async)]
        public function valuesAreAdjustedToBeMultiplesOfSnapIntervalUnlessTheyAreEitherMinOrMax():void
        {
            ranges.snapInterval = 3;
            
            after(FlexEvent.UPDATE_COMPLETE).on(ranges).assert(ranges, "values").equals([-2, 4, 7, 10, 12]);
        }
    }
}