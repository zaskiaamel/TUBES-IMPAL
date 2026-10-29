<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List" %>
        <%@ page import="model.Event" %>
            <% if (session==null || !"admin".equals(session.getAttribute("userRole"))) {
                response.sendRedirect(request.getContextPath() + "/login.jsp" ); return; } List<Event> events = (List
                <Event>) request.getAttribute("events");
                    String created = request.getParameter("created");
                    String updated = request.getParameter("updated");
                    String deleted = request.getParameter("deleted");
                    String userName = (String) session.getAttribute("userName");
                    %>
                    <!DOCTYPE html>
                    <html lang="id">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Admin Dashboard - Eventify</title>
                        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
                            rel="stylesheet">
                        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"
                            rel="stylesheet">
                        <style>
                            body {
                                background: #f8f9fa;
                                font-family: 'Segoe UI', sans-serif;
                            }

                            .navbar-custom {
                                background: #1e1b4b;
                                padding: 14px 24px;
                                display: flex;
                                justify-content: space-between;
                                align-items: center;
                            }

                            .navbar-custom h2 {
                                color: #fff;
                                margin: 0;
                                font-size: 20px;
                            }

                            .navbar-custom a {
                                color: #c7d2fe;
                                text-decoration: none;
                                font-size: 14px;
                            }

                            .table th {
                                background: #1e1b4b;
                                color: #fff;
                            }

                            .btn-sm-indigo {
                                background: #4f46e5;
                                color: #fff;
                                border: none;
                                border-radius: 6px;
                                padding: 4px 12px;
                                font-size: 13px;
                                cursor: pointer;
                            }

                            .btn-sm-red {
                                background: #dc2626;
                                color: #fff;
                                border: none;
                                border-radius: 6px;
                                padding: 4px 12px;
                                font-size: 13px;
                                cursor: pointer;
                            }
                        </style>
                    </head>

                    <body>

                        <div class="navbar-custom">
                            <h2><i class="bi bi-lightning-fill me-2"></i>Eventify Admin</h2>
                            <div>
                                <span class="text-light me-3 small">Halo, <%= userName %></span>
                                <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
                            </div>
                        </div>

                        <div class="container py-4">

                            <% if ("1".equals(created)) { %>
                                <div class="alert alert-success">Event berhasil dibuat!</div>
                                <% } %>
                                    <% if ("1".equals(updated)) { %>
                                        <div class="alert alert-success">Event berhasil diperbarui!</div>
                                        <% } %>
                                            <% if ("1".equals(deleted)) { %>
                                                <div class="alert alert-warning">Event berhasil dihapus.</div>
                                                <% } %>

                                                    <div class="d-flex justify-content-between align-items-center mb-4">
                                                        <h3 class="fw-bold">Manajemen Event</h3>
                                                        <a href="<%= request.getContextPath() %>/admin/events?action=new"
                                                            class="btn btn-primary">
                                                            <i class="bi bi-plus-circle me-1"></i> Tambah Event
                                                        </a>
                                                    </div>

                                                    <table class="table table-bordered table-hover bg-white">
                                                        <thead>
                                                            <tr>
                                                                <th>#</th>
                                                                <th>Judul</th>
                                                                <th>Kategori</th>
                                                                <th>Tanggal</th>
                                                                <th>Lokasi</th>
                                                                <th>Kapasitas</th>
                                                                <th>Aksi</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <% if (events !=null) { for (Event ev : events) { %>
                                                                <tr>
                                                                    <td>
                                                                        <%= ev.id %>
                                                                    </td>
                                                                    <td>
                                                                        <%= ev.title %>
                                                                    </td>
                                                                    <td>
                                                                        <%= ev.category %>
                                                                    </td>
                                                                    <td>
                                                                        <%= ev.date %>
                                                                    </td>
                                                                    <td>
                                                                        <%= ev.location %>
                                                                    </td>
                                                                    <td>
                                                                        <%= String.format("%,d", ev.capacity) %>
                                                                    </td>
                                                                    <td>
                                                                        <a href="<%= request.getContextPath() %>/admin/events?action=edit&id=<%= ev.id %>"
                                                                            class="btn-sm-indigo me-1">Edit</a>

                                                                        <form
                                                                            action="<%= request.getContextPath() %>/admin/events"
                                                                            method="post" style="display:inline;"
                                                                            onsubmit="return confirm('Hapus event ini?')">
                                                                            <input type="hidden" name="action"
                                                                                value="delete">
                                                                            <input type="hidden" name="id"
                                                                                value="<%= ev.id %>">
                                                                            <button type="submit"
                                                                                class="btn-sm-red">Hapus</button>
                                                                        </form>
                                                                    </td>
                                                                </tr>
                                                                <% } } %>
                                                        </tbody>
                                                    </table>
                        </div>

                    </body>

                    </html>