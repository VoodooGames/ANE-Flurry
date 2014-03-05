package com.freshplanet.flurry.functions.ads;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
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

		ExtensionContext context = (ExtensionContext)arg0;

		Log.i(Extension.TAG, "Displaying ad for space : " + space + " ...");
		FlurryAds.displayAd(context.getActivity(), space,  context.getCurrentAdLayout());

		return null;
	}

}
