package com.patrickmowrer.components.test
{
    import com.patrickmowrer.components.supportClasses.SliderBase2;
    import com.patrickmowrer.components.supportClasses.Thumb;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.morefluent.integrations.flexunit4.*;

    public class SliderBaseTest
    {
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule();
        
        private var slider:SliderBase2;
        
        [Before(async, ui)]
        public function setUp():void
        {
            slider = new SliderBase2();
            slider.thumb = new ThumbFactory();
            
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
        public function createsAThumbForEveryValueInValuesProperty():void
        {
            slider.values = [10, 20, 30];
            
            after(FlexEvent.UPDATE_COMPLETE).on(slider).call(verifyThumbs, slider, slider.values);
            
            function verifyThumbs(slider:SliderBase2, values:Array):void
            {
                for(var index:int = 0; index < slider.numElements; index++)
                {
                    var thumb:Thumb = Thumb(slider.getElementAt(index));
                    
                    assertThat(thumb.value, equalTo(values[index]));
                }
            }           
        }
    }
}

import com.patrickmowrer.components.supportClasses.Thumb;

import mx.core.IFactory;

internal class ThumbFactory implements IFactory
{
    public function newInstance():*
    {
        return new Thumb();
    }
}