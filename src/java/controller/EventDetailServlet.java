package controller;

import database.DBConnection;
import model.Event;
import model.TicketType;
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
 * Servlet untuk menampilkan detail event dan tiket yang tersedia.
 * URL: /event-detail?id=X
 */
@WebServlet("/event-detail")
public class EventDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Cek session – jika belum login, redirect ke login
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("events");
            return;
        }

        try {
            int eventId = Integer.parseInt(idParam.trim());
            Event event = null;
            List<TicketType> ticketTypes = new ArrayList<>();

            // 1. Get Event by ID
            String eventSql = "SELECT e.*, (SELECT MIN(tt.price) FROM ticket_types tt WHERE tt.event_id = e.id) AS min_price "
                            + "FROM events e WHERE e.id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(eventSql)) {
                ps.setInt(1, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        event = mapEvent(rs);
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            if (event == null) {
                response.sendRedirect("events");
                return;
            }

            // 2. Get Ticket Types for the event
            String ttSql = "SELECT tt.*, COALESCE(SUM(b.quantity), 0) AS sold "
                         + "FROM ticket_types tt "
                         + "LEFT JOIN bookings b ON b.ticket_type_id = tt.id AND b.payment_status IN ('pending','paid') "
                         + "WHERE tt.event_id = ? "
                         + "GROUP BY tt.id";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(ttSql)) {
                ps.setInt(1, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ticketTypes.add(mapTicketType(rs, eventId));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            request.setAttribute("event", event);
            request.setAttribute("ticketTypes", ticketTypes);
            request.getRequestDispatcher("event-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("events");
        }
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

    private TicketType mapTicketType(ResultSet rs, int eventId) throws SQLException {
        TicketType t = new TicketType();
        t.setId(rs.getInt("id"));
        t.setEventId(eventId);
        t.setTypeName(rs.getString("type_name"));
        t.setPrice(rs.getDouble("price"));
        t.setQuota(rs.getInt("quota"));
        t.setSold(rs.getInt("sold"));
        t.setAvailable(t.getQuota() - t.getSold());
        return t;
    }
}
