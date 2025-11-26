<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%

    request.setCharacterEncoding("UTF-8");

    // DB 연결 정보 (mac) 
    //String url = "jdbc:oracle:thin:@localhost:1521:xe";
    //String dbId = "SYSTEM";
    //String dbPw = ""; 

    // DB 연결 정보 (window)      
    String url = "jdbc:oracle:thin:@localhost:1521:xe";
    String dbId = "scott";
    String dbPw = "tiger";
%>