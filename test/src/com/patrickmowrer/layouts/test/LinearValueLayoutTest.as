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
    import com.patrickmowrer.layouts.supportClasses.LinearValueLayout;
    
    import flash.geom.Point;
    
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.morefluent.integrations.flexunit4.MorefluentRule;
    import org.morefluent.integrations.flexunit4.after;
    
    import spark.components.Group;

    [RunWith("org.flexunit.runners.Parameterized")]
    public class LinearValueLayoutTest
    {	
        private var layout:LinearValueLayout;
        private var group:Group;
        
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        [Before(async, ui)]
        public function setUp():void
        {
            layout = new LinearValueLayout(new Point(0, 0), new Point(1, 1));

            group = new Group();
            group.setLayoutBoundsSize(200, 100);
            group.layout = layout;
            
            UIImpersonator.addChild(group);
            after(FlexEvent.UPDATE_COMPLETE).on(group).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(group);			
            group = null;
        }
        
        public static var translate:Array = [   
            // Point lies on line
            [new Point(0.0, 0.0), new Point(1, 1), 20, 90, 0, 100, 10], 
            [new Point(0.1, 0.1), new Point(0.9, 0.9), 80, 60, 0, 100, 37.5],
            [new Point(0.1, 0.9), new Point(0.9, 0.1), 60, 30, 0, 100, 25],
            // Point lies outside line but within container
            [new Point(0.0, 0.0), new Point(1, 1), 20, 10, 0, 100, 10], 
            [new Point(0.0, 0.0), new Point(1, 1), 100, 90, 0, 100, 50], 
            // Point lies outside container
            [new Point(0.0, 0.0), new Point(1, 1), 20, 101, 0, 100, 10]  ];
        
        [Test(dataProvider="translate")]
        public function translatesContainerRelativeCoordinateToValue(start:Point, end:Point, containerX:Number, containerY:Number,
             min:Number, max:Number, expected:Number):void
        {   
            layout = new LinearValueLayout(start, end);
            layout.minimum = min;
            layout.maximum = max;
            group.layout = layout;
            
            assertThat(layout.pointToValue(new Point(containerX, containerY)), equalTo(expected));
        }
        
        [Test(async)]
        public function positionsElementAtXEquals0IfElementWidthIsGreaterThanContainerWidth():void
        {
            var element:IVisualElement = new VisualElementWithValue(40);
            
            element.setLayoutBoundsSize(100, 0);
            group.width = 10;
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "x").equals(0);
        }
        
        [Test]
        public function positionsElementAtYEquals0IfElementHeightIsGreaterThanContainerHeight():void
        {
            var element:IVisualElement = new VisualElementWithValue(40);
            
            element.setLayoutBoundsSize(0, 100);
            group.height = 10;
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "y").equals(0);
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