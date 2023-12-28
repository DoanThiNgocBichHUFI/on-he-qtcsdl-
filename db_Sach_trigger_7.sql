--bài tập 7
create database QL_Sach_7
use QL_Sach_7
create table Sach(
	MaSH varchar(10) primary key,TenSH nvarchar(50),TacGia nvarchar(50),Loai nvarchar(10),TinhTrang nvarchar(50)
)
create table DocGia(
	MaDG varchar(10) primary key, TenDG nvarchar(50),Tuoi int,Phai nvarchar(10),DiaChi nvarchar(50)
)
create table MuonSach(
	MaDG varchar(10),MaSH varchar(10),NgMuon date,NgTra date,
	primary key (MaDG,MaSH,NgMuon),
	foreign key (MaDG) references DocGia(MaDG),
	foreign key (MaSH) references Sach(MaSH)
)

--a/ Viết trigger kiểm tra tuổi của độc giả phải >=15
-------c1
CREATE TRIGGER trg_KiemTraTuoi
ON DocGia
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Tuoi < 15)
    BEGIN
        RAISERROR (N'Tuổi của độc giả phải lớn hơn hoặc bằng 15.', 16, 1);
        ROLLBACK;
    END
END;

----------c2
CREATE TRIGGER trg_CheckAge
ON DocGia
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DATEDIFF(YEAR, NgaySinh, GETDATE()) < 15)
    BEGIN
        RAISERROR ('Tuổi của độc giả phải >=15', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

--b/ Viết trigger kiểm tra phái của độc giả phải là “Nam’ hay “Nu
----c1
CREATE TRIGGER trg_KiemTraPhai
ON DocGia
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE NOT (Phai = N'Nam' OR Phai = N'Nữ'))
    BEGIN
        RAISERROR (N'Phái của độc giả phải là ''Nam'' hoặc ''Nữ''.', 16, 1);
        ROLLBACK;
    END
END;
----c2
CREATE TRIGGER trg_CheckGender
ON DocGia
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Phai NOT IN ('Nam', 'Nu'))
    BEGIN
        RAISERROR ('Phái của độc giả phải là "Nam" hoặc "Nu"', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

--c/ Viết trigger kiểm tra loại sách phải thuộc trong các loại như: Khoa học tu nhien, Xa
--hoi, Kinh te, Truyen
------c1
CREATE TRIGGER trg_KiemTraLoaiSach
ON Sach
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE NOT Loai IN (N'Khoa học tự nhiên', N'Xã hội', N'Kinh tế', N'Truyện'))
    BEGIN
        RAISEERROR (N'Loại sách không hợp lệ.', 16, 1);
        ROLLBACK;
    END
END;
--------c2
CREATE TRIGGER trg_CheckBookType
ON Sach
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Loai NOT IN ('Khoa học tự nhiên', 'Xã hội', 'Kinh tế', 'Truyện'))
    BEGIN
        RAISERROR ('Loại sách phải thuộc trong các loại: Khoa học tự nhiên, Xã hội, Kinh tế, Truyện', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

--d/ Dùng lệnh xóa các ràng trigger trên
DROP TRIGGER trg_KiemTraTuoi ON DocGia;
DROP TRIGGER trg_KiemTraPhai ON DocGia;
DROP TRIGGER trg_KiemTraLoaiSach ON Sach;

--e/ Viết trigger kiểm tra khi thêm hay sửa dữ liệu trên bảng MUONSACH thì ngày trả >= ngày mượn
------c1
CREATE TRIGGER trg_KiemTraNgayTra
ON MuonSach
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE NgTra < NgMuon)
    BEGIN
        RAISERROR (N'Ngày trả phải lớn hơn hoặc bằng ngày mượn.', 16, 1);
        ROLLBACK;
    END
END;
----------c2
CREATE TRIGGER trg_CheckReturnDate
ON MuonSach
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE NgTra < NgMuon)
    BEGIN
        RAISERROR ('Ngày trả phải >= ngày mượn', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

--f/ Viết trigger kiểm tra cập nhật TINHTRANG trên bảng SACH là ‘Da muon’ mỗi
--khi thêm sách vào bảng MUONSACH (tức là hành động cho mượn sách). Khi thêm
--dòng dữ liệu vào bảng MUONSACH thì NGAYTRA để trống.
-----c1
CREATE TRIGGER trg_CapNhatTinhTrangMuon
ON MuonSach
AFTER INSERT
AS
BEGIN
    UPDATE SACH
    SET TINHTRANG = N'Đã mượn'
    FROM SACH
    JOIN inserted ON SACH.MaSach = inserted.MaSach
    WHERE inserted.NgayTra IS NULL;
END;

--------c2
CREATE TRIGGER trg_UpdateBookStatus
ON MuonSach
FOR INSERT
AS
BEGIN
    UPDATE Sach
    SET TinhTrang = 'Da muon'
    WHERE MaSH IN (SELECT MaSH FROM inserted);
END;

--g/ Viết trigger kiểm tra cập nhật TINHTRANG trên bảng SACH là ‘Chua muon’ mỗi
--khi sách đó được trả (tức là khi cập nhật NGAYTRA vào bảng MUONSACH)
-------c1
CREATE TRIGGER trg_CapNhatTinhTrangTra
ON MuonSach
AFTER UPDATE
AS
BEGIN
    UPDATE SACH
    SET TINHTRANG = N'Chưa mượn'
    FROM SACH
    JOIN inserted ON SACH.MaSH = inserted.MaSH
    WHERE inserted.NgTra IS NOT NULL;
END;
----------c2
CREATE TRIGGER trg_UpdateBookStatusOnReturn
ON MuonSach
FOR UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE NgTra IS NOT NULL)
    BEGIN
        UPDATE Sach
        SET TinhTrang = 'Chua muon'
        WHERE MaSH IN (SELECT MaSH FROM inserted WHERE NgTra IS NOT NULL);
    END
END;
--h/ Viết trigger kiểm tra kiểm tra nếu số sách chưa trả >=3 thì không được mượn tiếp.
--(HD: sách chưa trả nghĩa là NGAYMUON có giá trị NULL, hành động cho mượn
--sách có nghĩa là cho thêm dòng dữ liệu vào bảng MUONSACH)
-------c1
CREATE TRIGGER trg_KiemTraSoSachChuaTra
ON MuonSach
AFTER INSERT
AS
BEGIN
    DECLARE @SoSachChuaTra INT;

    SELECT @SoSachChuaTra = COUNT(*)
    FROM MuonSach
    WHERE NgTra IS NULL;

    IF @SoSachChuaTra >= 3
    BEGIN
        RAISERROR (N'Không được mượn sách khi số sách chưa trả >= 3.', 16, 1);
        ROLLBACK;
    END
END;
-----------c2
CREATE TRIGGER trg_CheckBorrowLimit
ON MuonSach
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM MuonSach
        WHERE NgTra IS NULL
        GROUP BY MaDG
        HAVING COUNT(*) >= 3
    )
    BEGIN
        RAISERROR ('Nếu số sách chưa trả >=3 thì không được mượn tiếp', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
