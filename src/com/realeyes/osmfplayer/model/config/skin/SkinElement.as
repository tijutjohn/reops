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
	import com.realeyes.osmfplayer.controls.ControlBar;
	
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	/**
	 * Visual element defined in the skin and defined in the config.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class SkinElement
	{
		static public const CONTROL_BAR:String = "controlBar";
		static public const LOADING_INDICATOR:String = "loadingIndicator";
		static public const CLOSED_CAPTION_FIELD:String = "closedCaptionField";
		
		/**
		 * Unique identifier for the element. Required in the XML config and must be unique.	(String)
		 */
		public var id:String;
		
		/**
		 * Name of a method on the control bar container to call once the component has instantiated.	(String)
		 */
		public var initMethodName:String;
		
		/**
		 * Class path for the functionality of the skin element.	(String)
		 */
		public var elementClassString:String;
		
		/**
		 * Different properties for the element.	(Dictionary)
		 */
		public var properties:Dictionary;
		
		private var _elementXML:XML;
		
		/**
		 * Constructor
		 * 
		 * @param	elementXML	(XML) XML node defining the skin element. Defaults to null.
		 */
		public function SkinElement( elementXML:XML=null )
		{
			properties = new Dictionary();
			this.elementXML = elementXML;
		}
		
		/**
		 * Instantiates the class defined by elementClassString, and set properties
		 * on it defined in the XML
		 * 
		 * @return	*	(whatever class type was defined by elementClassString)
		 */
		public function buildSkinElement():*
		{
			var elementClassDef:Class = ApplicationDomain.currentDomain.getDefinition( elementClassString ) as Class;
			var elementClass:* = new elementClassDef(); // Create the object
			for( var key:String in properties ) // Set the specified properties from the config on the new control bar object
			{
				elementClass[ key ] = properties[ key ];
			}
			return elementClass;
		}

		/**
		 * XML node defining the skin element	(XML)
		 * Parses the XML when set.
		 */
		public function get elementXML():XML
		{
			return _elementXML;
		}

		public function set elementXML(value:XML):void
		{
			if( value != _elementXML )
			{
				if( value )
				{
					_elementXML = value;
					
					id = _elementXML.@id.toString();
					elementClassString = _elementXML.@elementClass.toString();
					initMethodName = _elementXML.@initMethod.toString();
					
					var attributes:XMLList = _elementXML.attributes();
					for each( var attribute:XML in attributes )
					{
						if( attribute.name() != "id" && attribute.name() != "elementClass" && attribute.name() != "initMethod" )
						{
							var attrValue:String = attribute.toString();
							if( attrValue == "true" || attrValue == "false" )
							{
								properties[ attribute.name().toString() ] = attrValue == "true" ? true:false;
							}
							else
							{
								properties[ attribute.name().toString() ] = attrValue;
							}
						}
					}
				}
				else
				{
					elementXML = value;
				}
			}
		}

	}
}