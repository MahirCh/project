<%@ page import="java.sql.*" %>
<%




try {
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/projectdb","root","school"
    );

    
    Statement st = con.createStatement();
    
    String user = (String) session.getAttribute("user");
    
    String album = request.getParameter("album");
    String artist = request.getParameter("artist");
    String year = request.getParameter("year");
    String type = request.getParameter("type");
    String condition = request.getParameter("condition");
    String price = request.getParameter("price");
    String increment = request.getParameter("increment");
    String minprice = request.getParameter("minprice");
    String end_date = request.getParameter("closingdate");
    
    if("CD".equals(type)){
    	String special_edition = request.getParameter("special_edition");
    	
    	String sql = "INSERT INTO Music (artist, album_title, release_year, conditions) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, artist);
        ps.setString(2, album);
        ps.setString(3, year);
        ps.setString(4, condition);
        ps.executeUpdate();
    	
        String sql2 = "INSERT INTO CD (artist, album_title, special_edition) VALUES (?, ?, ?)";
        PreparedStatement ps2 = con.prepareStatement(sql2);
        ps2.setString(1, artist);
        ps2.setString(2, album);
        ps2.setString(3, special_edition);
        ps2.executeUpdate();
        
        String sql3 = "INSERT INTO auction (artist, album_title, seller_username, start_price, increment, reserve_price, end_time) VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps3 = con.prepareStatement(sql3);
        
        ps3.setString(1, artist);
        ps3.setString(2, album);
        ps3.setString(3, user);
        ps3.setString(4, price);
        ps3.setString(5, increment);
        ps3.setString(6, minprice);
        ps3.setString(7, end_date);
        ps3.executeUpdate(); %>
        <script>
        alert("Item added!");
        window.location="CD.jsp";
        </script>
        <%
    	
    } else if("Vinyl".equals(type)){
    	String size = request.getParameter("size");
    	
    	String sql = "INSERT INTO Music (artist, album_title, release_year, conditions) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, artist);
        ps.setString(2, album);
        ps.setString(3, year);
        ps.setString(4, condition);
        ps.executeUpdate();
        
        String sql2 = "INSERT INTO Vinyl (artist, album_title, size) VALUES (?, ?, ?)";
        PreparedStatement ps2 = con.prepareStatement(sql2);
        ps2.setString(1, artist);
        ps2.setString(2, album);
        ps2.setString(3, size);
        ps2.executeUpdate();
        
        String sql3 = "INSERT INTO auction (artist, album_title, seller_username, start_price, increment, reserve_price, end_time) VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps3 = con.prepareStatement(sql3);
        
        ps3.setString(1, artist);
        ps3.setString(2, album);
        ps3.setString(3, user);
        ps3.setString(4, price);
        ps3.setString(5, increment);
        ps3.setString(6, minprice);
        ps3.setString(7, end_date);
        ps3.executeUpdate();
        %>
        <script>
        alert("Item added!");
        window.location="Vinyl.jsp";
        </script>
        <%
    	
    } else if("Cassette".equals(type)){
    	String typeof = request.getParameter("typeof");
    	
    	
    	String sql = "INSERT INTO Music (artist, album_title, release_year, conditions) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, artist);
        ps.setString(2, album);
        ps.setString(3, year);
        ps.setString(4, condition);
        ps.executeUpdate();
        
        String sql2 = "INSERT INTO Cassette (artist, album_title, type) VALUES (?, ?, ?)";
        PreparedStatement ps2 = con.prepareStatement(sql2);
        ps2.setString(1, artist);
        ps2.setString(2, album);
        ps2.setString(3, typeof);
        
        ps2.executeUpdate();
        
        String sql3 = "INSERT INTO auction (artist, album_title, seller_username, start_price, increment, reserve_price, end_time) VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps3 = con.prepareStatement(sql3);
        
        ps3.setString(1, artist);
        ps3.setString(2, album);
        ps3.setString(3, user);
        ps3.setString(4, price);
        ps3.setString(5, increment);
        ps3.setString(6, minprice);
        ps3.setString(7, end_date);
        ps3.executeUpdate();
        %>
        <script>
        alert("Item added!");
        window.location="Cassette.jsp";
        </script>
        <%
        
    }

    


} catch(Exception e){
    e.printStackTrace();
}
%>


