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
    import com.patrickmowrer.components.supportClasses.SliderThumb;
    import com.patrickmowrer.skins.SliderThumbSkin;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.morefluent.integrations.flexunit4.*;

    public class ThumbConstraintTest
    {
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        private var thumb1:SliderThumb;
        private var thumb2:SliderThumb;
        
        [Before(async, ui)]
        public function setUp():void
        {
            thumb1 = new SliderThumb();
            thumb2 = new SliderThumb();
            
            thumb1.setStyle("skinClass", SliderThumbSkin);
            thumb2.setStyle("skinClass", SliderThumbSkin);
            
            UIImpersonator.addChild(thumb1);
            UIImpersonator.addChild(thumb2);
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb1).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(thumb1);
            UIImpersonator.removeChild(thumb2);
            thumb1 = null;
            thumb2 = null;
        }
        
        [Test(async)]
        public function shouldConstrainMinimumToNearestMultipleOfSnapIntervalEqualOrGreaterThanOtherThumbsValue():void
        {
            thumb1.minimum = 7;
            thumb1.maximum = 13;
            thumb1.snapInterval = 4;
            thumb1.value = 11;
            
            thumb2.minimum = 0;
            thumb2.maximum = 6;
            thumb2.value = 2;
            
            thumb1.constrainMinimumTo(thumb2);
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb1)
                .assert(thumb1, "minimum").equals(3);
        }
        
        [Test(async)]
        public function shouldConstrainMaximumToNearestMultipleOfSnapIntervalEqualOrLessThanOtherThumbsValue():void
        {
            thumb1.minimum = -7;
            thumb1.maximum = 13;
            thumb1.snapInterval = 4.5;
            thumb1.value = 2;
            
            thumb2.minimum = 0;
            thumb2.maximum = 6;
            thumb2.value = 5;
            
            thumb1.constrainMaximumTo(thumb2);
            
            after(FlexEvent.UPDATE_COMPLETE).on(thumb1)
                .assert(thumb1, "maximum").equals(2);
        }
    }
}