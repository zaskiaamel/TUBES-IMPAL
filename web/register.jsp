<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sign Up - Eventify</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="container">
    <div class="top-logo">
        <img src="images/logo.png" class="small-logo" alt="Eventify">
    </div>
    <h1 class="title">Sign up</h1>
    <% if (error != null) { %>
        <div style="color:red; margin-bottom:12px; font-size:14px;"><%= error %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/RegisterServlet" method="post">
        <div class="form-group">
            <input type="text"  name="name"     placeholder="Full Name"      required>
        </div>
        <div class="form-group">
            <input type="email" name="email"    placeholder="Email Address"  required>
        </div>
        <div class="form-group">
            <input type="password" name="password" placeholder="Password (min. 6 karakter)" required>
        </div>
        <button class="btn" type="submit">Create Account</button>
    </form>
    <div class="link">
        <a href="<%= request.getContextPath() %>/login.jsp">or Log in</a>
    </div>
</div>

</body>
</html>
