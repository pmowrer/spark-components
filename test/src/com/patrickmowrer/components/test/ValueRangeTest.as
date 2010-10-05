package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.ValueRange;
    
    import flash.events.Event;
    
    import org.flexunit.rules.IMethodRule;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.morefluent.integrations.flexunit4.*;

    public class ValueRangeTest
    {	
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule();
        
        private var valueRange:ValueRange;
        
        [Before]
        public function setUp():void
        {
            valueRange = new ValueRange(0, 100, 1);
        }
        
        [Test]
        public function minimumCannotBeSetGreaterThanMaximum():void
        {
            valueRange.minimum = 999999999;
            
            assertThat(valueRange.minimum, equalTo(valueRange.maximum));
        }
        
        [Test]
        public function maximumCannotBeSetLowerThanMinimum():void
        {
            valueRange.maximum = -40;
            
            assertThat(valueRange.maximum, equalTo(valueRange.minimum));
        }
        
        [Test]
        public function floatingPointNumberIsPreservedWhenIntervalIs0():void
        {
            var floatingPoint:Number = 1.22354565637589688569;
            
            valueRange.snapInterval = 0;
            
            assertThat(valueRange.getNearestValidValueTo(floatingPoint), equalTo(floatingPoint));
        }
        
        [Test]
        public function floatingPointNumberIsRoundedToNearestMultipleOfAnIntervalGreaterThan0():void
        {
            var floatingPoint:Number = 1.22354565637589688569;
            
            valueRange.snapInterval = 2;
            
            assertThat(valueRange.getNearestValidValueTo(floatingPoint), equalTo(valueRange.snapInterval));
        }      
        
        [Test]
        public function roundsValueToNearestLesserSnapIntervalValue():void
        {
            valueRange.minimum = -3;
            valueRange.snapInterval = 5;
            
            assertThat(valueRange.roundToNearestLesserInterval(-3.000001), equalTo(-8));
            assertThat(valueRange.roundToNearestLesserInterval(-3), equalTo(-3));
            assertThat(valueRange.roundToNearestLesserInterval(6.999999), equalTo(2));
        }
        
        [Test]
        public function roundsValueToNearestGreaterSnapIntervalValue():void
        {
            valueRange.minimum = 7;
            valueRange.snapInterval = 4;
            
            assertThat(valueRange.roundToNearestGreaterInterval(7.00000001), equalTo(11));
            assertThat(valueRange.roundToNearestGreaterInterval(7), equalTo(7));
            assertThat(valueRange.roundToNearestGreaterInterval(-3.999999), equalTo(-1));        
        }
    }
}