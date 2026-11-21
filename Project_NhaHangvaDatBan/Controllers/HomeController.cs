using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web.Mvc;

namespace Project_NhaHangvaDatBan.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        /* Save a booking request to SQL Server after the customer confirms step 3. */
        [HttpPost]
        [ValidateAntiForgeryToken]
        public JsonResult SaveBooking(
            string restaurantName,
            string bookingDate,
            string bookingTime,
            int? guestCount,
            string bookingName,
            string bookingPhone,
            string specialRequest)
        {
            restaurantName = (restaurantName ?? "").Trim();
            bookingName = (bookingName ?? "").Trim();
            bookingPhone = (bookingPhone ?? "").Trim();
            specialRequest = (specialRequest ?? "").Trim();

            if (restaurantName.Length == 0)
            {
                return BookingError("Bạn hãy chọn nhà hàng.", 400);
            }

            if (bookingName.Length == 0 || bookingName.Length > 120)
            {
                return BookingError("Tên cần có từ 1 đến 120 ký tự.", 400);
            }

            if (!Regex.IsMatch(bookingPhone, @"^0[0-9]{9}$"))
            {
                return BookingError("Số điện thoại cần có 10 chữ số và bắt đầu bằng số 0.", 400);
            }

            if (!guestCount.HasValue || guestCount.Value < 1 || guestCount.Value > 30)
            {
                return BookingError("Số lượng khách cần từ 1 đến 30.", 400);
            }

            if (specialRequest.Length > 1000)
            {
                return BookingError("Yêu cầu đặc biệt không được dài quá 1.000 ký tự.", 400);
            }

            DateTime bookingDateTime;
            if (!DateTime.TryParseExact(
                    (bookingDate ?? "") + " " + (bookingTime ?? ""),
                    "yyyy-MM-dd HH:mm",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out bookingDateTime))
            {
                return BookingError("Bạn hãy chọn ngày và giờ đặt bàn hợp lệ.", 400);
            }

            TimeSpan selectedTime;
            if (!TimeSpan.TryParseExact(bookingTime, @"hh\:mm", CultureInfo.InvariantCulture, out selectedTime) ||
                selectedTime < new TimeSpan(10, 0, 0) ||
                selectedTime > new TimeSpan(22, 0, 0) ||
                selectedTime.Minutes % 30 != 0)
            {
                return BookingError("Giờ đặt cần trong khoảng 10:00–22:00 và theo mốc 30 phút.", 400);
            }

            if (bookingDateTime < DateTime.Now)
            {
                return BookingError("Thời gian đặt bàn phải từ hiện tại trở đi.", 400);
            }

            ConnectionStringSettings settings = ConfigurationManager.ConnectionStrings["FoodTableDB"];
            if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString))
            {
                return BookingError("Website chưa được cấu hình kết nối SQL Server.", 500);
            }

            try
            {
                using (SqlConnection connection = new SqlConnection(settings.ConnectionString))
                using (SqlCommand command = connection.CreateCommand())
                {
                    command.CommandText = @"
INSERT INTO dbo.DatBan
    (MaNguoiDung, MaNhaHang, TenNguoiDat, NgayGioDatBan, SoLuongKhach,
     SoDienThoaiLienHe, YeuCauDacBiet, TrangThai)
OUTPUT INSERTED.MaDatBan
SELECT NULL, n.MaNhaHang, @TenNguoiDat, @NgayGioDatBan, @SoLuongKhach,
       @SoDienThoaiLienHe, NULLIF(@YeuCauDacBiet, N''), N'Chờ xác nhận'
FROM dbo.NhaHang AS n
WHERE n.TenNhaHang = @TenNhaHang
  AND n.TrangThai = 1;";

                    command.Parameters.Add("@TenNhaHang", SqlDbType.NVarChar, 160).Value = restaurantName;
                    command.Parameters.Add("@TenNguoiDat", SqlDbType.NVarChar, 120).Value = bookingName;
                    command.Parameters.Add("@NgayGioDatBan", SqlDbType.DateTime2).Value = bookingDateTime;
                    command.Parameters.Add("@SoLuongKhach", SqlDbType.Int).Value = guestCount.Value;
                    command.Parameters.Add("@SoDienThoaiLienHe", SqlDbType.NVarChar, 20).Value = bookingPhone;
                    command.Parameters.Add("@YeuCauDacBiet", SqlDbType.NVarChar, 1000).Value =
                        specialRequest.Length == 0 ? (object)DBNull.Value : specialRequest;

                    connection.Open();
                    object savedId = command.ExecuteScalar();

                    if (savedId == null || savedId == DBNull.Value)
                    {
                        return BookingError("Không tìm thấy nhà hàng trong cơ sở dữ liệu. Hãy chạy file SQL cập nhật trước.", 400);
                    }

                    int bookingId = Convert.ToInt32(savedId);
                    return Json(new
                    {
                        success = true,
                        code = "FT" + bookingId.ToString("D6"),
                        message = "Yêu cầu đặt bàn đã được lưu và đang chờ nhà hàng xác nhận."
                    });
                }
            }
            catch (Exception exception)
            {
                Trace.TraceError("SaveBooking failed: {0}", exception);
                return BookingError("Chưa lưu được yêu cầu đặt bàn. Hãy kiểm tra kết nối SQL Server rồi thử lại.", 500);
            }
        }

        private JsonResult BookingError(string message, int statusCode)
        {
            Response.StatusCode = statusCode;
            Response.TrySkipIisCustomErrors = true;
            return Json(new { success = false, message = message });
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";
            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";
            return View();
        }
    }
}
