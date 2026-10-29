package model;

public class Event {
    public int id;
    public String title;
    public String description;
    public String date;          // YYYY-MM-DD from DB
    public String time;
    public String location;
    public int capacity;
    public String category;
    public String imageUrl;
    public double minPrice;      // lowest ticket price for display

    public Event() {}

    public Event(int id, String title, String location, String date, double price) {
        this.id = id;
        this.title = title;
        this.location = location;
        this.date = date;
        this.minPrice = price;
    }

    // Keep basic getters for backward compatibility with root test code if any
    public int getId() { return id; }
    public String getTitle() { return title; }
    public String getLocation() { return location; }
    public String getDate() { return date; }
    public double getPrice() { return minPrice; }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public double getMinPrice() {
        return minPrice;
    }

    public void setMinPrice(double minPrice) {
        this.minPrice = minPrice;
    }
    
    
}