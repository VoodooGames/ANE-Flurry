package com.freshplanet.flurry.functions.ads;

import android.util.Log;
import android.widget.FrameLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAdSize;
import com.flurry.android.FlurryAds;
import com.freshplanet.flurry.Extension;
import com.freshplanet.flurry.ExtensionContext;

public class DisplayAdFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		// Retrieve the ad space name
		String space = null;
		try {
			space = arg1[0].getAsString();
		}
		catch (Exception e) {
			e.printStackTrace();
			Log.i(Extension.TAG, "displayAd() : no space provided !");
			return null;
		}
		
		// Retrieve the ad size
		FlurryAdSize size;
		try {
			String sizeString = arg1[1].getAsString();

			if (sizeString.equals("BANNER_TOP"))
				size = FlurryAdSize.BANNER_TOP;
			else if (sizeString.equals("BANNER_BOTTOM"))
				size = FlurryAdSize.BANNER_BOTTOM;
			else
				size = FlurryAdSize.FULLSCREEN;
		}
		catch (Exception e) {
			e.printStackTrace();
			Log.i(Extension.TAG, "fetchAd() : invalid size !");
			return null;
		}
		
		ExtensionContext context = (ExtensionContext)arg0;
		FrameLayout layout = context.getAdLayout(space);
		
		Log.i(Extension.TAG, "Showing layout " + layout + " ...");
		context.showAdLayout(space, size);
		
		Log.i(Extension.TAG, "Displaying ad for space : " + space + " on layout : " + layout + " ...");
		FlurryAds.displayAd(context.getActivity(), space, layout);
		
		Log.i(Extension.TAG, "Displayed ad, height is : " + layout.getHeight());

		return null;
	}

}
