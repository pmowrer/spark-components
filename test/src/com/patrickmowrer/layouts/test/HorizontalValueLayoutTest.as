package com.patrickmowrer.layouts.test
{
    import com.patrickmowrer.layouts.HorizontalValueLayout;
    
    import flash.events.Event;
    import flash.geom.Point;
    
    import flexunit.framework.Test;
    
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    
    import org.flexunit.assertThat;
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasProperty;
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