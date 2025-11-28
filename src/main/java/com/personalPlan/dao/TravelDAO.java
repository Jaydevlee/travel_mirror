package com.personalPlan.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.personalPlan.dto.TravelInfoDTO;
import com.personalPlan.dto.TravelPlanDTO;
import com.common.DBConnection;

public class TravelDAO {

	// 여행 정보 등록하기 (INSERT)
	public int insertTravelInfo(Connection conn, TravelInfoDTO info) {
		int result = 0;
		PreparedStatement pstmt = null;

		String sql = "INSERT INTO TRAVEL_INFO (TRAVEL_NO, TITLE, COUNTRY, START_DATE, END_DATE, COMPANION, TR_MEM_ID) "
	            + "VALUES (SEQ_TRAVEL_INFO_NO.NEXTVAL, ?, ?, ?, ?, ?, ?)";

		try {
			pstmt = conn.prepareStatement(sql);

			pstmt.setString(1, info.getTitle());
			pstmt.setString(2, info.getCountry());
			pstmt.setDate(3, info.getStartDate());
			pstmt.setDate(4, info.getEndDate());
			pstmt.setString(5, info.getCompanion());
			pstmt.setString(6, info.getTrMemId());

			result = pstmt.executeUpdate();

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			DBConnection.close(pstmt);
		}
		return result;
	}

	// 여행 정보 목록 보기 (SELECT)
	public List<TravelInfoDTO> selectTravelList(Connection conn, String memId) {
	    List<TravelInfoDTO> list = new ArrayList<>();
	    PreparedStatement pstmt = null;
	    ResultSet rset = null;

	    String sql = "SELECT * FROM TRAVEL_INFO WHERE TR_MEM_ID = ? ORDER BY START_DATE ASC";

			try {
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, memId);
				rset = pstmt.executeQuery();

				while (rset.next()) {
					TravelInfoDTO info = new TravelInfoDTO();
					// DB 컬럼명으로 값을 꺼내서 DTO에 담기
					info.setTravelNo(rset.getInt("TRAVEL_NO"));
					info.setTitle(rset.getString("TITLE"));
					info.setCountry(rset.getString("COUNTRY"));
					info.setStartDate(rset.getDate("START_DATE"));
					info.setEndDate(rset.getDate("END_DATE"));
					info.setTotalBudget(rset.getInt("TOTAL_BUDGET"));
					info.setCompanion(rset.getString("COMPANION")); 
					info.setTrMemId(rset.getString("TR_MEM_ID"));

					list.add(info);
				}
			} catch (SQLException e) {
				e.printStackTrace();
			} finally {
				try {
					if (rset != null)
						rset.close();
					if (pstmt != null)
						pstmt.close();
				} catch (Exception e) {
				}
			}
			return list;
		}

	// 세부 일정 등록하기 (INSERT)
	public int insertTravelPlan(Connection conn, TravelPlanDTO plan) {
	    int result = 0;
	    PreparedStatement pstmt = null;

	    // 1. SQL문에 BOOKING_NO 컬럼과 ? 추가
	    String sql = "INSERT INTO TRAVEL_PLAN (PLAN_NO, TRAVEL_NO, DAY_NO, CATEGORY, TITLE, BOOKING_NO, START_TIME, END_TIME, LOCATION, COST) "
	            + "VALUES (SEQ_PLAN_NO.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

	    try {
	        pstmt = conn.prepareStatement(sql);

	        pstmt.setInt(1, plan.getTravelNo());
	        pstmt.setInt(2, plan.getDayNo());
	        pstmt.setString(3, plan.getCategory());
	        pstmt.setString(4, plan.getTitle());
	        pstmt.setString(5, plan.getBookingNo()); 

	        pstmt.setTimestamp(6, plan.getStartTime()); 
	        pstmt.setTimestamp(7, plan.getEndTime());   

	        pstmt.setString(8, plan.getLocation());     
	        pstmt.setInt(9, plan.getCost());            

	        result = pstmt.executeUpdate();
	        
	        if (result > 0) {
	            refreshTotalBudget(conn, plan.getTravelNo());
	        }

	    } catch (SQLException e) {
	        e.printStackTrace();
	    } finally {
	        try {
	            if (pstmt != null) pstmt.close();
	        } catch (Exception e) {}
	    }
	    return result;
	}

	// 세부 일정 특정 여행의 일정만 가져오기 (SELECT)
	public List<TravelPlanDTO> selectPlanList(Connection conn, int travelNo) {
		List<TravelPlanDTO> list = new ArrayList<>();
		PreparedStatement pstmt = null;
		ResultSet rset = null;

		// 해당 여행(TRAVEL_NO)의 일정만 가져오되, 날짜순 -> 시간순 정렬
		String sql = "SELECT * FROM TRAVEL_PLAN WHERE TRAVEL_NO = ? ORDER BY START_TIME ASC";

		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, travelNo);

			rset = pstmt.executeQuery();

			while (rset.next()) {
		        TravelPlanDTO plan = new TravelPlanDTO();
		        plan.setPlanNo(rset.getInt("PLAN_NO"));
		        plan.setTravelNo(rset.getInt("TRAVEL_NO"));
		        plan.setDayNo(rset.getInt("DAY_NO"));
		        plan.setTitle(rset.getString("TITLE"));
		        plan.setCategory(rset.getString("CATEGORY"));
		        
		        plan.setBookingNo(rset.getString("BOOKING_NO")); 

		        plan.setStartTime(rset.getTimestamp("START_TIME"));
		        plan.setEndTime(rset.getTimestamp("END_TIME"));

		        plan.setLocation(rset.getString("LOCATION"));
		        plan.setCost(rset.getInt("COST"));

		        list.add(plan);
		    }
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				if (rset != null)
					rset.close();
				if (pstmt != null)
					pstmt.close();
			} catch (Exception e) {
			}
		}
		return list;
	}

//세부 일정 삭제하기 (DELETE)
	public int deleteTravelPlan(Connection conn, int planNo) {
	    int result = 0;
	    PreparedStatement pstmt = null;
	    PreparedStatement pstmtSelect = null;
	    ResultSet rs = null;
	    int travelNo = 0;

	    try {
	        // 1. 삭제하기 전에 해당 일정의 travelNo를 먼저 조회 (예산 업데이트용)
	        String sqlSelect = "SELECT TRAVEL_NO FROM TRAVEL_PLAN WHERE PLAN_NO = ?";
	        pstmtSelect = conn.prepareStatement(sqlSelect);
	        pstmtSelect.setInt(1, planNo);
	        rs = pstmtSelect.executeQuery();
	        if (rs.next()) {
	            travelNo = rs.getInt("TRAVEL_NO");
	        }

	        // 2. 일정 삭제
	        String sql = "DELETE FROM TRAVEL_PLAN WHERE PLAN_NO = ?";
	        pstmt = conn.prepareStatement(sql);
	        pstmt.setInt(1, planNo);
	        result = pstmt.executeUpdate();
	        
	        // 3. ★ 삭제 성공 시 총 예산 업데이트
	        if (result > 0 && travelNo > 0) {
	            refreshTotalBudget(conn, travelNo);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        // 자원 해제 (rs, pstmtSelect, pstmt 모두 닫기)
	        try { if(rs!=null) rs.close(); } catch(Exception e){}
	        try { if(pstmtSelect!=null) pstmtSelect.close(); } catch(Exception e){}
	        try { if(pstmt!=null) pstmt.close(); } catch(Exception e){}
	    }
	    return result;
	}

// 세부 일정 수정하기 (UPDATE)
	public int updateTravelPlan(Connection conn, TravelPlanDTO plan) {
		int result = 0;
		PreparedStatement pstmt = null;

		String sql = "UPDATE TRAVEL_PLAN SET TITLE=?, CATEGORY=?, BOOKING_NO=?, START_TIME=?, END_TIME=?, LOCATION=?, COST=? WHERE PLAN_NO=?";

		try {
			pstmt = conn.prepareStatement(sql);

			pstmt.setString(1, plan.getTitle());
			pstmt.setString(2, plan.getCategory());
			pstmt.setString(3, plan.getBookingNo());
			pstmt.setTimestamp(4, plan.getStartTime());
			pstmt.setTimestamp(5, plan.getEndTime());
			pstmt.setString(6, plan.getLocation());
			pstmt.setInt(7, plan.getCost());
			pstmt.setInt(8, plan.getPlanNo()); // 어떤 일정을 수정할지(WHERE 조건)

			result = pstmt.executeUpdate();
			
			if(result >0) {
				refreshTotalBudget(conn, plan.getTravelNo());
		    }

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
			} catch (Exception e) {
			}
		}
		return result;
	}

// 여행 정보 전체 삭제 (DELETE)
	public int deleteTravelInfo(Connection conn, int travelNo) {
		int result = 0;
		PreparedStatement pstmt = null;
		String sql = "DELETE FROM TRAVEL_INFO WHERE TRAVEL_NO = ?";

		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, travelNo);
			result = pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
			} catch (Exception e) {
			}
		}
		return result;
	}
	
	// 내 여행만 가져오기
	public List<TravelInfoDTO> selectMyTravelList(Connection conn, String memberId) {
        List<TravelInfoDTO> list = new ArrayList<>();
        PreparedStatement pstmt = null;
        ResultSet rset = null;

        // WHERE TR_MEM_ID = ? 조건으로 내 것만 가져옴
        String sql = "SELECT * FROM TRAVEL_INFO WHERE TR_MEM_ID = ? ORDER BY START_DATE ASC";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, memberId); // 세션 아이디 바인딩
            rset = pstmt.executeQuery();

            while (rset.next()) {
                TravelInfoDTO info = new TravelInfoDTO();
                info.setTravelNo(rset.getInt("TRAVEL_NO"));
                info.setTitle(rset.getString("TITLE"));
                info.setCountry(rset.getString("COUNTRY"));
                info.setStartDate(rset.getDate("START_DATE"));
                info.setEndDate(rset.getDate("END_DATE"));
                info.setTotalBudget(rset.getInt("TOTAL_BUDGET"));
                info.setCompanion(rset.getString("COMPANION"));
                info.setTrMemId(rset.getString("TR_MEM_ID")); // DTO에 trMemId 필드가 있어야 함

                list.add(info);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if(rset!=null) rset.close(); if(pstmt!=null) pstmt.close(); } catch(Exception e){}
        }
        return list;
    }
	
	// 여행 번호(PK)로 여행 정보 1개만 상세 조회하기
    public TravelInfoDTO selectTravelInfo(Connection conn, int travelNo) {
        TravelInfoDTO info = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sql = "SELECT * FROM TRAVEL_INFO WHERE TRAVEL_NO = ?";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, travelNo);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                info = new TravelInfoDTO();
                info.setTravelNo(rs.getInt("TRAVEL_NO"));
                info.setTitle(rs.getString("TITLE"));
                info.setCountry(rs.getString("COUNTRY"));
                info.setStartDate(rs.getDate("START_DATE"));
                info.setEndDate(rs.getDate("END_DATE"));
                info.setTotalBudget(rs.getInt("TOTAL_BUDGET"));
                info.setCompanion(rs.getString("COMPANION"));
                info.setTrMemId(rs.getString("TR_MEM_ID"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
            } catch(Exception e) {}
        }
        return info;
    }
    
   
 // 일정 변경 시 TRAVEL_INFO의 총 예산을 재계산하여 업데이트하는 메서드
    public void refreshTotalBudget(Connection conn, int travelNo) {
        PreparedStatement pstmt = null;
        String sql = "UPDATE TRAVEL_INFO "
                   + "SET TOTAL_BUDGET = (SELECT NVL(SUM(COST), 0) FROM TRAVEL_PLAN WHERE TRAVEL_NO = ?) "
                   + "WHERE TRAVEL_NO = ?";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, travelNo);
            pstmt.setInt(2, travelNo);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
            } catch (Exception e) {}
        }
    }
}