const ReviewStorage = {
    //모든 리뷰 조회
    getAll() {
        const data = localStorage.getItem('reviews');
        return data ? JSON.parse(data) : [];
    },
    
    //리뷰저장
    save(review) {
        const reviews = this.getAll();
        review.id = Date.now();
        review.createdAt = new Date().toISOString();
        reviews.push(review);
        localStorage.setItem('reviews', JSON.stringify(reviews));
        console.log(review);
        return review;
    },
    
    //리뷰수정
    modify(id, updatedData) {
        const reviews = this.getAll();
        const index = reviews.findIndex(r => r.id === id);
        if (index !== -1) {
            reviews[index] = { ...reviews[index], ...updatedData, updatedAt: new Date().toISOString() };
            localStorage.setItem('reviews', JSON.stringify(reviews));
            return reviews[index];
        }
        return null;
    },
    
    //리뷰삭제
    delete(id) {
        const reviews = this.getAll();
        const filtered = reviews.filter(r => r.id !== id);
        localStorage.setItem('reviews', JSON.stringify(filtered));
        return true;
    },
    
    //id로 리뷰 조회(수정 시 사용)
    getById(id) {
        const reviews = this.getAll();
        return reviews.find(r => r.id === id);
    }
};

// 이미지 Base64 변환 함수
function fileToBase64(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

/**
 * 여러 파일을 Base64로 변환
 * @param {FileList} files - 파일 목록
 * @returns {Promise<string[]>} Base64 문자열 배열
 */
async function filesToBase64Array(files) {
    const promises = Array.from(files).map(file => {
        if (file.type && file.type.startsWith('image/')) {
            return fileToBase64(file);
        }
        return null;
    });
    const results = await Promise.all(promises);
    return results.filter(r => r !== null);
}