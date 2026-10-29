package model;

public class Booking {
    public int id; // maps to bookingId / id
    public int userId;
    public int eventId;
    public int ticketTypeId;
    public int quantity;
    public double totalPrice;
    public String paymentMethod;
    public String paymentStatus;
    public String bookedAt;

    // Join fields
    public String eventTitle;
    public String eventDate;
    public String eventTime;
    public String eventLocation;
    public String typeName;
    public String ticketCode;
    public String ticketStatus;
    public String eventImageUrl;

    public Booking() {}

    public Booking(int id, int userId, int eventId, int ticketTypeId,
                   int quantity, double totalPrice,
                   String paymentMethod, String paymentStatus) {
        this.id = id;
        this.userId = userId;
        this.eventId = eventId;
        this.ticketTypeId = ticketTypeId;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
    }

    // Getters for backward compatibility with model methods
    public int getBookingId() { return id; }
    public int getUserId() { return userId; }
    public int getEventId() { return eventId; }
    public int getTicketTypeId() { return ticketTypeId; }
    public int getQuantity() { return quantity; }
    public double getTotalPrice() { return totalPrice; }
    public String getPaymentMethod() { return paymentMethod; }
    public String getPaymentStatus() { return paymentStatus; }
    public String getBookedAt() { return bookedAt; }

    public double calculateTotal(double pricePerTicket) {
        return pricePerTicket * quantity;
    }
}
