<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    /*
     * payment.jsp sebelumnya berisi data hardcoded dan tidak terhubung ke alur booking.
     * Sekarang halaman ini diredirect ke /events karena pilihan metode pembayaran
     * sudah terintegrasi langsung di booking.jsp (inline payment section).
     *
     * Jika ada link lama yang mengarah ke payment.jsp, akan diredirect ke dashboard.
     */
    response.sendRedirect(request.getContextPath() + "/events");
%>
