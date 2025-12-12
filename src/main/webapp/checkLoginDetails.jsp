<%@ page import ="java.sql.*" %>
<%
String userid = request.getParameter("username");
String pwd = request.getParameter("password");
Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/projectdb","root",
"school");
Statement st = con.createStatement();



ResultSet rs;

rs = st.executeQuery("select * from eu_account where username='" + userid + "' and password='" + pwd + "'");
if (rs.next()) {
 session.setAttribute("user", userid);
 session.setAttribute("role", "end_user"); 


 ResultSet rsSeller = st.executeQuery(
     "select username from seller where username='" + userid + "'"
 );
 if(rsSeller.next()){
     session.setAttribute("userType", "seller");
 }

 ResultSet rsBuyer = st.executeQuery(
     "select username from buyer where username='" + userid + "'"
 );
 if(rsBuyer.next()){
     session.setAttribute("userType", "buyer");
 }

 response.sendRedirect("success.jsp");
 return;
}

rs = st.executeQuery(
"SELECT * FROM admin a JOIN staff_acc s ON a.username=s.username " +
"WHERE s.username='" + userid + "' AND s.password='" + pwd + "'"
);

if (rs.next()) {
session.setAttribute("user", userid); // the username will be stored in the session
session.setAttribute("role", "admin");
out.println("welcome admin" + userid);
out.println("<a href='logout.jsp'>Log out</a>");
response.sendRedirect("success.jsp");
} 


rs = st.executeQuery(
"SELECT * FROM customer_rep c JOIN staff_acc s ON c.username=s.username " +
"WHERE s.username='" + userid + "' AND s.password='" + pwd + "'"
);

if (rs.next()) {
session.setAttribute("user", userid); // the username will be stored in the session
session.setAttribute("role", "customer_rep");
out.println("welcome " + userid);
out.println("<a href='logout.jsp'>Log out</a>");
response.sendRedirect("success.jsp");
} 

out.println("Invalid password <a href='login.jsp'>try again</a>");

%> 


