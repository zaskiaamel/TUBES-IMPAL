package model;

public class Ticket {

    private int ticketId;
    private String ticketCode;
    private String eventName;

    public Ticket() {
    }

    public Ticket(int ticketId, String ticketCode, String eventName) {
        this.ticketId = ticketId;
        this.ticketCode = ticketCode;
        this.eventName = eventName;
    }

    public int getTicketId() {
        return ticketId;
    }

    public String getTicketCode() {
        return ticketCode;
    }

    public String getEventName() {
        return eventName;
    }
}