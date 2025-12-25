\documentclass[a4paper,12pt]{article}

% --- Cấu hình Tiếng Việt và Font ---
\usepackage[utf8]{inputenc}
\usepackage[T5]{fontenc}
\usepackage[vietnamese]{babel}

% --- Các gói hỗ trợ Toán học và Bảng ---
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{booktabs} % Để kẻ bảng đẹp hơn
\usepackage{geometry} % Căn lề
\usepackage{hyperref} % Tạo liên kết
\usepackage{listings} % Để hiển thị code/tên file

% --- Cấu hình lề trang ---
\geometry{
    left=2.5cm,
    right=2.5cm,
    top=2cm,
    bottom=2cm
}

% --- Thông tin tiêu đề ---
\title{\textbf{ExpApprox: Bộ Tính Hàm Mũ $e^t$ Trên FPGA Sử Dụng CORDIC}}
\author{Nhóm Thực Hiện Đồ Án}
\date{\today}

\begin{document}

\maketitle

\section{Giới thiệu (Overview)}
Dự án thiết kế mô-đun phần cứng (Hardware Module) sử dụng ngôn ngữ VHDL để tính giá trị xấp xỉ của hàm mũ tự nhiên:
\begin{equation}
    Output = e^t
\end{equation}
Thuật toán được sử dụng là \textbf{CORDIC (Coordinate Rotation Digital Computer)} ở chế độ \textit{Hyperbolic Vectoring}. Thiết kế được tối ưu hóa cho FPGA với kiến trúc không sử dụng bộ nhân (Multiplier-less), chỉ sử dụng phép cộng, trừ và dịch bit (Shift) để tiết kiệm tài nguyên phần cứng.

\section{Thông số kỹ thuật (Specifications)}
\begin{itemize}
    \item \textbf{Ngôn ngữ thiết kế:} VHDL (IEEE 1164, Numeric\_std).
    \item \textbf{Định dạng dữ liệu (Data Format):} Fixed-point \textbf{Q3.13} (16-bit).
    \begin{itemize}
        \item 1 bit dấu (Sign).
        \item 2 bit phần nguyên (Integer).
        \item 13 bit phần thập phân (Fractional).
        \item \textit{Ví dụ:} $1.0$ được biểu diễn là $8192$ (\texttt{0010 0000 0000 0000}).
    \end{itemize}
    \item \textbf{Phạm vi đầu vào:} $-4 \le t < 4$ (Thực tế tốt nhất trong khoảng $-1.5$ đến $1.5$ để đảm bảo độ chính xác cao nhất).
    \item \textbf{Số vòng lặp (Iterations):} $N = 13$.
    \item \textbf{Độ trễ (Latency):} 15 chu kỳ clock (1 Init + 13 Calc + 1 Done).
    \item \textbf{Kiến trúc:} RTL Structural (Tách biệt Controller và Datapath).
\end{itemize}

\section{Cấu trúc thư mục (File Structure)}
Thứ tự biên dịch (Compile Order) quan trọng như sau:
\begin{enumerate}
    \item \texttt{Mylib.vhd}: Package chứa khai báo các Component (\texttt{Datapath}, \texttt{Controller}, \texttt{Reg\_n}).
    \item \texttt{Reg\_n.vhd}: Thanh ghi 16-bit có tín hiệu Reset và Enable.
    \item \texttt{Datapath.vhd}: Khối xử lý dữ liệu. Chứa bảng LUT, bộ cộng/trừ/dịch bit và các thanh ghi trạng thái X, Y, Z.
    \begin{itemize}
        \item \textit{Lưu ý:} Ngõ ra \texttt{exp} được gán trực tiếp (Combinational Output) để đảm bảo không bị trễ nhịp khi tín hiệu \texttt{done} lên 1.
    \end{itemize}
    \item \texttt{Controller.vhd}: Khối điều khiển (FSM). Quản lý các trạng thái \texttt{IDLE}, \texttt{INIT}, \texttt{CALC}, \texttt{FINISH} và biến đếm $i$.
    \item \texttt{ExpApprox.vhd}: Top-level Module. Kết nối Controller và Datapath.
    \item \texttt{ExpApprox\_tb.vhd}: Testbench để mô phỏng và kiểm tra kết quả.
\end{enumerate}

\section{Nguyên lý hoạt động (Theory of Operation)}
Hệ thống hoạt động dựa trên thuật toán CORDIC Hyperbolic:
\begin{enumerate}
    \item \textbf{Khởi tạo (Init):}
    \begin{itemize}
        \item $Z_0 = t$ (Góc quay đầu vào).
        \item $Y_0 = 0$.
        \item $X_0 = 1/K \approx 0.8281$ (Biểu diễn Q3.13 là \texttt{6784}). Đây là giá trị khởi tạo để bù trừ hệ số dãn của thuật toán sau 13 vòng lặp.
    \end{itemize}
    
    \item \textbf{Tính toán (Calculation - 13 vòng):}
    Tại mỗi bước $i$, tùy thuộc vào dấu của $Z$:
    \begin{itemize}
        \item Nếu $Z \ge 0$: Xoay vector theo chiều dương (Giảm Z, Tăng X, Y).
        \item Nếu $Z < 0$: Xoay vector theo chiều âm (Tăng Z, Giảm X, Y).
    \end{itemize}
    Các phép nhân với $2^{-i}$ được thay thế bằng phép dịch phải \texttt{shift\_right}.
    
    \item \textbf{Kết quả (Result):}
    \begin{itemize}
        \item Sau $N$ vòng lặp: $X_N \approx \cosh(t)$, $Y_N \approx \sinh(t)$.
        \item Ngõ ra: $e^t = \cosh(t) + \sinh(t) = X_N + Y_N$.
    \end{itemize}
\end{enumerate}

\section{Hướng dẫn mô phỏng (Simulation Guide)}

\subsection{Bước 1: Chuẩn bị}
Sử dụng các phần mềm mô phỏng như \textbf{ModelSim}, \textbf{QuestaSim}, hoặc \textbf{Vivado Simulator}.

\subsection{Bước 2: Biên dịch & Chạy Testbench}
\begin{itemize}
    \item Add tất cả các file vào Project và biên dịch theo đúng thứ tự ở mục 3.
    \item Set Top-level simulation là \texttt{ExpApprox\_tb}.
    \item Run mô phỏng trong khoảng \texttt{1 us} (1000 ns).
\end{itemize}

\subsection{Bước 3: Kiểm tra kết quả}
Để dễ quan sát, hãy chuyển định dạng hiển thị (Radix) của \texttt{t\_in} và \texttt{exp\_out} sang \textbf{Decimal (Signed)}.

\vspace{0.5cm}
\begin{table}[h!]
    \centering
    \caption{Bảng kết quả kỳ vọng (Q3.13)}
    \begin{tabular}{|c|c|c|c|c|}
        \hline
        \textbf{Test Case} & \textbf{Input $t$ (Float)} & \textbf{Input (Dec)} & \textbf{Output ($e^t$)} & \textbf{Output (Dec)} \\
        \hline
        Case 1 & $1.0$ & 8192 & 2.718 & $\approx 22268$ \\
        \hline
        Case 2 & $0.5$ & 4096 & 1.648 & $\approx 13506$ \\
        \hline
        Case 3 & $-0.5$ & -4096 & 0.606 & $\approx 4968$ \\
        \hline
        Case 4 & $0.0$ & 0 & 1.0 & 8192 \\
        \hline
    \end{tabular}
\end{table}

\section{Lưu ý quan trọng}
\begin{itemize}
    \item \textbf{Reset:} Hệ thống sử dụng Reset tích cực thấp (\texttt{rst\_n}). Trong code hiện tại, logic Reset đã được thống nhất để hoạt động chính xác với Testbench.
    \item \textbf{Độ chính xác:} Do sử dụng số nguyên 16-bit, sai số lượng tử hóa (Quantization Error) là không thể tránh khỏi, nhưng kết quả sẽ nằm trong phạm vi chấp nhận được của định dạng Q3.13.
\end{itemize}

\section{Tác giả}
\begin{itemize}
    \item \textbf{Project:} Final Year Project - Hardware Design.
    \item \textbf{Phiên bản:} 1.0 (Fixed Logic \& Timing).
\end{itemize}

\end{document}
