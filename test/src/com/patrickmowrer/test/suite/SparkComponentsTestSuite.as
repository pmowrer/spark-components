package com.patrickmowrer.test.suite
{
    import com.patrickmowrer.components.test.SliderBaseTest;
    import com.patrickmowrer.components.test.SliderDefaultsTest;
    import com.patrickmowrer.components.test.ThumbConstraintTest;
    import com.patrickmowrer.components.test.ThumbPropertySettingTest;
    import com.patrickmowrer.components.test.ValueRangeTest;
    import com.patrickmowrer.layouts.test.ValueLayoutBaseDefaultsTest;
    import com.patrickmowrer.layouts.test.HorizontalValueLayoutTest;
    
    [Suite]
    [RunWith("org.flexunit.runners.Suite")]
    public class SparkComponentsTestSuite
    {
        public var test1:SliderBaseTest;
        public var test2:SliderDefaultsTest;
        public var test3:ThumbConstraintTest;
        public var test4:ThumbPropertySettingTest;
        public var test5:ValueRangeTest;
        public var test6:HorizontalValueLayoutTest;
        public var test7:ValueLayoutBaseDefaultsTest;
    }
}