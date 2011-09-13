package com.realeyes.osmfplayer.util
{
	import com.realeyes.osmfplayer.events.PlaylistEvent;
	import com.realeyes.osmfplayer.model.config.PlayerConfig;
	import com.realeyes.osmfplayer.model.playlist.Playlist;
	import com.realeyes.osmfplayer.model.playlist.PlaylistItem;
	import com.realeyes.osmfplayer.view.SkinContainer;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;

	public class PlaylistManager
	{
		//==========================================================
		//	PROPERTY DECLARATIONS
		//==========================================================
		private var _currentIndex:int = -1;
		private var _currentMedia:MediaElement;
		private var _currentItem:PlaylistItem;
		
		private var _config:PlayerConfig;
		private var _playlist:Playlist;
		private var _skinContainer:SkinContainer;
		private var _player:MediaPlayer;
		//==========================================================
		//	INIT METHODS
		//==========================================================
		public function PlaylistManager( config:PlayerConfig, skinContainer:SkinContainer, player:MediaPlayer )
		{
			this.config = config;
			this.playlist = config.playlist;
			this.skinContainer = skinContainer;
			this.player = player;
			
			if( _playlist.length > 0 )
			{
				_currentIndex = 0;
			}
		}
		
		protected function _initSkinListeners():void
		{
			_skinContainer.addEventListener( PlaylistEvent.PLAYLIST_NEXT, _onPlaylistNext );
			_skinContainer.addEventListener( PlaylistEvent.PLAYLIST_PREV, _onPlaylistPrev );
			_skinContainer.addEventListener( PlaylistEvent.PLAYLIST_SELECT, _onPlaylistSelect );
		}
		
		protected function _removeSkinListeners():void
		{
			_skinContainer.removeEventListener( PlaylistEvent.PLAYLIST_NEXT, _onPlaylistNext );
			_skinContainer.removeEventListener( PlaylistEvent.PLAYLIST_PREV, _onPlaylistPrev );
			_skinContainer.removeEventListener( PlaylistEvent.PLAYLIST_SELECT, _onPlaylistSelect );
		}
		
		protected function _initPlayerListeners():void
		{
			//TODO: listen for complete event
			_player.addEventListener( TimeEvent.COMPLETE, _onMediaComplete );
		}
		
		/*
		protected function _onMediaElementChange( event:MediaElementChangeEvent ):void
		{
			_mediaPlayerCore.media.addEventListener( MediaElementEvent.TRAIT_ADD, _onTraitAdd );
			_mediaPlayerCore.removeEventListener( MediaElementChangeEvent.MEDIA_ELEMENT_CHANGE, _onMediaElementChange );
		}
		*/
		
		protected function _removePlayerListeners():void
		{
			_player.removeEventListener( TimeEvent.COMPLETE, _onMediaComplete );
		}
		
		//==========================================================
		//	CONTROL METHODS
		//==========================================================
		public function playItemAtIndex( index:uint ):void
		{
			 _currentMedia = _config.getPlaylistMediaElement( index );
			 player.media = _currentMedia;
			 
			_currentItem = playlist.getItemAt( index );
			_skinContainer.playlistItem = _currentItem;
		}
		
		//==========================================================
		//	EVENT HANDLERS
		//==========================================================
		protected function _onPlaylistNext( event:PlaylistEvent ):void
		{
			if( _currentIndex + 1 >= _playlist.length )
			{
				if( _playlist.loopPlayback )
				{
					currentIndex = 0;
				}
			}
			else
			{
				currentIndex += 1;
			}

			trace( 'next' );
		}
		
		protected function _onPlaylistPrev( event:PlaylistEvent ):void
		{
			if( _currentIndex - 1 < 0 )
			{
				if( _playlist.loopPlayback )
				{
					currentIndex = _playlist.length - 1;
				}
			}
			else
			{
				currentIndex -= 1;
			}

			trace( 'prev' );
		}
		
		protected function _onPlaylistSelect( event:PlaylistEvent ):void
		{
			if( event.index >= 0 && event.index < playlist.length )
			{
				currentIndex = event.index;
			}
			trace( 'selected ' + event.index );	
		}
		
		protected function _onMediaComplete( event:TimeEvent ):void
		{
			if( playlist.autoProgress )
			{
				if( currentIndex >= playlist.length - 1 )
				{
					if( playlist.loopPlayback )
					{
						currentIndex = 0;
					}
				}
				else
				{
					currentIndex += 1;
				}
			}
		}
		
		//==========================================================
		//	GETTER/SETTERS
		//==========================================================
		public function get config():PlayerConfig
		{
			return _config;
		}
		public function set config( value:PlayerConfig ):void
		{
			_config = value;
			
			if( value )
			{
				playlist = _config.playlist;
			}
			else
			{
				playlist = null;
			}
		}
		
		public function get playlist():Playlist
		{
			return _playlist;
		}
		public function set playlist( value:Playlist ):void
		{
			_playlist = value;
		}
		
		public function get skinContainer():SkinContainer
		{
			return _skinContainer;
		}
		public function set skinContainer( value:SkinContainer ):void
		{
			if( _skinContainer )
			{
				_removeSkinListeners();
			}
			_skinContainer = value;
			
			if( _skinContainer )
			{
				_initSkinListeners();
			}
		}
		
		public function get player():MediaPlayer
		{
			return _player;
		}
		public function set player( value:MediaPlayer ):void
		{
			if( _player )
			{
				_removePlayerListeners();
			}
			
			_player = value;
			
			if( _player )
			{
				_initPlayerListeners();
			}
		}
		
		public function get currentIndex():uint
		{
			return _currentIndex;
		}
		public function set currentIndex( value:uint ):void
		{
			if( value >= 0 && value < _playlist.length )
			{
				_currentIndex = value;
				playItemAtIndex( _currentIndex );
			}
		}
		
		public function get currentMedia():MediaElement
		{
			return _currentMedia;
		}
		
		public function get currentItem():PlaylistItem
		{
			return _currentItem;
		}
	}
}