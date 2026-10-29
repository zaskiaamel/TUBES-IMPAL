package controller;

import database.DBConnection;
import model.Event;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Servlet yang mengambil daftar event dari DB lalu forward ke dashboard.jsp.
 * Mendukung pencarian (keyword) dan filter kategori.
 * URL: /events
 */
@WebServlet("/events")
public class EventListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String keyword  = request.getParameter("keyword");
        String category = request.getParameter("category");

        List<Event> events = new ArrayList<>();
        List<String> categories = new ArrayList<>();

        boolean hasKeyword  = keyword  != null && !keyword.trim().isEmpty();
        boolean hasCategory = category != null && !category.trim().isEmpty();

        // Query Categories
        String catSql = "SELECT DISTINCT category FROM events WHERE category IS NOT NULL ORDER BY category";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(catSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Query Events
        StringBuilder sql = new StringBuilder(
            "SELECT e.*, "
          + "(SELECT MIN(tt.price) FROM ticket_types tt WHERE tt.event_id = e.id) AS min_price "
          + "FROM events e WHERE 1=1 ");

        if (hasKeyword)  sql.append("AND e.title LIKE ? ");
        if (hasCategory) sql.append("AND e.category = ? ");
        sql.append("ORDER BY e.date ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            if (hasKeyword)  ps.setString(idx++, "%" + keyword.trim() + "%");
            if (hasCategory) ps.setString(idx,   category.trim());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    events.add(mapEvent(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("events",     events);
        request.setAttribute("categories", categories);
        request.setAttribute("keyword",    keyword  != null ? keyword  : "");
        request.setAttribute("category",   category != null ? category : "");

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    private Event mapEvent(ResultSet rs) throws SQLException {
        Event e = new Event();
        e.id          = rs.getInt("id");
        e.title       = rs.getString("title");
        e.setDescription(rs.getString("description"));
        e.date        = rs.getString("date");
        e.setTime(rs.getString("time"));
        e.location    = rs.getString("location");
        e.setCapacity(rs.getInt("capacity"));
        e.setCategory(rs.getString("category"));
        e.setImageUrl(rs.getString("image_url"));
        try { e.setMinPrice(rs.getDouble("min_price")); } catch (SQLException ignored) {}
        return e;
    }
}
