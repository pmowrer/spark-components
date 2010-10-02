package com.patrickmowrer.layouts.test
{
    import com.patrickmowrer.layouts.HorizontalValueLayout;
    
    import flash.events.Event;
    
    import flexunit.framework.Test;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.assertThat;
    import org.flexunit.rules.IMethodRule;

    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasProperty;
    import org.morefluent.integrations.flexunit4.*;
    
    import spark.components.Group;

    public class HorizontalValueLayoutTest
    {		
        private const WIDTH:Number = 160;
        
        private var layout:HorizontalValueLayout;
        private var group:Group;
        
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        [Before(async, ui)]
        public function setUp():void
        {
            layout = new HorizontalValueLayout();
            layout.minimum = 20;
            layout.maximum = 100;
            
            group = new Group();
            group.layout = layout;
            group.width = WIDTH;
            
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
        public function positionsElementsHorizontallyBasedOnValueProperty():void
        {
            var value1:VisualElementWithValue = new VisualElementWithValue(40);
            var value2:VisualElementWithValue = new VisualElementWithValue(44);
            var value3:VisualElementWithValue = new VisualElementWithValue(68);
            
            group.addElement(value1);
            group.addElement(value2);
            group.addElement(value3);
                        
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(value1, "x").equals(40).and()
                .assert(value2, "x").equals(48).and()
                .assert(value3, "x").equals(96);
        }
        
        [Test]
        public function elementIsCenterPositionedOverValue():void
        {
            var value:VisualElementWithValue = new VisualElementWithValue(40);
            value.setLayoutBoundsSize(20, 0);
            
            group.addElement(value);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(value, "x").equals(30);
        }
        
        [Test]
        public function positionsElementsWithNegativeValuesOnPositiveXCoordinate():void
        {
            var value1:VisualElementWithValue = new VisualElementWithValue(-5);
            
            layout.minimum = -10;
            group.width = 110;            
            group.addElement(value1);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(value1, "x").equals(5);
        }
        
        [Test]
        public function translatesXCoordinateToValueBasedOnTargetWidthAndMinMax():void
        {            
            assertThat(layout.pointToValue(48, 0), equalTo(44));
        }
        
        [Test]
        public function preservesFloatingPointXCoordinateInValue():void
        {            
            assertThat(layout.pointToValue(48.3234287352537, 0), equalTo(44.16171436762685));
        }
        
        [Test]
        public function elementPositionIsBoundedByMaximum():void
        {
            var value1:VisualElementWithValue = new VisualElementWithValue(153);
            
            group.addElement(value1);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(value1, "x").equals(WIDTH);
        }
        
        [Test]
        public function elementPositionIsBoundedByMinimum():void
        {
            var value1:VisualElementWithValue = new VisualElementWithValue(-40);
            
            group.width = 150;
            group.addElement(value1);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(value1, "x").equals(0);
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