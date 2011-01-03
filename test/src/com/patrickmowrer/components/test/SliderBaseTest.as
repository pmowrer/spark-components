package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.SliderBase;
    import com.patrickmowrer.components.supportClasses.SliderThumb;
    import com.patrickmowrer.layouts.supportClasses.ValueLayout;
    import com.patrickmowrer.skins.SliderThumbSkin;
    
    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.events.Event;
    
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    import mx.managers.IFocusManager;
    import mx.managers.IFocusManagerComponent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasProperties;
    import org.hamcrest.object.sameInstance;
    import org.morefluent.integrations.flexunit4.*;
    
    import spark.layouts.supportClasses.LayoutBase;

    public class SliderBaseTest
    {
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule();
        
        private var slider:SliderBase;
        private var skin:SliderThumbSkin;
        
        private var testValues:Array = [-5, 23, 47, 68, 89];
        
        [Before(async, ui)]
        public function setUp():void
        {
            slider = new SliderBase();
            slider.thumb = new ThumbFactory();
            slider.layout = new ValueBasedLayoutDummy();
            slider.minimum = -10;
            slider.maximum = 90;
            slider.values = testValues;
            
            UIImpersonator.addChild(slider);
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider).pass();
        }
        
        [After(async, ui)]
        public function tearDown():void
        {
            UIImpersonator.removeChild(slider);
            slider = null;
        }
        
        [Test(async)]
        public function setPropertiesCanBeRetrievedImmediately():void
        {
            slider.values = [99, 999, 9999];
            slider.minimum = 99;
            slider.maximum = 9999;
            slider.allowOverlap = true;
            
            assertThat(slider, hasProperties(
                {
                    "values": array(99, 999, 9999),
                    "minimum": 99,
                    "maximum": 9999,
                    "allowOverlap": true
                }));
        }
        
        [Test(async)]
        public function createsAThumbForEveryValueInValuesProperty():void
        {
            for(var index:int = 0; index < slider.values.length; index++)
            {
                var thumb:SliderThumb = SliderThumb(slider.getElementAt(index));
                
                assertThat(thumb.value, equalTo(testValues[index]));
            }
        }
        
        [Test(async)]
        public function givesFocusToEachThumb():void
        {
            var focusManager:IFocusManager = slider.focusManager;
            var nextFocus:IFocusManagerComponent;
            
            for(var index:int = 0; index < slider.numElements; index++)
            {
                nextFocus = focusManager.getNextFocusManagerComponent();
                assertThat(nextFocus, sameInstance(slider.getElementAt(index)));
                focusManager.setFocus(nextFocus);
            }
        }
        
        [Test(async)]
        public function slideDurationStyleIsPropagatedToThumbsOnCreation():void
        {
            slider.setStyle("slideDuration", 9999);
            slider.values = [1];
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider).call(thumbSlideDurationVerification, slider);
            
            function thumbSlideDurationVerification(slider:SliderBase):void
            {
                for(var index:int = 0; index < slider.numElements; index++)
                {
                    var thumb:SliderThumb = SliderThumb(slider.getElementAt(index));
                    
                    assertThat(thumb.getStyle("slideDuration"), equalTo(9999));
                }                
            }
        }
        
        [Test(async)]
        public function dispatchesValueCommitEventOnceWhenValuesChange():void
        {
            observing(FlexEvent.VALUE_COMMIT).on(slider);
            
            slider.values = [1, 2, 3];
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider)
                .assert(slider).observed(FlexEvent.VALUE_COMMIT, times(1));
        }
        
        [Test(async)]
        public function dispatchesChangeEventOnceWhenValuesChange():void
        {
            slider.values = [1, 2, 3];
            
            after(Event.CHANGE).on(slider).pass();
        }
        
        [Test(async)]
        public function dispatchesChangeEventWhenThumbValueChanges():void
        {
            var thumb:SliderThumb = SliderThumb(slider.getElementAt(0));
            thumb.value = 55;
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider).pass();
        }
        
        [Test(async)]
        public function valuesOutsideOfMinMaxRangeAreAdjustedToNearestValidValue():void
        {   
            slider.values = [-20, 50, 115];
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider)
                .assert(slider, "values").equals([-10, 50, 90]);
        }
        
        [Test(async)]
        public function minChangeAdjustsAnyOutOfRangeValuesToNearestValidValue():void
        {
            slider.minimum = 50;
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider)
                .assert(slider, "values").equals([50, 50, 50, 68, 89]);
        }
        
        [Test(async)]
        public function maxChangeAdjustsAnyOutOfRangeValuesToNearestValidValue():void
        {
            slider.maximum = -1;
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider)
                .assert(slider, "values").equals([-5, -1, -1, -1, -1]);
        }
        
        [Test(async)]
        public function overlappingValuesAreSortedWhenOverlapIsntAllowed():void
        {
            slider.allowOverlap = false;
            slider.values = [5, 10, 2];
            
            after(Event.CHANGE).on(slider)
                .assert(slider, "values").equals([2, 5, 10]);
        }
        
        [Test(async)]
        public function allowsOverlappingValues():void
        {
            slider.allowOverlap = true;
            slider.values = [5, 10, 2];
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider).assert(slider, "values").equals([5, 10, 2]);
        }
        
        [Test(async)]
        public function valuesAreAdjustedNearestMultiplesOfSnapInterval():void
        {
            slider.snapInterval = 4;
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider).assert(slider, "values").equals([-6, 22, 46, 70, 90]);
        }        
    }
}

import com.patrickmowrer.components.supportClasses.SliderThumb;
import com.patrickmowrer.layouts.supportClasses.ValueLayout;
import com.patrickmowrer.skins.SliderThumbSkin;

import flash.geom.Point;
import flash.net.registerClassAlias;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.core.IFactory;
import mx.core.IVisualElement;

import spark.layouts.supportClasses.LayoutBase;

internal class ThumbFactory implements IFactory
{
    public var skin:SliderThumbSkin;
    public function newInstance():*
    {
        var sliderThumb:SliderThumb = new SliderThumb();
        sliderThumb.setStyle("skinClass", SliderThumbSkin);
        
        return sliderThumb;
    }
}

internal class ValueBasedLayoutDummy extends LayoutBase implements ValueLayout
{
    private var _min:Number;
    private var _max:Number;
    
    public function get minimum():Number
    {
        return _min;
    }
    
    public function set minimum(value:Number):void
    {
        _min = value;
    }
    
    public function get maximum():Number
    {
        return _max;
    }
    
    public function set maximum(value:Number):void
    {
        _max = value;
    }
    
    public function pointToValue(point:Point):Number
    {
        return 0;
    }
}