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

package com.patrickmowrer.test.suite
{
    import com.patrickmowrer.components.test.SliderBaseTest;
    import com.patrickmowrer.components.test.SliderDefaultsTest;
    import com.patrickmowrer.components.test.ThumbConstraintTest;
    import com.patrickmowrer.components.test.ThumbPropertySettingTest;
    import com.patrickmowrer.components.test.ValueRangeTest;
    import com.patrickmowrer.layouts.test.LinearValueLayoutTest;
    import com.patrickmowrer.layouts.test.ValueLayoutBaseDefaultsTest;
    import com.patrickmowrer.layouts.test.ValueLayoutBaseTest;
    
    [Suite]
    [RunWith("org.flexunit.runners.Suite")]
    public class SparkComponentsTestSuite
    {
        public var test1:SliderBaseTest;
        public var test2:SliderDefaultsTest;
        public var test3:ThumbConstraintTest;
        public var test4:ThumbPropertySettingTest;
        public var test5:ValueRangeTest;
        
        public var test6:ValueLayoutBaseTest;
        public var test7:ValueLayoutBaseDefaultsTest;
        public var test8:LinearValueLayoutTest;
    }
}