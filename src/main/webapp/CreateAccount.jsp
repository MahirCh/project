<%@ page import ="java.sql.*" %>
<%
try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/projectdb","root","school"
    );

    Statement st = con.createStatement();
    String user = request.getParameter("userid");
    String fname= request.getParameter("fname");
   	String lname= request.getParameter("lname");
   	String phone= request.getParameter("phone");
   	String address= request.getParameter("address");
    
    String userid = request.getParameter("username");
    String pwd = request.getParameter("password");
    String sellbuy= request.getParameter("sellbuy");
	
    String sql = "SELECT * FROM End_User WHERE user_id = ?";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, user);
    ResultSet rs = ps.executeQuery();
    if(rs.next()){
    	out.print("Each user can only have one account!"); %>
    	<a href="login.jsp">Please Login</a> <% 
    	
    } else {
    	String insert = "INSERT INTO End_User(user_id, first_name, last_name, address, phone) VALUES (?, ?, ?, ?, ?)";
    	PreparedStatement xs = con.prepareStatement(insert);
    	xs.setString(1, user);
        xs.setString(2, fname);
        xs.setString(3, lname);
        xs.setString(4, phone);
        xs.setString(5, address);
        xs.executeUpdate();
        
    
    String insert2 = "INSERT INTO eu_account(username, password, user_id) VALUES (?, ?, ?)";

    PreparedStatement zs = con.prepareStatement(insert2);

    zs.setString(1, userid);
    zs.setString(2, pwd);
    zs.setString(3, user);

    zs.executeUpdate();
    session.setAttribute("currentUser", userid);

    
    if("Seller".equals(sellbuy)){
    	String insert3= "INSERT INTO Seller(username) VALUES (?)";
    			PreparedStatement ab = con.prepareStatement(insert3);
    			ab.setString(1, userid);
    			ab.executeUpdate();
    } else if("Buyer".equals(sellbuy)){
    	String insert4= "INSERT INTO Buyer(username) VALUES (?)";
    			PreparedStatement bc = con.prepareStatement(insert4);
    			bc.setString(1, userid);
    			bc.executeUpdate();
    } else {
    	out.print("You must specify if you are a seller or buyer!");
    	%>
    	<a href="Sellbuy.jsp">Please indicate if you are a seller or buyer to continue.</a> <% 
    	return;
    }
    con.close();

    out.print("Creation succeeded!");%>
	<a href="login.jsp">Please Login</a> <% 
    }
} catch (Exception ex) {
    out.print(ex);
    out.print("Creation failed :()");
}
%>
