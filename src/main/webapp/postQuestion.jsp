<%@ page import="java.sql.*" %>
<%


try {
	Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/projectdb","root","school"
    );

    
    Statement st = con.createStatement();
    String user = (String) session.getAttribute("user");
    String msg = request.getParameter("message");

    

    // insert question using uid
    String sql = "INSERT INTO Question (username, question_text) VALUES (?, ?)";
    PreparedStatement ps = con.prepareStatement(sql);

    ps.setString(1, user);
    ps.setString(2, msg);

    ps.executeUpdate();

} catch(Exception e){
    e.printStackTrace();
}
%>

<script>
alert("Question added!");
window.location="Questions.jsp";
</script>
