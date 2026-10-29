<%@ page contentType="text/html" pageEncoding="UTF-8" %>
    <% String error=(String) request.getAttribute("error"); String registered=request.getParameter("registered"); String
        logout=request.getParameter("logout"); %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="UTF-8">
            <title>Login - Eventify</title>
            <link rel="stylesheet" href="css/style.css">
        </head>

        <body>

            <div class="container">
                <div class="top-logo">
                    <img src="images/logo.png" class="small-logo" alt="Eventify">
                </div>

                <h1 class="title">Log in</h1>

                <% if (error !=null) { %>
                    <div style="color:red; margin-bottom:12px; font-size:14px;">
                        <%= error %>
                    </div>
                    <% } %>
                        <% if ("1".equals(registered)) { %>
                            <div style="color:green; margin-bottom:12px; font-size:14px;">
                                Akun berhasil dibuat! Silakan login.
                            </div>
                            <% } %>
                                <% if ("1".equals(logout)) { %>
                                    <div style="color:#555; margin-bottom:12px; font-size:14px;">
                                        Kamu berhasil logout.
                                    </div>
                                    <% } %>

                                        <form action="<%= request.getContextPath() %>/LoginServlet" method="post">
                                            <div class="form-group">
                                                <input type="email" name="email" placeholder="Email" required>
                                            </div>
                                            <div class="form-group">
                                                <input type="password" name="password" placeholder="Password" required>
                                            </div>
                                            <button class="btn" type="submit">Log in</button>
                                        </form>

                                        <div class="link">
                                            <a href="<%= request.getContextPath() %>/register.jsp">or Sign up</a>
                                        </div>
            </div>

        </body>

        </html>