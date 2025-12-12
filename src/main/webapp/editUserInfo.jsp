<%@ page import="java.sql.*" %>

<%
    String username = request.getParameter("username");
    String userId   = request.getParameter("userid");
    String fname    = request.getParameter("fname");
    String lname    = request.getParameter("lname");
    String address  = request.getParameter("add");
    String phone    = request.getParameter("phone");
    String password = request.getParameter("pass");

   
   

    try {
        Class.forName("com.mysql.jdbc.Driver");

        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/projectdb?useSSL=false&allowPublicKeyRetrieval=true",
            "root",
            "school"
        );

        int rows1 = 0;
        int rows2 = 0;
     // 1. Make sure user exists
        PreparedStatement ps1 = con.prepareStatement(
            "SELECT * FROM End_User WHERE user_id = ?"
        );
        ps1.setString(1, userId);
        ResultSet rs1 = ps1.executeQuery();

        if (!rs1.next()) {
            out.print("User does not exist!");
    %>
            <a href="success.jsp">Back home</a>
    <%
            return;
        }

        // -------- Update account password ------
        if (password != null && !password.trim().isEmpty()) {

            String sql1 = "UPDATE eu_account SET password=?, username=? WHERE user_id=?";
            PreparedStatement ps = con.prepareStatement(sql1);
            ps.setString(1, password);
            ps.setString(2, username);
            ps.setString(3, userId);

            rows1 = ps.executeUpdate();
            ps.close();
        }

        // -------- Update end_user info ---------
        String sql2 = "UPDATE end_user SET first_name=?, last_name=?, address=?, phone=? WHERE user_id=?";
        PreparedStatement ps2 = con.prepareStatement(sql2);
        ps2.setString(1, fname);
        ps2.setString(2, lname);
        ps2.setString(3, address);
        ps2.setString(4, phone);
        ps2.setString(5, userId);

        rows2 = ps2.executeUpdate();
        ps2.close();

        out.println("<h3>Finished.</h3>");
        out.println("Rows updated eu_account: " + rows1 + "<br>");
        out.println("Rows updated end_user: " + rows2 + "<br>");

        %><a href="success.jsp">Back home</a><%
        return;

    } catch (Exception e) {
        out.println("<h3>Error: " + e.getMessage() + "</h3>");
        e.printStackTrace();
    }
%>
