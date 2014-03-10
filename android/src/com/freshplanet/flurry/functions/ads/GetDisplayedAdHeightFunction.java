package com.freshplanet.flurry.functions.ads;

import android.util.Log;
import android.widget.FrameLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;
import com.freshplanet.flurry.Extension;
import com.freshplanet.flurry.ExtensionContext;

public class GetDisplayedAdHeightFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		// Retrieve the ad space name
		String space = null;
		try {
			space = arg1[0].getAsString();
		}
		catch (Exception e) {
			e.printStackTrace();
			Log.i(Extension.TAG, "getDisplayedAdHeight() : no space provided !");
			return null;
		}
		
		ExtensionContext context = (ExtensionContext) arg0;
		FrameLayout layout = context.getAdLayout(space);
		
		int adHeight = layout.getHeight();
		Log.i(Extension.TAG, "Displayed ad height for space " + space + " : " + adHeight);
		
		try {
			return FREObject.newObject(adHeight);
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		}
		
		return null;
	}
}
