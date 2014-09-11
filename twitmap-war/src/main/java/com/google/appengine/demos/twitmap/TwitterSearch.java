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


public class TwitterSearch extends HttpServlet {
	
	public static ArrayList<String> dataArr = new ArrayList<String>();
  	
	@Override
  	public void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws IOException {
		String search_item = req.getParameter("tweet");
		if(search_item == null) {
			search_item= req.getParameter("searchtweet");
		}
		if(search_item.length() > 1) {
	        Twitter twitter = new TwitterFactory().getInstance();
	
	        try {
				System.out.println("Search length: " + search_item.length() + ", searchitem is >>" + search_item + "<<");
				System.out.println("SEARCH ITEM: " + search_item);
				dataArr.clear();
	            Query query = new Query(search_item);
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
	
	      				    /*System.out.println("@" + tweet.getUser().getScreenName() + " - " + tweet.getText());
				    		   	resp.setContentType("text/plain");
								    resp.getWriter().println("@" + tweet.getUser().getScreenName() + " - " + tweet.getText());
										date = dateformatJava.format(tweet.getCreatedAt());
								    resp.getWriter().println("Date: " + date);
								    resp.getWriter().println("Latitude: " + tweet.getUser().getLocation());
										try {
							        	resp.getWriter().println("Latitude: " + tweet.getGeoLocation().getLatitude());
							        	resp.getWriter().println("Longitude: " + tweet.getGeoLocation().getLongitude());
										} catch(Exception e) {
												System.out.println(">>> " + e.getMessage());
										}
			        			//resp.getWriter().println("Location: " + tweet.getGeoLocation().latitude + ", " + tweet.getGeoLocation().longitude + ", Date: " + tweet.getCreatedAt() + ", Place: " + tweet.getPlace().getStreetAddress());
				        		resp.getWriter().println("===================================");	*/
									}
    	          	}
	            	} while ((query = result.nextQuery()) != null);

    	    } catch (TwitterException te) {
	            //te.printStackTrace();
	            System.out.println("Failed to search tweets: " + te.getMessage());
	            //System.exit(-1);
	        } catch(Exception e) {
				e.printStackTrace();
			}
		
			dataArr = GetTwitterData.fetch_data(search_item);
			System.out.println("SIZE: " + dataArr.size());
		} 
		resp.sendRedirect("/index.jsp");
  }
}
