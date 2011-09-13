var applicationName = "REOPS";
function changeMedia( mediaPath, mediaType, streamType )
{
	var swf = document.getElementById( applicationName );
	swf.changeMedia( mediaPath, mediaType, streamType );
}

//This is testing for the external interface interaction
function onMediaListChange()
{
	selectList = document.getElementById( "mediaList" );
	streamingType = "";
	mediaType = "VIDEO";
	switch( selectList.selectedIndex )
	{
		case 0:
		{
			mediaType = "IMAGE";
			break;
		}
		case 1:
		{
			mediaType = "SWF";
			break;
		}
		case 2:
		{
			streamingType = "PROGRESSIVE";
			break;
		}
		case 3:
		{
			streamingType = "STREAMING";
			break;
		}
		case 4:
		{
			streamingType = "DYNAMIC_STREAMING";
			synStreamData = "<smil>";
			synStreamData += "<head>"
			  synStreamData += "<meta base='rtmp://cp67126.edgefcs.net/ondemand' />";
			  synStreamData += "</head>";
			  synStreamData += "<body>";
			    synStreamData += "<switch>";
			      synStreamData += "<video src='mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_408kbps.mp4' system-bitrate='408000'/>";
			      synStreamData += "<video src='mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_608kbps.mp4' system-bitrate='608000'/>";
			      synStreamData += "<video src='mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_908kbps.mp4' system-bitrate='908000'/>";
			      synStreamData += "<video src='mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_1308kbps.mp4' system-bitrate='1308000'/>";
			      synStreamData += "<video src='mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1280x720_24.0fps_1708kbps.mp4' system-bitrate='1708000'/>";
			    synStreamData += "</switch>";
			  synStreamData += "</body>";
			synStreamData += "</smil>";
			break;
		}
	}
	
	if( selectList.selectedIndex == 4 )
	{
		
		changeMedia( synStreamData, mediaType, streamingType );
	}
	else
	{
		changeMedia( selectList.value, mediaType, streamingType );
	}
}