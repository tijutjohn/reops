/*****************************************************
 *  Copyright 2010 Realeyes Media, LLC.  All Rights Reserved.
 *  
 *  The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *   
 *  Software distributed under the License is distributed on an "AS IS" basis, 
 *  WITHOUT WARRANTY OF ANY KIND, either express or implied. 
 *  See the License for the specific language governing 
 *  rights and limitations under the License.
 *  
 *  The Initial Developer of the Original Code is Realeyes Media, LLC..
 *  Portions created by Realeyes Media, LLC. are Copyright (C) 2010 Realeyes Media 
 *  All Rights Reserved. 
 *****************************************************/
package com.realeyes.osmfplayer.model.config.skin
{
	

	/**
	 * Parses and stores config data for the skin and
	 * control bar.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class SkinConfig
	{
		static public const SCALE_MODE_FIT:String = "FIT";
		static public const SCALE_MODE_SELECT:String = "SELECT";
		static public const SCALE_MODE_NONE:String = "NONE";
		
		static public const ALIGN_NONE:String = "NONE";
		static public const ALIGN_LEFT:String = "LEFT";
		static public const ALIGN_CENTER:String = "CENTER";
		static public const ALIGN_RIGHT:String = "RIGHT";
		static public const ALIGN_TOP:String = "TOP";
		static public const ALIGN_BOTTOM:String = "BOTTOM";
		
		/**
		 * Path for the skin file	(String)
		 */
		public var path:String;
		
		/**
		 * Skin config XML	(XML)
		 */
		public var skinXML:XML;
		
		private var _elements:Array;
		
		/**
		 * Constructor
		 * @param	skinConfigXML	(XML) defaults to null
		 * @return	void
		 */
		public function SkinConfig( skinConfigXML:XML=null )
		{
			if( skinConfigXML )
			{
				skinXML = skinConfigXML;
				path = skinXML.@path;
				_elements = new Array();
				
				var configElements:XMLList = skinXML.skinElement;
				var len:int = configElements.length();
				for( var i:int = 0; i < len; i++ )
				{
					var elementXML:XML = configElements[i];
					var skinElement:SkinElement = new SkinElement( elementXML );
					
					_elements.push( skinElement );
				}
			}
		}
		
		/**
		 * Returns the skin element specified by the ID
		 * 
		 * @param	elementID	(String)
		 * @return	SkinElement
		 */
		public function getSkinElementByID( elementID:String ):SkinElement
		{
			for each( var element:SkinElement in _elements )
			{
				if( element.id == elementID )
				{
					return element;
				}
			}
			return null;
		}
		
		/**
		 * Returns an array of all skin elements that have been created in the skin
		 * 
		 * @return	Array
		 */
		public function getSkinElements():Array
		{
			return _elements;
		}
		
		public function get elements():Array
		{
			return _elements;
		}
		public function set elements( value:Array ):void
		{
			_elements = value;
		}
	}
}