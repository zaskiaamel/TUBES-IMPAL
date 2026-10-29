package database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class untuk mengambil koneksi ke database MySQL.
 * Ubah URL, USER, dan PASSWORD sesuai konfigurasi lokal kalian.
 */
public class DBConnection {

    // ── Sesuaikan 3 baris ini ──────────────────────────────────────────
    private static final String URL      = "jdbc:mysql://localhost:3306/eventify_db"
                                         + "?useSSL=false&serverTimezone=Asia/Jakarta"
                                         + "&allowPublicKeyRetrieval=true";
    private static final String USER     = "root";
    private static final String PASSWORD = "";          // isi jika ada password
    // ──────────────────────────────────────────────────────────────────

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] Driver MySQL tidak ditemukan: " + e.getMessage());
        }
    }

    /**
     * Mengembalikan objek Connection ke database eventify.
     * Jika gagal, mencetak stack trace dan mengembalikan null.
     */
    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            System.err.println("[DBConnection] Koneksi gagal: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}