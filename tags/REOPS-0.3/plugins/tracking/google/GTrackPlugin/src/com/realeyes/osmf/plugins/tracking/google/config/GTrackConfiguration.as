package com.realeyes.osmf.plugins.tracking.google.config
{
	public class GTrackConfiguration
	{
		public var account:String;
		public var trackingURL:String;
		public var debugging:Boolean;
		
		public function GTrackConfiguration( account:String, trackingURL:String, debugging:Boolean=false )
		{
			this.account = account;
			this.trackingURL = trackingURL;
			this.debugging = debugging;
		}
	}
}