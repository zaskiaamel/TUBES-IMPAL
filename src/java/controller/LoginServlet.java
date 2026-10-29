package controller;

import database.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

   
        if (email == null || email.trim().isEmpty()
         || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email dan password wajib diisi.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

     
        int userId = -1;
        String userName = null;
        String userEmail = null;
        String userRole = null;

        String sql = "SELECT id, name, email, role FROM users WHERE email = ? AND password = MD5(?) LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            ps.setString(2, password.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getInt("id");
                    userName = rs.getString("name");
                    userEmail = rs.getString("email");
                    userRole = rs.getString("role");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (userId == -1) {
          
            request.setAttribute("error", "Email atau password salah.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

  
        HttpSession session = request.getSession(true);
        session.setAttribute("userId",    userId);
        session.setAttribute("userName",  userName);
        session.setAttribute("userEmail", userEmail);
        session.setAttribute("userRole",  userRole);
        session.setMaxInactiveInterval(60 * 60); 

   
        if ("admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/admin/events");
        } else {
            response.sendRedirect(request.getContextPath() + "/events");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}