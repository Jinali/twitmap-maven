<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@page import="com.google.appengine.demos.twitmap.TwitterSearch"%>
<%@page import="com.google.appengine.demos.twitmap.GetTwitterData"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
   <%@ page import="java.util.*"%>


<html>
    <head>
        <title>TwitMap</title>
		<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
		<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=visualization"></script>
        <link rel="stylesheet" type="text/css" href="/stylesheets/homepage.css" /> 
    </head>

    <body>
        		<div id = "page_title_background">
                <div id='page_title'><a class='title_link' href='/'><h3>twitmap</a><i id='tagline' style='font-size:15px'>&nbsp;&nbsp;Display tweets on map</i></h3></div>
        </div>
				<form id='form_search_tweets' action="/search" method="get">
					<label for="searchtweetfor">Search tweets for:</label>
					<input id="display_box" type="text" name="searchtweet" value=" "/>
				    <input type="submit" value="Search"/>
				<select id="the_list" onchange="on_list_item_change()" >
  					<option value="select">Select keywords:</option>
  					<option value="ipl">IPL</option>
  					<option value="election">Indian Election</option>
  					<option value="snowfall">SnowFall</option>
  					<option value="facebook">Facebook Drones</option>
  					<option value="nexus5">Nexus5</option>
					<option value="happy">Thanksgiving</option>
					<option value="audi">Audi</option>
					<option value="cloud">Weather</option>
					<option value="tendulkar">Tendulkar</option>
					<option value="android">Android</option>
				</select>
				<a href='/HeatMap.jsp' style='margin-left:200px'>Show Heatmap</a>
			</form>

	  			<hr>
				<div id='map_canvas' style="height:500px; width:1200px"></div>
	  			<hr>
				<div id='dynamic_keywords'></div>
				<script>
					var heatmap;
					var map_heat;
					var latArr = new Array();
					var lngArr = new Array();
					var nextAddress = 0;
    				var delay = 10;
					var taxiData = [];	
					var map;
					var geo;
					var bounds;
					var infowindow;
					var latlng;
					var mapOptions;

				    // Create map
					function initialize() {
					    infowindow = new google.maps.InfoWindow();
					    latlng = new google.maps.LatLng(-34.397, 150.644);
					    mapOptions = {
						      zoom: 2,
						      center: latlng,
						      mapTypeId: google.maps.MapTypeId.ROADMAP
					    }

				    	geo = new google.maps.Geocoder(); 
					    map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
					    bounds = new google.maps.LatLngBounds();

						theNext();
						displayDynamicKeywords();
					}

		
					function on_list_item_change(){
						var mylist=document.getElementById("the_list");
						document.getElementById("display_box").value=mylist.options[mylist.selectedIndex].text;
					}


				    // Geocoding 
				    function getAddress(search, next, arrLat, arrLong) {
					      geo.geocode({address:search}, function (results,status) { 
					           if (status == google.maps.GeocoderStatus.OK) {
					              var p = results[0].geometry.location;
					              var lat=p.lat();
					              var lng=p.lng();
								  latArr.push(lat);
								  lngArr.push(lng);
						          createMarker(search,lat,lng);
						       } else {
						            if (status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
						               nextAddress--;
						               delay++;
						            } else {
						               var reason="Code "+status;
						            }   
						       }
						           next();
					      });
					 }
				     
				     function createMarker(add,lat,lng) {
					       var contentString = add;
					       var marker = new google.maps.Marker({
						         position: new google.maps.LatLng(lat,lng),
						         map: map,
						         icon:'http://wiki.alumni.net/wiki/images/thumb/5/55/Wikimap-blue-dot.png/50px-Wikimap-blue-dot.png',
						         zIndex: Math.round(latlng.lat()*-100000)<<5
					       });
					       google.maps.event.addListener(marker, 'click', function() {
				               infowindow.setContent(contentString); 
					           infowindow.open(map,marker);
			        	   });
					       bounds.extend(marker.position);
					 }
			      	

			      	 function theNext() {

          	         	<% ArrayList<String> list = new ArrayList<String>();%>
		              	<%list = TwitterSearch.dataArr;%>
						<% System.out.println("dataArr: " + list.toString()); %>
	        	          var jsArray = [], longLatArr = [];
	             	      <%for(int i=0;i<list.size();i++){%>
    	              	  	  jsArray.push("<%= list.get(i)%>");
        	          	  <%}%>
						  if (nextAddress < jsArray.length) {
					          setTimeout('getAddress("'+jsArray[nextAddress]+'",theNext)', delay);
					          nextAddress++;
				          } else {
					          map.fitBounds(bounds);
	  		 		      }
			     	 }

					 function displayDynamicKeywords() {
						  var div_dynamic = document.getElementById('dynamic_keywords');
						  <% System.out.println("displayDynamicKeywords...."); %> 
	                      <% ArrayList<String> dynamicArr = new ArrayList<String>();
	                      dynamicArr = GetTwitterData.keywordArr;%>
						  <%System.out.println("DynamicArr: " + dynamicArr.toString()); %>
						  var words = "Dynamic keywords to search: ";
						  <% if(dynamicArr.size() > 0) { %>
	    	                  <%for(int i=0;i<dynamicArr.size();i++){%>
								  words += " ";
								  //words += "<a href='/search?tweet=" + "<%=dynamicArr.get(i) %>" +"'>" + "<%= dynamicArr.get(i) %></a>";
								  var val = "<%=dynamicArr.get(i) %>";
								  words += "<a href='#' onclick=\"onLinkClick('<%= dynamicArr.get(i) %>')\">" + "<%= dynamicArr.get(i) %></a>";
		                      <%}%>
							  div_dynamic.innerHTML = words;
						  <% } else { %>
					    	  div_dynamic.innerHTML = "Search for keywords.";
						  <% } 
						  	dynamicArr.clear();	
					  	  %>
					}

					function onLinkClick(tweet) {
						//alert(tweet);
						document.getElementById('display_box').value = tweet;
					}

					//====Functions====	 
					google.maps.event.addDomListener(window, 'load', initialize);
        </script>
    </body>
</html>

