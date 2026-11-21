/* Run this script after SQLQuery2.sql in SQL Server Management Studio. */
USE FoodTableDB;
GO

/* Allow guest bookings and keep the customer name on the booking itself. */
IF OBJECT_ID(N'dbo.DatBan', N'U') IS NULL
BEGIN
    THROW 50001, N'Chưa có bảng dbo.DatBan. Hãy chạy SQLQuery2.sql trước.', 1;
END;
GO

IF COL_LENGTH(N'dbo.DatBan', N'TenNguoiDat') IS NULL
BEGIN
    ALTER TABLE dbo.DatBan
        ADD TenNguoiDat NVARCHAR(120) NULL;
END;
GO

IF EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.DatBan')
      AND name = N'MaNguoiDung'
      AND is_nullable = 0
)
BEGIN
    ALTER TABLE dbo.DatBan
        ALTER COLUMN MaNguoiDung INT NULL;
END;
GO

/* Add the cuisine labels used by the three newest restaurant cards. */
INSERT INTO dbo.LoaiAmThuc (TenLoaiAmThuc, MoTa)
SELECT v.TenLoaiAmThuc, v.MoTa
FROM (VALUES
    (N'Buffet', N'Nhiều món ăn tự chọn theo hình thức buffet'),
    (N'Lẩu', N'Các món lẩu dùng chung')
) AS v(TenLoaiAmThuc, MoTa)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.LoaiAmThuc l
    WHERE l.TenLoaiAmThuc = v.TenLoaiAmThuc
);
GO

/* Add restaurant records that appear on the page but are not in SQLQuery2 yet. */
INSERT INTO dbo.NhaHang
    (MaKhuVuc, TenNhaHang, DiaChi, MoTa, TrangThai, NoiBat)
SELECT k.MaKhuVuc, v.TenNhaHang, v.DiaChi, v.MoTa, 1, 0
FROM (VALUES
    (N'Gánh Quê Buffet', N'Quận 3', N'152 Võ Văn Tần, Quận 3, TP. Hồ Chí Minh', N'Buffet món Việt, phù hợp cho gia đình và nhóm bạn.'),
    (N'Hải Sản Bến Gió', N'Thành phố Thủ Đức', N'48 Kha Vạn Cân, TP. Thủ Đức, TP. Hồ Chí Minh', N'Tôm, cua, cá và các món hải sản trong không gian thoáng.'),
    (N'Lẩu Mộc Garden', N'Bình Thạnh', N'86 Nguyễn Gia Trí, Quận Bình Thạnh, TP. Hồ Chí Minh', N'Lẩu nấm, rau tươi và không gian xanh.')
) AS v(TenNhaHang, TenKhuVuc, DiaChi, MoTa)
INNER JOIN dbo.KhuVuc k ON k.TenKhuVuc = v.TenKhuVuc
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.NhaHang n
    WHERE n.TenNhaHang = v.TenNhaHang
);
GO

/* Link the new restaurants to the matching cuisine category. */
INSERT INTO dbo.NhaHangLoaiAmThuc (MaNhaHang, MaLoaiAmThuc)
SELECT n.MaNhaHang, l.MaLoaiAmThuc
FROM (VALUES
    (N'Gánh Quê Buffet', N'Buffet'),
    (N'Hải Sản Bến Gió', N'Hải sản'),
    (N'Lẩu Mộc Garden', N'Lẩu')
) AS v(TenNhaHang, TenLoaiAmThuc)
INNER JOIN dbo.NhaHang n ON n.TenNhaHang = v.TenNhaHang
INNER JOIN dbo.LoaiAmThuc l ON l.TenLoaiAmThuc = v.TenLoaiAmThuc
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.NhaHangLoaiAmThuc x
    WHERE x.MaNhaHang = n.MaNhaHang
      AND x.MaLoaiAmThuc = l.MaLoaiAmThuc
);
GO
