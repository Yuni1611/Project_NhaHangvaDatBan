FOODTABLE — LƯU YÊU CẦU ĐẶT BÀN VÀO SQL

Phần này kết nối nút “Xác nhận đặt bàn” ở bước 3 với bảng dbo.DatBan.

CÁC FILE TRONG GÓI
- Database\BookingMigration.sql
  Cập nhật bảng DatBan để lưu tên khách và cho phép khách chưa đăng nhập đặt bàn.
  Thêm 3 nhà hàng đang có trên trang nhưng chưa có trong SQLQuery2.sql.
- Project_NhaHangvaDatBan\Controllers\HomeController.cs
  Nhận dữ liệu, kiểm tra hợp lệ và ghi yêu cầu đặt bàn vào SQL.
- Project_NhaHangvaDatBan\Views\Home\Index.cshtml
  Gửi thông tin biểu mẫu đến HomeController sau khi khách bấm Xác nhận.
- Project_NhaHangvaDatBan\Web.config
  Thêm chuỗi kết nối SQL Server; đã cấu hình theo máy chủ YUNI\NGOCNGAN và Windows Authentication.

THỨ TỰ ÁP DỤNG
1. Mở SQL Server Management Studio và kết nối đến máy chủ đang chứa database FoodTableDB.
2. Nếu chưa có FoodTableDB, mở và chạy SQLQuery2.sql trước.
3. Mở Database\BookingMigration.sql và chạy trên cùng kết nối SSMS đó.
4. Web.config đã dùng Server name YUNI\NGOCNGAN và Windows Authentication.
5. Thay các file HomeController.cs, Index.cshtml và Web.config trong project bằng các file cùng tên trong gói.
6. Chạy website, tạo yêu cầu đặt bàn và bấm Xác nhận đặt bàn. Mã trên màn hình được tạo từ MaDatBan trong SQL.

TÌM TÊN MÁY CHỦ SQL TRONG SSMS
- Nếu cửa sổ Connect to Server đang mở, sao chép nội dung ô Server name.
- Nếu đã kết nối, nhìn tên máy chủ ở đầu Object Explorer. Bạn cũng có thể bấm Connect ở Object Explorer để mở lại cửa sổ kết nối.
- Không cần mở CMD.

LƯU Ý
- MaNguoiDung được để trống (NULL) vì đăng nhập hiện tại của trang là dữ liệu mẫu, không phải tài khoản trong bảng NguoiDung.
- Trang chỉ báo thành công sau khi SQL đã lưu bản ghi.
- Không chạy BookingMigration.sql trước SQLQuery2.sql nếu database FoodTableDB chưa tồn tại.
