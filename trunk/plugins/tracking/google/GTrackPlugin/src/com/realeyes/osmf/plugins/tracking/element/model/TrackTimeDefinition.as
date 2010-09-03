package com.realeyes.osmf.plugins.tracking.element.model
{
	public class TrackTimeDefinition extends TrackDefinition
	{
		public var markers:Array;
		
		public function TrackTimeDefinition(name:String=null, category:String=null, action:String=null, label:String=null, value:uint=0)
		{
			super( name, category, action, label, value );
			markers = new Array();
		}
	}
}