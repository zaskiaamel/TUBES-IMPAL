<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Event" %>
<%@ page import="model.TicketType" %>
<%
    if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Event            event       = (Event)            request.getAttribute("event");
    List<TicketType> ticketTypes = (List<TicketType>) request.getAttribute("ticketTypes");
    boolean isEdit      = (event != null);
    String  formAction  = isEdit ? "update" : "create";
    String[] catOptions = {"Music","Technology","Food","Sport","Art","Education","Other"};
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit Event" : "Tambah Event" %> - Eventify Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: 'Segoe UI', sans-serif; }
        .ticket-type-row { background:#f8f9fa; border-radius:8px; padding:10px 12px; margin-bottom:8px; }
        .badge-existing { font-size:11px; background:#e0e7ff; color:#3730a3;
                          padding:2px 8px; border-radius:10px; font-weight:600; }
        .badge-new      { font-size:11px; background:#d1fae5; color:#065f46;
                          padding:2px 8px; border-radius:10px; font-weight:600; }
    </style>
</head>
<body class="bg-light">

<div class="container py-5" style="max-width:680px;">

    <!-- Back link -->
    <a href="<%= request.getContextPath() %>/admin/events" class="text-decoration-none text-muted small mb-3 d-inline-block">
        ← Kembali ke Dashboard
    </a>
    <h3 class="fw-bold mb-4"><%= isEdit ? "Edit Event" : "Tambah Event Baru" %></h3>

    <div class="card p-4 shadow-sm">
        <form action="<%= request.getContextPath() %>/admin/events" method="post">
            <input type="hidden" name="action" value="<%= formAction %>">
            <% if (isEdit) { %>
            <input type="hidden" name="id" value="<%= event.id %>">
            <% } %>

            <!-- Judul -->
            <div class="mb-3">
                <label class="form-label fw-medium">Judul Event <span class="text-danger">*</span></label>
                <input type="text" name="title" class="form-control"
                       value="<%= isEdit ? event.title : "" %>" required>
            </div>

            <!-- Deskripsi -->
            <div class="mb-3">
                <label class="form-label fw-medium">Deskripsi</label>
                <textarea name="description" class="form-control" rows="3"><%= isEdit ? event.description : "" %></textarea>
            </div>

            <!-- Tanggal & Jam -->
            <div class="row">
                <div class="col mb-3">
                    <label class="form-label fw-medium">Tanggal <span class="text-danger">*</span></label>
                    <input type="date" name="date" class="form-control"
                           value="<%= isEdit ? event.date : "" %>" required>
                </div>
                <div class="col mb-3">
                    <label class="form-label fw-medium">Jam Mulai <span class="text-danger">*</span></label>
                    <input type="time" name="time" class="form-control"
                           value="<%= isEdit ? event.time : "" %>" required>
                </div>
            </div>

            <!-- Lokasi -->
            <div class="mb-3">
                <label class="form-label fw-medium">Lokasi <span class="text-danger">*</span></label>
                <input type="text" name="location" class="form-control"
                       value="<%= isEdit ? event.location : "" %>" required>
            </div>

            <!-- Kapasitas & Kategori -->
            <div class="row">
                <div class="col mb-3">
                    <label class="form-label fw-medium">Kapasitas <span class="text-danger">*</span></label>
                    <input type="number" name="capacity" class="form-control"
                           value="<%= isEdit ? event.capacity : 100 %>" min="1" required>
                </div>
                <div class="col mb-3">
                    <label class="form-label fw-medium">Kategori</label>
                    <select name="category" class="form-select">
                        <% for (String c : catOptions) { %>
                        <option value="<%= c %>"
                            <%= (isEdit && c.equals(event.category)) ? "selected" : "" %>>
                            <%= c %>
                        </option>
                        <% } %>
                    </select>
                </div>
            </div>

            <!-- URL Gambar -->
            <div class="mb-4">
                <label class="form-label fw-medium">URL Gambar (opsional)</label>
                <input type="url" name="imageUrl" class="form-control"
                       value="<%= isEdit && event.imageUrl != null ? event.imageUrl : "" %>"
                       placeholder="https://...">
            </div>

            <!-- ── Ticket Types ──────────────────────────────────────── -->
            <hr>
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-semibold mb-0">Jenis Tiket</h5>
                <% if (isEdit) { %>
                <small class="text-muted">
                    Tiket yang sudah dibeli tidak bisa dihapus, hanya kuotanya yang bisa diubah.
                </small>
                <% } %>
            </div>

            <div id="ticket-types">

                <% if (isEdit && ticketTypes != null && !ticketTypes.isEmpty()) {
                       for (TicketType tt : ticketTypes) { %>
                <!-- Ticket type EXISTING (sudah ada di DB) -->
                <div class="ticket-type-row d-flex align-items-center gap-2 flex-wrap">
                    <span class="badge-existing">Existing</span>
                    <!-- ID hidden agar servlet tahu ini update, bukan insert baru -->
                    <input type="hidden" name="ticketTypeId" value="<%= tt.id %>">
                    <input type="text" name="ticketTypeName" class="form-control form-control-sm"
                           style="width:150px;" value="<%= tt.typeName %>" placeholder="Nama" required>
                    <input type="number" name="ticketTypePrice" class="form-control form-control-sm"
                           style="width:130px;" value="<%= (long) tt.price %>"
                           placeholder="Harga (Rp)" min="0" required>
                    <input type="number" name="ticketTypeQuota" class="form-control form-control-sm"
                           style="width:100px;" value="<%= tt.quota %>"
                           placeholder="Kuota" min="<%= tt.sold %>" required>
                    <small class="text-muted">Terjual: <%= tt.sold %></small>
                    <% if (tt.sold == 0) { %>
                    <small class="text-muted">&bull; bisa dihapus dengan menghapus baris ini</small>
                    <% } %>
                </div>
                <%     }
                   } %>

                <!-- Baris pertama untuk ticket type BARU (id kosong = insert) -->
                <div class="ticket-type-row d-flex align-items-center gap-2 flex-wrap" id="new-row-template">
                    <span class="badge-new">Baru</span>
                    <input type="hidden" name="ticketTypeId" value="new">
                    <input type="text" name="ticketTypeName" class="form-control form-control-sm"
                           style="width:150px;" placeholder="Nama (mis. Regular)"
                           <%= !isEdit ? "required" : "" %>>
                    <input type="number" name="ticketTypePrice" class="form-control form-control-sm"
                           style="width:130px;" placeholder="Harga (Rp)" min="0"
                           <%= !isEdit ? "required" : "" %>>
                    <input type="number" name="ticketTypeQuota" class="form-control form-control-sm"
                           style="width:100px;" placeholder="Kuota" min="1"
                           <%= !isEdit ? "required" : "" %>>
                    <% if (isEdit) { %>
                    <button type="button" class="btn btn-sm btn-outline-danger"
                            onclick="removeRow(this)">✕</button>
                    <% } %>
                </div>
            </div>

            <!-- Tombol tambah baris tiket baru -->
            <button type="button" class="btn btn-sm btn-outline-secondary mt-2"
                    onclick="addNewTicketRow()">+ Tambah Jenis Tiket Baru</button>

            <!-- ── Submit ────────────────────────────────────────────── -->
            <div class="d-flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary">
                    <%= isEdit ? "Simpan Perubahan" : "Buat Event" %>
                </button>
                <a href="<%= request.getContextPath() %>/admin/events"
                   class="btn btn-outline-secondary">Batal</a>
            </div>
        </form>
    </div>
</div>

<script>
function addNewTicketRow() {
    const container = document.getElementById('ticket-types');
    const row = document.createElement('div');
    row.className = 'ticket-type-row d-flex align-items-center gap-2 flex-wrap';
    row.innerHTML = `
        <span class="badge-new">Baru</span>
        <input type="hidden" name="ticketTypeId" value="new">
        <input type="text"   name="ticketTypeName"  class="form-control form-control-sm"
               style="width:150px;" placeholder="Nama">
        <input type="number" name="ticketTypePrice" class="form-control form-control-sm"
               style="width:130px;" placeholder="Harga (Rp)" min="0">
        <input type="number" name="ticketTypeQuota" class="form-control form-control-sm"
               style="width:100px;" placeholder="Kuota" min="1">
        <button type="button" class="btn btn-sm btn-outline-danger"
                onclick="removeRow(this)">✕</button>
    `;
    container.appendChild(row);
}

function removeRow(btn) {
    btn.closest('.ticket-type-row').remove();
}
</script>
</body>
</html>
