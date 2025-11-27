package com.member.dao;

import java.sql.*;
import com.member.dto.*;
import com.common.*;

public class TravelSignUpDAO {
	public int insertMember(Connection conn, TravelMemberDTO dto) throws Exception {
	    String sql = "INSERT INTO TR_MEMBER(tr_mem_no, tr_mem_id, tr_mem_password, tr_mem_name, tr_mem_email, tr_mem_phone, tr_mem_level) "
	               + "VALUES(tr_member_seq.NEXTVAL, ?, ?, ?, ?, ?, ?)";

	    String[] returnCols = { "tr_mem_no" }; 
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;

	    try {
	        // 반환될 컬럼 지정 필수
	        pstmt = conn.prepareStatement(sql, returnCols);

	        pstmt.setString(1, dto.getMemId());
	        pstmt.setString(2, dto.getMemPw());
	        pstmt.setString(3, dto.getMemName());
	        pstmt.setString(4, dto.getMemEmail());
	        pstmt.setString(5, dto.getMemPhone());
	        pstmt.setInt(6, dto.getMemLevel());

	        int result = pstmt.executeUpdate();

	        // 생성된 시퀀스 번호 받아오기
	        rs = pstmt.getGeneratedKeys();
	        if (rs.next()) {
	            dto.setMemNo(rs.getInt(1));
	        }

	        return result;

	    } finally {
	        DBConnection.close(rs);
	        DBConnection.close(pstmt);
	    }
	}
}