package com.patrickmowrer.layouts.test
{
    import com.patrickmowrer.layouts.HorizontalValueLayout;
    
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
        private var layout:HorizontalValueLayout;
        private var group:Group;
        
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        [Before(async, ui)]
        public function setUp():void
        {
            layout = new HorizontalValueLayout();
            layout.minimum = 0;
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
        public function positionsElementsHorizontallyBasedOnValueProperty():void
        {
            var value1:VisualElementWithValue = new VisualElementWithValue(5);
            var value2:VisualElementWithValue = new VisualElementWithValue(43);
            var value3:VisualElementWithValue = new VisualElementWithValue(68);
            
            group.width = 150;
            
            group.addElement(value1);
            group.addElement(value2);
            group.addElement(value3);
                        
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(value1, "x").equals(7.5).and()
                .assert(value2, "x").equals(64.5).and()
                .assert(value3, "x").equals(102);
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
        
        [Test(async)]
        public function translatesXCoordinateToValueBasedOnTargetWidthAndMinMax():void
        {
            group.width = 150;
            
            assertThat(layout.pointToValue(48, 0), equalTo(32));
        }
        
        [Test]
        public function elementPositionIsBoundedByMaximum():void
        {
            var value1:VisualElementWithValue = new VisualElementWithValue(153);
            
            group.width = 150;
            group.addElement(value1);
            
            after(FlexEvent.UPDATE_COMPLETE).on(group)
                .assert(value1, "x").equals(150);
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

import com.patrickmowrer.components.supportClasses.Value;

import mx.core.UIComponent;

internal class VisualElementWithValue extends UIComponent implements Value
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