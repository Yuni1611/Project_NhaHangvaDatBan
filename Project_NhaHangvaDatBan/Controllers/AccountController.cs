using System.Linq;
using System.Web.Mvc;
// Thay bằng namespace Models thực tế của dự án bạn
using System.Web.Mvc;

namespace Project_NhaHangvaDatBan.Controllers
{
    public class AccountController : Controller
    {
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DangNhap(string EmailOrPhone, string MatKhau, string returnUrl)
        {
            if ((EmailOrPhone == "admin@gmail.com" || EmailOrPhone == "0901234567" || EmailOrPhone == "84344006801") && MatKhau == "123456")
            {
                Session["UserID"] = "5MEUXX";
                Session["UserName"] = "Khách hàng Test";
                Session["UserPhone"] = string.IsNullOrWhiteSpace(EmailOrPhone) ? "+84344006801" : EmailOrPhone;

                if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
                {
                    return Redirect(returnUrl);
                }

                return RedirectToAction("LichSuDatCho", "Account");
            }

            TempData["LoginError"] = "Tài khoản hoặc mật khẩu không chính xác! (Thử: admin@gmail.com / 123456)";
            TempData["OpenTab"] = "dangnhap";
            TempData["ReturnUrl"] = returnUrl;
            return RedirectToAction("Index", "Home");
        }

        public ActionResult LichSuDatCho()
        {
            if (Session["UserID"] == null)
            {
                TempData["OpenTab"] = "dangnhap";
                TempData["ReturnUrl"] = Url.Action("LichSuDatCho", "Account");
                return RedirectToAction("Index", "Home");
            }

            ViewBag.UserCode = Session["UserID"] ?? "5MEUXX";
            ViewBag.UserPhone = Session["UserPhone"] ?? "+84344006801";
            return View();
        }

        public ActionResult DangXuat()
        {
            Session.Clear();
            return RedirectToAction("Index", "Home");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DangKy(string HoTen, string SoDienThoai, string Email, string MatKhau, string XacNhanMatKhau)
        {
            if (MatKhau != XacNhanMatKhau)
            {
                TempData["RegisterError"] = "Mật khẩu xác nhận không khớp!";
                TempData["OpenTab"] = "dangky";
                return RedirectToAction("Index", "Home");
            }

            Session["UserID"] = "FT" + System.DateTime.Now.ToString("mmss");
            Session["UserName"] = HoTen;
            Session["UserPhone"] = SoDienThoai;
            return RedirectToAction("LichSuDatCho", "Account");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult QuenMatKhau(string Email, string MatKhauMoi)
        {
            TempData["SuccessMessage"] = "Đặt lại mật khẩu thành công! Vui lòng đăng nhập.";
            TempData["OpenTab"] = "dangnhap";
            return RedirectToAction("Index", "Home");
        }
    }
}