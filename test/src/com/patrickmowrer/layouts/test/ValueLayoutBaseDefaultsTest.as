package com.patrickmowrer.layouts.test
{
    import com.patrickmowrer.layouts.supportClasses.ValueLayoutBase;
    
    import mx.events.FlexEvent;
    
    import org.flexunit.rules.IMethodRule;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.hamcrest.assertThat;
    import org.hamcrest.object.equalTo;
    import org.morefluent.integrations.flexunit4.*;
    
    import spark.components.supportClasses.GroupBase;

    public class ValueLayoutBaseDefaultsTest
    {		
        private var layout:ValueLayoutBase;
        private var group:GroupBase;
        
        [Rule]
        public var morefluentRule:IMethodRule = new MorefluentRule(); 
        
        [Before(async, ui)]
        public function setUp():void
        {
            layout = new ValueLayoutBase();
            layout.minimum = 0;
            layout.maximum = 100;
            
            group = new GroupBase();
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
        public function defaultMinimumIs0():void
        {
            assertThat(layout.minimum, equalTo(0));
        }
        
        [Test]
        public function defaultMaximumIs100():void
        {
            assertThat(layout.maximum, equalTo(100));
        }
    }
}