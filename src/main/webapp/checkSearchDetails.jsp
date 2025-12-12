<%@ page import ="java.sql.*" %>
<%

String item = request.getParameter("item");

Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/projectdb","root","school"
);

PreparedStatement ps = con.prepareStatement(
    "SELECT * FROM music WHERE album_title LIKE ?"
);
ps.setString(1, "%" + item + "%");

ResultSet rs = ps.executeQuery();

if (rs.next()){
%>

<table border="1">
<tr><th>Title</th><th>Artist</th><th>Year</th></tr>

<%
    do {
%>
<tr>
    <td><%= rs.getString("album_title") %></td>
    <td><%= rs.getString("artist") %></td>
    <td><%= rs.getString("release_year") %></td>
</tr>
<%
    } while(rs.next());
%>
</table>

<%
} else {
    out.print("Sorry! No relevant results.");
}
%>
<a href="success.jsp">Go back</a>