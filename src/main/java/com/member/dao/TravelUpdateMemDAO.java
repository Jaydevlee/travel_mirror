package com.member.dao;
import java.sql.*;
import com.common.*;
import com.member.dto.*;

public class TravelUpdateMemDAO {
	public int updateMem(Connection conn, TravelMemberDTO dto) throws Exception {
		String sql="UPDATE tr_member SET tr_mem_password=?, tr_mem_email=?, tr_mem_phone=? WHERE tr_mem_id=?";
		PreparedStatement pstmt=null;
		
		try {
		pstmt=conn.prepareStatement(sql);
		pstmt.setString(1, dto.getMemPw());
		pstmt.setString(2, dto.getMemEmail());
		pstmt.setString(3, dto.getMemPhone());
		pstmt.setString(4, dto.getMemId());
		
		int result = pstmt.executeUpdate();
		
		return result;
		} finally { 
			DBConnection.close(pstmt);
		}
	}
	
	public int resetPw(Connection conn, TravelMemberDTO dto) throws Exception {
		 String sql="UPDATE tr_member SET tr_mem_password=? WHERE tr_mem_id=?";
		 PreparedStatement pstmt=null;
		 try {
			 pstmt=conn.prepareStatement(sql);
			pstmt.setString(1, dto.getMemPw());
			pstmt.setString(2, dto.getMemId());
			int result = pstmt.executeUpdate();
			
			return result;
		 } finally {
			 DBConnection.close(pstmt);
		 }
			
	}
	
	public int changePic(Connection conn, TravelMemberDTO dto) throws Exception{
		String sql="UPDATE tr_member SET tr_mem_pic=? WHERE tr_mem_id=?";
		PreparedStatement pstmt=null;
		try {
			pstmt=conn.prepareStatement(sql);
			pstmt.setString(1, dto.getMemFileName());
			pstmt.setString(2, dto.getMemId());
			int result=pstmt.executeUpdate();
			return result;
		} finally {
			DBConnection.close(pstmt);
		}
	}
	
}


