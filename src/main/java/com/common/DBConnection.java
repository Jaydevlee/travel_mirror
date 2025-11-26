package com.common;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DBConnection {

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // DB 연결 정보 
            String url = "jdbc:oracle:thin:@localhost:1521:xe";
            String id = "scott";
            String pw = "tiger";

            conn = DriverManager.getConnection(url, id, pw);

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("DB 연결 실패!");
        }
        return conn;
    }

    public static void close(Connection conn) {
        try { if(conn != null && !conn.isClosed()) conn.close(); } catch(Exception e) {}
    }
    
    public static void close(Statement stmt) {
        try { if(stmt != null && !stmt.isClosed()) stmt.close(); } catch(Exception e) {}
    }
    
    public static void close(ResultSet rset) {
        try { if(rset != null && !rset.isClosed()) rset.close(); } catch(Exception e) {}
    }
}