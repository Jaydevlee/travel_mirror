package com.member.dao;
import java.sql.*;
import java.util.*;
import com.common.*;
import com.member.dto.*;

public class TravelSelectMemDAO {
	public TravelMemberDTO selectMem(Connection conn, String id) throws SQLException {
		String sql="SELECT * FROM tr_member WHERE tr_mem_id=?";
		
		PreparedStatement pstmt=null;
		ResultSet rs = null;
		TravelMemberDTO dto=null;
	try {
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, id);
		
		rs=pstmt.executeQuery();
		
		
		if(rs.next()) {
		dto = new TravelMemberDTO();
		dto.setMemNo(rs.getInt("tr_mem_no"));
		dto.setMemId(rs.getString("tr_mem_id"));
		dto.setMemPw(rs.getString("tr_mem_password"));
		dto.setMemName(rs.getString("tr_mem_name"));
		dto.setMemEmail(rs.getString("tr_mem_email"));
		dto.setMemPhone(rs.getString("tr_mem_phone"));
		dto.setMemFileName(rs.getString("tr_mem_pic"));
		}
		return dto;
	} finally{
		DBConnection.close(rs);
		DBConnection.close(pstmt);
	}
	}
	
	public TravelMemberDTO dupCheck(Connection conn, String id) throws Exception{
		String sql="SELECT tr_mem_id FROM tr_member WHERE tr_mem_id=?";
		
		PreparedStatement pstmt=null;
		ResultSet rs = null;
		TravelMemberDTO dto=null;
	try {
		pstmt=conn.prepareStatement(sql);
		pstmt.setString(1, id);
		rs=pstmt.executeQuery();
		
		if(rs.next()) {
			dto=new TravelMemberDTO();
			dto.setMemId(rs.getString("tr_mem_id"));
		}
		return dto;
	} finally {
		DBConnection.close(rs);
		DBConnection.close(pstmt);
		}
	}
	
	
	public TravelMemberDTO findMemId(Connection conn, String email) throws SQLException {
		String sql="SELECT tr_mem_id FROM tr_member WHERE tr_mem_email=?";
		PreparedStatement pstmt=null;
		ResultSet rs = null;
		TravelMemberDTO dto=null;
		
	try{
		pstmt=conn.prepareStatement(sql);
		pstmt.setString(1, email);
		rs=pstmt.executeQuery();
		
		if(rs.next()) {
			dto=new TravelMemberDTO();
			dto.setMemId(rs.getString("tr_mem_id"));
		}
		return dto;
	} finally {
		DBConnection.close(rs);
		DBConnection.close(pstmt);
		}	
	}
	
	public TravelMemberDTO findMemPw(Connection conn, String email, String id) throws SQLException{
		String sql="SELECT tr_mem_password FROM tr_member WHERE tr_mem_email=? AND tr_mem_id=?";
		PreparedStatement pstmt=null;
		ResultSet rs = null;
		TravelMemberDTO dto=null;
	try {
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, email);
		pstmt.setString(2, id);
		rs=pstmt.executeQuery();
		
		if(rs.next()) {
			dto = new TravelMemberDTO();
			dto.setMemPw(rs.getString("tr_mem_password"));
	} return dto;

	} finally {
		DBConnection.close(rs);
		DBConnection.close(pstmt);
		}				
	}
}
