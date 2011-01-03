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

package com.patrickmowrer.layouts.test
{
    import com.patrickmowrer.layouts.supportClasses.ValueLayoutBase;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.assertThat;
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.object.equalTo;
    import org.morefluent.integrations.flexunit4.*;
    
    import spark.components.Group;

    public class ValueLayoutBaseTest
    {		
        private var layout:ValueLayoutBase;
        private var group:Group;
        
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        [Before(async, ui)]
        public function setUp():void
        {
            layout = new ValueLayoutBase();
            layout.minimum = 20;
            layout.maximum = 100;
            
            group = new Group();
            group.layout = layout;
            
            UIImpersonator.addChild(group);
            after(FlexEvent.UPDATE_COMPLETE).on(group).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(group);			
            group = null;
            layout = null;
        }
        
        [Test]
        public function settingMaximumSmallerThanMinimumAdjustsFormerToLatter():void
        {
            layout.maximum = -20;
            
            assertThat(layout.maximum, equalTo(layout.minimum));
        }
        
        [Test]
        public function settingMinimumGreaterThanMaximumAdjustsFormerToLatter():void
        {
            layout.minimum = 120;
            
            assertThat(layout.minimum, equalTo(layout.maximum));
        }

        [Test(async)]
        public function changeToMinimumPropertyInvalidatesTargetDisplayList():void
        {
            layout.minimum = 10;
            
            after(FlexEvent.UPDATE_COMPLETE).on(group).pass();
        }
        
        [Test(async)]
        public function changeToMaximumPropertyInvalidatesTargetDisplayList():void
        {
            layout.maximum = 120;
            
            after(FlexEvent.UPDATE_COMPLETE).on(group).pass();
        }
    }
}