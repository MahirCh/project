<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q&A – BuyMe</title>

<!-- CSS SECTION -->
<style>
    body {
        font-family: Arial;
        background: #f3f3f3;
        margin: 0;
        padding: 30px;
    }

    .container {
        max-width: 700px;
        background: white;
        margin: auto;
        padding: 25px;
        border-radius: 12px;
        box-shadow: 0 3px 6px rgba(0,0,0,0.1);
    }

    h1 {
        text-align: center;
        margin-bottom: 25px;
    }

    fieldset {
        border-radius: 8px;
        padding: 15px;
        border: 1px solid #ddd;
    }

    legend {
        padding: 5px 10px;
        background: #0078ff;
        color: white;
        border-radius: 6px;
    }

    textarea {
        width: 100%;
        padding: 12px;
        border-radius: 6px;
        border: 1px solid #ccc;
        font-size: 14px;
        resize: vertical;
    }

    input[type="submit"] {
        margin-top: 15px;
        padding: 12px 22px;
        background: #0078ff;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-size: 15px;
        transition: .2s;
    }

    input[type="submit"]:hover {
        background: #005dcc;
    }

    .search-box {
        margin-top: 35px;
        padding: 18px;
        background: white;
        border-radius: 12px;
        border: 1px solid #ddd;
        box-shadow: 0 2px 5px rgba(0,0,0,0.06);
    }

    .search-box input[type="text"]{
        padding: 10px;
        width: 250px;
        border: 1px solid #ccc;
        border-radius: 6px;
    }

</style>

</head>
<body>

<div class="container">

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

<h1>Ask Your Questions</h1>

<form method="post" action="postQuestion.jsp">
    <fieldset>
        <legend>Send your question</legend>
        <textarea name="message" id="message" cols="30" rows="8" placeholder="Enter your question here"></textarea>
    </fieldset>
    <input type="submit" value="Post Question">
</form>

<br><br>

<a href="showQuestions.jsp">View all questions</a>


</div> <!-- container end -->



</body>
</html>

<%-- IMPORTANT

Need to iterate through a Question Set. Question Set will be composed of Question and Answer. Cust Rep can post Answers. Users post questions.

--%>




<%-- <% if("customer_rep".equals(role)) { --%> 
    
 
