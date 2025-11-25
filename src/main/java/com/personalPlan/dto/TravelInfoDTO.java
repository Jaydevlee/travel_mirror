package com.personalPlan.dto;
import java.sql.Date; 

public class TravelInfoDTO {
	
 private int travelNo;          // TRAVEL_NO
 private String title;          	// TITLE
 private String country;       // COUNTRY
 private Date startDate;       // START_DATE (날짜만)
 private Date endDate;         // END_DATE (날짜만)
 private String companion;   // COMPANION
 private int totalBudget;       // TOTAL_BUDGET
 private Date createdAt;       // CREATED_AT
 private String trMemId;	//회원 아이디, 로그인한 계정의 계획을 표시하기 위함

 // 기본 생성자
 public TravelInfoDTO() {}

 // 전체 필드 생성자 
 public TravelInfoDTO(int travelNo, String title, String country, Date startDate, 
		 Date endDate, String companion, int totalBudget, Date createdAt, String trMemId) {
     this.travelNo = travelNo;
     this.title = title;
     this.country = country;
     this.startDate = startDate;
     this.endDate = endDate;
     this.companion = companion;
     this.totalBudget = totalBudget;
     this.createdAt = createdAt;
     this.trMemId = trMemId;
 }

 public int getTravelNo() { return travelNo; }
 public void setTravelNo(int travelNo) { this.travelNo = travelNo; }
 
 public String getTitle() { return title; }
 public void setTitle(String title) { this.title = title; }

 public String getCountry() { return country; }
 public void setCountry(String country) { this.country = country; }

 public Date getStartDate() { return startDate; }
 public void setStartDate(Date startDate) { this.startDate = startDate; }

 public Date getEndDate() { return endDate; }
 public void setEndDate(Date endDate) { this.endDate = endDate; }

 public String getCompanion() { return companion; }
 public void setCompanion(String companion) { this.companion = companion; }

 public int getTotalBudget() { return totalBudget; }
 public void setTotalBudget(int totalBudget) { this.totalBudget = totalBudget; }

 public Date getCreatedAt() { return createdAt; }
 public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

 public String getTrMemId() {return trMemId; }
 public void setTrMemId(String trMemId) {this.trMemId = trMemId;}

 @Override
 public String toString() {
     return "TravelInfoDTO [travelNo=" + travelNo + ", title=" + title + "]";
 }
}