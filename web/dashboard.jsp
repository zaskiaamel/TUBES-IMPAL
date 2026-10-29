<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Event" %>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String      userName   = (String)         session.getAttribute("userName");
    List<Event> events     = (List<Event>)    request.getAttribute("events");
    List<String>   categories = (List<String>)   request.getAttribute("categories");
    String         keyword    = (String)          request.getAttribute("keyword");
    String         selCat     = (String)          request.getAttribute("category");
    if (keyword  == null) keyword  = "";
    if (selCat   == null) selCat   = "";
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Eventify</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>

<!-- Navbar -->
<div class="navbar">
    <div class="nav-left">
        <img src="images/logoclear_cropped.png" class="logo" alt="Eventify">
    </div>
    <div class="nav-center">
        <a href="my-tickets" class="ticket-btn">
            <i class="bi bi-ticket"></i> My Tickets
        </a>
    </div>
    <div class="nav-right">
        <div class="user-dropdown">
            <button type="button" class="user-btn" onclick="toggleUserMenu()">
                <span>👋🏻 Halo, <%= userName %>!</span>
                <i class="bi bi-chevron-down user-caret"></i>
            </button>
            <div class="user-menu" id="userMenu">
                <a href="<%= request.getContextPath() %>/LogoutServlet" class="user-menu-item">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </div>
    </div>
</div>

<script>
    function toggleUserMenu() {
        document.getElementById('userMenu').classList.toggle('show');
    }

    // Tutup dropdown kalau klik di luar area
    document.addEventListener('click', function (event) {
        const dropdown = document.querySelector('.user-dropdown');
        const menu = document.getElementById('userMenu');
        if (dropdown && !dropdown.contains(event.target)) {
            menu.classList.remove('show');
        }
    });
</script>

<div class="container mt-4">
    <h1>Discover Events</h1>

    <!-- ── Search & Filter Form ───────────────────────────────────── -->
    <form method="get" action="<%= request.getContextPath() %>/events"
          class="d-flex flex-wrap gap-2 mb-4 align-items-center">

        <!-- Search keyword -->
        <div class="input-group" style="max-width:320px;">
            <span class="input-group-text bg-white border-end-0">
                <i class="bi bi-search text-muted"></i>
            </span>
            <input type="text" name="keyword" value="<%= keyword %>"
                   class="form-control border-start-0 ps-0"
                   placeholder="Cari nama event...">
        </div>

        <!-- Dropdown kategori -->
        <select name="category" class="form-select" style="max-width:180px;">
            <option value="">Semua Kategori</option>
            <% if (categories != null) {
                   for (String cat : categories) { %>
            <option value="<%= cat %>" <%= cat.equals(selCat) ? "selected" : "" %>><%= cat %></option>
            <%     }
               } %>
        </select>

        <button type="submit" class="btn btn-primary px-4">Filter</button>

        <% if (!keyword.isEmpty() || !selCat.isEmpty()) { %>
        <a href="<%= request.getContextPath() %>/events" class="btn btn-outline-secondary">Reset</a>
        <% } %>
    </form>

    <!-- ── Hasil Event ────────────────────────────────────────────── -->
    <% if (events == null || events.isEmpty()) { %>
        <div class="alert alert-info">
            <% if (!keyword.isEmpty() || !selCat.isEmpty()) { %>
                Tidak ada event yang cocok dengan pencarian. <a href="<%= request.getContextPath() %>/events">Lihat semua event</a>
            <% } else { %>
                Belum ada event tersedia.
            <% } %>
        </div>
    <% } else { %>
        <p class="text-muted small mb-3"><%= events.size() %> event ditemukan</p>
        <% for (Event ev : events) { %>
        <div class="card">
            <img src="<%= ev.imageUrl != null && !ev.imageUrl.isEmpty() ? ev.imageUrl : "images/event1.jpg" %>"
                 alt="<%= ev.title %>"
                 onerror="this.src='images/event1.jpg'">
            <div class="card-body">
                <span class="badge bg-secondary mb-1"><%= ev.category %></span>
                <h3><%= ev.title %></h3>
                <p><i class="bi bi-geo-alt"></i> <%= ev.location %></p>
                <p><i class="bi bi-calendar3"></i> <%= ev.date %></p>
                <p class="fw-bold">
                    Mulai dari Rp <%= String.format("%,.0f", ev.minPrice) %>
                </p>
                <a class="btn" href="event-detail?id=<%= ev.id %>">Details</a>
            </div>
        </div>
        <% } %>
    <% } %>
</div>

</body>
</html>
