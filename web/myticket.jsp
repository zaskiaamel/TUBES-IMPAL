<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Booking" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    List<Booking> tickets = (List<Booking>) request.getAttribute("tickets");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Tickets - Eventify</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/myticket.css">
</head>
<body>

<!-- QR Modal -->
<div class="modal-overlay" id="qrModal" onclick="closeModal(event)">
    <div class="modal-card" onclick="event.stopPropagation()">
        <h3 class="fw-semibold text-dark mb-1 fs-4">Your Ticket</h3>
        <p class="text-muted mb-4" id="modalEventTitle">-</p>
        <div class="qr-box">
            <div class="qr-inner">
                <svg width="160" height="160" viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg">
                    <rect x="10" y="10" width="50" height="50" rx="4" fill="#1f2937"/>
                    <rect x="20" y="20" width="30" height="30" rx="2" fill="white"/>
                    <rect x="28" y="28" width="14" height="14" rx="1" fill="#1f2937"/>
                    <rect x="100" y="10" width="50" height="50" rx="4" fill="#1f2937"/>
                    <rect x="110" y="20" width="30" height="30" rx="2" fill="white"/>
                    <rect x="118" y="28" width="14" height="14" rx="1" fill="#1f2937"/>
                    <rect x="10" y="100" width="50" height="50" rx="4" fill="#1f2937"/>
                    <rect x="20" y="110" width="30" height="30" rx="2" fill="white"/>
                    <rect x="28" y="118" width="14" height="14" rx="1" fill="#1f2937"/>
                    <rect x="70" y="10" width="8" height="8" fill="#1f2937"/>
                    <rect x="82" y="10" width="8" height="8" fill="#1f2937"/>
                    <rect x="70" y="70" width="8" height="8" fill="#1f2937"/>
                    <rect x="82" y="82" width="8" height="8" fill="#1f2937"/>
                    <rect x="94" y="70" width="8" height="8" fill="#1f2937"/>
                    <rect x="106" y="94" width="8" height="8" fill="#1f2937"/>
                    <rect x="118" y="70" width="8" height="8" fill="#1f2937"/>
                    <rect x="130" y="82" width="8" height="8" fill="#1f2937"/>
                    <rect x="70" y="142" width="8" height="8" fill="#1f2937"/>
                    <rect x="94" y="130" width="8" height="8" fill="#1f2937"/>
                </svg>
            </div>
        </div>
        <div class="mb-4">
            <p class="text-muted small mb-1">Kode Tiket</p>
            <p class="fw-semibold text-dark font-monospace" id="modalTicketNumber">-</p>
        </div>
        <button class="btn-close-modal"
                onclick="document.getElementById('qrModal').classList.remove('show')">
            Tutup
        </button>
    </div>
</div>

<!-- Header -->
<header class="top-header">
    <div class="container d-flex align-items-center gap-3 py-3" style="max-width:860px;">
        <button class="btn-back" onclick="window.location.href='<%= request.getContextPath() %>/events'">
            <i class="bi bi-arrow-left fs-5"></i>
        </button>
            
        <h1 class="mb-0 fs-5 fw-semibold text-dark">My Tickets</h1>
    </div>
</header>

<main class="container py-4" style="max-width:860px;">

    <% if (tickets == null || tickets.isEmpty()) { %>
    <div class="text-center py-5">
        <i class="bi bi-ticket fs-1 text-muted"></i>
        <p class="text-muted mt-3">Kamu belum punya tiket.</p>
        <a href="<%= request.getContextPath() %>/events" class="btn btn-primary">Jelajahi Event</a>
    </div>
    <% } else {
        for (Booking t : tickets) { %>

    <div class="ticket-card">
        <div class="ticket-inner">
            <div class="ticket-image-wrap">
                <img src="<%= t.eventImageUrl != null ? t.eventImageUrl : "images/event1.jpg" %>"
                     alt="<%= t.eventTitle %>" class="ticket-image"
                     onerror="this.src='images/event1.jpg'">
            </div>
            <div class="p-4 flex-grow-1">
                <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-2">
                    <div>
                        <h3 class="fs-5 fw-semibold text-dark mb-2"><%= t.eventTitle %></h3>
                        <span class="badge-type"><%= t.typeName %></span>
                    </div>
                    <span class="badge-status"><%= t.ticketStatus %></span>
                </div>

                <div class="mb-3">
                    <div class="d-flex align-items-center gap-2 text-muted mb-1">
                        <i class="bi bi-calendar3 detail-icon"></i>
                        <span class="small"><%= t.eventDate %> &bull; <%= t.eventTime %> WIB</span>
                    </div>
                    <div class="d-flex align-items-center gap-2 text-muted mb-1">
                        <i class="bi bi-geo-alt detail-icon"></i>
                        <span class="small"><%= t.eventLocation %></span>
                    </div>
                    <div class="d-flex align-items-center gap-2 text-muted">
                        <i class="bi bi-ticket detail-icon"></i>
                        <span class="small font-monospace"><%= t.ticketCode %></span>
                    </div>
                </div>

                <div class="d-flex gap-2 flex-wrap">
                    <button class="btn-outline-action"
                            onclick="showQR('<%= t.eventTitle %>', '<%= t.ticketCode %>')">
                        <i class="bi bi-qr-code"></i> Show QR
                    </button>
                </div>
            </div>
        </div>
    </div>

    <%  }
    } %>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function showQR(eventTitle, ticketNumber) {
    document.getElementById('modalEventTitle').textContent  = eventTitle;
    document.getElementById('modalTicketNumber').textContent = ticketNumber;
    document.getElementById('qrModal').classList.add('show');
}
function closeModal(e) {
    if (e.target === document.getElementById('qrModal')) {
        document.getElementById('qrModal').classList.remove('show');
    }
}
</script>
</body>
</html>
