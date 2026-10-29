import java.util.ArrayList;

public class Admin extends User {

    private ArrayList<Event> daftarEvent;

    public Admin(String username, String password) {
        super(username, password);
        daftarEvent = new ArrayList<>();
    }

    // CREATE
    public void createEvent(Event event) {
        daftarEvent.add(event);
        System.out.println("Event berhasil ditambahkan");
    }

    // READ
    public void readEvent() {

        System.out.println("\nDaftar Event");

        for (Event e : daftarEvent) {
            System.out.println(
                e.getId() + " | " +
                e.getNama() + " | " +
                e.getLokasi() + " | " +
                e.getTanggal() + " | Rp" +
                e.getHarga()
            );
        }
    }

    // UPDATE
    public void updateEvent(String id, String namaBaru) {

        for (Event e : daftarEvent) {

            if (e.getId().equals(id)) {
                e.setNama(namaBaru);

                System.out.println(
                    "Event berhasil diupdate"
                );
                return;
            }
        }

        System.out.println("Event tidak ditemukan");
    }

    // DELETE
    public void deleteEvent(String id) {

        for (Event e : daftarEvent) {

            if (e.getId().equals(id)) {

                daftarEvent.remove(e);

                System.out.println(
                    "Event berhasil dihapus"
                );

                return;
            }
        }

        System.out.println("Event tidak ditemukan");
    }
}