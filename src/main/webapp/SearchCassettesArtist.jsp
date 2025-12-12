<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<%
String search= request.getParameter("search2");
Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/projectdb","root",
"school");
Statement st = con.createStatement();



ResultSet rs;
PreparedStatement ps = con.prepareStatement(
	    "SELECT c.artist, c.album_title, c.type, m.release_year " +
	    "FROM Cassette c JOIN Music m USING(album_title) " +
	    "WHERE c.artist LIKE ?"
	);
	ps.setString(1, "%" + search + "%");


rs = ps.executeQuery();


if(rs.next()){
%>

<table border="1">
<tr><th>Artist</th><th>Album</th><th>Year</th><th>Type</th></tr>


<tr>
<td><%=rs.getString("artist")%></td>
<td><%=rs.getString("album_title")%></td>
<td><%=rs.getString("release_year")%></td>
<td><%=rs.getString("type")%></td>
</tr>

<%
    while(rs.next()){
%>
<tr>
<td><%=rs.getString("artist")%></td>
<td><%=rs.getString("album_title")%></td>
<td><%=rs.getString("release_year")%></td>
<td><%=rs.getString("type")%></td>
</tr>
<%
    }

%>
</table>

<%

	
} else{
	out.print("Sorry! No relevant results."); %>
	<a href="Cassette.jsp">Go back</a>
	<%
	return;
}
%>    
    
    
<a href="Cassette.jsp">Go back</a>
</body>
</html>