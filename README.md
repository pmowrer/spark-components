# Spark multiple thumb slider
***

[Introduction post](http://patrickmowrer.com/2010/10/18/multiple-thumb-spark-slider-component)

## Changelist:

### 0.1.2
* Fixed an issue with VerticalValueLayout which was making the VSlider convenience component run top-to-bottom in terms of min/max rather than vice-versa.

### 0.1.1
* Refactored HorizontalValueLayout and VerticalValueLayout into LinearValueLayout. This should enable easy creation of sliders between any two points, not just horizontal and vertical planes.

* Added element alignment to value layouts, enabling the Slider thumb to be positioned over its value in any way desired. Constants classes provide convenience values for layouts, used by the HSlider and VSlider classes.

* Renamed ThumbDragEvent to ThumbMouseEvent, and two if its types from BEGIN_DRAG and END_DRAG to PRESS and RELEASE respectively. This was done in order to be more consistent with the core Flex components and to better describe the event. 

* Made ThumbMouseEvents bubble such that event listeners won't need to be added to individual thumbs, but can be listened to on the Slider component.

### 0.1.0
First version of the multiple thumb spark slider.

## To-do list:
* documentation
* stepSize or equivalent to handle interval=0 key-movement on thumb.
* trackHighlight equivalent (between thumbs) skin
  * make it [draggable](http://dougmccune.com/blog/2007/01/21/draggable-slider-component-for-flex/)

