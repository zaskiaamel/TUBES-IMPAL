import java.util.ArrayList;

public class Participant extends User {

    private ArrayList<Event> eventTersedia;
    private ArrayList<Event> eventDipesan;

    public Participant(String username, String password) {
        super(username, password);

        eventTersedia = new ArrayList<>();
        eventDipesan = new ArrayList<>();
    }

    // Menampilkan event yang tersedia
    public void viewEvent() {

        System.out.println("\n===== DAFTAR EVENT =====");

        for (Event e : eventTersedia) {

            System.out.println(
                e.getId() + " | " +
                e.getNama() + " | " +
                e.getLokasi() + " | " +
                e.getTanggal() + " | Rp" +
                e.getHarga()
            );
        }
    }

    // Menambahkan event ke daftar yang bisa dilihat
    public void addAvailableEvent(Event event) {
        eventTersedia.add(event);
    }

    // Booking event berdasarkan ID
    public void bookingEvent(String id) {

        for (Event e : eventTersedia) {

            if (e.getId().equals(id)) {

                eventDipesan.add(e);

                System.out.println(
                    "Booking berhasil untuk event: "
                    + e.getNama()
                );

                return;
            }
        }

        System.out.println("Event tidak ditemukan");
    }

    // Melihat tiket yang sudah dibooking
    public void viewBooking() {

        System.out.println(
            "\n===== EVENT YANG DIBOOKING ====="
        );

        if (eventDipesan.isEmpty()) {

            System.out.println(
                "Belum ada event yang dibooking"
            );

            return;
        }

        for (Event e : eventDipesan) {

            System.out.println(
                e.getId() + " | " +
                e.getNama() + " | " +
                e.getLokasi() + " | " +
                e.getTanggal()
            );
        }
    }
}