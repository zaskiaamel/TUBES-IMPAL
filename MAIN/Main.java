public class Main {

    public static void main(String[] args) {

        Admin admin =
            new Admin("admin", "123");

        Event e1 =
            new Event(
                "EV001",
                "Music Festival",
                "Bandung",
                "10 Juni 2026",
                150000
            );

        Event e2 =
            new Event(
                "EV002",
                "Tech Conference",
                "Jakarta",
                "15 Juni 2026",
                250000
            );

        // CREATE
        admin.createEvent(e1);
        admin.createEvent(e2);

        // READ
        admin.readEvent();

        // UPDATE
        admin.updateEvent(
            "EV001",
            "International Music Festival"
        );

        admin.readEvent();

        // DELETE
        admin.deleteEvent("EV002");

        admin.readEvent();
    }
}