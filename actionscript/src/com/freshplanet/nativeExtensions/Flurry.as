//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.nativeExtensions
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	import flash.utils.getTimer;

	/**
	 * Singleton managing both Flurry Analytics and Ads. First set your API keys, then, create the instance you will 
	 * use with <code>getInstance()</code>.
	 */
	public class Flurry extends EventDispatcher
	{
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		// SINGLETON SECTION
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		/** The Singleton instance. */
		private static var _instance:Flurry;
		
		/** The Native Extension context. */
		private var extCtx:ExtensionContext;
		
		/**
		 * Set this to your own logging function. Signature : function(message:String):void.
		 */
		public static var logger:Function = trace;
		
		/**
		 * Do not call this, use <code>getInstance()</code> instead.
		 */
		public function Flurry()
		{
			if (!_instance)
			{
				if (this.isFlurrySupported)
				{
					log('creating Flurry context');
					extCtx = ExtensionContext.createExtensionContext("com.freshplanet.AirFlurry", null);
					extCtx.addEventListener(StatusEvent.STATUS, onStatus);
				} else
				{
					log('Flurry is not supported', "no log will be displayed");
				}
				_instance = this;
			}
			else
			{
				throw Error( '[Flurry Error] This is a singleton, use getInstance, do not call the constructor directly');
			}

		}
		
		private function onStatus(event:StatusEvent):void
		{
			var e:FlurryAdsEvent;
			
			if(event.code == "LOGGING") {
				log(event.level);
				return;
			}
			
			e = new FlurryAdsEvent(event.code, event.level);
			
			if(e) dispatchEvent(e);
		}
		
		/**
		 * Returns the Singleton instance.
		 */
		public static function getInstance() : Flurry
		{
			return _instance ? _instance : new Flurry();
		}

		private function get isAndroid():Boolean
		{
			return Capabilities.manufacturer.indexOf('Android') > -1;
		}
		
		private function get isIOS():Boolean
		{
			return Capabilities.manufacturer.indexOf('iOS') > -1;
		}

		private function get isFlurrySupported():Boolean
		{
			var result:Boolean = this.isIOS || this.isAndroid;
			return result;
		}
		
		/**
		 * Outputs the given message(s) using the provided logger function, or using trace.
		 */
		private static function log(message:String, ... additionnalMessages):void {
			if(logger == null) return;
			
			if(!additionnalMessages)
				additionnalMessages = [];
			
			logger(message + additionnalMessages.join(" "));
		}
		
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		// ANALYTICS SECTION
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Log an event (not timed). For timed events, @see startTimedEvent
		 *  
		 * @param eventName name of the event. Limits :
		 * <ul>
		 * <li>300 event name differents per project</li>
		 * <li>event name below 255 characters</li>
		 * <li>each session can log up to 200 events and up to 100 unique event names</li>
		 * </ul>
		 * @param properties map of additional parameters sent with the event. Limits :
		 * <ul>
		 * <li>max 10 parameters per event</li>
		 * <li>key and value name below 255 characters</li>
		 * </ul>
		 */
		public function logEvent(eventName:String, properties:Object = null):void
		{
			log("logEvent", eventName, properties);

			if (isFlurrySupported)
			{
				if (!checkLength(eventName))
				{
					log("Warning : event name too long (>255 characters)", eventName);
					return;
				}

				var parameterKeys:Array = [];
				var parameterValues:Array = [];
				if (properties != null)
				{
					var value:String;
					var count:int = 0;
					for (var key:String in properties)
					{
						if (count > 10)
						{
							log("Warning : too many properties sent (>10) for event", eventName);
							break;
						}
						value = properties[key].toString();
						if (checkLength(value) && checkLength(key))
						{
							parameterKeys.push(key);
							parameterValues.push(value);
						} else
						{
							log("Warning : key or value too long (>255 characters)", key, value);
						}
						count++;
					}
					log("logEvent", eventName, parameterKeys, parameterValues);
					extCtx.call("logEvent", eventName, parameterKeys, parameterValues);
				} else
				{
					log("logEvent", eventName);
					extCtx.call("logEvent", eventName, [], []);
				}
			}
		}
		
		private function checkLength(value:String):Boolean
		{
			return value != null && value.length < 255;
		}
		
		
		
		/**
		 * Report Application errors. Limits:
		 * Flurry will report the first 10 errors to occur in each session
		 * 
		 * We also limit error and message to 255 characters (truncate if higher). 
		 * 
		 * @param errorId
		 * @param message
		 * 
		 */
		public function logError(errorId:String, message:String):void
		{
			if (isFlurrySupported && errorId != null)
			{
				errorId = errorId.length > 255 ? errorId.substr(0, 253) : errorId;
				
				message = message == null ? "" : message;
				message = message.length > 255 ? message.substr(0, 253) : message;

				extCtx.call("logError", errorId, message)
			}
		}
		
		
		/**
		 * Set the user id associated with the current session. 
		 * @param userId 
		 * 
		 */
		public function setUserId(userId:String):void
		{
			if (isFlurrySupported)
			{
				extCtx.call("setUserId", userId)
			}
		}
		
		public static const MALE_GENDER:String   = "m";
		public static const FEMALE_GENDER:String = "f";

		
		/**
		 * Set the user info associated with the current session 
		 * @param age age of the user ( > 0)
		 * @param gender gender of the user. Must be one of the two defined constants: @see MALE_GENDER, @see FEMALE_GENDER
		 * 
		 */
		public function setUserInfo(age:int, gender:String):void
		{
			if (isFlurrySupported)
			{
				if ([MALE_GENDER, FEMALE_GENDER].indexOf(gender) == -1)
				{
					log("wrong gender provided", gender, "must be Flurry.MALE_GENDER or Flurry.FEMALE_GENDER")
				}
				extCtx.call("setUserInfo", age, gender)
			}
		}
		
		
		/**
		 * Set the version name sent for this session. Limits:
		 * There is a maximum of 605 versions allowed for a single app. 
		 * This method must be called prior to invoking startSession:.
		 * @param versionName
		 * 
		 */
		public function setAppVersion(versionName:String):void
		{
			if (isFlurrySupported)
			{
				extCtx.call("setAppVersion", versionName)
			}
		}
		
		/**
		 * Switch the send events when user pauses the app. 
		 * @param value True : send events on pause. False : send events on stop.
		 * 
		 */
		public function setSendEventsOnPause(value:Boolean):void
		{
			if (isFlurrySupported)
			{
				extCtx.call("setSendEventsOnPause", value)
			}
		}

		
		/**
		 * Start logging a timed event. 
		 * @param eventName
		 * 
		 */
		public function startTimedEvent(eventName:String):void
		{
			log("startTimedEvent", eventName);

			if (isFlurrySupported)
			{
				if (!checkLength(eventName))
				{
					log("Warning : event name too long (>255 characters)", eventName);
					return;
				}
				log("start logEvent Timed", eventName);

				extCtx.call("startTimedEvent", eventName)
			}
		}
		
		
		/**
		 * Stop recording the given timed event. 
		 * @param eventName
		 * 
		 */
		public function stopTimedEvent(eventName:String):void
		{
			log("stopTimedEvent", eventName);

			if (isFlurrySupported)
			{
				if (!checkLength(eventName))
				{
					log("Warning : event name too long (>255 characters)", eventName);
					return;
				}
				log("stop logEvent Timed", eventName);

				extCtx.call("stopTimedEvent", eventName)
			}
		}

		
		/**
		 * Start a new Flurry Session.
		 * Every event will be recorded afterwards.
		 */
		public function startSession():void
		{
			trace('start session');
			if (isFlurrySupported)
			{
				
				var apiKey:String = getApiKeyFromDevice();
				if (apiKey != null)
				{
					trace('start session with api key'+apiKey);
					extCtx.call("startSession", apiKey)
				} else
				{
					log("Warning : api key not found");
				}
			}
		}
		
		private var iOSApiKey:String;
		private var androidApiKey:String;
		
		private function getApiKeyFromDevice():String
		{
			if (this.isAndroid)
			{
				return androidApiKey;
			}
			if (this.isIOS)
			{
				return iOSApiKey;
			}
			return null;
		}
		
		public function setIOSAPIKey(apiKey:String):void
		{
			this.iOSApiKey = apiKey;
		}
		
		public function setAndroidAPIKey(apiKey:String):void
		{
			this.androidApiKey = apiKey;
		}

		
		/**
		 * Stop the current session. 
		 */
		public function stopSession():void
		{
			if (isFlurrySupported)
			{
				extCtx.call("stopSession")
			}
		}
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		// ADS SECTION
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Fetches an ad to be displayed later (with <code>displayAd()</code>).
		 * 
		 * @param space String: Name of the adSpace that you defined on the Flurry website.
		 * @param size String: Size of the ad. This is generally overridden on the server-side
		 * by the size specified on the Flurry website.
		 * 
		 * @see FlurryAdSize
		 */
		public function fetchAd( space : String, size : String ) : void
		{
			if (!isFlurrySupported) return;
			log('Fetch ad "'+space+'" with size "'+size+'"');
			extCtx.call('fetchAd', space, size);
		}
		
		/**
		 * Returns true if an ad has been fetched and prepared by a previous call to fetchAd().
		 */
		public function isAdReady( space : String ) : Boolean {
			if (!isFlurrySupported) return false;
			var adReady:Boolean = extCtx.call("isAdReady", space);
			log("isAdReady(" + space + ") ? " + adReady);
			return adReady;
		}
		
		/**
		 * Displays a previously fetched ad (with <code>fetchAd()</code>).
		 * 
		 * @param space String: Name the adSpace that you defined on the Flurry website.
		 */
		public function displayAd( space : String ) : void
		{
			if (!isFlurrySupported) return;
			log('Display ad "'+space+'"');
			extCtx.call('displayAd', space);
		}
		
		/**
		 * Remove an ad from the screen.
		 * 
		 * @param space String: Name of the adSpace that you defined on the Flurry website.
		 */ 
		public function removeAd( space : String ) : void
		{
			if (!isFlurrySupported) return;
			log('Remove ad "'+space+'"');
			extCtx.call('removeAd', space);
		}
		
		/**
		 * Adds a key/value pair to the user cookies.
		 * Those cookies are used once the user install new app.
		 */
		public function addUserCookie( key : String, value : String ) : void
		{
			if (!isFlurrySupported) return;
			extCtx.call("addUserCookie", key, value);
		}
		
		/**
		 * Clear the stored cookies.
		 * 
		 * @see #addUserCookie()
		 */
		public function clearUserCookies() : void
		{
			if (!isFlurrySupported) return;
			extCtx.call("clearUserCookies");
		}
		
		/**
		 * Adds a key/value pair to the targeting keywords.
		 * Those keywords are used to target ads.
		 */
		public function addTargetingKeyword( key : String, value : String ) : void
		{
			if (!isFlurrySupported) return;
			extCtx.call("addTargetingKeyword", key, value);
		}
		
		/**
		 * Clear the stored targeting keywords.
		 * 
		 * @see #addTargetingKeyword()
		 */
		public function clearTargetingKeywords() : void
		{
			if (!isFlurrySupported) return;
			extCtx.call("clearTargetingKeywords");
		}
		
		/**
		 * Allows you to request test ads from the server.
		 */
		public function enableTestAds(enable:Boolean):void {
			if (!isFlurrySupported) return;
			log("Enabling test ads...");
			extCtx.call("enableTestAds", enable);
		}
	}
}