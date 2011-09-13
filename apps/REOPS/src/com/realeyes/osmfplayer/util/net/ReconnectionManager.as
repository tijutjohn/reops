package com.realeyes.osmfplayer.util.net
{
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import org.osmf.net.NetConnectionCodes;
	import flash.events.EventDispatcher;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import org.osmf.events.TimeEvent;
	import flash.events.Event;

	/**
	 * Class for monitoring a NetConnection and attempting to reconnect it when it is
	 * disconnected. It broadcasts events to let the larger application know its status.
	 * The larger app would need to handle restarting the stream, or handling success in
	 * its own way. Each instance of the ReconnectionManager handles one NetConnection.
	 * 
	 * NOTE!! To use the ReconnectionManager, currently you must pass the loader to the  
	 * constructor of the MediaElement you create in the MediaFactory, rather than let 
	 * it be automatically generated.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	[Event (name='disconnected', type='com.mobilerider.osmfplayer.utils.net.ReconnectionManager')]
	[Event (name='reconnectAbandoned', type='com.mobilerider.osmfplayer.utils.net.ReconnectionManager')]
	[Event (name='reconnectFailed', type='com.mobilerider.osmfplayer.utils.net.ReconnectionManager')]
	[Event (name='reconnectSuccess', type='com.mobilerider.osmfplayer.utils.net.ReconnectionManager')]
	public class ReconnectionManager extends EventDispatcher
	{
		//=====================================================================
		//	PROPERTY DECLARATIONS
		//=====================================================================
		static public const DISCONNECTED:String = 'disconnected';
		static public const RECONNECT_ABANDONED:String = 'reconnectAbandoned';
		static public const RECONNECT_FAILED:String = 'reconnectFailed';
		static public const RECONNECT_SUCCESS:String = 'reconnectSuccess';
		
		private var _nc:NetConnection;
		private var _reconnecting:Boolean;
		private var _numAttempts:uint;
		private var _interval:uint;
		
		private var _reconnectTimer:Timer;
		private var _maxAttemptsReached:Boolean;
		
		private var _timeAtDisconnect:Number;
		
		//=====================================================================
		//	INIT METHODS
		//=====================================================================
		/**
		 * Constructor
		 * @param	netConnection	(NetConnection) the connection to monitor
		 * @param	numAttempts		(uint) the number of times to try to reconnect before giving up. Optional. Defaults to 5
		 * @param	interval		(uint) the amount of time (in milliseconds) to wait between each connection attempt. Optional. Defaults to 5000
		 */
		public function ReconnectionManager( netConnection:NetConnection, numAttempts:uint=5, interval:uint=5000 )
		{
			_numAttempts = numAttempts;
			_interval = interval;
			
			_nc = netConnection;
			
			_initListeners();
		}
		
		/**
		 * Listen for status events on the connection
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			_nc.addEventListener( NetStatusEvent.NET_STATUS, _onNetStatus );
		}
		
		//=====================================================================
		//	CONTROL METHODS
		//=====================================================================
		/**
		 * Start a reconnection sequence
		 * 
		 * @return	void
		 */
		private function _startReconnection():void
		{
			_reconnecting = true;
			
			_reconnectTimer = new Timer( interval, numAttempts );
			_reconnectTimer.addEventListener( TimerEvent.TIMER, _onTimer );
			_reconnectTimer.addEventListener( TimerEvent.TIMER_COMPLETE, _onTimerComplete );
			_reconnectTimer.start();
		}
		
		/**
		 * Ends the reconnection attempt and cleans up.
		 * 
		 * @return	void
		 */
		private function _endReconnection():void
		{
			_reconnecting = false;
			
			if( _reconnectTimer )
			{
				_reconnectTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
				_reconnectTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, _onTimerComplete );
				_reconnectTimer.stop();
				_reconnectTimer = null;
				
				_maxAttemptsReached = false;
			}
		}
		
		/**
		 * Tells the connection to attempt to connect to the URI originally
		 * passed to the NetConnection's connect method
		 * 
		 * @return	void
		 */
		private function _reconnect():void
		{
			if( !_nc.connected )
			{
				_nc.connect( _nc.uri );
			}
		}
		
		//=====================================================================
		//	EVENT HANDLERS
		//=====================================================================
		/**
		 * Handles status events. When it receives a closed event, it starts the
		 * reconnection attempt. When a connection failure is receives, it broadcasts
		 * a RECONNECT_FAILED event, unless the attempt has tried the max number of times,
		 * in which case it will broadcast a RECONNECT_ABANDONED event and stop trying to
		 * reconnect. If there is a connection success event, it will broadcast the 
		 * RECONNECT_SUCCESS event and stop the reconnection attempt.
		 * 
		 * @param	event	(NetStatusEvent)
		 * @return	void
		 */
		protected function _onNetStatus( event:NetStatusEvent ):void
		{
			trace( 'In Reconnect Manager ' + event.info.code );
			switch( event.info.code )
			{
				case NetConnectionCodes.CONNECT_CLOSED:
				{
					if( !_reconnecting )
					{
						dispatchEvent( new Event( DISCONNECTED ) );
						_startReconnection();
						trace( 'disconnected' );
					}
					break;
				}
				case NetConnectionCodes.CONNECT_FAILED:
				case NetConnectionCodes.CONNECT_REJECTED:
				case NetConnectionCodes.CONNECT_INVALIDAPP:
				{
					dispatchEvent( new Event( RECONNECT_FAILED ) );
					if( _maxAttemptsReached )
					{
						trace( 'timed out' );
						dispatchEvent( new Event( RECONNECT_ABANDONED ) );
					}
					break;
				}
				case NetConnectionCodes.CONNECT_SUCCESS:
				{
					if( reconnecting )
					{
						dispatchEvent( new Event( RECONNECT_SUCCESS ) );
						_endReconnection();
					}
					trace( 'reconnected' );
					break;
				}
			}
		}
		
		/**
		 * When the given interval has passed, attempt to reconnect
		 * 
		 * @param	event	(TimerEvent) TimerEvent.TIMER
		 * @return	void
		 */
		private function _onTimer( event:TimerEvent ):void
		{
			trace( 'timer ' + _reconnectTimer.currentCount );
			_reconnect();
		}
		
		/**
		 * When the timer has run the set number of times, stop
		 * the reconnection attempt
		 * 
		 * @param	evetn	(TimerEvent) TimerEvent.TIMER_COMPLETE
		 * @return	void
		 */
		private function _onTimerComplete( event:TimerEvent ):void
		{
			trace( 'timed out ' + _reconnectTimer.currentCount );
			_maxAttemptsReached = true;
		}
		
		//=====================================================================
		//	GETTER/SETTERS
		//=====================================================================
		/**
		 * The monitored NetConnection
		 */
		public function get netConnection():NetConnection
		{
			return _nc;
		}
		
		/**
		 * Is the NetConnection connected?
		 */
		public function get connected():Boolean
		{
			return _nc.connected;
		}
		
		/**
		 * Is the manager currently attempting to reconnect?
		 */
		public function get reconnecting():Boolean
		{
			return _reconnecting;
		}
		
		/**
		 * How many times should the manager attempt to reconnect?
		 */
		public function get numAttempts():uint
		{
			return _numAttempts;
		}
		public function set numAttempts( value:uint ):void
		{
			_numAttempts = value;
		}
		
		/**
		 * How long (in milliseconds) should the manager wait between
		 * connection attemtps?
		 */
		public function get interval():uint
		{
			return _interval;
		}
		public function set interval( value:uint ):void
		{
			_interval = value;
		}
		
		/**
		 * The time on the NetStream when the connection was disconnected. This
		 * is used by the larger application to return the viewer to the point
		 * in the video where they were at when they were disconnected. This also
		 * needs to be supplied by the larger application.
		 */
		public function get timeAtDisconnect():Number
		{
			return _timeAtDisconnect;
		}
		public function set timeAtDisconnect( value:Number ):void
		{
			_timeAtDisconnect = value;
		}
	}
}