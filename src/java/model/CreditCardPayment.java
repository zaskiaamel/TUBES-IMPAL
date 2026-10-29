package model;

public class CreditCardPayment implements PaymentMethod {

    @Override
    public void processPayment() {
        System.out.println("Paid using Credit Card");
    }
}