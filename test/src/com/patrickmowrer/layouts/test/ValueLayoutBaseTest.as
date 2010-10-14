package com.patrickmowrer.layouts.test
{
    import com.patrickmowrer.layouts.supportClasses.ValueLayoutBase;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.assertThat;
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.hasProperty;
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