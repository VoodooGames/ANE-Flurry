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

package com.freshplanet.flurry.functions.ads;

import android.util.Log;
import android.widget.RelativeLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAds;
import com.freshplanet.flurry.Extension;
import com.freshplanet.flurry.ExtensionContext;

public class RemoveAdFunction implements FREFunction
{
	
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve the ad space name
		String space = null;
		try
		{
			space = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			Log.d(Extension.TAG, "Couldn't retrieve ad space. Ad won't be removed.");
			return null;
		}
		
		// Update space status
		ExtensionContext context = (ExtensionContext)arg0;
		
		// Remove the ad
		RelativeLayout adLayout = context.getCurrentAdLayout();
		FlurryAds.removeAd(context.getActivity(), space, adLayout);
		
		return null;
	}

}
