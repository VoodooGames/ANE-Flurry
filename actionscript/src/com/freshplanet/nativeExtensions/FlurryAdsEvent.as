package com.freshplanet.nativeExtensions
{
	import flash.events.Event;

	public class FlurryAdsEvent extends Event
	{
		public static const SPACE_DID_DISMISS:String = "SPACE_DID_DISMISS";
		public static const SPACE_WILL_LEAVE_APPLICATION:String = "SPACE_WILL_LEAVE_APPLICATION";
		public static const SPACE_DID_FAIL_TO_RENDER:String = "SPACE_DID_FAIL_TO_RENDER";
		public static const SPACE_DID_FAIL_TO_RECEIVE_AD:String = "SPACE_DID_FAIL_TO_RECEIVE_AD";
		public static const SPACE_DID_RECEIVE_AD:String = "SPACE_DID_RECEIVE_AD";
		/** Android only. */
		public static const SPACE_AD_OPENED:String = "SPACE_AD_OPENED";
		public static const SPACE_AD_CLICKED:String = "SPACE_AD_CLICKED";
		public static const SPACE_VIDEO_COMPLETED:String = "SPACE_VIDEO_COMPLETED";
		/** Android only. */
		public static const SPACE_AD_RENDERED:String = "SPACE_AD_RENDERED";
		
		// IOS ONLY
		public static const SPACE_WILL_DISMISS:String = "SPACE_WILL_DISMISS";
		public static const SPACE_WILL_EXPAND:String = "SPACE_WILL_EXPAND";
		public static const SPACE_WILL_COLLAPSE:String = "SPACE_WILL_COLLAPSE";
		public static const SPACE_DID_COLLAPSE:String = "SPACE_DID_COLLAPSE";
		
		/** Name of the ad space related to the event. */
		public var adSpace:String;
		
		public function FlurryAdsEvent( type : String, adSpace : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.adSpace = adSpace;
		}
	}
}