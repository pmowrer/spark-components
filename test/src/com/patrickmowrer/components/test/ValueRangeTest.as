/**
 * The MIT License
 *
 * Copyright (c) 2011 Patrick Mowrer
 *  
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.ValueRange;
    
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
        public function calculatesFractionOfTheWholeRangeThatAValueRepresents():void
        {
            valueRange.minimum = 0;
            valueRange.maximum = 1;
            valueRange.snapInterval = 0;
            
            assertThat(valueRange.getNearestValidRatioFromValue(0.4523), equalTo(0.4523));
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
        
        [Test]
        public function returnsValidRatioWhenMinAndMaxAreSameNumber():void
        {
            valueRange.minimum = 100;
            valueRange.maximum = 100;
            
            assertThat(valueRange.getNearestValidRatioFromValue(100), equalTo(0));
        }
    }
}