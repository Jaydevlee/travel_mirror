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

		String sql = "INSERT INTO TRAVEL_INFO (TRAVEL_NO, TITLE, COUNTRY, START_DATE, END_DATE, COMPANION) "
				+ "VALUES (SEQ_TRAVEL_INFO_NO.NEXTVAL, ?, ?, ?, ?, ?)";

		try {
			pstmt = conn.prepareStatement(sql);

			pstmt.setString(1, info.getTitle());
			pstmt.setString(2, info.getCountry());
			pstmt.setDate(3, info.getStartDate());
			pstmt.setDate(4, info.getEndDate());
			pstmt.setString(5, info.getCompanion());

			result = pstmt.executeUpdate();

		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			DBConnection.close(pstmt);
		}
		return result;
	}

	// 여행 정보 목록 보기 (SELECT)
		public List<TravelInfoDTO> selectTravelList(Connection conn) {
			List<TravelInfoDTO> list = new ArrayList<>();
			PreparedStatement pstmt = null;
			ResultSet rset = null;

			String sql = "SELECT * FROM TRAVEL_INFO ORDER BY START_DATE ASC";

			try {
				pstmt = conn.prepareStatement(sql);
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

		String sql = "INSERT INTO TRAVEL_PLAN (PLAN_NO, TRAVEL_NO, DAY_NO, CATEGORY, TITLE, START_TIME, END_TIME, LOCATION, COST) "
				+ "VALUES (SEQ_PLAN_NO.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?)";

		try {
			pstmt = conn.prepareStatement(sql);

			pstmt.setInt(1, plan.getTravelNo()); // FK
			pstmt.setInt(2, plan.getDayNo());
			pstmt.setString(3, plan.getCategory());
			pstmt.setString(4, plan.getTitle());

			// Timestamp로 넣어야 시간까지 저장됨
			pstmt.setTimestamp(5, plan.getStartTime());
			pstmt.setTimestamp(6, plan.getEndTime());

			pstmt.setString(7, plan.getLocation());
			pstmt.setInt(8, plan.getCost());

			result = pstmt.executeUpdate();

		} catch (SQLException e) {
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

				// 꺼낼 때도 Timestamp
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

		String sql = "DELETE FROM TRAVEL_PLAN WHERE PLAN_NO = ?";

		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, planNo);

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
}