package com.realeyes.osmf.plugins.tracking.events
{
	import com.realeyes.osmf.plugins.tracking.element.model.Marker;
	
	import flash.events.Event;
	
	public class DurationMarkerEvent extends Event
	{
		public static const TIME_MARKER:String = "timeMarker";
		public static const PERCENT_MARKER:String = "percentMarker";
		public static const COMPLETE_MARKER:String = "completeMarker";
		
		public var marker:Marker;
		public var time:Number;
		public var percent:uint;
		
		public function DurationMarkerEvent( p_type:String, p_marker:Marker, p_percent:uint, p_time:Number, p_bubbles:Boolean=false, p_cancelable:Boolean=false)
		{
			super( p_type, p_bubbles, p_cancelable);
			marker = p_marker;
			time = p_time;
			percent = p_percent;
		}
		
		override public function clone():Event
		{
			return new DurationMarkerEvent( super.type, marker, percent, time, super.bubbles, super.cancelable );
		}
	}
}