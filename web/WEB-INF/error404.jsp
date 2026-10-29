<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Halaman Tidak Ditemukan - Eventify</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background:#f8f9fa; font-family:'Segoe UI',sans-serif; }
        .err-card { max-width:420px; margin:100px auto; text-align:center; }
        .err-code { font-size:80px; font-weight:800; color:#4f46e5; line-height:1; }
    </style>
</head>
<body>
<div class="err-card">
    <div class="err-code">404</div>
    <h2 class="fw-bold mt-3">Halaman Tidak Ditemukan</h2>
    <p class="text-muted">Halaman yang kamu cari tidak ada atau sudah dipindahkan.</p>
    <a href="<%= request.getContextPath() %>/events" class="btn btn-primary mt-2">Kembali ke Dashboard</a>
</div>
</body>
</html>
