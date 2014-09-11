<%@page import="com.google.appengine.demos.twitmap.TwitterSearch"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta charset="utf-8">
    <title>Heatmaps</title>
    <style>
      html, body, #map-canvas {
        height: 100%;
        margin: 0px;
        padding: 0px
      }
      #panel {
        position: absolute;
        top: 5px;
        left: 50%;
        margin-left: -180px;
        z-index: 5;
        background-color: #fff;
        padding: 5px;
        border: 1px solid #999;
      }
    </style>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=visualization"></script>
    <script>
var map, pointarray, heatmap;
 var latArr = [];
 var longArr = [];
 var taxiData = [];
 var locArr = [];
 var geo;
 var len;
 var counter = 0;
 var cnt = 0;

var intervals = setInterval("getAddress()", 1000);
function initialize() {
  var mapOptions = {
    zoom: 2,
    center: new google.maps.LatLng(37.774546, -122.433523),
    mapTypeId: google.maps.MapTypeId.SATELLITE
  };

  geo = new google.maps.Geocoder();
  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);

<% ArrayList<String> list = new ArrayList<String>(); %>
                      <%list = TwitterSearch.dataArr;%>
                      var jsArray = [], longLatArr = [];
					  len = "<%= list.size()%>";
                      <%for(int i=0;i<list.size();i++){%>
						locArr.push("<%= list.get(i)%>");		
  						 // getAddress("<%= list.get(i)%>");
                      <%}%>
  //var pointArray = new google.maps.MVCArray(taxiData);

  //heatmap = new google.maps.visualization.HeatmapLayer({
  //  data: pointArray
  //});

  //heatmap.setMap(map);
}

// Geocoding 
function getAddress() {
	counter++;
	cnt++;
	if(cnt >= locArr.length) {
		//alert("cnt: " + cnt + ", locaArr length: " + locArr.length);
	    clearInterval(intervals);
	}
	geo.geocode({address:locArr[cnt]}, function (results,status) { 
    	if (status == google.maps.GeocoderStatus.OK) {
        	var p = results[0].geometry.location;
            var lat=p.lat();
            var lng=p.lng();
			//alert("lat: " + lat);
			//alert("lng: " + lng);
			 taxiData.push(new google.maps.LatLng(lat, lng));
			 //alert("Length: " + len + ", Counter: " + counter);
			 //alert("taxiData length" + taxiData.length);

			 //if(counter == len) {
			    //alert(taxiData);
  				var pointArray = new google.maps.MVCArray(taxiData);

				heatmap = new google.maps.visualization.HeatmapLayer({
				  data: pointArray
				});

				heatmap.setMap(map);
			 //}
        }
    });
}


function toggleHeatmap() {
  heatmap.setMap(heatmap.getMap() ? null : map);
}

function changeGradient() {
  var gradient = [
    'rgba(0, 255, 255, 0)',
    'rgba(0, 255, 255, 1)',
    'rgba(0, 191, 255, 1)',
    'rgba(0, 127, 255, 1)',
    'rgba(0, 63, 255, 1)',
    'rgba(0, 0, 255, 1)',
    'rgba(0, 0, 223, 1)',
    'rgba(0, 0, 191, 1)',
    'rgba(0, 0, 159, 1)',
    'rgba(0, 0, 127, 1)',
    'rgba(63, 0, 91, 1)',
    'rgba(127, 0, 63, 1)',
    'rgba(191, 0, 31, 1)',
    'rgba(255, 0, 0, 1)'
  ]
  heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);
}

function changeRadius() {
  heatmap.set('radius', heatmap.get('radius') ? null : 20);
}

function changeOpacity() {
  heatmap.set('opacity', heatmap.get('opacity') ? null : 0.2);
}

google.maps.event.addDomListener(window, 'load', initialize);

    </script>
  </head>

  <body>
    <div id="panel">
      <button onclick="toggleHeatmap()">Toggle Heatmap</button>
      <button onclick="changeGradient()">Change gradient</button>
      <button onclick="changeRadius()">Change radius</button>
      <button onclick="changeOpacity()">Change opacity</button>
    </div>
    <div id="map-canvas"></div>
  </body>
</html>
