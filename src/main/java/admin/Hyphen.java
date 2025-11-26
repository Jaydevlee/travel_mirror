package admin;

public class Hyphen {

    public static String formatPhoneNumber(String phone) {

        if (phone.length() == 10 || phone.length() == 11) {
            return phone.replaceFirst("^(\\d{3,3})(\\d{3,4})(\\d{4})$", "$1-$2-$3");
        }
        return phone;
    }
}