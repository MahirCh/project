<%@ page language="java" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
if (session.getAttribute("user") == null){
%>
You are not logged in<br/>
<a href="login.jsp">Please Login</a>
<%
return;
}
String role=(String)session.getAttribute("role");
%>

<!DOCTYPE html>
<html>
<head>
<title>Success</title>

<style>
    body {
        font-family: Arial, sans-serif;
        background: #f5f5f5;
        padding: 20px;
    }

    .welcome {
        font-size: 20px;
        font-weight: bold;
        margin-bottom: 15px;
    }

    .logout {
        margin-left: 10px;
        font-size: 14px;
    }

    /* NAV BAR */
    .navbar {
        background: white;
        border-radius: 12px;
        overflow: hidden;
        border: 1px solid #ddd;
        width: fit-content;
        margin-bottom: 25px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }

    .navbar a {
        display: inline-block;
        padding: 12px 20px;
        text-decoration: none;
        color: #333;
        font-weight: bold;
        border-right: 1px solid #eee;
        transition: 0.25s;
    }

    .navbar a:last-child {
        border-right: none;
    }

    .navbar a:hover {
        background: #0078ff;
        color: white;
    }
	.form-box {
        background: white;
        padding: 22px;
        border-radius: 12px;
        width: 420px;
        border: 1px solid #ddd;
        box-shadow: 0 2px 5px rgba(0,0,0,0.08);
        margin-top: 25px;
    }

    .form-box table td {
        padding: 8px 5px;
        font-size: 15px;
    }

    .form-box input[type="text"],
    .form-box input[type="password"] {
        width: 260px;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 6px;
        font-size: 14px;
    }

    .form-box input[type="submit"] {
        margin-top: 10px;
        padding: 10px 18px;
        background: #28a745;
        border: none;
        color: white;
        border-radius: 6px;
        cursor: pointer;
        transition: 0.25s;
        font-weight: bold;
    }

    .form-box input[type="submit"]:hover {
        background: #1e8f39;
    }
    /* SEARCH FORM */
    .search-box {
        background: white;
        padding: 20px;
        border-radius: 12px;
        width: 380px;
        border: 1px solid #ddd;
        box-shadow: 0 2px 5px rgba(0,0,0,0.08);
    }

    .search-box input[type="text"] {
        width: 250px;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 6px;
        font-size: 14px;
    }

    .search-box input[type="submit"] {
        padding: 10px 15px;
        background: #0078ff;
        border: none;
        color: white;
        border-radius: 6px;
        cursor: pointer;
        transition: 0.25s;
        font-weight: bold;
    }

    .search-box input[type="submit"]:hover {
        background: #005fcc;
    }
</style>

</head>
<body>

<div class="welcome">
    Welcome TO BuyMe, <%=session.getAttribute("user")%>
    <a class="logout" href='logout.jsp'>(Log out)</a>
</div>

<div class="navbar">
    <a href='success.jsp'>Home</a>
    <a href='CD.jsp'>CDs</a>
    <a href='Vinyl.jsp'>Vinyl</a>
    <a href='Cassette.jsp'>Cassette</a>
    <a href='About_Us.jsp'>About Us</a>
    <a href='Contact_Us.jsp'>Contact Us</a>
    <a href='Questions.jsp'>Q&A</a>
</div>

<% if("customer_rep".equals(role)){ %>
Customer Rep! <br><br><br>

Edit User   <br>

<div class="form-box">
    <h3 style="margin-top:0;">Edit User Info</h3>

    <form method="post" action="editUserInfo.jsp">
        <table>
        	<tr>
                <td>User ID</td>
                <td><input type="text" name="userid" required></td>
            </tr>
            <tr>
                <td>Username</td>
                <td><input type="text" name="username" required></td>
            </tr>
            <tr>
                <td>First Name</td>
                <td><input type="text" name="fname" required></td>
            </tr>
            <tr>
                <td>Last Name</td>
                <td><input type="text" name="lname" required></td>
            </tr>
            <tr>
                <td>Password</td>
                <td><input type="text" name="pass" required></td>
            </tr>
            <tr>
                <td>Address</td>
                <td><input type="text" name="add" required></td>
            </tr>
            <tr>
                <td>Phone</td>
                <td><input type="text" name="phone" required></td>
            </tr>
        </table>

        <input type="submit" value="Edit User">
    </form>
</div>

Delete User<br>

<div class="form-box">
    <h3 style="margin-top:0;">Delete User Info</h3>

    <form method="post" action="deleteUser.jsp">
        <table>
        	<tr>
                <td>User ID</td>
                <td><input type="text" name="useridz" required></td>
            </tr>
        </table>

        <input type="submit" value="Delete User">
    </form>
</div>

Delete Auction<br>

<div class="form-box">
    <h3 style="margin-top:0;">Delete Auction</h3>

    <form method="post" action="deleteAuction.jsp">
        <table>
        	<tr>
                <td>Auction ID</td>
                <td><input type="text" name="id" required></td>
            </tr>
        </table>

        <input type="submit" value="Delete Auction">
    </form>
</div>

<% } %>

<% if("admin".equals(role)) { %>

<div class="form-box">
    <h3 style="margin-top:0;">Create Customer Representative</h3>

    <form method="post" action="createCustomerRep.jsp">
        <table>
        	<tr>
                <td>SSN</td>
                <td><input type="text" name="ssn" required></td>
            </tr>
            <tr>
                <td>First Name</td>
                <td><input type="text" name="fname" required></td>
            </tr>
            <tr>
                <td>Last Name</td>
                <td><input type="text" name="lname" required></td>
            </tr>
            <tr>
                <td>DOB (format YYYY-MM-DD)</td>
                <td><input type="text" name="dob" required></td>
            </tr>
            <tr>
                <td>Address</td>
                <td><input type="text" name="address" required></td>
            </tr>
            <tr>
                <td>Phone</td>
                <td><input type="text" name="phone" required></td>
            </tr>
            <tr>
                <td>Username</td>
                <td><input type="text" name="username" required></td>
            </tr>
            <tr>
                <td>Password</td>
                <td><input type="password" name="password" required></td>
            </tr>
            
            <tr>
                <td>Email</td>
                <td><input type="text" name="email" required></td>
            </tr>
        </table>

        <input type="submit" value="Create Representative">
    </form>
</div>

<div class="navbar">
    <a href='salesReport.jsp'>Sales Report</a>
</div>

<% } %>

<!-- SEARCH ALWAYS SHOWN -->
<div class="search-box">
    <form method="get" action="checkSearchDetails.jsp">
        <table>
            <tr>
                <td>Search</td>
                <td><input type="text" name="item"></td>
            </tr>
        </table>
        <br>
        <input type="submit" value="Find your items to buy today!">
    </form>
</div>

</body>
</html>
