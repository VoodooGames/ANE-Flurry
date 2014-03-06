package com.freshplanet.flurry.functions.ads;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAdSize;
import com.flurry.android.FlurryAds;
import com.freshplanet.flurry.Extension;
import com.freshplanet.flurry.ExtensionContext;

public class FetchAdFunction implements FREFunction {
	
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {

		// Retrieve the ad space name
		String space = null;
		try {
			space = arg1[0].getAsString();
		}
		catch (Exception e) {
			e.printStackTrace();
			Log.i(Extension.TAG, "fetchAd() : no space provided !");
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
			Log.i(Extension.TAG, "Couldn't retrieve ad size. Defaulting to fullscreen.");
			size = FlurryAdSize.FULLSCREEN;
		}
		
		ExtensionContext context = (ExtensionContext)arg0;
		
		Log.i(Extension.TAG, "Fetching ad for space : " + space + " using size " + size + " ...");
		FlurryAds.fetchAd(context.getActivity(), space,  context.getNewAdLayout(), size);
		
		return null;
	}

}
