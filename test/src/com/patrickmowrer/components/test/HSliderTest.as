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
    import com.patrickmowrer.components.HSlider;
    import com.patrickmowrer.components.supportClasses.SliderBase;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.hasProperties;
    import org.morefluent.integrations.flexunit4.*;

    public class HSliderTest
    {
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule();
        
        private var slider:SliderBase;
        
        [Before(async, ui)]
        public function setUp():void
        {
            slider = new HSlider();
            
            UIImpersonator.addChild(slider);
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(slider);
            slider = null;
        }
        
        /**  There was a bug where setting minimum to something greater
             than the maximum would limit the minimum to whatever the
             maximum was, even if the maximum was increased at the same
             time.
        **/
        [Test(async)]
        public function previousMaximumShouldntInterfereWithSettingMinimum():void
        {
            slider.minimum = 101;
            slider.maximum = 200;
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider)
                .assert(slider, "minimum").equals(101)
                .and().assert(slider, "maximum").equals(200);
        }
        
        [Test(async)]
        public function previousMinimumShouldntInterfereWithSettingMaximum():void
        {
            slider.minimum = -100;
            slider.maximum = -1;

            after(FlexEvent.UPDATE_COMPLETE).on(slider)
                .assert(slider, "minimum").equals(-100)
                .and().assert(slider, "maximum").equals(-1);
        }
    }
}