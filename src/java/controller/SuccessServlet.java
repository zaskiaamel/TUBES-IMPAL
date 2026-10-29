package controller;

import database.DBConnection;
import model.Booking;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Menangani halaman konfirmasi booking berhasil.
 * URL: /booking-success?bookingId=X
 */
@WebServlet("/booking-success")
public class SuccessServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String bidParam = request.getParameter("bookingId");
        if (bidParam == null) {
            response.sendRedirect(request.getContextPath() + "/events");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bidParam);
            int userId    = (int) session.getAttribute("userId");

            Booking booking = getBookingById(bookingId);

            // Pastikan booking ini milik user yang sedang login (keamanan)
            if (booking == null || booking.userId != userId) {
                response.sendRedirect(request.getContextPath() + "/events");
                return;
            }

            request.setAttribute("booking", booking);
            request.getRequestDispatcher("/success.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/events");
        }
    }

    private Booking getBookingById(int bookingId) {
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
          + "WHERE b.id = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapBooking(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
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
