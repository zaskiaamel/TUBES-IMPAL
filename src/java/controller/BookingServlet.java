package controller;

import database.DBConnection;
import model.Event;
import model.TicketType;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Menangani dua hal:
 *   GET  /booking?eventId=1  → tampilkan form booking
 *   POST /booking            → proses booking & payment, redirect ke /booking-success
 */
@WebServlet("/booking")
public class BookingServlet extends HttpServlet {

    // ── GET: tampilkan form booking ───────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idParam = request.getParameter("eventId");
        if (idParam == null) { response.sendRedirect("events"); return; }

        try {
            int eventId = Integer.parseInt(idParam);
            Event event = getEventById(eventId);
            List<TicketType> ticketTypes = getTicketTypes(eventId);

            if (event == null) { response.sendRedirect("events"); return; }

            request.setAttribute("event",       event);
            request.setAttribute("ticketTypes", ticketTypes);
            request.getRequestDispatcher("booking.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("events");
        }
    }

    // ── POST: simpan booking ke DB ────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        try {
            int    eventId       = Integer.parseInt(request.getParameter("eventId"));
            int    ticketTypeId  = Integer.parseInt(request.getParameter("ticketTypeId"));
            int    quantity      = Integer.parseInt(request.getParameter("quantity"));
            double totalPrice    = Double.parseDouble(request.getParameter("totalPrice"));
            String paymentMethod = request.getParameter("paymentMethod");

            // Validasi kuota
            List<TicketType> types = getTicketTypes(eventId);
            TicketType chosen = types.stream()
                    .filter(t -> t.getId() == ticketTypeId)
                    .findFirst().orElse(null);

            if (chosen == null || chosen.getAvailable() < quantity) {
                request.setAttribute("error", "Maaf, tiket tidak tersedia atau kuota tidak cukup.");
                request.setAttribute("event",       getEventById(eventId));
                request.setAttribute("ticketTypes", types);
                request.getRequestDispatcher("booking.jsp").forward(request, response);
                return;
            }

            // Buat booking langsung via JDBC
            int bookingId = createBooking(userId, eventId, ticketTypeId, quantity, totalPrice, paymentMethod);

            if (bookingId < 0) {
                request.setAttribute("error", "Terjadi kesalahan saat memproses booking. Coba lagi.");
                request.setAttribute("event",       getEventById(eventId));
                request.setAttribute("ticketTypes", types);
                request.getRequestDispatcher("booking.jsp").forward(request, response);
                return;
            }

            // Redirect ke servlet sukses
            response.sendRedirect(request.getContextPath() + "/booking-success?bookingId=" + bookingId);

        } catch (NumberFormatException e) {
            response.sendRedirect("events");
        }
    }

    // ── Database helper methods ────────────────────────────────────────

    private Event getEventById(int eventId) {
        String sql = "SELECT e.*, (SELECT MIN(tt.price) FROM ticket_types tt WHERE tt.event_id = e.id) AS min_price "
                   + "FROM events e WHERE e.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
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
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private List<TicketType> getTicketTypes(int eventId) {
        List<TicketType> list = new ArrayList<>();
        String sql = "SELECT tt.*, COALESCE(SUM(b.quantity), 0) AS sold "
                   + "FROM ticket_types tt "
                   + "LEFT JOIN bookings b ON b.ticket_type_id = tt.id AND b.payment_status IN ('pending','paid') "
                   + "WHERE tt.event_id = ? "
                   + "GROUP BY tt.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TicketType t = new TicketType();
                    t.setId(rs.getInt("id"));
                    t.setEventId(eventId);
                    t.setTypeName(rs.getString("type_name"));
                    t.setPrice(rs.getDouble("price"));
                    t.setQuota(rs.getInt("quota"));
                    t.setSold(rs.getInt("sold"));
                    t.setAvailable(t.getQuota() - t.getSold());
                    list.add(t);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private int createBooking(int userId, int eventId, int ticketTypeId,
                              int quantity, double totalPrice, String paymentMethod) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);   // mulai transaksi

            // 1. Insert ke bookings
            String sqlBooking = "INSERT INTO bookings "
                    + "(user_id, event_id, ticket_type_id, quantity, total_price, payment_method, payment_status) "
                    + "VALUES (?,?,?,?,?,?,'paid')";

            int bookingId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlBooking, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt   (1, userId);
                ps.setInt   (2, eventId);
                ps.setInt   (3, ticketTypeId);
                ps.setInt   (4, quantity);
                ps.setDouble(5, totalPrice);
                ps.setString(6, paymentMethod);
                ps.executeUpdate();

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        bookingId = keys.getInt(1);
                    }
                }
            }

            if (bookingId == -1) {
                conn.rollback();
                return -1;
            }

            // 2. Generate tiket (satu tiket per quantity)
            String sqlTicket = "INSERT INTO tickets (booking_id, ticket_code) VALUES (?,?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlTicket)) {
                for (int i = 0; i < quantity; i++) {
                    String code = generateTicketCode();
                    ps.setInt   (1, bookingId);
                    ps.setString(2, code);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            conn.commit();
            return bookingId;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            return -1;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    private String generateTicketCode() {
        String uuid = UUID.randomUUID().toString().replace("-", "").toUpperCase();
        return "EVT-" + uuid.substring(0,4) + "-" + uuid.substring(4,8);
    }
}
