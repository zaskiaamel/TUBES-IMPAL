package model;

/**
 * Abstract base class untuk semua tipe user.
 * Admin dan Participant meng-extend class ini.
 */
public abstract class User {

    public int id;
    public String name;
    public String email;
    public String password;
    public String role;

    public User() {}

    public User(int id, String name, String email, String password) {
        this.id       = id;
        this.name     = name;
        this.email    = email;
        this.password = password;
    }

    // ── Getters ───────────────────────────────────────────────────────
    public int    getId()       { return id; }
    public String getName()     { return name; }
    public String getEmail()    { return email; }
    public String getPassword() { return password; }
    public String getRole()     { return role; }

    // ── Setters ───────────────────────────────────────────────────────
    public void setId(int id)             { this.id       = id; }
    public void setName(String name)      { this.name     = name; }
    public void setEmail(String email)    { this.email    = email; }
    public void setPassword(String pass)  { this.password = pass; }
    public void setRole(String role)      { this.role     = role; }

    // ── Abstract methods ──────────────────────────────────────────────
    public abstract boolean login();
    public abstract void    register();
    public abstract void    logout();

    @Override
    public String toString() {
        return "User{id=" + id + ", name='" + name + "', email='" + email + "', role='" + role + "'}";
    }
}
