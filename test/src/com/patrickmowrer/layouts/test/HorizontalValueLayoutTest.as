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
    import com.patrickmowrer.layouts.HorizontalValueLayout;
    
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.morefluent.integrations.flexunit4.*;
    
    import spark.components.Group;

    [RunWith("org.flexunit.runners.Parameterized")]
    public class HorizontalValueLayoutTest
    {		
        private var layout:HorizontalValueLayout;
        private var group:Group;
        private var element:IVisualElement;
        
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        [Before(async, ui)]
        public function setUp():void
        {
            layout = new HorizontalValueLayout();
            
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
        
        public static var positional:Array = [	[10, 0, 20, 0, 100, 50], 
                                                [10, 0, 10, 11, 100, 89], 
                                                [-12, -15, -5, 1, 100, 29.7], 
                                                [0.4523, 0, 1, 1.52, 100, 44.5] ];
        
        [Test(dataProvider="positional")]
        public function positionsElementCenterHorizontallyWithRespectToItsValuePropertyInRelationToBounds
            (value:Number, min:Number, max:Number, elementWidth:Number, containerWidth:Number, expected:Number):void
        {
            element = new VisualElementWithValue(value);
            
            layout.minimum = min;
            layout.maximum = max;
            element.setLayoutBoundsSize(elementWidth, 0);
            group.width = containerWidth;
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "x").equals(expected);
        }
        
        public static var boundedByMax:Array = [	[100, 0, 20, 123.45, 123.45], 
                                                    [0, -15, -5, 0.95, 0.95], 
                                                    [0.4523, 0, 0.1, 0.55, 0.55]  ];
        
        [Test(dataProvider="boundedByMax")]
        public function elementPositionIsBoundedByMaximum
            (value:Number, min:Number, max:Number, targetWidth:Number, expected:Number):void
        {
            element = new VisualElementWithValue(value);
            
            layout.minimum = min;
            layout.maximum = max;
            group.setLayoutBoundsSize(targetWidth, 0);
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "x").equals(expected);
        }
        
        public static var boundedByMin:Array = [	[4.9, 5.0, 20, 1, 0], 
                                                    [-15.1, -15, -5, 0.95, 0], 
                                                    [0.4523, 0.55, 0.65, 1, 0]  ];
        
        [Test(dataProvider="boundedByMin")]
        public function elementPositionIsBoundedByMinimum
            (value:Number, min:Number, max:Number, targetWidth:Number, expected:Number):void
        {
            element = new VisualElementWithValue(value);
            
            layout.minimum = min;
            layout.maximum = max;
            group.setLayoutBoundsSize(targetWidth, 0);
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "x").equals(expected);
        }
    }
}

import com.patrickmowrer.components.supportClasses.ValueCarrying;

import mx.core.UIComponent;

internal class VisualElementWithValue extends UIComponent implements ValueCarrying
{
    private var _value:Number;
    
    public function VisualElementWithValue(value:Number)
    {
        super();
        
        _value = value;
    }
    
    public function get value():Number
    {
        return _value;
    }
    
    public function set value(value:Number):void
    {
        _value = value;
    }
}