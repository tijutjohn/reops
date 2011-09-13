package com.realeyes.osmf.plugins.tracking.element.model
{
	public class TrackDefinition
	{
		public var name:String;
		public var category:String;
		public var action:String;
		public var label:String;
		public var value:uint;
		
		public function TrackDefinition( name:String=null, category:String=null, action:String=null, label:String=null, value:uint=0 )
		{
			this.name = name;
			this.category = category;
			this.action = action;
			this.label = label;
			this.value = value;
		}
	}
}