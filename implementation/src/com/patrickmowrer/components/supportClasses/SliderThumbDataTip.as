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

package com.patrickmowrer.components.supportClasses
{
    import flash.geom.Rectangle;
    
    import mx.formatters.NumberFormatter;
    
    import spark.components.DataRenderer;
    
    public class SliderThumbDataTip extends DataRenderer
    {
        private const DEFAULT_DATA_TIP_PRECISION:uint = 2;
        
        public var dataTipPrecision:uint = DEFAULT_DATA_TIP_PRECISION;
        public var dataTipFormatFunction:Function;

        private var dataFormatter:NumberFormatter;
        
        public function SliderThumbDataTip()
        {
            super();
        }
        
        override public function set data(value:Object):void
        {
            super.data = formatDataTipText(value);
        }
        
        override public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean = true):void
        {
            // Force render to calculate proper offset
            validateNow();
            setActualSize(getExplicitOrMeasuredWidth(), getExplicitOrMeasuredHeight());
            
            var centeredX:Number = x - getExplicitOrMeasuredWidth() / 2;
            var centeredY:Number = y - getExplicitOrMeasuredHeight() / 2;
            
            var screenBounds:Rectangle = systemManager.getVisibleApplicationRect();
            var tipBounds:Rectangle = getBounds(parent);
            
            // Make sure the tip doesn't exceed the bounds of the screen
            centeredX = Math.floor(Math.max(screenBounds.left, 
                Math.min(screenBounds.right - tipBounds.width, centeredX)));
            centeredY = Math.floor(Math.max(screenBounds.top, 
                Math.min(screenBounds.bottom - tipBounds.height, centeredY)));
            
            super.setLayoutBoundsPosition(centeredX, centeredY);
        }
        
        private function formatDataTipText(value:Object):Object
        {
            var formattedValue:Object;
            
            if(dataTipFormatFunction != null)
            {
                formattedValue = dataTipFormatFunction(value); 
            }
            else
            {
                if(dataFormatter == null)
                    dataFormatter = new NumberFormatter();
                
                dataFormatter.precision = dataTipPrecision;
                
                formattedValue = dataFormatter.format(value);   
            }
            
            return formattedValue;
        }
    }
}