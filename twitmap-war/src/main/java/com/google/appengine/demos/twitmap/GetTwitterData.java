package com.google.appengine.demos.twitmap;

import java.util.ArrayList;
import java.util.logging.Level;
import java.util.*;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.CompositeFilter;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.memcache.*;
import java.util.regex.*;
import java.util.Collections; 
import java.util.HashMap; 

public class GetTwitterData {
	public static ArrayList<String> keywordArr = new ArrayList<String>();
	public static ArrayList<String> fetch_data(String str){
		ArrayList<String> locArr = new ArrayList<String>();
		HashMap<String, Integer> keywordHash = new HashMap<String, Integer>();

		ArrayList<String> value;
		// Using the synchronous cache
	    MemcacheService syncCache = MemcacheServiceFactory.getMemcacheService();
	    syncCache.setErrorHandler(ErrorHandlers.getConsistentLogAndContinue(Level.INFO));
	    value = (ArrayList<String>) syncCache.get(str); // read from cache
	    String msg = "Data not from CACHE !!";
	    if (value != null) {
			msg = "Got data from CACHE!";
			for(String val : value) {
				locArr.add(val);
			}	
		}
			System.out.println(msg);
			DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
			Query q = new Query("TweetInfo");
			
			PreparedQuery pq = datastore.prepare(q);
			for (Entity result : pq.asIterable()) {
			String text = (String) result.getProperty("text");
				if(text.contains(str)){
					String location = (String) result.getProperty("location");
					locArr.add(location);
				  	System.out.println("tweets having "+str +" are coming from location "+ location);

				
					//Regex
					Pattern pattern = Pattern.compile("(?U)(\\b\\p{Lu}+\\p{L}{4,}\\b\\s?){1,2}", Pattern.CASE_INSENSITIVE);
					Matcher matcher = pattern.matcher(text);
					System.out.println("========= Keywords:=======");
					while(matcher.find()) {
						if(!keywordHash.containsKey(matcher.group())) {
							keywordHash.put(matcher.group(), 1);
						} else {
							keywordHash.put(matcher.group(), keywordHash.get(matcher.group()) + 1);
						}
						//System.out.println(matcher.group());
						//keywordArr.add(matcher.group());					
					}

		    	}
			}

			Iterator it = keywordHash.entrySet().iterator();
			while(it.hasNext()) {
				Map.Entry<String, Integer> keywd = (Map.Entry<String, Integer>) it.next();
					//System.out.println((String)keywd.getKey() + ":" + keywd.getValue());
				if(keywd.getValue() >= 4) {
					keywordArr.add((String) keywd.getKey());
					//System.out.println("======START==========");
					//System.out.println(">>>>>>>" + keywd.getKey());
					//System.out.println("=======END==========");
				}
			}

			//System.out.println("Got data from datastore!");
		   	syncCache.put(str, locArr); // populate cache
		return locArr;
	}
}
