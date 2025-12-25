# Bộ Tính Hàm Mũ $e^t$ Trên FPGA Sử Dụng CORDIC

1. Giới thiệu

Dự án thiết kế mô-đun phần cứng (Hardware Module) sử dụng ngôn ngữ VHDL để tính giá trị xấp xỉ của hàm mũ tự nhiên: $$Output = e^t$$

Thuật toán được sử dụng là CORDIC (Coordinate Rotation Digital Computer) ở chế độ Hyperbolic Vectoring. 

Thiết kế được tối ưu hóa cho FPGA với kiến trúc không sử dụng bộ nhân, chỉ sử dụng phép cộng, trừ và dịch bit để tiết kiệm tài nguyên phần cứng.

2. Thông số kỹ thuật
- Ngôn ngữ thiết kế: VHDL (IEEE 1164, Numeric_std).
- Định dạng dữ liệu: Fixed-point Q3.13 (16-bit).
  + 1 bit dấu.
  + 2 bit phần nguyên.
  + 13 bit phần thập phân.
  + Ví dụ: $1.0$ được biểu diễn là $8192$ (0010 0000 0000 0000).
- Phạm vi đầu vào: $-1.38 < t < 1.38$ (để đảm bảo độ chính xác).
- Số vòng lặp: $N = 13$.
- Độ trễ: 15 chu kỳ clock (1 Init + 13 Calc + 1 Done).
- Kiến trúc: RTL Structural.
3. Cấu trúc thư mục
  
Thứ tự biên dịch quan trọng như sau:
- Mylib.vhd: Package chứa khai báo các Component.
- Reg_n.vhd: Thanh ghi 16-bit có tín hiệu Reset và Enable.
- Datapath.vhd: Khối xử lý dữ liệu. Chứa bảng LUT, bộ cộng/trừ/dịch bit và các thanh ghi trạng thái X, Y, Z.
  + Lưu ý: Ngõ ra exp được gán trực tiếp (Combinational Output) để đảm bảo không bị trễ nhịp khi tín hiệu done lên 1.
- Controller.vhd: Khối điều khiển. Quản lý các trạng thái IDLE, INIT, CALC, FINISH và biến đếm i.
- ExpApprox.vhd: Top-level Module. Kết nối Controller và Datapath.
- ExpApprox_tb.vhd: Testbench để mô phỏng và kiểm tra kết quả.
4. Nguyên lý hoạt động
  
Hệ thống hoạt động dựa trên thuật toán CORDIC Hyperbolic:
- Khởi tạo:
  + $Z_0 = t$ (Góc quay đầu vào).
  + $Y_0 = 0$.
  + $X_0 = 1/K$ (Biểu diễn Q3.13 là 9872). Đây là giá trị khởi tạo để bù trừ hệ số dãn của thuật toán sau 13 vòng lặp.
- Tính toán: Tại mỗi bước $i$, tùy thuộc vào dấu của $Z$:
  + Nếu $Z \ge 0$: Xoay vector theo chiều dương (Giảm Z, Tăng X, Y).
  + Nếu $Z < 0$: Xoay vector theo chiều âm (Tăng Z, Giảm X, Y).
  + Các phép nhân với $2^{-i}$ được thay thế bằng phép dịch phải shift_right.
- Kết quả:
  + Sau $N$ vòng lặp: $X_N \approx \cosh(t)$, $Y_N \approx \sinh(t)$.
  + Ngõ ra: $e^t = \cosh(t) + \sinh(t) = X_N + Y_N$.
5. Hướng dẫn mô phỏng

Bước 1: Chuẩn bị

Sử dụng các phần mềm mô phỏng như ModelSim, QuestaSim, hoặc Vivado Simulator.

Bước 2: Biên dịch

Add tất cả các file vào Project và biên dịch theo đúng thứ tự ở mục 3.

Bước 3: Chạy Testbench
- Set Top-level simulation là ExpApprox_tb.
- Run mô phỏng trong khoảng 1 us.
- Quan sát dạng sóng.

Bước 4: Kiểm tra kết quảĐể dễ quan sát, hãy chuyển định dạng hiển thị của t_in và exp_out sang Decimal.

6. Lưu ý quan trọng

Độ chính xác: Do sử dụng số nguyên 16-bit, sai số lượng tử hóa (Quantization Error) là không thể tránh khỏi, nhưng kết quả sẽ nằm trong phạm vi chấp nhận được của định dạng Q3.13.

7. Tác giả
- Project: ExpApprox
- Thiết kế bởi: Đặng Hoàng Nam
- Phiên bản: 1.0 (Fixed Logic & Timing)
