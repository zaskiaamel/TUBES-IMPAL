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
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;


@WebServlet("/admin/events")
public class AdminEventServlet extends HttpServlet {

 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("new".equals(action)) {
            request.getRequestDispatcher("/admin-event-form.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            int id = parseIntParam(request.getParameter("id"), -1);
            if (id < 1) {
                response.sendRedirect(request.getContextPath() + "/admin/events");
                return;
            }
            Event event = getEventById(id);
            if (event == null) {
                response.sendRedirect(request.getContextPath() + "/admin/events");
                return;
            }
            request.setAttribute("event", event);
            request.setAttribute("ticketTypes", getTicketTypes(id));
            request.getRequestDispatcher("/admin-event-form.jsp").forward(request, response);
            return;
        }

        List<Event> events = getAllEvents();
        request.setAttribute("events", events);
        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

 
        if ("delete".equals(action)) {
            int id = parseIntParam(request.getParameter("id"), -1);
            if (id > 0) deleteEvent(id);
            response.sendRedirect(request.getContextPath() + "/admin/events?deleted=1");
            return;
        }

        // ── Field umum event ──────────────────────────────────────────
        String title       = sanitize(request.getParameter("title"));
        String description = sanitize(request.getParameter("description"));
        String date        = sanitize(request.getParameter("date"));
        String time        = sanitize(request.getParameter("time"));
        String location    = sanitize(request.getParameter("location"));
        String imageUrl    = sanitize(request.getParameter("imageUrl"));
        String category    = sanitize(request.getParameter("category"));

        // Validasi field wajib
        if (title.isEmpty() || date.isEmpty() || time.isEmpty() || location.isEmpty()) {
            request.setAttribute("error", "Field title, tanggal, waktu, dan lokasi wajib diisi.");
            // Jika edit, kembalikan data event ke form
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                int id = parseIntParam(idParam, -1);
                if (id > 0) {
                    request.setAttribute("event", getEventById(id));
                    request.setAttribute("ticketTypes", getTicketTypes(id));
                }
            }
            request.getRequestDispatcher("/admin-event-form.jsp").forward(request, response);
            return;
        }

        int capacity = parseIntParam(request.getParameter("capacity"), 0);
        if (capacity < 0) capacity = 0;

        HttpSession session = request.getSession(false);
        int adminId = (int) session.getAttribute("userId");

        // ── CREATE ────────────────────────────────────────────────────
        if ("create".equals(action)) {
            int newId = createEvent(title, description, date, time,
                                    location, capacity, category, imageUrl, adminId);
            if (newId > 0) {
                addTicketTypesFromRequest(request, newId);
            }
            response.sendRedirect(request.getContextPath() + "/admin/events?created=1");
            return;
        }

        // ── UPDATE ────────────────────────────────────────────────────
        if ("update".equals(action)) {
            int id = parseIntParam(request.getParameter("id"), -1);
            if (id < 1) {
                response.sendRedirect(request.getContextPath() + "/admin/events");
                return;
            }

            // 1. Update field event
            updateEvent(id, title, description, date, time,
                        location, capacity, category, imageUrl);

            // 2. Update ticket types yang sudah ada
            updateExistingTicketTypes(request);

            // 3. Hapus ticket types lama yang tidak punya booking, lalu insert baru
            deleteUnbookedTicketTypes(id);
            addTicketTypesFromRequest(request, id);

            response.sendRedirect(request.getContextPath() + "/admin/events?updated=1");
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && "admin".equals(session.getAttribute("userRole"));
    }

    /**
     * Sanitasi input: trim, dan escape karakter HTML berbahaya untuk mencegah XSS.
     * Mengembalikan string kosong jika input null.
     */
    private String sanitize(String input) {
        if (input == null) return "";
        return input.trim()
                    .replace("&",  "&amp;")
                    .replace("<",  "&lt;")
                    .replace(">",  "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'",  "&#x27;");
    }

    /**
     * Parse integer dari string, kembalikan defaultValue jika null / tidak valid.
     */
    private int parseIntParam(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) return defaultValue;
        try { return Integer.parseInt(value.trim()); }
        catch (NumberFormatException e) { return defaultValue; }
    }

    /**
     * Membaca parameter ticketTypeName[], ticketTypePrice[], ticketTypeQuota[]
     * dari form dan menyimpannya sebagai ticket type BARU ke DB.
     * (Field ticketTypeId[] yang kosong / bernilai "new" dianggap baru.)
     */
    private void addTicketTypesFromRequest(HttpServletRequest request, int eventId) {
        String[] ids    = request.getParameterValues("ticketTypeId");
        String[] names  = request.getParameterValues("ticketTypeName");
        String[] prices = request.getParameterValues("ticketTypePrice");
        String[] quotas = request.getParameterValues("ticketTypeQuota");

        if (names == null) return;

        for (int i = 0; i < names.length; i++) {
            if (names[i] == null || names[i].trim().isEmpty()) continue;

            boolean isNew = (ids == null || i >= ids.length
                             || ids[i] == null || ids[i].isEmpty() || "new".equals(ids[i]));
            if (!isNew) continue;

            try {
                double price = Double.parseDouble(prices[i]);
                int    quota = Integer.parseInt(quotas[i]);
                if (price < 0 || quota < 0) continue; // skip nilai negatif
                addTicketType(eventId, sanitize(names[i]), price, quota);
            } catch (NumberFormatException ignored) { /* lewati baris tidak valid */ }
        }
    }

    
    private void updateExistingTicketTypes(HttpServletRequest request) {
        String[] ids    = request.getParameterValues("ticketTypeId");
        String[] names  = request.getParameterValues("ticketTypeName");
        String[] prices = request.getParameterValues("ticketTypePrice");
        String[] quotas = request.getParameterValues("ticketTypeQuota");

        if (ids == null || names == null) return;

        for (int i = 0; i < ids.length; i++) {
            if (ids[i] == null || ids[i].isEmpty() || "new".equals(ids[i])) continue;
            try {
                int    ttId  = Integer.parseInt(ids[i]);
                double price = Double.parseDouble(prices[i]);
                int    quota = Integer.parseInt(quotas[i]);
                if (price < 0 || quota < 0) continue; // skip nilai negatif
                updateTicketType(ttId, sanitize(names[i]), price, quota);
            } catch (NumberFormatException ignored) {}
        }
    }

    // ── Database operations ───────────────────────────────────────────

    private Event getEventById(int id) {
        String sql = "SELECT e.*, (SELECT MIN(tt.price) FROM ticket_types tt WHERE tt.event_id = e.id) AS min_price "
                   + "FROM events e WHERE e.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapEvent(rs);
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

    private List<Event> getAllEvents() {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT e.*, (SELECT MIN(tt.price) FROM ticket_types tt WHERE tt.event_id = e.id) AS min_price "
                   + "FROM events e ORDER BY e.date ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapEvent(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private boolean deleteEvent(int id) {
        String sql = "DELETE FROM events WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private int createEvent(String title, String description, String date,
                            String time, String location, int capacity,
                            String category, String imageUrl, int createdBy) {
        String sql = "INSERT INTO events "
                   + "(title,description,date,time,location,capacity,category,image_url,created_by) "
                   + "VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, date);
            ps.setString(4, time);
            ps.setString(5, location);
            ps.setInt   (6, capacity);
            ps.setString(7, category);
            ps.setString(8, imageUrl);
            ps.setInt   (9, createdBy);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    private boolean addTicketType(int eventId, String typeName, double price, int quota) {
        String sql = "INSERT INTO ticket_types (event_id, type_name, price, quota) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, eventId);
            ps.setString(2, typeName);
            ps.setDouble(3, price);
            ps.setInt   (4, quota);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private boolean updateEvent(int id, String title, String description, String date,
                               String time, String location, int capacity,
                               String category, String imageUrl) {
        String sql = "UPDATE events SET title=?, description=?, date=?, time=?, "
                   + "location=?, capacity=?, category=?, image_url=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, date);
            ps.setString(4, time);
            ps.setString(5, location);
            ps.setInt   (6, capacity);
            ps.setString(7, category);
            ps.setString(8, imageUrl);
            ps.setInt   (9, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private boolean updateTicketType(int ticketTypeId, String typeName, double price, int quota) {
        String sql = "UPDATE ticket_types SET type_name=?, price=?, quota=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, typeName);
            ps.setDouble(2, price);
            ps.setInt   (3, quota);
            ps.setInt   (4, ticketTypeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void deleteUnbookedTicketTypes(int eventId) {
        String sql = "DELETE FROM ticket_types "
                   + "WHERE event_id = ? "
                   + "AND NOT EXISTS ("
                   + "  SELECT 1 FROM bookings b "
                   + "  WHERE b.ticket_type_id = ticket_types.id"
                   + ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
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
}