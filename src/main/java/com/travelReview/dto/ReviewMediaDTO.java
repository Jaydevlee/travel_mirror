package com.travelReview.dto;

public class ReviewMediaDTO {
	
	private int mediaNo;
    private int reviewNo;
    private String originalName;
    private String savedName;
    private String fileType;
	public int getMediaNo() {
		return mediaNo;
	}
	public void setMediaNo(int mediaNo) {
		this.mediaNo = mediaNo;
	}
	public int getReviewNo() {
		return reviewNo;
	}
	public void setReviewNo(int reviewNo) {
		this.reviewNo = reviewNo;
	}
	public String getOriginalName() {
		return originalName;
	}
	public void setOriginalName(String originalName) {
		this.originalName = originalName;
	}
	public String getSavedName() {
		return savedName;
	}
	public void setSavedName(String savedName) {
		this.savedName = savedName;
	}
	public String getFileType() {
		return fileType;
	}
	public void setFileType(String fileType) {
		this.fileType = fileType;
	}
    
    

}
