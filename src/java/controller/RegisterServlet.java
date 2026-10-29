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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name     = request.getParameter("name");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");

     
        if (name == null || name.trim().isEmpty()
         || email == null || email.trim().isEmpty()
         || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Semua field wajib diisi.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Password minimal 6 karakter.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        
        boolean success = false;
        boolean emailExists = false;

        String checkSql = "SELECT id FROM users WHERE email = ? LIMIT 1";
        String insertSql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, MD5(?), 'participant')";

        try (Connection conn = DBConnection.getConnection()) {
            
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setString(1, email.trim());
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        emailExists = true;
                    }
                }
            }

            if (!emailExists) {
              
                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setString(1, name.trim());
                    psInsert.setString(2, email.trim());
                    psInsert.setString(3, password.trim());
                    psInsert.executeUpdate();
                    success = true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (emailExists) {
            request.setAttribute("error", "Email sudah terdaftar. Silakan login.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!success) {
            request.setAttribute("error", "Terjadi kesalahan saat pendaftaran. Silakan coba lagi.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        response.sendRedirect("login.jsp?registered=1");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }
}