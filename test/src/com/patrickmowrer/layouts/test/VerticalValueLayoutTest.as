package com.patrickmowrer.layouts.test
{
    import com.patrickmowrer.layouts.VerticalValueLayout;
    
    import flash.events.Event;
    
    import flexunit.framework.Test;
    
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.flexunit.runners.Parameterized;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasProperty;
    import org.morefluent.integrations.flexunit4.*;
    
    import spark.components.Group;

    [RunWith("org.flexunit.runners.Parameterized")]
    public class VerticalValueLayoutTest
    {		
        private var paramaterized:Parameterized;
        
        private var layout:VerticalValueLayout;
        private var group:Group;
        private var element:IVisualElement;
        
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        [Before(async, ui)]
        public function setUp():void
        {
            layout = new VerticalValueLayout();
            
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
                                                [-12, -15, -5, 1, 100, 69.5], 
                                                [0.4523, 0, 1, 0.5522, 100, 54.45]  ];
        
        /** With the vertical layout, max and min are seemingly reversed because the max value is typically
        *   represented with a lower-value y-coordinate than the min value. */
        [Test(dataProvider="positional")]
        public function positionsElementCenterVerticallyWithRespectToItsValuePropertyInRelationToBounds
                            (value:Number, min:Number, max:Number, elementHeight:Number, targetHeight:Number, expected:Number):void
        {
            element = new VisualElementWithValue(value);
            
            layout.minimum = min;
            layout.maximum = max;
            element.setLayoutBoundsSize(0, elementHeight);
            group.height = targetHeight;
            group.addElement(element);
                        
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "y").equals(expected);
        }
        
        [Test]
        public function positionsElementAtContainerHeightIfElementHeightIsGreaterThanContainerHeight():void
        {
            element = new VisualElementWithValue(40);
            
            element.setLayoutBoundsSize(0, 100);
            group.height = 10;
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "y").equals(10);
        }
        
        public static var boundedByMax:Array = [	[100, 0, 20, 100, 0], 
                                                    [0, -15, -5, 0.95, 0], 
                                                    [0.4523, 0, 0.1, 0.55, 0]  ];
        
        [Test(dataProvider="boundedByMax")]
        public function elementPositionIsBoundedByMaximum
            (value:Number, min:Number, max:Number, targetHeight:Number, expected:Number):void
        {
            element = new VisualElementWithValue(value);
            
            layout.minimum = min;
            layout.maximum = max;
            group.setLayoutBoundsSize(0, targetHeight);
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "y").equals(expected);
        }
        
        public static var boundedByMin:Array = [	[5, 5.1, 20, 0, 0], 
                                                    [-15.1, -15, -5, 0.95, 0.95], 
                                                    [0.4523, 0.55, 0.65, 1, 1]  ];
        
        [Test(dataProvider="boundedByMin")]
        public function elementPositionIsBoundedByMinimum
            (value:Number, min:Number, max:Number, targetHeight:Number, expected:Number):void
        {
            element = new VisualElementWithValue(value);
            
            layout.minimum = min;
            layout.maximum = max;
            group.setLayoutBoundsSize(0, targetHeight);
            group.addElement(element);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(element, "y").equals(expected);
        }
        
        public static var translate:Array = [	[10, 100, 0, 20, 18], 
                                                [15,  100, -15, -5, -6.5], 
                                                [48.3234287352537, 100, 20, 160, 92.34719977064482] ];
        
        [Test(dataProvider="translate")]
        public function translatesContainerRelativeYCoordinateToValue
            (y:Number, targetHeight:Number, min:Number, max:Number, expected:Number):void
        {   
            layout.minimum = min;
            layout.maximum = max;
            group.setLayoutBoundsSize(0, targetHeight);
            
            assertThat(layout.pointToValue(0, y), equalTo(expected));
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