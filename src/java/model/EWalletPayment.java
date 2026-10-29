package model;

public class EWalletPayment implements PaymentMethod {

    @Override
    public void processPayment() {
        System.out.println("Paid using E-Wallet");
    }
}