package com.google.appengine.demos.twitmap;

import twitter4j.*;
import java.util.List;
import java.util.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.IOException;
import java.util.Properties;
import javax.servlet.*;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;


public class TweetSchedular extends HttpServlet {
	
  	
	@Override
  	public void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws IOException {
		ArrayList<String> dataArr = new ArrayList<String>();
		dataArr.add("IPL");
		dataArr.add("India Election");
		dataArr.add("Snowfall");
		dataArr.add("Facebook Drones");
		dataArr.add("Nexus5");
		dataArr.add("Happy");
		dataArr.add("Audi");
		dataArr.add("Cloud");
		dataArr.add("Tendulkar");
		dataArr.add("Android");
        Twitter twitter = new TwitterFactory().getInstance();
		for(String keyword : dataArr) {
	        try {
				System.out.println("Running Schedular for keyword: " + keyword);
	            Query query = new Query(keyword);
	            QueryResult result;
				String searchkey = "kak611";
	            do {
	                	result = twitter.search(query);
		                List<Status> tweets = result.getTweets();
						String date;
						SimpleDateFormat dateformatJava = new SimpleDateFormat("dd-MM-yyyy HH:MM:ss");
		
						//Datastore object
						Key twitKey = KeyFactory.createKey("TwitMap", searchkey);
					
	            	    for (Status tweet : tweets) {
							if(tweet.getUser().getLocation().length() > 0) {
								Entity tweetInfo = new Entity("TweetInfo", twitKey);
								tweetInfo.setProperty("text", tweet.getText());
								tweetInfo.setProperty("date", tweet.getCreatedAt());
								tweetInfo.setProperty("location", tweet.getUser().getLocation());
								DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
							    datastore.put(tweetInfo);
							}
    	          		}
        		   	} while ((query = result.nextQuery()) != null);
	        } catch (TwitterException te) {
	            te.printStackTrace();
	            System.out.println("Failed to search tweets: " + te.getMessage());
	            //System.exit(-1);
	        } catch(Exception e) {
				e.printStackTrace();
			}
		}
  }
}
