<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Event" %>
<%@ page import="model.TicketType" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Event event = (Event) request.getAttribute("event");
    List<TicketType> ticketTypes = (List<TicketType>) request.getAttribute("ticketTypes");
    String error = (String) request.getAttribute("error");
    if (event == null) { response.sendRedirect(request.getContextPath() + "/events"); return; }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Tickets - <%= event.title %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/booking.css">
</head>
<body>

<header class="top-header">
    <div class="container d-flex align-items-center gap-3 py-3" style="max-width:860px;">
        <button class="btn-back" onclick="history.back()">
            <i class="bi bi-arrow-left fs-5"></i>
        </button>
        <h1 class="mb-0 fs-5 fw-semibold text-dark">Book Tickets</h1>
    </div>
</header>

<main class="container py-4" style="max-width:860px;">

    <% if (error != null) { %>
    <div class="alert alert-danger"><%= error %></div>
    <% } %>

    <!-- Event Info -->
    <div class="card-section">
        <div class="d-flex gap-3 mb-4">
            <img src="<%= event.imageUrl != null ? event.imageUrl : "images/event1.jpg" %>"
                 alt="<%= event.title %>" class="event-thumbnail"
                 onerror="this.src='images/event1.jpg'">
            <div>
                <h2 class="fs-5 fw-semibold text-dark mb-2"><%= event.title %></h2>
                <div class="d-flex align-items-center gap-2 text-muted small mb-1">
                    <i class="bi bi-calendar3"></i>
                    <span><%= event.date %> &bull; <%= event.time %> WIB</span>
                </div>
                <div class="d-flex align-items-center gap-2 text-muted small">
                    <i class="bi bi-geo-alt"></i>
                    <span><%= event.location %></span>
                </div>
            </div>
        </div>

        <hr>
        <h3 class="fs-6 fw-semibold text-dark mb-3">Pilih Jenis Tiket</h3>

        <%-- Render satu radio pilihan jenis tiket --%>
        <% if (ticketTypes != null) {
               for (int i = 0; i < ticketTypes.size(); i++) {
                   TicketType tt = ticketTypes.get(i); %>
        <div class="ticket-row d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center gap-3">
                <input type="radio" name="selectedType" id="tt-<%= tt.getId() %>"
                       value="<%= tt.getId() %>"
                       data-price="<%= tt.getPrice() %>"
                       <% if (tt.getAvailable() <= 0) { %>disabled<% } %>
                       onchange="updateTotal()">
                <label for="tt-<%= tt.getId() %>">
                    <p class="ticket-name mb-0"><%= tt.getTypeName() %></p>
                    <p class="ticket-price mb-0">Rp <%= String.format("%,.0f", tt.getPrice()) %></p>
                    <small class="text-muted">Sisa: <%= tt.getAvailable() %> tiket</small>
                </label>
            </div>
        </div>
        <%     }
           } %>

        <hr class="mt-3">

        <!-- Quantity -->
        <div class="d-flex align-items-center gap-3 mt-3">
            <label class="fw-medium">Jumlah Tiket:</label>
            <button class="btn-counter btn-minus" id="btn-minus" onclick="decrement()" disabled>
                <i class="bi bi-dash"></i>
            </button>
            <span id="qty-display" class="counter-value">1</span>
            <button class="btn-counter btn-plus" id="btn-plus" onclick="increment()">
                <i class="bi bi-plus"></i>
            </button>
        </div>
    </div>

    <!-- Total & Form Submit -->
    <div class="card-section d-flex align-items-center justify-content-between flex-wrap gap-3">
        <div>
            <p class="total-label mb-0" id="total-label">Total (1 tiket)</p>
            <p class="total-value mb-0" id="total-value">Rp 0</p>
        </div>
        <button class="btn-proceed" id="btn-proceed" disabled onclick="submitBooking()">
            Lanjut ke Pembayaran
        </button>
    </div>

    <!-- Hidden form yang akan di-submit -->
    <form id="booking-form" action="<%= request.getContextPath() %>/booking" method="post" style="display:none;">
        <input type="hidden" name="eventId"      value="<%= event.id %>">
        <input type="hidden" name="ticketTypeId" id="form-ticket-type-id">
        <input type="hidden" name="quantity"     id="form-quantity">
        <input type="hidden" name="totalPrice"   id="form-total-price">
        <input type="hidden" name="paymentMethod" id="form-payment-method" value="e_wallet">
    </form>

    <!-- Payment Method (inline) -->
    <div class="card-section" id="payment-section" style="display:none;">
        <h3 class="fs-6 fw-semibold text-dark mb-3">Metode Pembayaran</h3>

        <label class="d-flex align-items-center gap-3 border rounded p-3 mb-2 cursor-pointer">
            <input type="radio" name="pay-method" value="credit_card" onchange="setPayMethod(this)">
            <div>
                <strong>Kartu Kredit/Debit</strong>
                <div class="text-muted small">Visa, Mastercard, JCB</div>
            </div>
        </label>

        <label class="d-flex align-items-center gap-3 border rounded p-3 mb-2 cursor-pointer">
            <input type="radio" name="pay-method" value="e_wallet" onchange="setPayMethod(this)">
            <div>
                <strong>E-Wallet</strong>
                <div class="text-muted small">GoPay, OVO, DANA</div>
            </div>
        </label>

        <label class="d-flex align-items-center gap-3 border rounded p-3 cursor-pointer">
            <input type="radio" name="pay-method" value="bank_transfer" onchange="setPayMethod(this)">
            <div>
                <strong>Transfer Bank</strong>
                <div class="text-muted small">BCA, Mandiri, BNI, BRI</div>
            </div>
        </label>

        <button class="btn-proceed mt-3" id="btn-pay" disabled onclick="confirmPay()">
            Bayar Sekarang
        </button>
    </div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let qty = 1;
    const MAX_QTY = 10;

    function getSelectedType() {
        return document.querySelector('input[name="selectedType"]:checked');
    }

    function updateTotal() {
        const radio = getSelectedType();
        if (!radio) return;
        const price = parseFloat(radio.dataset.price);
        const total = price * qty;
        document.getElementById('total-label').textContent = 'Total (' + qty + ' tiket)';
        document.getElementById('total-value').textContent = 'Rp ' + total.toLocaleString('id-ID');
        document.getElementById('btn-proceed').disabled = false;
        document.getElementById('payment-section').style.display = 'none';
        document.getElementById('btn-pay').disabled = true;
    }

    function increment() {
        if (qty < MAX_QTY) { qty++; document.getElementById('qty-display').textContent = qty; }
        document.getElementById('btn-minus').disabled = qty <= 1;
        updateTotal();
    }

    function decrement() {
        if (qty > 1) { qty--; document.getElementById('qty-display').textContent = qty; }
        document.getElementById('btn-minus').disabled = qty <= 1;
        updateTotal();
    }

    function submitBooking() {
        const radio = getSelectedType();
        if (!radio) return;
        const price = parseFloat(radio.dataset.price);
        document.getElementById('form-ticket-type-id').value = radio.value;
        document.getElementById('form-quantity').value = qty;
        document.getElementById('form-total-price').value = price * qty;
        // tampilkan payment section
        document.getElementById('payment-section').style.display = 'block';
        document.getElementById('btn-proceed').disabled = true;
    }

    function setPayMethod(el) {
        document.getElementById('form-payment-method').value = el.value;
        document.getElementById('btn-pay').disabled = false;
    }

    function confirmPay() {
        document.getElementById('booking-form').submit();
    }
</script>
</body>
</html>
