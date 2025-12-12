<%@ page import ="java.sql.*" %>
<%
try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/projectdb","root","school"
    );

    Statement st = con.createStatement();
    String ssn = request.getParameter("ssn");
    String dob= request.getParameter("dob");
    String fname= request.getParameter("fname");
   	String lname= request.getParameter("lname");
   	String phone= request.getParameter("phone");
   	String address= request.getParameter("address");
    
    String userid = request.getParameter("username");
    String pwd = request.getParameter("password");
    String sellbuy= request.getParameter("sellbuy");
	
    
    	String insert = "INSERT INTO staff(ssn, dob, address, phone, last_name, first_name) VALUES (?, ?, ?, ?, ?, ?)";
    	PreparedStatement xs = con.prepareStatement(insert);
    	xs.setString(1, ssn);
        xs.setString(2, dob);
        xs.setString(3, address);
        xs.setString(4, phone);
        xs.setString(5, lname);
        xs.setString(6, fname);
       
        xs.executeUpdate();
        
    
    String insert2 = "INSERT INTO staff_acc(ssn, username, password) VALUES (?, ?, ?)";

    PreparedStatement zs = con.prepareStatement(insert2);

    zs.setString(1, ssn);
    zs.setString(2, userid);
    zs.setString(3, pwd);
    zs.executeUpdate();
    
    String insert3 = "INSERT INTO customer_rep(username, created_by_admin_user) VALUES (?, ?)";
    String user = (String) session.getAttribute("user");
    PreparedStatement ab = con.prepareStatement(insert3);
    ab.setString(1, userid);
    ab.setString(2, user);
   

    ab.executeUpdate();
    con.close();

    out.print("Creation succeeded!");%>
	<a href="login.jsp">Please Login</a> <% 
    
} catch (Exception ex) {
    out.print(ex);
    out.print("Creation failed :()");
}
%>
