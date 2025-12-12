<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="java.sql.*" %>

    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>CDs</title>



<style>
    body{
        font-family: Arial, sans-serif;
        background:#f4f4f4;
        padding:30px;
    }
    .logout {
        margin-left: 10px;
        font-size: 14px;
    }
.welcome {
        font-size: 20px;
        font-weight: bold;
        margin-bottom: 15px;
    }
    .navbar{
        background:white;
        padding:12px;
        border-radius:12px;
        margin-bottom:30px;
        box-shadow:0 2px 6px rgba(0,0,0,.1);
    }
    .navbar a{
        margin-right:20px;
        text-decoration:none;
        font-weight:bold;
        color:#333;
    }
    .navbar a:hover{
        color:#0078ff;
    }

    /* GRID */
    .grid{
        display:grid;
        grid-template-columns:repeat(4, 200px);
        gap:20px;
        margin-top:30px;
    }
    
    .item{
        background:white;
        padding:30px;
        text-align:center;
        border-radius:10px;
        box-shadow:0 2px 5px rgba(0,0,0,.08);
    }

    .item a{
        text-decoration:none;
        color:#333;
        font-weight:bold;
        font-size:20px;
    }

    .item a:hover{
        color:#0078ff;
    }
</style>

</head>
<body>


<div class="navbar">
    <a href='success.jsp'>Home</a>
    <a class="logout" href='logout.jsp'>(Log out)</a>
</div>

<%
String type = (String) session.getAttribute("userType"); %>
<form method="get" action="SearchCD.jsp" style="margin-bottom:20px;">
<input type="text" name="search" placeholder="Search CDs..."
       style="padding:10px;width:300px;border-radius:8px;border:1px solid #ccc;">
<button type="submit" style="padding:8px 16px;border:none;border-radius:8px;background:#0078ff;color:white;">
    Search
</button>
</form>
<form method="get" action="SearchCDArtist.jsp" style="margin-bottom:20px;">
<input type="text" name="search2" placeholder="Search CD Artists..."
       style="padding:10px;width:300px;border-radius:8px;border:1px solid #ccc;">
<button type="submit" style="padding:8px 16px;border:none;border-radius:8px;background:#0078ff;color:white;">
    Search
</button>
</form>
<form method="get" action="SearchCDYear.jsp" style="margin-bottom:20px;">
<input type="text" name="search3" placeholder="Search Release Year..."
       style="padding:10px;width:300px;border-radius:8px;border:1px solid #ccc;">
<button type="submit" style="padding:8px 16px;border:none;border-radius:8px;background:#0078ff;color:white;">
    Search
</button>
</form>
<% 
if("seller".equals(type)){
    out.print("Post Items for Sale!");
    %>
    <form method="post" action="PostCD.jsp">
        <table>
        	<tr>
                <td>Album Title</td>
                <td><input type="text" name="album" required></td>
            </tr>
            <tr>
                <td>Artist</td>
                <td><input type="text" name="artist" required></td>
            </tr>
            <tr>
                <td>Release Year</td>
                <td><input type="text" name="year" required></td>
            </tr>
            <tr>
				  <td>Type</td>
				  <td>
				    <input type="radio" name="type" value="CD" onclick="showFields(this.value)">CD
				    <input type="radio" name="type" value="Vinyl" onclick="showFields(this.value)">Vinyl
				    <input type="radio" name="type" value="Cassette" onclick="showFields(this.value)">Cassette
				  </td>
			</tr>
			<tr id="cdFields" style="display:none;">
			    <td>Special Edition?</td>
                <td><input type="radio" name="special_edition" value="Yes">True
   					<input type="radio" name="special_edition" value="No">False</td>
			</tr>
			
			<tr id="vinylFields" style="display:none;">
			    <td>Condition</td>
                <td><input type="radio" name="size" value="1">1g
                	<input type="radio" name="size" value="2">2g
   					<input type="radio" name="size" value="3">3g</td>
			</tr>
			
			<tr id="cassetteFields" style="display:none;">
			    <td>Type</td>
                <td><input type="radio" name="typeof" value="Gold">Gold
   					<input type="radio" name="typeof" value="Black">Black</td>
			</tr>
			

            <tr>
                <td>Condition</td>
                <td><input type="radio" name="condition" value="New">New
   					<input type="radio" name="condition" value="Preowned">Preowned</td>
            </tr>
            <tr>
                <td>Initial Starting Price</td>
                <td><input type="text" name="price" required></td>
            </tr>
            <tr>
                <td>Price Increments</td>
                <td><input type="text" name="increment" required></td>
            </tr>
            <tr>
                <td>Minimum Price</td>
                <td><input type="text" name="minprice" required></td>
            </tr>
            <tr>
                <td>Closing Date for Auction</td>
                <td><input type="text" name="closingdate" required></td>
            </tr>
        </table>

        <input type="submit" value="Post Item for Sale">
    </form>
    <br>
    <%



Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection(
"jdbc:mysql://localhost:3306/projectdb","root","school");

PreparedStatement ps = con.prepareStatement("SELECT a.winner_id, a.winning_bid, a.auction_id, m.artist, m.album_title, m.release_year, m.conditions, cd.special_edition, a.start_price, a.increment, a.start_time, a.end_time, a.seller_username FROM Music m JOIN CD cd ON m.artist = cd.artist AND m.album_title = cd.album_title JOIN Auction a ON m.artist = a.artist AND m.album_title = a.album_title;");

ResultSet rs = ps.executeQuery();
%>

<table border="1">
<tr><th>Auction ID</th><th>Artist</th><th>Album</th><th>Year</th><th>Condition</th><th>Special_Edition</th><th>Initial Price</th><th>Increment($)</th><th>Start Time</th><th>End Time</th><th>Seller</th><th>Winner</th><th>Winning Bid</th></tr>
<%
while(rs.next()){
	String aucId= rs.getString("auction_id");
%>
<tr>
<td><%= rs.getString("auction_id") %></td>
<td><%= rs.getString("artist") %></td>
<td><%= rs.getString("album_title") %></td>
<td><%= rs.getString("release_year") %></td>
<td><%= rs.getString("conditions") %></td>
<td><%= rs.getString("special_edition") %></td>

<td><%= rs.getDouble("start_price") %></td>
<td><%= rs.getDouble("increment") %></td>
<td><%= rs.getString("start_time") %></td>
<td><%= rs.getString("end_time") %></td>
<td><%= rs.getString("seller_username") %></td>

	<td>
    <!-- BID HISTORY -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="bid_history">
        <input type="hidden" name="auction_id" value="<%= aucId %>">
        <button type="submit">Bid History</button>
    </form>

    <!-- USER AUCTION PARTICIPATION -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="user_history">
        <br><br>Username:  
            <input type="text" name="userz" required><br>
        <button type="submit">User Auctions</button>
    </form>
	<br><br>
    <!-- SIMILAR ITEMS -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="similar_items">
        <input type="hidden" name="artist" value="<%= rs.getString("artist") %>">
        <input type="hidden" name="album_title" value="<%= rs.getString("album_title") %>">
        <button type="submit">Similar Items (same Artist)</button>
    </form>
</td>
<td><%= rs.getString("winner_id") %></td>
<td><%= rs.getString("winning_bid") %></td>
</tr>

<%
}}
%>
</table>
<%
if("buyer".equals(type)){
    out.print("Buyer!");
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/projectdb","root","school");

    PreparedStatement ps = con.prepareStatement("SELECT a.winner_id, a.winning_bid, a.auction_id, m.artist, m.album_title, m.release_year, m.conditions, cd.special_edition, a.start_price, a.increment, a.start_time, a.end_time, a.seller_username FROM Music m JOIN CD cd ON m.artist = cd.artist AND m.album_title = cd.album_title JOIN Auction a ON m.artist = a.artist AND m.album_title = a.album_title;");

    ResultSet rs = ps.executeQuery();
    
    %>

    <table border="1">
    <tr><th>Auction ID</th><th>Artist</th><th>Album</th><th>Year</th><th>Condition</th><th>Special Edition</th><th>Initial Price($)</th><th>Increment($)</th><th>Start Time</th><th>End Time</th><th>Seller</th><th>Bid?</th><th>Bid History</th><th>Winner</th><th>Winning Bid</th></tr>
    <%
    while(rs.next()){
    	String aucId= rs.getString("auction_id");
    %>
    <tr>
    <td><%= rs.getString("auction_id") %></td>
    <td><%= rs.getString("artist") %></td>
    <td><%= rs.getString("album_title") %></td>
    <td><%= rs.getString("release_year") %></td>
    <td><%= rs.getString("conditions") %></td>
    <td><%= rs.getString("special_edition") %></td>

    <td><%= rs.getDouble("start_price") %></td>
    <td><%= rs.getDouble("increment") %></td>
    <td><%= rs.getString("start_time") %></td>
    <td><%= rs.getString("end_time") %></td>
    <td><%= rs.getString("seller_username") %></td>
    <td>
    <!-- BID BUTTON -->
    <button type="button" onclick="toggleBidForm('<%= aucId %>')">
        Bid
    </button>

    <!-- HIDDEN BID FORM -->
    <div id="bidForm_<%= aucId %>" style="display:none; margin-top:10px;">

        <form action="PlaceBid.jsp" method="post">
            <input type="hidden" name="auction_id" value="<%= aucId %>">
            <input type="hidden" name="artist" value="<%= rs.getString("artist") %>">
       	 	<input type="hidden" name="album_title" value="<%= rs.getString("album_title") %>">

            Bid Amount ($):  
            <input type="number" name="bid_amount" step="0.01" required><br>

            Upper Limit ($) (optional):  
            <input type="number" name="upper_limit" step="0.01"><br><br>
            
            Auto-Bid Increment (optional):<br>
            <input type="number" name="increment" step="0.01"><br><br>

            <button type="submit">Submit Bid</button>
        </form>

    </div>
</td>
	<td>
    <!-- BID HISTORY -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="bid_history">
        <input type="hidden" name="auction_id" value="<%= aucId %>">
        <button type="submit">Bid History</button>
    </form>

    <!-- USER AUCTION PARTICIPATION -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="user_history">
        <br><br>Username:  
            <input type="text" name="userz" required><br>
        <button type="submit">User Auctions</button>
    </form>
	<br><br>
    <!-- SIMILAR ITEMS -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="similar_items">
        <input type="hidden" name="artist" value="<%= rs.getString("artist") %>">
        <input type="hidden" name="album_title" value="<%= rs.getString("album_title") %>">
        <button type="submit">Similar Items (same Artist)</button>
    </form>
</td>
<td><%= rs.getString("winner_id") %></td>
    <td><%= rs.getString("winning_bid") %></td>
    
    </tr>
<%
    }}
    %>
    </table>

<%
String role=(String)session.getAttribute("role");
if("admin".equals(role)){
    out.print("admin!");
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/projectdb","root","school");

    PreparedStatement ps = con.prepareStatement("SELECT a.winner_id, a.winning_bid, a.auction_id, m.artist, m.album_title, m.release_year, m.conditions, cd.special_edition, a.start_price, a.increment, a.start_time, a.end_time, a.seller_username FROM Music m JOIN CD cd ON m.artist = cd.artist AND m.album_title = cd.album_title JOIN Auction a ON m.artist = a.artist AND m.album_title = a.album_title;");

    ResultSet rs = ps.executeQuery();
    %>

    <table border="1">
    <tr><th>Auction ID</th><th>Artist</th><th>Album</th><th>Year</th><th>Condition</th><th>Special_Edition</th><th>Initial Price</th><th>Increment($)</th><th>Start Time</th><th>End Time</th><th>Seller</th><th>Winner</th><th>Winning Bid</th></tr>
    <%
    while(rs.next()){
    
    	String aucId= rs.getString("auction_id");
    %>
    <tr>
    <td><%= rs.getString("auction_id") %></td>
    <td><%= rs.getString("artist") %></td>
    <td><%= rs.getString("album_title") %></td>
    <td><%= rs.getString("release_year") %></td>
    <td><%= rs.getString("conditions") %></td>
    <td><%= rs.getString("special_edition") %></td>

    <td><%= rs.getDouble("start_price") %></td>
    <td><%= rs.getDouble("increment") %></td>
    <td><%= rs.getString("start_time") %></td>
    <td><%= rs.getString("end_time") %></td>
    <td><%= rs.getString("seller_username") %></td>
    
	<td>
    <!-- BID HISTORY -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="bid_history">
        <input type="hidden" name="auction_id" value="<%= aucId %>">
        <button type="submit">Bid History</button>
    </form>

    <!-- USER AUCTION PARTICIPATION -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="user_history">
        <br><br>Username:  
            <input type="text" name="userz" required><br>
        <button type="submit">User Auctions</button>
    </form>
	<br><br>
    <!-- SIMILAR ITEMS -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="similar_items">
        <input type="hidden" name="artist" value="<%= rs.getString("artist") %>">
        <input type="hidden" name="album_title" value="<%= rs.getString("album_title") %>">
        <button type="submit">Similar Items (same Artist)</button>
    </form>
</td>
    <td><%= rs.getString("winner_id") %></td>
<td><%= rs.getString("winning_bid") %></td>
    </tr>

    <%
    }}
    %>
    </table>
<%
if("customer_rep".equals(role)){
    out.print("rep!");
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/projectdb","root","school");

    PreparedStatement ps = con.prepareStatement("SELECT a.winner_id, a.winning_bid, a.auction_id, m.artist, m.album_title, m.release_year, m.conditions, cd.special_edition, a.start_price, a.increment, a.start_time, a.end_time, a.seller_username FROM Music m JOIN CD cd ON m.artist = cd.artist AND m.album_title = cd.album_title JOIN Auction a ON m.artist = a.artist AND m.album_title = a.album_title;");

    ResultSet rs = ps.executeQuery();
    %>

    <table border="1">
    <tr><th>Auction ID</th><th>Artist</th><th>Album</th><th>Year</th><th>Condition</th><th>Special_Edition</th><th>Initial Price</th><th>Increment($)</th><th>Start Time</th><th>End Time</th><th>Seller</th><th>Winner</th><th>Winning Bid</th></tr>
    <%
    while(rs.next()){
    
    	String aucId= rs.getString("auction_id");
    %>
    <tr>
    <td><%= rs.getString("auction_id") %></td>
    <td><%= rs.getString("artist") %></td>
    <td><%= rs.getString("album_title") %></td>
    <td><%= rs.getString("release_year") %></td>
    <td><%= rs.getString("conditions") %></td>
    <td><%= rs.getString("special_edition") %></td>

    <td><%= rs.getDouble("start_price") %></td>
    <td><%= rs.getDouble("increment") %></td>
    <td><%= rs.getString("start_time") %></td>
    <td><%= rs.getString("end_time") %></td>
    <td><%= rs.getString("seller_username") %></td>
    
	<td>
    <!-- BID HISTORY -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="bid_history">
        <input type="hidden" name="auction_id" value="<%= aucId %>">
        <button type="submit">Bid History</button>
    </form>

    <!-- USER AUCTION PARTICIPATION -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="user_history">
        <br><br>Username:  
            <input type="text" name="userz" required><br>
        <button type="submit">User Auctions</button>
    </form>
	<br><br>
    <!-- SIMILAR ITEMS -->
    <form action="ViewHistory.jsp" method="get" style="display:inline;">
        <input type="hidden" name="mode" value="similar_items">
        <input type="hidden" name="artist" value="<%= rs.getString("artist") %>">
        <input type="hidden" name="album_title" value="<%= rs.getString("album_title") %>">
        <button type="submit">Similar Items (same Artist)</button>
    </form>
</td>
    <td><%= rs.getString("winner_id") %></td>
<td><%= rs.getString("winning_bid") %></td>
    </tr>

    <%
    }}
    %>
    </table>



<script>
function showFields(type){
    document.getElementById("cdFields").style.display = (type === "CD") ? "" : "none";
    document.getElementById("vinylFields").style.display = (type === "Vinyl") ? "" : "none";
    document.getElementById("cassetteFields").style.display = (type === "Cassette") ? "" : "none";
}
function toggleBidForm(id) {
    let box = document.getElementById("bidForm_" + id);
    box.style.display = (box.style.display === "none") ? "block" : "none";
}
</script>

</body>
</html>

