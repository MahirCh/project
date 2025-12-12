<%@ page import="java.sql.*" %>
<%

try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/projectdb","root","school"
    );

    String user = request.getParameter("useridz");

    
    PreparedStatement ps = con.prepareStatement(
        "SELECT * FROM End_User WHERE user_id = ?"
    );
    ps.setString(1, user);
    ResultSet rs = ps.executeQuery();

    if (!rs.next()) {
        out.print("User does not exist!");
%>
        <a href="success.jsp">Back home</a>
<%
        return;
    }

    
    PreparedStatement ps2 = con.prepareStatement(
        "SELECT username FROM eu_account WHERE user_id = ?"
    );
    ps2.setString(1, user);
    ResultSet rs2 = ps2.executeQuery();

    if (!rs2.next()) {
        out.print("Account not found!");
        return;
    }

    String username = rs2.getString("username");
    
    PreparedStatement q = con.prepareStatement(
    	    "Select * from question WHERE username = ?"
    	);
    	q.setString(1, username);
    	ResultSet r = q.executeQuery();

        boolean hasQuestion = r.next();
        if(hasQuestion){
 
    			PreparedStatement q2 = con.prepareStatement(
    		    	    "Delete from question WHERE username = ?"
    		    	);
    		    	q2.setString(1, username);
    		    	q2.executeUpdate();
        }
    
    PreparedStatement ps3 = con.prepareStatement(
        "SELECT * FROM seller WHERE username = ?"
    );
    ps3.setString(1, username);
    ResultSet rs3 = ps3.executeQuery();

    boolean isSeller = rs3.next();

    
    PreparedStatement ps4 = con.prepareStatement(
        "SELECT * FROM buyer WHERE username = ?"
    );
    ps4.setString(1, username);
    ResultSet rs4 = ps4.executeQuery();

    boolean isBuyer = rs4.next();

    
    if (isSeller) {
        PreparedStatement del1 = con.prepareStatement(
            "DELETE FROM seller WHERE username = ?"
        );
        del1.setString(1, username);
        del1.executeUpdate();
     
        PreparedStatement del3 = con.prepareStatement(
            "DELETE FROM eu_account WHERE user_id = ?"
        );
        del3.setString(1, user);
        del3.executeUpdate();

        
        PreparedStatement del4 = con.prepareStatement(
            "DELETE FROM end_user WHERE user_id = ?"
        );
        del4.setString(1, user);
        del4.executeUpdate();

        out.print("Account Deleted Successfully!"); %>
        <a href="success.jsp">Back home</a> <%
        return;
    }

    if (isBuyer) {
        PreparedStatement del2 = con.prepareStatement(
            "DELETE FROM buyer WHERE username = ?"
        );
        del2.setString(1, username);
        del2.executeUpdate();
     
        PreparedStatement del3 = con.prepareStatement(
            "DELETE FROM eu_account WHERE user_id = ?"
        );
        del3.setString(1, user);
        del3.executeUpdate();

        
        PreparedStatement del4 = con.prepareStatement(
            "DELETE FROM end_user WHERE user_id = ?"
        );
        del4.setString(1, user);
        del4.executeUpdate();

        out.print("Account Deleted Successfully!"); %>
        <a href="success.jsp">Back home</a> <% 
        return;
    }

    out.print("Account not found!");
    return;

} catch(Exception e) {
	 java.io.StringWriter sw = new java.io.StringWriter();
	    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
	    e.printStackTrace(pw);

	    out.println("<pre>" + sw.toString() + "</pre>");
}

%>
