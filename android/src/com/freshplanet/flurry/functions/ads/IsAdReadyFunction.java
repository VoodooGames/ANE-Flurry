package com.freshplanet.flurry.functions.ads;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;
import com.flurry.android.FlurryAds;
import com.freshplanet.flurry.Extension;

public class IsAdReadyFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		Boolean result = false;
		
		// Retrieve the ad space name
		String space = null;
		try {
			space = arg1[0].getAsString();
		}
		catch (Exception e) {
			e.printStackTrace();
			Log.i(Extension.TAG, "isAdReady() : no space provided !");
		}
		
		if(space != null) {
			result = FlurryAds.isAdReady(space);
			Log.i(Extension.TAG, "isAdReady(" + space + ") ? " + result);
		}
		
		try {
			return FREObject.newObject(result);
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		}
		
		return null;
	}

}
