package com.member.dao;
import java.sql.*;
import com.member.dto.*;
import com.common.*;

public class TravelDeleteMemDAO {
	public int deleteMem(Connection conn, TravelMemberDTO dto) throws SQLException {
		String sql = "DELETE FROM tr_member WHERE tr_mem_id=?";
		PreparedStatement pstmt = null;
	try {
		pstmt=conn.prepareStatement(sql);
		pstmt.setString(1, dto.getMemId());
		return pstmt.executeUpdate();
		
	} finally {
		DBConnection.close(pstmt);
	}
	}
}
