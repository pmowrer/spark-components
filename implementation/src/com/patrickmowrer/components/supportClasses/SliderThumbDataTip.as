package com.patrickmowrer.components.supportClasses
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.core.IDataRenderer;
    import mx.core.UIComponent;
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