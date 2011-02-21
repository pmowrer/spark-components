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
    import com.patrickmowrer.layouts.HorizontalValueLayoutAlign;
    import com.patrickmowrer.layouts.supportClasses.LinearValueLayout;
    
    import flash.geom.Point;
    
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.core.both;
    import org.hamcrest.object.equalTo;
    import org.morefluent.integrations.flexunit4.MorefluentRule;
    import org.morefluent.integrations.flexunit4.after;
    
    import spark.components.Group;

    [RunWith("org.flexunit.runners.Parameterized")]
    public class LinearValueLayoutTest
    {	
        private var layout:LinearValueLayout;
        private var group:Group;
        private var element:IVisualElement
        
        private static const GROUP_WIDTH:Number = 200;
        private static const GROUP_HEIGHT:Number = 100;
        
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        [Before(async, ui)]
        public function setUp():void
        {
            group = new Group();
            group.setLayoutBoundsSize(GROUP_WIDTH, GROUP_HEIGHT);
            
            layout = new LinearValueLayout(new Point(0,0), new Point(1, 1));
            layout.minimum = 0;
            layout.maximum = 100;
            layout.elementAlignment = HorizontalValueLayoutAlign.RIGHT;
            
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
        
        public static var positional:Array = [	
        // value,    start,          end,       min, max,  expectedPoint
            [10, new Point(0, 0), new Point(1, 1), 0, 100, new Point(20, 10)]
        ];
        
        [Test(dataProvider="positional")]
        public function positionsElementInContainerWithinGivenBoundsAccordingToValue
            (value:Number, start:Point, end:Point, min:Number, max:Number, expected:Point):void
        {
            element = new VisualElementWithValue(value);
            // Don't let element size affect this test
            element.setLayoutBoundsSize(0, 0);
            
            layout = new LinearValueLayout(start, end);
            layout.minimum = min;
            layout.maximum = max;
            
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "x").equals(expected.x).and()
                .assert(element, "y").equals(expected.y);
        }
        
        public static var alignment:Array = [	
        //  elementWidth,   elementHeight,  elementOffsetRatio,      expected
            [10,            10,             new Point(0, 0),         new Point(0, 0)],
            [10,            10,             new Point(-0.5, -0.5),   new Point(-5, -5)  ]
        ];
        
        [Test(dataProvider="alignment")]
        public function offsetsElementFromTopLeftOriginInAnyDirectionAccordingToRatio
             (elementWidth:Number, elementHeight:Number, elementOffsetRatio:Point, expected:Point):void
        {
             // Don't let value affect this test
            element = new VisualElementWithValue(0);
            element.setLayoutBoundsSize(elementWidth, elementHeight);
            
            layout.elementAlignment = elementOffsetRatio;
            
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "x").equals(expected.x).and()
                .assert(element, "y").equals(expected.y);
        }
        
        public static var translateToValue:Array = [   
            // Point lies on line
            [new Point(0.0, 0.0), new Point(1, 1), new Point(20, 10), 10], 
            [new Point(0.1, 0.1), new Point(0.9, 0.9), new Point(80, 40), 37.5],
            [new Point(0.1, 0.9), new Point(0.9, 0.1), new Point(60, 70), 25],
            // Point lies outside line but within container
            [new Point(0.0, 0.0), new Point(1, 1), new Point(20, 10), 10], 
            [new Point(0.0, 0.0), new Point(1, 1), new Point(100, 50), 50], 
            // Point lies outside container
            [new Point(0.0, 0.0), new Point(1, 1), new Point(20, 101), 10]  ];
        
        [Test(dataProvider="translateToValue")]
        public function translatesContainerRelativeCoordinateToValue
            (start:Point, end:Point, containerCoord:Point, expected:Number):void
        {   
            layout = new LinearValueLayout(start, end);
            group.layout = layout;
            
            assertThat(layout.pointToValue(containerCoord), equalTo(expected));
        }
        
        public static var translateToPoint:Array = [   
            [10, new Point(0.0, 0.0), new Point(1, 1), new Point(20, 10)], 
            [37.5, new Point(0.1, 0.1), new Point(0.9, 0.9), new Point(80, 40)],
            [25, new Point(0.1, 0.9), new Point(0.9, 0.1), new Point(60, 70)],
            [10, new Point(0.0, 0.0), new Point(1, 1), new Point(20, 10)], 
            [50, new Point(0.0, 0.0), new Point(1, 1), new Point(100, 50)], 
            // Value is outside min-max range
            [101, new Point(0.0, 0.0), new Point(1, 1), new Point(200, 100)]  ];
        
        [Test(dataProvider="translateToPoint")]
        public function translatesValueToContainerRelativeCoordinate
            (value:Number, start:Point, end:Point, expected:Point):void
        {   
            layout = new LinearValueLayout(start, end);
            group.layout = layout;
            
            assertThat(layout.valueToPoint(value).x, equalTo(expected.x));
            assertThat(layout.valueToPoint(value).y, equalTo(expected.y));
        }
        
        public static var boundedByMin:Array = [	
            [4.9, 5.0, 20, 1, 1, new Point(0, 0)], 
            [-15.1, -15, -5, 0.95, 0.15, new Point(0, 0)], 
            [0.4523, 0.55, 0.65, 1, 1, new Point(0, 0)]  ];
        
        [Test(dataProvider="boundedByMin")]
        public function elementPositionIsBoundedByMinimum
            (value:Number, min:Number, max:Number, targetWidth:Number, targetHeight:Number, expected:Point):void
        {
            element = new VisualElementWithValue(value);
            
            layout.minimum = min;
            layout.maximum = max;
            
            group.setLayoutBoundsSize(targetWidth, targetHeight);
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "x").equals(expected.x).and()
                .assert(element, "y").equals(expected.y);
        }
        
        public static var boundedByMax:Array = [	
            [100, 0, 20, 123.45, 123.45, new Point(123.45, 123.45)], 
            [0, -15, -5, 0.95, 1.15, new Point(0.95, 1.15)], 
            [0.4523, 0, 0.1, 0.55, 10, new Point(0.55, 10)]  ];
        
        [Test(dataProvider="boundedByMax")]
        public function elementPositionIsBoundedByMaximum
            (value:Number, min:Number, max:Number, targetWidth:Number, targetHeight:Number, expected:Point):void
        {
            element = new VisualElementWithValue(value);
            
            layout.minimum = min;
            layout.maximum = max;
            
            group.setLayoutBoundsSize(targetWidth, targetHeight);
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "x").equals(expected.x).and()
                .assert(element, "y").equals(expected.y);
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