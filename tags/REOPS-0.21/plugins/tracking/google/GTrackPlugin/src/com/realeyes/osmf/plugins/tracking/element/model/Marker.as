package com.realeyes.osmf.plugins.tracking.element.model
{
	public class Marker
	{
		public var marker:int;
		public var label:String;
		public var dispatched:Boolean;
		
		public function Marker( marker:int, label:String )
		{
			this.marker = marker;
			this.label = label;
		}
	}
}