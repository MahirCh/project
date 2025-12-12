<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*" %>
<% 
try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/projectdb","root","school"
    );
String userid = (String) session.getAttribute("currentUser");
String sellbuy = request.getParameter("sellbuy");

if (userid == null) {
    out.print("Invalid session. Please login again.");
    return;
}

if ("Seller".equals(sellbuy)) {
    PreparedStatement ps = con.prepareStatement("INSERT INTO Seller(username) VALUES (?)");
    ps.setString(1, userid);
    ps.executeUpdate();
} else if ("Buyer".equals(sellbuy)) {
    PreparedStatement ps = con.prepareStatement("INSERT INTO Buyer(username) VALUES (?)");
    ps.setString(1, userid);
    ps.executeUpdate();
} else {
    
    out.print("You must specify if you are a seller or buyer!");
	%>
	<a href="Sellbuy.jsp">Please indicate if you are a seller or buyer to continue.</a> <%
    return;
}

out.print("Creation succeeded!"); %>
<a href="login.jsp">Please Login</a> <% 
} catch (Exception ex) {
    out.print(ex);
    out.print("Creation failed :()");
}
%>