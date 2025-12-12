<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
String username = (String) session.getAttribute("user");
String role = (String) session.getAttribute("role");

if(username == null){
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Q&A – BuyMe</title>

<style>
    body {
        font-family: 'Segoe UI', Tahoma, sans-serif;
        background: #eef3f8;
        padding: 35px;
        margin: 0;
    }
    .container {
        width: 900px;
        background: white;
        margin: auto;
        padding: 30px;
        border-radius: 12px;
        box-shadow:0 3px 8px rgba(0,0,0,0.06);
    }
    h1 {
        font-size: 32px;
        font-weight: 500;
        text-align: center;
        color: #333;
        margin-bottom: 35px;
    }
    .askbox textarea{
        width:100%;
        padding:12px;
        border-radius:10px;
        border:1px solid #bbb;
        resize:vertical;
        font-size:15px;
    }
    .askbox input[type=submit]{
        background:#0084ff;
        border:none;
        padding:12px 22px;
        border-radius:8px;
        color:white;
        cursor:pointer;
        float:right;
        margin-top:8px;
        font-size:15px;
        transition:.2s;
    }
    .askbox input[type=submit]:hover{
        background:#005fcc;
    }
    .question {
        padding:18px;
        background:#ffffff;
        border-radius:10px;
        border:1px solid #ddd;
        margin-bottom:20px;
    }
    .question b{
        color:#333;
    }
    .answer{
        margin-top:12px;
        background:#e6f0ff;
        padding:14px;
        border-radius:10px;
        border-left:5px solid #4d8aff;
    }
    .answerform textarea{
        width:100%;
        padding:12px;
        border-radius:10px;
        border:1px solid #ccc;
        resize:vertical;
        font-size:15px;
    }
    .answerform input[type=submit]{
        background:#1976d2;
        border:none;
        padding:10px 18px;
        color:white;
        border-radius:8px;
        margin-top:8px;
        cursor:pointer;
        transition:.2s;
    }
    .answerform input[type=submit]:hover{
        background:#0d47a1;
    }
    .noanswer{
        color:#888;
        margin-top:6px;
        font-style:italic;
    }
</style>
</head>
<body>

<div class="container">

<%
List<Map<String,Object>> questions = new ArrayList<>();


try {
    Class.forName("com.mysql.jdbc.Driver");
    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/projectdb","root","school")) {

        if("customer_rep".equals(role) && request.getParameter("answerQuestion") != null){
            String ans = request.getParameter("answer");
            int qid = Integer.parseInt(request.getParameter("qid"));
            if(ans != null && !ans.trim().isEmpty()){
                String update = "UPDATE Question SET answer=?, handled_by=? WHERE question_id=?";
                try(PreparedStatement psUpd = con.prepareStatement(update)){
                    psUpd.setString(1, ans.trim());
                    psUpd.setString(2, username);
                    psUpd.setInt(3, qid);
                    psUpd.executeUpdate();
                }
            }
        }

        String keyword = request.getParameter("search");

        String fetchQ =
        	    "SELECT q.question_id, q.question_text, q.asked_at, q.answer, q.handled_by, eu.username AS asker " +
        	    "FROM Question q " +
        	    "JOIN eu_account eu ON q.username = eu.username ";   // <-- note space at end

        	if(keyword != null && !keyword.trim().isEmpty()){
        	    fetchQ += "WHERE q.question_text LIKE ? ";
        	}

        	


        fetchQ += "ORDER BY q.asked_at DESC";

        PreparedStatement ps = con.prepareStatement(fetchQ);

        if(keyword != null && !keyword.trim().isEmpty()){
            ps.setString(1, "%" + keyword.trim() + "%");
        }

        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            Map<String,Object> q = new HashMap<>();
            q.put("id", rs.getInt("question_id"));
            q.put("text", rs.getString("question_text"));
            q.put("askedAt", rs.getTimestamp("asked_at"));
            q.put("answer", rs.getString("answer"));
            q.put("handledBy", rs.getString("handled_by"));
            q.put("asker", rs.getString("asker"));
            questions.add(q);
        }

        rs.close();
        ps.close();

    }  // END inner try
}     // END outer try
catch(Exception e){
    out.println(e.getMessage());
}
%>



<h1>Customer Support Q&A</h1>

<% if(!"customer_rep".equals(role)) { %>
<form method="post" action="postQuestion.jsp" class="askbox">
    <textarea name="message" rows="4" placeholder="Ask a question…"></textarea>
    <input type="submit" value="Post Question">
</form>
<br/><br/>
<% } %>


<form method="get" action="SearchQuestions.jsp" style="margin-bottom:20px;">
    <input type="text" name="search" placeholder="Search questions..."
           style="padding:10px;width:300px;border-radius:8px;border:1px solid #ccc;">
    <button type="submit" style="padding:8px 16px;border:none;border-radius:8px;background:#0078ff;color:white;">
        Search
    </button>
</form>

<% for(Map<String,Object> q : questions) { %>


<div class="question">
    <b>Q (by <%= q.get("asker") %> on <%= q.get("askedAt") %>):</b><br/>
    <%= q.get("text") %>

    <% String answer = (String) q.get("answer");
       if(answer != null && !answer.trim().isEmpty()){ %>
       <div class="answer">
           <b>A (by <%= q.get("handledBy") %>):</b><br/>
           <%= answer %>
       </div>
    <% } else if("customer_rep".equals(role)){ %>
       <form method="post" class="answerform">
           <input type="hidden" name="qid" value="<%= q.get("id") %>">
           <textarea name="answer" rows="3" placeholder="Type your answer here..."></textarea>
           <input type="submit" name="answerQuestion" value="Submit Answer">
       </form>
    <% } else { %>
       <div class="noanswer">No answer yet.</div>
    <% } %>
</div>
<% } %>

<a href="showQuestions.jsp">View all questions</a>
</div>
</body>
</html>

