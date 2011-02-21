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

package com.patrickmowrer.events
{
    import flash.events.Event;
    
    public class ThumbMouseEvent extends Event
    {
        public static const PRESS:String    = "com.patrickmowrer.events.ThumbMouseEventPress";
        public static const DRAGGING:String = "com.patrickmowrer.events.ThumbMouseEventDragging";
        public static const RELEASE:String  = "com.patrickmowrer.events.ThumbMouseEventRelease";
        
        public var stageX:Number;
        public var stageY:Number;
        
        public function ThumbMouseEvent(type:String, stageX:Number, stageY:Number, bubbles:Boolean = true, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
            
            this.stageX = stageX;
            this.stageY = stageY;
        }
        
        override public function clone():Event
        {
            return new ThumbMouseEvent(type, stageY, stageX, bubbles, cancelable);
        }
    }
}