package com.realeyes.osmf.plugins.tracking.element.config
{
	import com.realeyes.osmf.plugins.tracking.element.model.Marker;
	import com.realeyes.osmf.plugins.tracking.element.model.TrackDefinition;
	import com.realeyes.osmf.plugins.tracking.element.model.TrackTimeDefinition;
	
	import flash.utils.Dictionary;

	public class GTrackConfiguration
	{
		///////////////////////////////////
		// Declarations
		///////////////////////////////////
		
		public var account:String;
		public var accounts:Array;
		public var url:String;
		public var updateInterval:int = 250;
		public var events:Dictionary;
		public var durrationTrackingEnabled:Boolean;
		
		private var _debug:Boolean;
		private var _configXML:XML;
		
		
		///////////////////////////////////
		// Init Methods
		///////////////////////////////////
		
		public function GTrackConfiguration( configXML:XML=null )
		{
			if( configXML )
			{
				this.configXML = configXML;
			}
		}
		
		
		///////////////////////////////////
		// Control Methods
		///////////////////////////////////
		
		public function getTrackEvent( eventType:String ):TrackDefinition
		{
			return events[ eventType ];
		}
		
		
		///////////////////////////////////
		// Getter/Setters
		///////////////////////////////////
		
		/**
		 *Toggles debugging for the GA for Flash
		 *  
		 * @return Boolean 
		 * 
		 */		
		public function get debug():Boolean
		{
			return _debug;
		}
		public function set debug( value:* ):void
		{
			_debug = value.toString() == "true" ? true:false;
		}
		
		public function set configXML( value:XML ):void
		{
			_configXML = value;
			
			accounts = new Array();
			var ua:String = "";
			// Deal with multiple tracking accts
			if( _configXML.account.length() > 1 )
			{
				
				for each( var acct:XML in _configXML.account )
				{
					ua = acct.text();
					accounts.push( ua );
				}
			}
			else
			{
				ua = _configXML.account[0];
				accounts.push( ua );
			}
			
			url = _configXML.url;
			debug = _configXML.debug;
			
			events = new Dictionary();
			for each( var event:XML in _configXML..event )
			{
				var label:String = event.hasOwnProperty( "label" ) == true ?  event.@label:null;
				var trackingValue:int = event.hasOwnProperty( "value" ) == true ? parseInt( event.@value ):null;
				
				var eventName:String = event.@name;
				switch( eventName )
				{
					case "percentWatched":
					case "timeWatched":
					{
						var newTimeEvent:TrackTimeDefinition = new TrackTimeDefinition( event.@name, event.@category, event.@action, label, trackingValue );
						
						for each( var marker:XML in event..marker )
						{
							var markerValue:int = parseInt( eventName == "percentWatched" ? marker.@percent:marker.@time );
							newTimeEvent.markers.push( new Marker( markerValue, marker.@label ) );	
						}
						events[ eventName ] = newTimeEvent;	
						
						durrationTrackingEnabled = true;
						
						break;
					}
					default:
					{
						var newEvent:TrackDefinition = new TrackDefinition( event.attribute( "name" ), event.attribute( "category" ), event.attribute( "action" ), label, trackingValue );
						events[ newEvent.name ] = newEvent;	
					}
				}					
			}
		}
		
		

	}
}