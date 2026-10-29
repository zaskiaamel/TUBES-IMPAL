<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Booking" %>
<%
    /* Logic query sudah dipindah ke SuccessServlet.
       JSP ini hanya merender data yang sudah disiapkan servlet. */
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Booking booking = (Booking) request.getAttribute("booking");
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/events");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pembayaran Berhasil - Eventify</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body { background:#f8f9fa; font-family:'Segoe UI',sans-serif; }
        .success-card {
            max-width:480px; margin:80px auto; background:#fff;
            border-radius:16px; padding:40px; text-align:center;
            box-shadow:0 4px 24px rgba(0,0,0,.08);
        }
        .icon-circle {
            width:72px; height:72px; border-radius:50%; background:#e8f5e9;
            display:flex; align-items:center; justify-content:center;
            margin:0 auto 24px; font-size:36px; color:#2e7d32;
        }
        .ticket-detail {
            background:#f8f9fa; border-radius:12px; padding:16px;
            text-align:left; margin:20px 0; font-size:14px;
        }
        .ticket-code {
            font-family:monospace; font-size:16px; font-weight:700;
            color:#4f46e5; background:#eef2ff; padding:8px 16px;
            border-radius:8px; display:inline-block; margin:8px 0;
        }
        .method-badge {
            display:inline-block; padding:3px 10px; border-radius:20px;
            background:#e0e7ff; color:#3730a3; font-size:12px; font-weight:600;
        }
        .btn-primary-custom {
            background:#4f46e5; color:#fff; border:none;
            border-radius:10px; padding:12px 24px; font-weight:600;
            text-decoration:none; display:inline-block; margin-top:8px;
            transition: background .2s;
        }
        .btn-primary-custom:hover { background:#4338ca; color:#fff; }
    </style>
</head>
<body>

<div class="success-card">
    <div class="icon-circle"><i class="bi bi-check-circle-fill"></i></div>

    <h2 class="fw-bold mb-2">Pembayaran Berhasil!</h2>
    <p class="text-muted">Tiket kamu sudah dikonfirmasi.</p>

    <div class="ticket-detail">
        <p class="mb-1"><strong>Event:</strong> <%= booking.eventTitle %></p>
        <p class="mb-1"><strong>Tanggal:</strong> <%= booking.eventDate %> &bull; <%= booking.eventTime %> WIB</p>
        <p class="mb-1"><strong>Lokasi:</strong> <%= booking.eventLocation %></p>
        <p class="mb-1"><strong>Jenis Tiket:</strong> <%= booking.typeName %></p>
        <p class="mb-1"><strong>Jumlah:</strong> <%= booking.quantity %> tiket</p>
        <p class="mb-1"><strong>Total Bayar:</strong>
            Rp <%= String.format("%,.0f", booking.totalPrice) %>
        </p>
        <p class="mb-2"><strong>Metode:</strong>
            <span class="method-badge">
                <%= booking.paymentMethod.replace("_", " ").toUpperCase() %>
            </span>
        </p>
        <div class="text-center">
            <small class="text-muted d-block mb-1">Kode Tiket</small>
            <span class="ticket-code"><%= booking.ticketCode %></span>
        </div>
    </div>

    <a href="<%= request.getContextPath() %>/my-tickets" class="btn-primary-custom">
        <i class="bi bi-ticket me-2"></i> Lihat Tiket Saya
    </a>
    <br>
    <a href="<%= request.getContextPath() %>/events" class="text-muted small d-block mt-3">
        Kembali ke Dashboard
    </a>
</div>

</body>
</html>
