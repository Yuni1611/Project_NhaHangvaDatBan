
IF DB_ID(N'FoodTableDB') IS NULL
BEGIN
    CREATE DATABASE FoodTableDB;
END;
GO

USE FoodTableDB;
GO

/* Accounts */
IF OBJECT_ID(N'dbo.NguoiDung', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NguoiDung
    (
        MaNguoiDung INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_NguoiDung PRIMARY KEY,
        HoTen NVARCHAR(120) NOT NULL,
        Email NVARCHAR(254) NOT NULL,
        SoDienThoai NVARCHAR(20) NULL,
        MatKhauHash NVARCHAR(500) NULL,
        VaiTro NVARCHAR(20) NOT NULL CONSTRAINT DF_NguoiDung_VaiTro DEFAULT N'User',
        TrangThai BIT NOT NULL CONSTRAINT DF_NguoiDung_TrangThai DEFAULT 1,
        NgayTao DATETIME2(0) NOT NULL CONSTRAINT DF_NguoiDung_NgayTao DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_NguoiDung_Email UNIQUE (Email),
        CONSTRAINT CK_NguoiDung_VaiTro CHECK (VaiTro IN (N'User', N'Admin'))
    );
END;
GO

/* Restaurant locations and cuisine categories */
IF OBJECT_ID(N'dbo.KhuVuc', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.KhuVuc
    (
        MaKhuVuc INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_KhuVuc PRIMARY KEY,
        TenKhuVuc NVARCHAR(100) NOT NULL,
        ThanhPho NVARCHAR(100) NOT NULL CONSTRAINT DF_KhuVuc_ThanhPho DEFAULT N'TP. Hồ Chí Minh',
        MoTa NVARCHAR(300) NULL,
        TrangThai BIT NOT NULL CONSTRAINT DF_KhuVuc_TrangThai DEFAULT 1,
        CONSTRAINT UQ_KhuVuc_Ten_ThanhPho UNIQUE (TenKhuVuc, ThanhPho)
    );
END;
GO

IF OBJECT_ID(N'dbo.LoaiAmThuc', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LoaiAmThuc
    (
        MaLoaiAmThuc INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_LoaiAmThuc PRIMARY KEY,
        TenLoaiAmThuc NVARCHAR(100) NOT NULL CONSTRAINT UQ_LoaiAmThuc_Ten UNIQUE,
        MoTa NVARCHAR(300) NULL,
        TrangThai BIT NOT NULL CONSTRAINT DF_LoaiAmThuc_TrangThai DEFAULT 1
    );
END;
GO

/* Restaurant profile */
IF OBJECT_ID(N'dbo.NhaHang', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NhaHang
    (
        MaNhaHang INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_NhaHang PRIMARY KEY,
        MaKhuVuc INT NOT NULL,
        TenNhaHang NVARCHAR(160) NOT NULL,
        DiaChi NVARCHAR(250) NOT NULL,
        SoDienThoai NVARCHAR(20) NULL,
        Website NVARCHAR(300) NULL,
        MoTa NVARCHAR(MAX) NULL,
        GioMoCua TIME(0) NULL,
        GioDongCua TIME(0) NULL,
        TrangThai BIT NOT NULL CONSTRAINT DF_NhaHang_TrangThai DEFAULT 1,
        NoiBat BIT NOT NULL CONSTRAINT DF_NhaHang_NoiBat DEFAULT 0,
        NgayTao DATETIME2(0) NOT NULL CONSTRAINT DF_NhaHang_NgayTao DEFAULT SYSDATETIME(),
        CONSTRAINT FK_NhaHang_KhuVuc FOREIGN KEY (MaKhuVuc) REFERENCES dbo.KhuVuc(MaKhuVuc)
    );
END;
GO

/* Many-to-many: one restaurant can offer several cuisine styles */
IF OBJECT_ID(N'dbo.NhaHangLoaiAmThuc', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NhaHangLoaiAmThuc
    (
        MaNhaHang INT NOT NULL,
        MaLoaiAmThuc INT NOT NULL,
        CONSTRAINT PK_NhaHangLoaiAmThuc PRIMARY KEY (MaNhaHang, MaLoaiAmThuc),
        CONSTRAINT FK_NhaHangLoaiAmThuc_NhaHang FOREIGN KEY (MaNhaHang) REFERENCES dbo.NhaHang(MaNhaHang),
        CONSTRAINT FK_NhaHangLoaiAmThuc_Loai FOREIGN KEY (MaLoaiAmThuc) REFERENCES dbo.LoaiAmThuc(MaLoaiAmThuc)
    );
END;
GO

IF OBJECT_ID(N'dbo.HinhAnhNhaHang', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.HinhAnhNhaHang
    (
        MaHinhAnh INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_HinhAnhNhaHang PRIMARY KEY,
        MaNhaHang INT NOT NULL,
        DuongDanAnh NVARCHAR(500) NOT NULL,
        ChuThich NVARCHAR(200) NULL,
        LaAnhDaiDien BIT NOT NULL CONSTRAINT DF_HinhAnh_LaAnhDaiDien DEFAULT 0,
        ThuTuHienThi INT NOT NULL CONSTRAINT DF_HinhAnh_ThuTu DEFAULT 0,
        CONSTRAINT FK_HinhAnhNhaHang_NhaHang FOREIGN KEY (MaNhaHang) REFERENCES dbo.NhaHang(MaNhaHang)
    );
END;
GO

IF OBJECT_ID(N'dbo.MonAn', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MonAn
    (
        MaMonAn INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MonAn PRIMARY KEY,
        MaNhaHang INT NOT NULL,
        TenMon NVARCHAR(160) NOT NULL,
        NhomMon NVARCHAR(100) NULL,
        MoTa NVARCHAR(500) NULL,
        GiaThamKhao DECIMAL(12,2) NOT NULL,
        HinhAnh NVARCHAR(500) NULL,
        TrangThai BIT NOT NULL CONSTRAINT DF_MonAn_TrangThai DEFAULT 1,
        CONSTRAINT CK_MonAn_Gia CHECK (GiaThamKhao >= 0),
        CONSTRAINT FK_MonAn_NhaHang FOREIGN KEY (MaNhaHang) REFERENCES dbo.NhaHang(MaNhaHang)
    );
END;
GO

/* Saved restaurants */
IF OBJECT_ID(N'dbo.YeuThich', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.YeuThich
    (
        MaNguoiDung INT NOT NULL,
        MaNhaHang INT NOT NULL,
        NgayLuu DATETIME2(0) NOT NULL CONSTRAINT DF_YeuThich_NgayLuu DEFAULT SYSDATETIME(),
        CONSTRAINT PK_YeuThich PRIMARY KEY (MaNguoiDung, MaNhaHang),
        CONSTRAINT FK_YeuThich_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES dbo.NguoiDung(MaNguoiDung),
        CONSTRAINT FK_YeuThich_NhaHang FOREIGN KEY (MaNhaHang) REFERENCES dbo.NhaHang(MaNhaHang)
    );
END;
GO

/* Reservation requests */
IF OBJECT_ID(N'dbo.DatBan', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DatBan
    (
        MaDatBan INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DatBan PRIMARY KEY,
        MaNguoiDung INT NOT NULL,
        MaNhaHang INT NOT NULL,
        NgayGioDatBan DATETIME2(0) NOT NULL,
        SoLuongKhach INT NOT NULL,
        SoDienThoaiLienHe NVARCHAR(20) NOT NULL,
        YeuCauDacBiet NVARCHAR(1000) NULL,
        TrangThai NVARCHAR(30) NOT NULL CONSTRAINT DF_DatBan_TrangThai DEFAULT N'Chờ xác nhận',
        ThoiDiemTao DATETIME2(0) NOT NULL CONSTRAINT DF_DatBan_ThoiDiemTao DEFAULT SYSDATETIME(),
        CONSTRAINT CK_DatBan_SoLuong CHECK (SoLuongKhach > 0),
        CONSTRAINT CK_DatBan_TrangThai CHECK (TrangThai IN (N'Chờ xác nhận', N'Đã xác nhận', N'Đã hoàn thành', N'Đã hủy', N'Từ chối')),
        CONSTRAINT FK_DatBan_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES dbo.NguoiDung(MaNguoiDung),
        CONSTRAINT FK_DatBan_NhaHang FOREIGN KEY (MaNhaHang) REFERENCES dbo.NhaHang(MaNhaHang)
    );
END;
GO

/* Customer reviews */
IF OBJECT_ID(N'dbo.DanhGia', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DanhGia
    (
        MaDanhGia INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DanhGia PRIMARY KEY,
        MaNguoiDung INT NOT NULL,
        MaNhaHang INT NOT NULL,
        SoSao TINYINT NOT NULL,
        NoiDung NVARCHAR(1000) NULL,
        NgayTao DATETIME2(0) NOT NULL CONSTRAINT DF_DanhGia_NgayTao DEFAULT SYSDATETIME(),
        TrangThai BIT NOT NULL CONSTRAINT DF_DanhGia_TrangThai DEFAULT 1,
        CONSTRAINT CK_DanhGia_SoSao CHECK (SoSao BETWEEN 1 AND 5),
        CONSTRAINT UQ_DanhGia_NguoiDung_NhaHang UNIQUE (MaNguoiDung, MaNhaHang),
        CONSTRAINT FK_DanhGia_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES dbo.NguoiDung(MaNguoiDung),
        CONSTRAINT FK_DanhGia_NhaHang FOREIGN KEY (MaNhaHang) REFERENCES dbo.NhaHang(MaNhaHang)
    );
END;
GO

/* Indexes for the common listing/filtering screens */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NhaHang_MaKhuVuc_TrangThai' AND object_id = OBJECT_ID(N'dbo.NhaHang'))
    CREATE INDEX IX_NhaHang_MaKhuVuc_TrangThai ON dbo.NhaHang(MaKhuVuc, TrangThai);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DatBan_NgayGio_TrangThai' AND object_id = OBJECT_ID(N'dbo.DatBan'))
    CREATE INDEX IX_DatBan_NgayGio_TrangThai ON dbo.DatBan(NgayGioDatBan, TrangThai);
GO

/* Demo areas: addresses and contacts below are sample data, not verified business listings. */
INSERT INTO dbo.KhuVuc (TenKhuVuc, ThanhPho, MoTa)
SELECT v.TenKhuVuc, N'TP. Hồ Chí Minh', v.MoTa
FROM (VALUES
    (N'Quận 1', N'Trung tâm thành phố'),
    (N'Quận 3', N'Khu vực trung tâm'),
    (N'Quận 5', N'Khu vực Chợ Lớn'),
    (N'Quận 7', N'Khu đô thị phía Nam'),
    (N'Quận 10', N'Khu vực nội thành'),
    (N'Bình Thạnh', N'Khu vực phía Đông trung tâm'),
    (N'Thành phố Thủ Đức', N'Khu vực phía Đông TP. Hồ Chí Minh')
) AS v(TenKhuVuc, MoTa)
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.KhuVuc k
    WHERE k.TenKhuVuc = v.TenKhuVuc AND k.ThanhPho = N'TP. Hồ Chí Minh'
);
GO

INSERT INTO dbo.LoaiAmThuc (TenLoaiAmThuc, MoTa)
SELECT v.TenLoaiAmThuc, v.MoTa
FROM (VALUES
    (N'Món Việt', N'Ẩm thực Việt Nam'),
    (N'Món Âu', N'Ẩm thực châu Âu'),
    (N'Món Hoa', N'Ẩm thực Trung Hoa'),
    (N'Món Nhật', N'Ẩm thực Nhật Bản'),
    (N'Món Hàn', N'Ẩm thực Hàn Quốc'),
    (N'Nướng', N'Lẩu nướng và BBQ'),
    (N'Món chay', N'Món ăn chay'),
    (N'Hải sản', N'Món ăn từ hải sản')
) AS v(TenLoaiAmThuc, MoTa)
WHERE NOT EXISTS (SELECT 1 FROM dbo.LoaiAmThuc l WHERE l.TenLoaiAmThuc = v.TenLoaiAmThuc);
GO

/* Six fictional restaurants for the home page and restaurant listing */
INSERT INTO dbo.NhaHang
    (MaKhuVuc, TenNhaHang, DiaChi, SoDienThoai, Website, MoTa, GioMoCua, GioDongCua, TrangThai, NoiBat)
SELECT k.MaKhuVuc, v.TenNhaHang, v.DiaChi, v.SoDienThoai, v.Website, v.MoTa, v.GioMoCua, v.GioDongCua, 1, v.NoiBat
FROM (VALUES
    (N'The Garden Bistro', N'Quận 1', N'123 Đường Mẫu, Quận 1, TP. Hồ Chí Minh', N'028 0000 1001', N'https://foodtable.local/garden-bistro', N'Nhà hàng Âu với không gian xanh, phù hợp cho bữa tối và gặp gỡ bạn bè.', CAST('10:00' AS TIME), CAST('22:00' AS TIME), 1),
    (N'Maison Steak', N'Quận 1', N'25 Đường Mẫu, Quận 1, TP. Hồ Chí Minh', N'028 0000 1002', N'https://foodtable.local/maison-steak', N'Không gian ấm cúng, phục vụ steak và các món ăn phong cách Âu.', CAST('11:00' AS TIME), CAST('22:00' AS TIME), 1),
    (N'Đông Phương', N'Quận 5', N'88 Đường Mẫu, Quận 5, TP. Hồ Chí Minh', N'028 0000 1003', N'https://foodtable.local/dong-phuong', N'Nhà hàng Hoa với thực đơn món ăn truyền thống và phòng dùng bữa riêng.', CAST('10:30' AS TIME), CAST('22:00' AS TIME), 1),
    (N'Mộc Việt Quán', N'Quận 3', N'36 Đường Mẫu, Quận 3, TP. Hồ Chí Minh', N'028 0000 1004', N'https://foodtable.local/moc-viet', N'Món Việt quen thuộc trong không gian gần gũi, phù hợp cho gia đình.', CAST('10:00' AS TIME), CAST('21:30' AS TIME), 1),
    (N'Sakura Table', N'Quận 1', N'52 Đường Mẫu, Quận 1, TP. Hồ Chí Minh', N'028 0000 1005', N'https://foodtable.local/sakura-table', N'Nhà hàng Nhật phục vụ sushi, sashimi và các món nóng.', CAST('11:00' AS TIME), CAST('22:00' AS TIME), 0),
    (N'Seoul House', N'Quận 7', N'19 Đường Mẫu, Quận 7, TP. Hồ Chí Minh', N'028 0000 1006', N'https://foodtable.local/seoul-house', N'Ẩm thực Hàn Quốc với các món nướng và món ăn dùng chung.', CAST('11:00' AS TIME), CAST('22:00' AS TIME), 0)
) AS v(TenNhaHang, TenKhuVuc, DiaChi, SoDienThoai, Website, MoTa, GioMoCua, GioDongCua, NoiBat)
INNER JOIN dbo.KhuVuc k ON k.TenKhuVuc = v.TenKhuVuc AND k.ThanhPho = N'TP. Hồ Chí Minh'
WHERE NOT EXISTS (SELECT 1 FROM dbo.NhaHang n WHERE n.TenNhaHang = v.TenNhaHang);
GO

/* Assign cuisine styles */
INSERT INTO dbo.NhaHangLoaiAmThuc (MaNhaHang, MaLoaiAmThuc)
SELECT n.MaNhaHang, l.MaLoaiAmThuc
FROM (VALUES
    (N'The Garden Bistro', N'Món Âu'),
    (N'Maison Steak', N'Món Âu'),
    (N'Đông Phương', N'Món Hoa'),
    (N'Mộc Việt Quán', N'Món Việt'),
    (N'Sakura Table', N'Món Nhật'),
    (N'Seoul House', N'Món Hàn'),
    (N'Seoul House', N'Nướng')
) AS v(TenNhaHang, TenLoaiAmThuc)
INNER JOIN dbo.NhaHang n ON n.TenNhaHang = v.TenNhaHang
INNER JOIN dbo.LoaiAmThuc l ON l.TenLoaiAmThuc = v.TenLoaiAmThuc
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.NhaHangLoaiAmThuc x
    WHERE x.MaNhaHang = n.MaNhaHang AND x.MaLoaiAmThuc = l.MaLoaiAmThuc
);
GO

/* Local image paths are placeholders; add matching files to Content/Images/Restaurants. */
INSERT INTO dbo.HinhAnhNhaHang (MaNhaHang, DuongDanAnh, ChuThich, LaAnhDaiDien, ThuTuHienThi)
SELECT n.MaNhaHang, v.DuongDanAnh, v.ChuThich, 1, 1
FROM (VALUES
    (N'The Garden Bistro', N'~/Content/Images/Restaurants/garden-bistro.jpg', N'Không gian The Garden Bistro'),
    (N'Maison Steak', N'~/Content/Images/Restaurants/maison-steak.jpg', N'Không gian Maison Steak'),
    (N'Đông Phương', N'~/Content/Images/Restaurants/dong-phuong.jpg', N'Không gian Đông Phương'),
    (N'Mộc Việt Quán', N'~/Content/Images/Restaurants/moc-viet.jpg', N'Không gian Mộc Việt Quán'),
    (N'Sakura Table', N'~/Content/Images/Restaurants/sakura-table.jpg', N'Không gian Sakura Table'),
    (N'Seoul House', N'~/Content/Images/Restaurants/seoul-house.jpg', N'Không gian Seoul House')
) AS v(TenNhaHang, DuongDanAnh, ChuThich)
INNER JOIN dbo.NhaHang n ON n.TenNhaHang = v.TenNhaHang
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.HinhAnhNhaHang h
    WHERE h.MaNhaHang = n.MaNhaHang AND h.DuongDanAnh = v.DuongDanAnh
);
GO

/* Sample dishes and prices in VND */
INSERT INTO dbo.MonAn (MaNhaHang, TenMon, NhomMon, MoTa, GiaThamKhao, HinhAnh, TrangThai)
SELECT n.MaNhaHang, v.TenMon, v.NhomMon, v.MoTa, v.GiaThamKhao, v.HinhAnh, 1
FROM (VALUES
    (N'The Garden Bistro', N'Bò bít tết Wagyu', N'Món chính', N'Bò Wagyu, sốt tiêu đen, khoai nghiền.', CAST(489000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/wagyu-steak.jpg'),
    (N'The Garden Bistro', N'Cá hồi sốt bơ chanh', N'Món chính', N'Cá hồi áp chảo dùng kèm rau củ.', CAST(289000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/salmon-lemon.jpg'),
    (N'The Garden Bistro', N'Mì Ý sốt kem nấm', N'Món chính', N'Mì Ý, nấm, kem tươi và phô mai Parmesan.', CAST(159000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/creamy-mushroom-pasta.jpg'),
    (N'Maison Steak', N'Steak bò sốt tiêu', N'Món chính', N'Thăn bò nướng dùng kèm khoai tây.', CAST(359000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/pepper-steak.jpg'),
    (N'Maison Steak', N'Súp nấm kem', N'Món khai vị', N'Súp nấm kem dùng nóng.', CAST(99000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/mushroom-soup.jpg'),
    (N'Đông Phương', N'Vịt quay kiểu Hoa', N'Món chính', N'Vịt quay dùng kèm bánh bao và nước sốt.', CAST(399000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/roast-duck.jpg'),
    (N'Đông Phương', N'Há cảo tôm', N'Dimsum', N'Há cảo hấp nhân tôm.', CAST(89000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/shrimp-dumpling.jpg'),
    (N'Mộc Việt Quán', N'Cá kho tộ', N'Món chính', N'Cá kho dùng kèm cơm trắng.', CAST(139000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/caramelized-fish.jpg'),
    (N'Mộc Việt Quán', N'Gỏi cuốn tôm thịt', N'Khai vị', N'Gỏi cuốn tươi kèm nước chấm.', CAST(69000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/spring-rolls.jpg'),
    (N'Sakura Table', N'Sushi tổng hợp', N'Sushi', N'Sushi tổng hợp theo phần.', CAST(229000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/sushi-set.jpg'),
    (N'Seoul House', N'Ba chỉ bò nướng', N'Nướng', N'Ba chỉ bò dùng kèm rau và sốt.', CAST(249000 AS DECIMAL(12,2)), N'~/Content/Images/Menu/korean-bbq.jpg')
) AS v(TenNhaHang, TenMon, NhomMon, MoTa, GiaThamKhao, HinhAnh)
INNER JOIN dbo.NhaHang n ON n.TenNhaHang = v.TenNhaHang
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.MonAn m
    WHERE m.MaNhaHang = n.MaNhaHang AND m.TenMon = v.TenMon
);
GO

/* Demo-only accounts. Password hashes are NULL, so these accounts cannot sign in. */
INSERT INTO dbo.NguoiDung (HoTen, Email, SoDienThoai, MatKhauHash, VaiTro, TrangThai)
SELECT v.HoTen, v.Email, v.SoDienThoai, NULL, N'User', 1
FROM (VALUES
    (N'Khách trải nghiệm 1', N'demo.guest1@foodtable.local', N'0900000001'),
    (N'Khách trải nghiệm 2', N'demo.guest2@foodtable.local', N'0900000002'),
    (N'Khách trải nghiệm 3', N'demo.guest3@foodtable.local', N'0900000003'),
    (N'Khách trải nghiệm 4', N'demo.guest4@foodtable.local', N'0900000004'),
    (N'Khách trải nghiệm 5', N'demo.guest5@foodtable.local', N'0900000005'),
    (N'Khách trải nghiệm 6', N'demo.guest6@foodtable.local', N'0900000006')
) AS v(HoTen, Email, SoDienThoai)
WHERE NOT EXISTS (SELECT 1 FROM dbo.NguoiDung u WHERE u.Email = v.Email);
GO

/* One sample review per restaurant so rating cards can show a computed score. */
INSERT INTO dbo.DanhGia (MaNguoiDung, MaNhaHang, SoSao, NoiDung)
SELECT u.MaNguoiDung, n.MaNhaHang, v.SoSao, v.NoiDung
FROM (VALUES
    (N'The Garden Bistro', N'demo.guest1@foodtable.local', 5, N'Không gian đẹp, món ăn trình bày chỉn chu.'),
    (N'Maison Steak', N'demo.guest2@foodtable.local', 5, N'Thịt mềm, phục vụ thân thiện.'),
    (N'Đông Phương', N'demo.guest3@foodtable.local', 4, N'Món ăn đậm vị, phù hợp đi nhóm.'),
    (N'Mộc Việt Quán', N'demo.guest4@foodtable.local', 5, N'Món Việt dễ ăn, không gian ấm cúng.'),
    (N'Sakura Table', N'demo.guest5@foodtable.local', 4, N'Thực đơn phong phú, phục vụ nhanh.'),
    (N'Seoul House', N'demo.guest6@foodtable.local', 5, N'Đồ nướng ngon, có nhiều món ăn kèm.')
) AS v(TenNhaHang, Email, SoSao, NoiDung)
INNER JOIN dbo.NhaHang n ON n.TenNhaHang = v.TenNhaHang
INNER JOIN dbo.NguoiDung u ON u.Email = v.Email
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.DanhGia d
    WHERE d.MaNguoiDung = u.MaNguoiDung AND d.MaNhaHang = n.MaNhaHang
);
GO

/* One future sample booking; it is for demonstration and is not a confirmed reservation. */
INSERT INTO dbo.DatBan (MaNguoiDung, MaNhaHang, NgayGioDatBan, SoLuongKhach, SoDienThoaiLienHe, YeuCauDacBiet, TrangThai)
SELECT u.MaNguoiDung, n.MaNhaHang, '2026-11-20T19:00:00', 4, N'0900000001', N'Bàn gần cửa sổ (dữ liệu minh họa)', N'Chờ xác nhận'
FROM dbo.NguoiDung u
CROSS JOIN dbo.NhaHang n
WHERE u.Email = N'demo.guest1@foodtable.local'
  AND n.TenNhaHang = N'The Garden Bistro'
  AND NOT EXISTS
  (
      SELECT 1 FROM dbo.DatBan d
      WHERE d.MaNguoiDung = u.MaNguoiDung
        AND d.MaNhaHang = n.MaNhaHang
        AND d.NgayGioDatBan = '2026-11-20T19:00:00'
  );
GO

/* Use this view for the restaurant cards' average score and review count. */
CREATE OR ALTER VIEW dbo.vw_NhaHangDanhGia
AS
    SELECT n.MaNhaHang,
           CAST(AVG(CAST(d.SoSao AS DECIMAL(4,2))) AS DECIMAL(3,2)) AS DiemDanhGia,
           COUNT(d.MaDanhGia) AS SoLuotDanhGia
    FROM dbo.NhaHang n
    LEFT JOIN dbo.DanhGia d ON d.MaNhaHang = n.MaNhaHang AND d.TrangThai = 1
    GROUP BY n.MaNhaHang;
GO

/* Quick check: restaurant, area, cuisine, rating and review count */
SELECT n.MaNhaHang, n.TenNhaHang, k.TenKhuVuc,
       STRING_AGG(l.TenLoaiAmThuc, N', ') AS LoaiAmThuc,
       COALESCE(g.DiemDanhGia, 0) AS DiemDanhGia,
       COALESCE(g.SoLuotDanhGia, 0) AS SoLuotDanhGia
FROM dbo.NhaHang n
INNER JOIN dbo.KhuVuc k ON k.MaKhuVuc = n.MaKhuVuc
LEFT JOIN dbo.NhaHangLoaiAmThuc nl ON nl.MaNhaHang = n.MaNhaHang
LEFT JOIN dbo.LoaiAmThuc l ON l.MaLoaiAmThuc = nl.MaLoaiAmThuc
LEFT JOIN dbo.vw_NhaHangDanhGia g ON g.MaNhaHang = n.MaNhaHang
GROUP BY n.MaNhaHang, n.TenNhaHang, k.TenKhuVuc, g.DiemDanhGia, g.SoLuotDanhGia
ORDER BY n.NoiBat DESC, n.TenNhaHang;
GO

