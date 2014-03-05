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

package com.freshplanet.flurry;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;
import android.widget.RelativeLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class Extension implements FREExtension
{
	public static String TAG = "AirFlurry";
	public static FREContext context;
	public static Map<String, RelativeLayout> adLayouts;

	
	public FREContext createContext(String extId)
	{
		context = new ExtensionContext();
		return context;
	}

	public void dispose()
	{
		Log.i(TAG, "Extension disposed.");
		context = null;
	}
	
	public void initialize()
	{
		Log.i(TAG, "Extension initialized.");
	}
	
	public static RelativeLayout getAdLayout(String space)
	{
		if (adLayouts == null) return null;
		
		return adLayouts.get(space);
	}
	
	public static void setAdLayout(String space, RelativeLayout layout)
	{
		if (adLayouts == null) adLayouts = new HashMap<String, RelativeLayout>();
		
		adLayouts.put(space, layout);
	}
}
