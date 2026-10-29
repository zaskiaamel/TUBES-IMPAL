package controller;

import database.DBConnection;
import model.Booking;
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

/** URL: /my-tickets */
@WebServlet("/my-tickets")
public class MyTicketServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        List<Booking> tickets = getTicketsByUser(userId);

        request.setAttribute("tickets", tickets);
        request.getRequestDispatcher("myticket.jsp").forward(request, response);
    }

    private List<Booking> getTicketsByUser(int userId) {
        List<Booking> list = new ArrayList<>();
        String sql =
            "SELECT b.*, "
          + "  e.title AS event_title, e.date AS event_date, "
          + "  e.time AS event_time,   e.location AS event_location, "
          + "  e.image_url AS event_image_url, "
          + "  tt.type_name, "
          + "  (SELECT t.ticket_code FROM tickets t WHERE t.booking_id = b.id ORDER BY t.id LIMIT 1) AS ticket_code, "
          + "  (SELECT t.status      FROM tickets t WHERE t.booking_id = b.id ORDER BY t.id LIMIT 1) AS ticket_status "
          + "FROM bookings b "
          + "JOIN events       e  ON e.id  = b.event_id "
          + "JOIN ticket_types tt ON tt.id = b.ticket_type_id "
          + "WHERE b.user_id = ? "
          + "ORDER BY b.booked_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBooking(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Booking mapBooking(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.id            = rs.getInt("id");
        b.userId        = rs.getInt("user_id");
        b.eventId       = rs.getInt("event_id");
        b.ticketTypeId  = rs.getInt("ticket_type_id");
        b.quantity      = rs.getInt("quantity");
        b.totalPrice    = rs.getDouble("total_price");
        b.paymentMethod = rs.getString("payment_method");
        b.paymentStatus = rs.getString("payment_status");
        b.bookedAt      = rs.getString("booked_at");
        b.eventTitle    = rs.getString("event_title");
        b.eventDate     = rs.getString("event_date");
        b.eventTime     = rs.getString("event_time");
        b.eventLocation = rs.getString("event_location");
        b.eventImageUrl = rs.getString("event_image_url");
        b.typeName      = rs.getString("type_name");
        b.ticketCode    = rs.getString("ticket_code");
        b.ticketStatus  = rs.getString("ticket_status");
        return b;
    }
}