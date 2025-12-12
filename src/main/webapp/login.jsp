<!DOCTYPE html>
<html>
<head>
<title>Login Form</title>
</head>
<body>
<form action="checkLoginDetails.jsp" method="POST">
Login! <br/>
Username: <input type="text" name="username"/> <br/>
Password: <input type="password" name="password"/> <br/>
<input type="submit" value="Submit"/>
</form>

<form action="CreateAccount.jsp" method="POST">
<br/>
Create Account! <br/>
Enter User ID (UNIQUE IDENTIFIER for each User): <input type="text" name="userid"/> <br/>
First Name:  <input type="text" name="fname"/> <br/>
Last_name:<input type="text" name="lname"/> <br/>
Address:<input type="text" name="address"/> <br/>
Phone:<input type="text" name="phone"/> <br/>
Username(Must be Unique!): <input type="text" name="username"/> <br/>
Password: <input type="password" name="password"/> <br/>
Seller or Buyer Account? <input type="text" name="sellbuy"/> <br/>
<input type="submit" value="Submit"/>
</form>
</body>
</html>
