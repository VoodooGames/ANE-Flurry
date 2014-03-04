package com.freshplanet.flurry.functions.ads;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAds;
import com.freshplanet.flurry.Extension;

public class EnableTestAdsFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		Boolean enableTestAds = false;
		
		try
		{
			enableTestAds = arg1[0].getAsBool();
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		FlurryAds.enableTestAds(enableTestAds);
		Log.d(Extension.TAG, "Test ads " + (enableTestAds ? "enabled" : "disabled"));
		
		return null;
	}

}
