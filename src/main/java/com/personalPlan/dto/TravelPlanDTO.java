package com.personalPlan.dto;

import java.sql.Timestamp;

public class TravelPlanDTO {
	private int planNo;
	private int travelNo; // FK
	private int dayNo;
	private String category;
	private String title;
	private String bookingNo;
	private Timestamp startTime; // START_TIME (날짜 + 시간)
	private Timestamp endTime; // END_TIME (날짜 + 시간)
	private String location;
	private int cost;

// 기본 생성자
	public TravelPlanDTO() {}

// 전체 필드 생성자

	public TravelPlanDTO(int planNo, int travelNo, int dayNo, String category, String title, String bookingNo,
			Timestamp startTime, Timestamp endTime, String location, int cost) {
		super();
		this.planNo = planNo;
		this.travelNo = travelNo;
		this.dayNo = dayNo;
		this.category = category;
		this.title = title;
		this.bookingNo = bookingNo;
		this.startTime = startTime;
		this.endTime = endTime;
		this.location = location;
		this.cost = cost;

	}

	public int getPlanNo() {
		return planNo;
	}

	public void setPlanNo(int planNo) {
		this.planNo = planNo;
	}

	public int getTravelNo() {
		return travelNo;
	}

	public void setTravelNo(int travelNo) {
		this.travelNo = travelNo;
	}

	public int getDayNo() {
		return dayNo;
	}

	public void setDayNo(int dayNo) {
		this.dayNo = dayNo;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getBookingNo() {
		return bookingNo;
	}

	public void setBookingNo(String bookingNo) {
		this.bookingNo = bookingNo;
	}

	public Timestamp getStartTime() {
		return startTime;
	}

	public void setStartTime(Timestamp startTime) {
		this.startTime = startTime;
	}

	public Timestamp getEndTime() {
		return endTime;
	}

	public void setEndTime(Timestamp endTime) {
		this.endTime = endTime;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public int getCost() {
		return cost;
	}

	public void setCost(int cost) {
		this.cost = cost;
	}
}