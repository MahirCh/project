<%@ page import="java.sql.*" %>
<%

try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/projectdb","root","school"
    );

    String id = request.getParameter("id");

    
    PreparedStatement ps = con.prepareStatement(
        "SELECT * FROM auction WHERE auction_id = ?"
    );
    ps.setString(1, id);
    ResultSet rs = ps.executeQuery();

    if (!rs.next()) {
        out.print("Auction does not exist!");
%>
        <a href="success.jsp">Back home</a>
<%
        return;
    } else {
    	PreparedStatement ps2= con.prepareStatement("Delete from auction where auction_id= ?");
    	ps2.setString(1, id);
        ps2.executeUpdate();
        out.print("Auction deleted!");
        %>
        <a href="success.jsp">Back home</a>
<%
    }

    

} catch(Exception e) {
	 java.io.StringWriter sw = new java.io.StringWriter();
	    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
	    e.printStackTrace(pw);

	    out.println("<pre>" + sw.toString() + "</pre>");
}

%>
