import ddf.minim.*; // Kéo thư viện Minim vào dự án

Minim minim;
AudioPlayer radioMusic; // Dùng cho nhạc dài (Radio)
AudioSample beepSound;  // Dùng cho hiệu ứng ngắn (Tiếng bíp đồng hồ)

// KÍCH THƯỚC VÀ TRẠNG THÁI CƠ BẢN
boolean isDay = true; // true = hiển thị Ảnh 1 (Ngày), false = hiển thị Ảnh 2 (Đêm)
int catPose = 0;   // 0, 1, 2 tương ứng 3 tư thế của mèo
PImage imgDay;
PImage imgNight;
PImage catDay1, catDay2, catDay3;
PImage catNight1, catNight2, catNight3;

// BIẾN CHO CLOCK (ĐỒNG HỒ)
boolean showClockUI = false;
boolean timerRunning = false;
boolean timerFinished = false;
int timerStart = 0;
int timerDuration = 1500; // Đếm ngược 10 giây (demo)
int timeLeft = 1500;

// BIẾN CHO PEGBOARD (BẢNG GHI CHÚ)
boolean showPegboard = false;
String typingText = "";
ArrayList<Note> notes = new ArrayList<Note>();

// BIẾN CHO RADIO
boolean showRadioUI = false;
boolean isPlayingMusic = false;

// ĐỊNH NGHĨA HITBOX (VÙNG CLICK) - Tọa độ (x, y, width, height) dựa theo tỷ lệ ảnh 1920x1080
int[] boxWindow = {300, 150, 550, 450};
int[] boxClock = {1280, 150, 120, 120};
int[] boxPegboard = {1150, 300, 350, 200};
int[] boxRadio = {1520, 530, 150, 80};
int[] boxCat = {300, 600, 180, 0};

void setup() {
  size(1920, 1080); // Kích thước màn hình
  // KHỞI TẠO ÂM THANH
  minim = new Minim(this);
  radioMusic = minim.loadFile("lofi.mp3"); // Đổi đúng tên file nhạc của bạn
  beepSound = minim.loadSample("beep.mp3"); // Đổi đúng tên file chuông của bạn
  // NẠP ẢNH MÈO BAN NGÀY
  catDay1 = loadImage("catDay1.png"); 
  catDay2 = loadImage("catDay2.png"); 
  catDay3 = loadImage("catDay3.png"); 
  
  // NẠP ẢNH MÈO BAN ĐÊM
  catNight1 = loadImage("catNight1.png"); 
  catNight2 = loadImage("catNight2.png"); 
  catNight3 = loadImage("catNight3.png");
  imgDay = loadImage("imgDay.png");   // Ảnh ban ngày
  imgNight = loadImage("imgNight.png"); // Ảnh ban đêm
}

void draw() {
  drawEnvironment();
  drawCat(); // Vẽ mèo

  // Vẽ các UI Overlays nếu được kích hoạt
  if (showClockUI) drawClockUI();
  if (showRadioUI) drawRadioUI();
  if (showPegboard) drawPegboardUI();
}

void drawEnvironment() {
  if (isDay) {
    image(imgDay, 0, 0, width, height); 
  } else {
    image(imgNight, 0, 0, width, height); 
  }
}

void drawCat() {
  if (isDay) {
    // NẾU ĐANG LÀ BAN NGÀY: Hiện nhóm ảnh Day
    if (catPose == 0) {
      if (catDay1 != null) {
        float h = boxCat[2] * ((float)catDay1.height / catDay1.width); // Tính tỷ lệ chiều cao
        image(catDay1, boxCat[0], boxCat[1], boxCat[2], h);             // Vẽ ảnh với chiều cao h
        boxCat[3] = int(h);                                             // Cập nhật lại hitbox
      }
    } else if (catPose == 1) {
      if (catDay2 != null) {
        float h = boxCat[2] * ((float)catDay2.height / catDay2.width);
        image(catDay2, boxCat[0], boxCat[1], boxCat[2], h);
        boxCat[3] = int(h);
      }
    } else if (catPose == 2) {
      if (catDay3 != null) {
        float h = boxCat[2] * ((float)catDay3.height / catDay3.width);
        image(catDay3, boxCat[0], boxCat[1], boxCat[2], h);
        boxCat[3] = int(h);
      }
    }
  } 
  else {
    // NẾU ĐANG LÀ BAN ĐÊM: Hiện nhóm ảnh Night
    if (catPose == 0) {
      if (catNight1 != null) {
        float h = boxCat[2] * ((float)catNight1.height / catNight1.width);
        image(catNight1, boxCat[0], boxCat[1], boxCat[2], h);
        boxCat[3] = int(h);
      }
    } else if (catPose == 1) {
      if (catNight2 != null) {
        float h = boxCat[2] * ((float)catNight2.height / catNight2.width);
        image(catNight2, boxCat[0], boxCat[1], boxCat[2], h);
        boxCat[3] = int(h);
      }
    } else if (catPose == 2) {
      if (catNight3 != null) {
        float h = boxCat[2] * ((float)catNight3.height / catNight3.width);
        image(catNight3, boxCat[0], boxCat[1], boxCat[2], h);
        boxCat[3] = int(h);
      }
    }
  }
}

// ================= HÀM VẼ UI =================
void drawClockUI() {
  int cx = 1390; 
  int cy = 820;  
  
  // Nền giao diện đồng hồ
  fill(30, 30, 30, 220);
  rect(cx, cy, 320, 200, 10);
  
  // Nút X 
  fill(255, 0, 0); rect(cx + 280, cy + 10, 30, 30, 5); 
  fill(255); textSize(20); text("X", cx + 288, cy + 32);
  
  fill(255); textSize(24); text("ĐẾM NGƯỢC", cx + 90, cy + 40);
  
  // ==========================================
  // XỬ LÝ HIỂN THỊ PHÚT : GIÂY
  // ==========================================
  int m = max(0, timeLeft / 60); // Chia lấy phần nguyên để ra Phút
  int s = max(0, timeLeft % 60); // Lấy phần dư để ra Giây
  String timeStr = nf(m, 2) + ":" + nf(s, 2); // Ghép lại thành dạng MM:SS
  
  textSize(45); text(timeStr, cx + 105, cy + 100);
  
  // Nút [-] và [+] chỉ hiện khi đồng hồ đang dừng
  if (!timerRunning) {
    fill(100); rect(cx + 30, cy + 65, 40, 40, 5); fill(255); textSize(30); text("-", cx + 42, cy + 95);
    fill(100); rect(cx + 250, cy + 65, 40, 40, 5); fill(255); textSize(30); text("+", cx + 260, cy + 95);
  }
  
  // Xử lý Logic thời gian và Nút Play/Stop
  if (timerRunning) {
    fill(255, 100, 100); rect(cx + 110, cy + 130, 100, 40, 5);
    fill(0); textSize(20); text("Stop", cx + 138, cy + 158);
    
    int elapsed = (millis() - timerStart) / 1000;
    timeLeft = timerDuration - elapsed;
    if (timeLeft <= 0) {
      timerRunning = false;
      if (beepSound != null) beepSound.trigger(); // Kêu chuông
      println("TÍT TÍT TÍT"); 
    }
  } else {
    fill(100, 255, 100); rect(cx + 110, cy + 130, 100, 40, 5);
    fill(0); textSize(20); text("Play", cx + 140, cy + 158);
  }
}

void drawRadioUI() {
  // Đặt biến tọa độ gốc tại đây (Khớp với tọa độ nền của bạn)
  int rx = 1390; 
  int ry =20;   
  
  // Nền giao diện Radio (Góc trên phải)
  fill(50, 150, 200, 220);
  rect(rx, ry, 300, 120, 10);
  
  // Nút X (Tắt cửa sổ)
  fill(255, 0, 0); rect(rx + 260, ry + 10, 30, 30, 5); 
  fill(255); textSize(20); text("X", rx + 268, ry + 32);
  
  // Tên bài hát
  fill(255); textSize(22); text("Lofi Girl - Chill Study", rx + 20, ry + 40);
  
  // Nút Play / Pause
  if (isPlayingMusic) {
    fill(255, 255, 0); rect(rx + 110, ry + 60, 80, 35, 5); 
    fill(0); textSize(16); text("Pause", rx + 125, ry + 83);
  } else {
    fill(100, 255, 100); rect(rx + 110, ry + 60, 80, 35, 5); 
    fill(0); textSize(16); text("Play", rx + 135, ry + 83);
  }
}
void drawPegboardUI() {
  fill(0, 0, 0, 150); // Nền tối overlay
  rect(0, 0, width, height);
  
  fill(222, 184, 135); // Màu bảng nỉ
  rect(460, 140, 1000, 800, 20); // Bảng giữa màn hình
  
  // Nút X
  fill(255, 0, 0); rect(1410, 160, 40, 40, 10); fill(255); textSize(24); text("X", 1422, 188);
  
  // Khung nhập liệu
  fill(255); rect(500, 850, 800, 50, 10);
  fill(0); textSize(24); text("Nhập ghi chú: " + typingText + (frameCount/30 % 2 == 0 ? "|" : ""), 520, 885);
  
  // Vẽ các tờ note đã lưu
  for (Note n : notes) {
    n.display();
  }
}

// ================= XỬ LÝ CLICK CHUỘT =================
void mousePressed() {
  // LỚP 1: TƯƠNG TÁC UI RADIO
  if (showRadioUI) {
    int rx = 1390; 
    int ry = 20; 
    
    if (overRect(rx + 260, ry + 10, 30, 30)) { showRadioUI = false; return; } // Click X
   if (overRect(rx + 110, ry + 60, 80, 35)) { 
      isPlayingMusic = !isPlayingMusic; 
      
      // THÊM ĐOẠN NÀY ĐỂ ĐIỀU KHIỂN NHẠC
      if (isPlayingMusic) {
        radioMusic.loop(); // loop() giúp nhạc phát lặp lại liên tục
      } else {
        radioMusic.pause(); // Dừng nhạc
      }
      return; 
    }// Click Play/Pause
  }
 // LỚP 2: TƯƠNG TÁC UI ĐỒNG HỒ
  if (showClockUI) {
    int cx = 1390; 
    int cy = 820; 
    
    if (overRect(cx + 280, cy + 10, 30, 30)) { showClockUI = false; return; } // Click X
    
    if (overRect(cx + 110, cy + 130, 100, 40)) { // Click Play/Stop
      if (!timerRunning) {
        timerRunning = true;
        timerStart = millis();     
        timerDuration = timeLeft;  
      } else {
        timerRunning = false;      
      }
      return;
    }
    
    // ==========================================
    // Nút [+] và [-] ĐÃ ĐƯỢC CHỈNH THÀNH PHÚT
    // ==========================================
    if (!timerRunning) {
      // Trừ 60 giây (tức là 1 phút). Tối thiểu không cho tuột xuống dưới 1 phút (60s)
      if (overRect(cx + 30, cy + 65, 40, 40)) { timeLeft = max(60, timeLeft - 60); return; } 
      
      // Cộng 60 giây (tức là 1 phút)
      if (overRect(cx + 250, cy + 65, 40, 40)) { timeLeft += 60; return; } 
    }
  }
  // LỚP 3: TƯƠNG TÁC BẢNG PEGBOARD
  if (showPegboard) {
    if (overRect(1410, 160, 40, 40)) { showPegboard = false; return; } // Click X
    if (!overRect(460, 140, 1000, 800)) { showPegboard = false; return; } // Click ra ngoài bảng cũng tắt
    return; // Đang mở bảng to ở giữa thì vô hiệu hóa click đồ vật đằng sau
  }
  
  // LỚP 4: TƯƠNG TÁC ĐỒ VẬT TRONG PHÒNG
  if (overRect(boxWindow[0], boxWindow[1], boxWindow[2], boxWindow[3])) { isDay = !isDay; } 
  else if (overRect(boxCat[0], boxCat[1], boxCat[2], boxCat[3])) { catPose = (catPose + 1) % 3; } 
  else if (overRect(boxClock[0], boxClock[1], boxClock[2], boxClock[3])) { showClockUI = true; } 
  else if (overRect(boxRadio[0], boxRadio[1], boxRadio[2], boxRadio[3])) { showRadioUI = true; } 
  else if (overRect(boxPegboard[0], boxPegboard[1], boxPegboard[2], boxPegboard[3])) { showPegboard = true; }
}

// ================= XỬ LÝ NHẬP BÀN PHÍM CHO PEGBOARD =================
void keyPressed() {
  if (showPegboard) {
    if (key == BACKSPACE && typingText.length() > 0) {
      typingText = typingText.substring(0, typingText.length() - 1);
    } else if (key == ENTER || key == RETURN) {
      if (typingText.length() > 0) {
        notes.add(new Note(typingText));
        typingText = "";
      }
    } else if (key != CODED) {
      typingText += key; 
    }
  }
}

// ================= HÀM PHỤ TRỢ (HELPER) =================
boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height) {
    return true;
  }
  return false;
}

// ================= CLASS NOTE CHO PEGBOARD =================
class Note {
  String text;
  float x, y;
  color c;
  
  Note(String t) {
    text = t;
    x = random(500, 1300);
    y = random(200, 700);
    c = color(random(150, 255), random(150, 255), random(150, 255));
  }
  
  void display() {
    fill(c);
    rect(x, y, 150, 150, 5); 
    fill(0);
    textSize(18);
    text(text, x + 10, y + 20, 130, 130);
  }
}
