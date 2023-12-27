--trigger mẫu
CREATE TRIGGER trg_NgayGiao_NgayDat
ON PhieuGiao 
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @madat char(10), @ngaygiao datetime, @ngaydat datetime

    -- Trường hợp thêm mới
    IF NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        SELECT @madat = i.MaDat, @ngaygiao = i.NgayGiao, @ngaydat = d.NgayDat
        FROM inserted i
        JOIN DonDat d ON i.MaDat = d.MaDat

        IF @ngaygiao < @ngaydat
        BEGIN
            RAISEERROR (N'Ngày giao phải sau ngày đặt', 16, 1)
            ROLLBACK
            RETURN
        END

        IF DATEDIFF(DD, @ngaydat, @ngaygiao) > 30
        BEGIN
            RAISEERROR (N'Ngày giao - ngày đặt > 30 ngày', 16, 1)
            ROLLBACK
            RETURN
        END
    END
    ELSE
    -- Trường hợp sửa
    BEGIN
        IF UPDATE(NgayGiao)
        BEGIN
            SELECT @madat = i.MaDat, @ngaygiao = i.NgayGiao, @ngaydat = d.NgayDat
            FROM inserted i
            JOIN DonDat d ON i.MaDat = d.MaDat

            IF @ngaygiao < @ngaydat
            BEGIN
                RAISEERROR (N'Ngày giao phải sau ngày đặt', 16, 1)
                ROLLBACK
                RETURN
            END

            IF DATEDIFF(DD, @ngaydat, @ngaygiao) > 30
            BEGIN
                RAISEERROR (N'Ngày giao - ngày đặt > 30 ngày', 16, 1)
                ROLLBACK
                RETURN
            END
        END
    END
END

--------------------
--bài tập 1
declare @hoten varchar(20)
declare @tuoi int
set @hoten= N'Huu Chien'
set @tuoi= 20

--print @hoten
--print @tuoi 

select @tuoi as N'Tuổi'
select @hoten as N'Họ tên'
----------------
--bài tập 2
create database DB1
use DB1

create table SINHVIEN(
	MASV varchar(10) primary key,
	HOTEN nvarchar(30),NGSINH date,DIEMTB float
)

INSERT INTO SINHVIEN(MASV, HOTEN, NGSINH, DIEMTB)
VALUES 
('SV001', N'Nguyễn Văn A', '2000-01-01', 7.5),
('SV002', N'Trần Thị B', '2000-02-02', 8.0),
('SV003', N'Lê Văn C', '2000-03-03', 7.0),
('SV004', N'Phạm Thị D', '2000-04-04', 8.5),
('SV005', N'Ngô Văn E', '2000-05-05', 9.0);

-- dùng lệnh set để gán giá trị 
declare @hoten nvarchar(30), @ngsinh date
set @hoten= (select HOTEN from SINHVIEN where MASV= 'SV004')
set @ngsinh= (select  NGSINH from SINHVIEN where MASV= 'SV004')
select @hoten as N'Họ tên', @ngsinh as N'Ngày sinh'

-- dùng lệnh select để gán giá trị 
declare @hoten nvarchar(30), @ngsinh date
select @hoten= HOTEN, @ngsinh= NGSINH from SINHVIEN where MASV= 'SV004'

--dùng print để in thông tin sv
--print N'Sinh viên:' +  @hoten + N' .Ngày sinh: ' + convert(nvarchar(10),@ngsinh,103)

--select @hoten as N'Họ tên', @ngsinh as N'Ngày sinh'

select N'Sinh viên:' +  @hoten + N' .Ngày sinh: ' + convert(nvarchar(10),@ngsinh,103)

-- kt dtb
declare @dtb float
set @dtb= (select DIEMTB from SINHVIEN where MASV= 'SV003')
if( @dtb < 5) print N'Yếu'
else if(@dtb < 7) print N'Trung bình'
else if(@dtb < 8) print N'Khá'
else print N'Giỏi'

-- kt tuổi sv
declare @tuoi int
set @tuoi= (select datediff(yy,NGSINH,getdate()) from SINHVIEN where  MASV= 'SV003')
if(@tuoi > 30)
	select *from SINHVIEN  where  MASV= 'SV003'
else
	print N'SV chưa đủ 30 tuổi'

-- kt tuổi sv
declare @tuoi int , @hoten nvarchar(30), @dtb float ,@ngsinh date
select @hoten= HOTEN, @ngsinh= NGSINH, @dtb= DIEMTB from SINHVIEN where  MASV= 'SV003'
set @tuoi  = (datediff(year,@ngsinh,getdate()))
if(@tuoi > 18)
	begin 
		print N'Họ tên: ' + @hoten
		print N'Tuổi :' + cast(@tuoi as nvarchar(10))
		print N'DTB: ' + cast(@dtb as nvarchar(10))
	end
else
	print N'SV chưa đủ 30 tuổi'

--Dùng cấu trúc if exists ...else để kiểm tra nếu có sinh viên có điểm trung bình >5
--thì xuất ra tổng số các sinh viên đó, ngược lại xuất ra thông báo: khong co sinh
--vien tren trung binh

IF EXISTS (SELECT * FROM TenBangSinhVien WHERE DiemTrungBinh > 5)
    SELECT COUNT(*) AS TongSoSinhVien FROM TenBangSinhVien WHERE DiemTrungBinh > 5;
ELSE
    SELECT 'Khong co sinh vien tren trung binh' AS ThongBao;

if exists (select *from SINHVIEN where DIEMTB > 8.2)
	select count(*) as N'Tổng số SV' from SINHVIEN where DIEMTB > 8.2
else 
	select 'Ko có sinh viên' as N'Thông báo'

---------------
--bài tập 3
create database db_SV_3
use db_SV_3

create table Lop(
 MaLop varchar(10) primary key, TenLop nvarchar(50) , SiSo int
)

create table SinhVien (
	MaSV varchar(10) primary key, HoTen nvarchar(50),NgSinh date,GTinh nvarchar(10),QueQuan nvarchar(50),
	MaLop varchar(10), DiemTB float, XepLoai nvarchar(50),
	foreign key (MaLop) references Lop(MaLop)
)

create table MonHoc(
	MaMH varchar(10) primary key, TenMH nvarchar(50), SoTC int, BatBuoc nvarchar(10)
)

create table KetQua(
	MaSV varchar(10) , MaMH varchar(10),
	HocKy nvarchar(50), DiemThi float,
	primary key (MaSV, MaMH, HocKy),
	foreign key (MaSV) references SinhVien(MaSV),
	foreign key (MaMH) references MonHoc(MaMH)
)

INSERT INTO Lop (MaLop, TenLop, SiSo) VALUES
('L001', N'Lớp 1', 30),
('L002', N'Lớp 2', 25),
('L003', N'Lớp 3', 28),
('L004', N'Lớp 4', 22),
('L005', N'Lớp 5', 20);

INSERT INTO SinhVien (MaSV, HoTen, NgSinh, GTinh, QueQuan, MaLop, DiemTB, XepLoai) VALUES
('SV001', N'Nguyễn Văn A', '2000-01-05', N'Nam', N'Hà Nội', 'L001', 8.5, N'Giỏi'),
('SV002', N'Trần Thị B', '2001-03-10', N'Nữ', N'TPHCM', 'L002', 7.2, N'Khá'),
('SV003', N'Phạm Văn C', '1999-12-15', N'Nam', N'Đà Nẵng', 'L003', 6.8, N'TB'),
('SV004', N'Lê Thị D', '2000-05-20', N'Nữ', N'Quảng Ninh', 'L004', 9.0, N'Giỏi'),
('SV005', N'Hoàng Văn E', '2000-08-25', N'Nam', N'Cần Thơ', 'L005', 7.5, N'Khá');

INSERT INTO MonHoc (MaMH, TenMH, SoTC, BatBuoc) VALUES
('MH001', N'Toán', 3, N'Có'),
('MH002', N'Văn', 2, N'Có'),
('MH003', N'Anh', 3, N'Không'),
('MH004', N'Lịch Sử', 2, N'Có'),
('MH005', N'Hóa', 3, N'Không');

INSERT INTO KetQua (MaSV, MaMH, HocKy, DiemThi) VALUES
('SV001', 'MH001', N'Học Kỳ 1', 8.0),
('SV002', 'MH002', N'Học Kỳ 1', 7.5),
('SV003', 'MH003', N'Học Kỳ 1', 6.0),
('SV004', 'MH004', N'Học Kỳ 1', 8.8),
('SV005', 'MH005', N'Học Kỳ 1', 7.2);

INSERT INTO KetQua (MaSV, MaMH, HocKy, DiemThi) VALUES
('SV002', 'MH005', N'Học Kỳ 1', 7.8),
('SV003', 'MH005', N'Học Kỳ 1', 6.2)


--a/ Thủ tục cập nhật SISO trên bảng LOP dựa vào bảng SINHVIEN:

create proc CapNhatSiSo_
 @malop varchar(10), @siso int output
as 
begin 
	update Lop set @siso= (select count(*) from SinhVien where MaLop= @malop),  SiSo= @siso where @malop =MaLop
end

--thực thi thủ tục
declare @ss int
exec CapNhatSiSo_ 'L001', @ss output 
print @ss

select *from Lop

--b/ Thủ tục cộng 1 điểm cho sinh viên khi truyền vào 3 tham số là mã sinh viên, tên môn học, và học kỳ.

create proc cong1diem 
 @masv varchar(10), @tenmh nvarchar(50), @hocki nvarchar(50)
as 
begin 
	update KetQua set DiemThi= DiemThi +1  where MaSV= @masv and HocKy= @hocki and MaMH= (select MaMH from MonHoc where TenMH= @tenmh);
end;

exec cong1diem 'SV002', N'Văn', N'Học Kỳ 1'
--drop proc cong1diem

select *from KetQua

-- e/ Thủ tục in ra họ tên và tên lớp của sinh viên khi truyền vào tham số MASV

create proc hoten_lop
@masv varchar(10)
as begin
	--select HOTEN, TenLop from SINHVIEN sv, Lop l where MaSV= @masv and sv.MaLop= l.MaLop;
	select HoTen,TenLop from SINHVIEN sv inner join Lop l on sv.MaLop= l.MaLop where MASV=@masv
end;

exec hoten_lop 'SV002'

select *from SINHVIEN

drop proc hoten_lop

--d/ Thủ tục trả về họ tên và tổng số môn học mà sinh viên đó học khi truyền vào 2 tham số: mã sinh viên và học kỳ

CREATE PROCEDURE hoten_tongMH_
 @masv varchar(10), @hocki nvarchar(50), @tongmh int OUTPUT
AS 
BEGIN 
	SELECT @tongmh = COUNT(*) 
	FROM KetQua
	WHERE MaSV = @masv AND HocKy = @hocki;

	SELECT HoTen
	FROM SinhVien
	WHERE MaSV = @masv;

END;

declare @sum int
exec hoten_tongMH_ 'SV003', N'Học Kỳ 1', @sum output 
SELECT @sum AS N'Tổng số mh'
drop proc hoten_tongMH_

select *from SINHVIEN
select *from KetQua

--g/ Viết thủ tục khi truyền vào tên môn học và học kỳ sẽ trả về mã môn học, số tín chỉ
--và tổng số sinh viên học môn học trong học kỳ đó
create proc mamh_sotc_tongsv
@tenmh nvarchar(50), @hocki nvarchar(50)
as begin
	select count(*)as N'Tổng SV' from KetQua where HocKy= @hocki and MaMH= (select MaMH from MonHoc where TenMH= @tenmh)
	select MaMH,SoTC from MonHoc  where TenMH= @tenmh
end;

exec mamh_sotc_tongsv N'Hóa', N'Học Kỳ 1'

---g/ (cách 2) tham khảo
CREATE PROCEDURE ThongTinMonHoc
 @TenMH nvarchar(50), @HocKy nvarchar(50)
AS 
BEGIN 
	SELECT MonHoc.MaMH, MonHoc.SoTC
	FROM MonHoc
	WHERE MonHoc.TenMH = @TenMH;

	SELECT COUNT(SinhVien.MaSV) as SoSinhVien
	FROM MonHoc
	INNER JOIN KetQua ON MonHoc.MaMH = KetQua.MaMH
	INNER JOIN SinhVien ON KetQua.MaSV = SinhVien.MaSV
	WHERE MonHoc.TenMH = @TenMH AND KetQua.HocKy = @HocKy;
END;

EXEC ThongTinMonHoc N'Hóa', N'Học Kỳ 1'

drop proc mamh_sotc_tongsv

select *from MonHoc
select *from SINHVIEN
select *from KetQua

--h/ Viết thủ tục khi truyền vào 3 tham số: mã sinh viên, tên môn học và học kỳ sẽ trả về
--‘chua dang ky nếu như sinh viên đó chưa đăng ký môn học, trả về ‘dat’ nếu điểm
--môn đó >=5, trả về ‘khong dat’ neu điểm của môn đó <5.
CREATE PROCEDURE KiemTraDangKyVaDiem
 @MaSV varchar(10), @TenMH nvarchar(50), @HocKy nvarchar(50)
AS 
BEGIN 
	declare @Diem float;
	SELECT @Diem = DiemThi
	FROM KetQua
	INNER JOIN MonHoc ON KetQua.MaMH = MonHoc.MaMH
	WHERE MaSV = @MaSV AND TenMH = @TenMH AND HocKy = @HocKy;

	IF @Diem IS NULL
		SELECT N'Chưa đăng ký' AS N'Kết quả'
	ELSE IF @Diem >= 6
		SELECT N'Đạt' AS N'Kết quả'
	ELSE
		SELECT N'Không đạt' AS N'Kết quả';
END;

--
EXEC KiemTraDangKyVaDiem 'SV003', N'Hóa', N'Học Kỳ 1'

--drop proc KiemTraDangKyVaDiem

--i/ Viết thủ tục trả về điểm trung bình của sinh viên khi truyền vào tham số mã sinh viên
--(HD: Điểm trung bình =(số tín chỉl * điểm môn học1+số tín chỉ2*điểm môn
--hoc2+...+số tín chỉ n * điểm môn học n)/tổng số tín chỉ)

CREATE PROCEDURE TinhDiemTrungBinh
 @MaSV varchar(10), @DiemTB float OUTPUT
AS 
BEGIN 
	SELECT @DiemTB = SUM(MonHoc.SoTC * KetQua.DiemThi) / SUM(MonHoc.SoTC)
	FROM KetQua
	INNER JOIN MonHoc ON KetQua.MaMH = MonHoc.MaMH
	WHERE MaSV = @MaSV;
END;

DECLARE @dtb float
EXEC TinhDiemTrungBinh 'SV002', @dtb OUTPUT 
SELECT @dtb AS DiemTrungBinh

--j/ Viết hàm cho các câu c,d,e,f,g,h,
--c/ Hàm cập nhật SISO trên bảng LOP dựa vào bảng SINHVIEN:

create function capnhat_siso(@malop varchar(10))
returns int
as begin
	declare @siso int
	select @siso= count(*) from SINHVIEN where MaLop = @malop
	
	return @siso
end
--
declare @malop varchar(10)= 'L005'
update Lop set SiSo= dbo.capnhat_siso(@malop) where MaLop= @malop

select *from Lop
--d/ Hàm cộng 1 điểm cho sinh viên khi truyền vào 3 tham số là mã sinh viên, tên môn học, và học kỳ.
create function cong1d(@masv varchar(10), @tenmh nvarchar(50), @hocki nvarchar(50))
returns float
as begin 
	declare @diem float
	select @diem= DiemThi +1 from KetQua where MaSV= @masv and HocKy= @hocki and MaMH= (select MaMH from MonHoc where TenMH= @tenmh)
	return @diem
end
--
declare @masv varchar(10)= 'SV002', @tenmh nvarchar(50)= N'Hóa', @hocki  nvarchar(50)= N'Học kỳ 1'
update KetQua set DiemThi= dbo.cong1d(@masv,@tenmh,@hocki) where MaSV= @masv and HocKy= @hocki and MaMH= (select MaMH from MonHoc where TenMH= @tenmh)

select * from KetQua

-- e.Thủ tục in ra họ tên và tên lớp của sinh viên khi truyền vào tham số MASV
create function hoten_lop_func(@masv varchar(10))
returns @result table (HoTen nvarchar(50), TenLop nvarchar(50))
as begin
	insert into @result
	select HOTEN, TenLop from SINHVIEN sv inner join Lop l on sv.MaLop= l.MaLop where MaSV= @masv
	return
end

--
declare @masv varchar(10)= 'SV003'
select *from dbo.hoten_lop_func(@masv)

drop function hoten_lop

select * from SINHVIEN
select * from Lop

-- f.Thủ tục trả về họ tên và tổng số môn học mà sinh viên đó học khi truyền vào 2 tham số: mã sinh viên và học kỳ
CREATE FUNCTION hoten_tongmh(@masv varchar(10), @hocki nvarchar(50))
RETURNS TABLE
AS 
RETURN (
	SELECT sv.HoTen, COUNT(*) as TongMH 
	FROM SinhVien sv 
	INNER JOIN KetQua kq ON sv.MaSV = kq.MaSV
	WHERE sv.MaSV = @masv AND kq.HocKy = @hocki
	GROUP BY sv.HoTen
)
--
DECLARE @masv varchar(10) = 'SV003', @hocki nvarchar(50) = N'Học Kỳ 1'
SELECT * FROM dbo.hoten_tongmh(@masv, @hocki)

select *from SinhVien
select *from KetQua

--g. Viết hàm khi truyền vào tên môn học và học kỳ sẽ trả về mã môn học, số tín chỉ
--và tổng số sinh viên học môn học trong học kỳ đó
create function mamh_sotc_tongsv(@tenmh nvarchar(50), @hocki nvarchar(50))
returns table 
as 
return(
	select kq.MaMH, SoTC, count(*) as N'Tổng sv'
	from KetQua kq inner join MonHoc mh on kq.MaMH= mh.MaMH  where TenMH= @tenmh and HocKy= @hocki
	group by kq.MaMH, SoTC
)

declare @ten nvarchar(50)= N'Hóa', @hk nvarchar(50) = N'Học Kỳ 1'
select *from dbo.mamh_sotc_tongsv(@ten, @hk)

select *from MonHoc
select *from KetQua

--h. Viết hàm khi truyền vào 3 tham số: mã sinh viên, tên môn học và học kỳ sẽ trả về
--‘chua dang ky nếu như sinh viên đó chưa đăng ký môn học, trả về ‘dat’ nếu điểm
--môn đó >=5, trả về ‘khong dat’ neu điểm của môn đó <5.

create function  dat_chuadat(@masv varchar(10) ,@tenmh nvarchar(50), @hocki nvarchar(50))
returns float
as begin
	declare @diemthi float
	select @diemthi= DiemThi from MonHoc mh inner join KetQua kq on mh.MaMH= kq.MaMH where MaSV= @masv and TenMH= @tenmh and HocKy= @hocki
	return @diemthi
end

declare @ma_sv nvarchar(50)= 'SV003', @ten_mh nvarchar(50)= N'Hóa', @hk  nvarchar(50)= N'Học Kỳ 1'
--declare @ma_sv nvarchar(50)= 'SV003', @ten_mh nvarchar(50)= N'Toán', @hk  nvarchar(50)= N'Học Kỳ 1'
if(dbo.dat_chuadat(@ma_sv,@ten_mh,@hk) >= 5)
	print N'Đạt'
else if(dbo.dat_chuadat(@ma_sv,@ten_mh,@hk) < 5)
	print N'Chưa đạt'
else print N'SV chưa đăng kí môn này'

select *from MonHoc
select *from KetQua

----i/ Viết hàm trả về điểm trung bình của sinh viên khi truyền vào tham số mã sinh viên
--(HD: Điểm trung bình =(số tín chỉl * điểm môn học1+số tín chỉ2*điểm môn
--hoc2+...+số tín chỉ n * điểm môn học n)/tổng số tín chỉ)
create function tinh_dtb(@masv varchar(10))
returns float
as begin
	declare @dtb float
	select @dtb = SUM(mh.SoTC * kq.DiemThi) / SUM(mh.SoTC) from MonHoc mh inner join KetQua kq on mh.MaMH= kq.MaMH where MaSV= @masv
	return @dtb
end

declare @ma_sv varchar(10)= 'SV003'
select  dbo.tinh_dtb(@ma_sv)

select *from SinhVien
select *from KetQua
select *from MonHoc

--k/ Viết hàm nội tuyến trả về table gồm: mã sinh viên, họ tên, tên lớp, tổng số môn học.
--Với tham số truyền vào là ‘lop A’ Thực hiện truy vấn trên hàm (liệt kê mã họ tên và
--tổng số môn học của các sinh viên)

create function masv_hoten_tenlop_tongmh(@tenlop nvarchar(50))
returns table
as return(
	select sv.MaSV,HoTen,TenLop, count(*) as N'Tổng mh' from SinhVien sv 
	inner join Lop l on sv.MaLop = l.MaLop 
	inner join KetQua kq on sv.MaSV= kq.MaSV
	where TenLop= @tenlop
	group by sv.MaSV,HoTen,TenLop
)
--
declare @ten_lop nvarchar(50)= N'Lớp 3'
select *from dbo.masv_hoten_tenlop_tongmh(@ten_lop)

select *from SinhVien
select *from Lop
select *from KetQua

--------- bt 4
create database db_sach
use db_sach

create table DocGia(
	MaDG varchar(10) primary key, TenDG nvarchar(50),DiaChi nvarchar(100)
)

create table Sach(
	MaSH varchar(10) primary key, 
	TenSH nvarchar(50), Loai nvarchar(50),NXB nvarchar(50), NamXB int, TacGia nvarchar(50),TinhTrang nvarchar(50)
)

create table MuonSH(
	MaDG varchar(10),MaSH varchar(10),NgMuon date, NgTra date,
	primary key (MaDG, MaSH,NgMuon),
	foreign key (MaDG) references DocGia(MaDG),
	foreign key (MaSH) references Sach(MaSH)
)

-- Chèn dữ liệu vào bảng DocGia
INSERT INTO DocGia(MaDG, TenDG, DiaChi)
VALUES 
('DG001', N'Nguyễn Văn A', N'123 Đường ABC, Quận 1, TP.HCM'),
('DG002', N'Trần Thị B', N'456 Đường DEF, Quận 2, TP.HCM'),
('DG003', N'Lê Văn C', N'789 Đường GHI, Quận 3, TP.HCM'),
('DG004', N'Phạm Thị D', N'321 Đường JKL, Quận 4, TP.HCM'),
('DG005', N'Ngô Văn E', N'654 Đường MNO, Quận 5, TP.HCM');

-- Chèn dữ liệu vào bảng Sach
INSERT INTO Sach(MaSH, TenSH, Loai, NXB, NamXB, TacGia, TinhTrang)
VALUES 
('SH001', N'Hóa học', N'Khoa học', N'NXB Giáo dục', 2020, N'Tác giả A', N'Còn'),
('SH002', N'Vật lý', N'Khoa học', N'NXB Giáo dục', 2021, N'Tác giả B', N'Còn'),
('SH003', N'Toán học', N'Khoa học', N'NXB Giáo dục', 2022, N'Tác giả C', N'Hết hàng'),
('SH004', N'Ngữ văn', N'Ngữ văn', N'NXB Giáo dục', 2023, N'Tác giả D', N'Còn'),
('SH005', N'Lịch sử', N'Xã hội', N'NXB Giáo dục', 2024, N'Tác giả E', N'Hết hàng');

INSERT INTO Sach(MaSH, TenSH, Loai, NXB, NamXB, TacGia, TinhTrang)
VALUES 
	('SH006', N'Toán học song ngữ Anh', N'Khoa học', N'NXB Thời đại', 2022, N'Tác giả F', N'Hết hàng'),
	('SH007', N'Toán học song ngữ Nhật', N'Khoa học', N'NXB Trẻ', 2022, N'Tác giả G', N'Hết hàng'),
	('SH008', N'Vật lý học song ngữ Anh', N'Khoa học', N'NXB Thanh niên', 2022, N'Tác giả H', N'Hết hàng'),
	('SH009', N'Hóa học song ngữ Anh', N'Khoa học', N'NXB Thời đại', 2022, N'Tác giả K', N'Hết hàng');

-- Chèn dữ liệu vào bảng MuonSH
INSERT INTO MuonSH(MaDG, MaSH, NgMuon, NgTra)
VALUES 
('DG001', 'SH001', '2023-01-01', '2023-01-31'),
('DG002', 'SH002', '2023-02-01', '2023-02-28'),
('DG003', 'SH003', '2023-03-01', '2023-03-31'),
('DG004', 'SH004', '2023-04-01', '2023-04-30'),
('DG005', 'SH005', '2023-05-01', '2023-05-31');

INSERT INTO MuonSH(MaDG, MaSH, NgMuon, NgTra)
VALUES 
('DG001', 'SH003', '2023-04-08', '2023-05-31'),
('DG002', 'SH003', '2023-07-21', '2023-07-21'),
('DG003', 'SH007', '2023-11-01', '2023-11-11'),
('DG003', 'SH008', '2023-12-01', '2023-12-01'),
('DG005', 'SH006', '2023-10-01', '2023-10-08');

INSERT INTO MuonSH(MaDG, MaSH, NgMuon, NgTra)
VALUES 
('DG005', 'SH004', '2023-12-01', '2023-12-31'),
('DG003', 'SH005', '2023-12-01', '2023-12-31');

--c/ Viết thủ tục truyền vào tham số mã đọc giả sẽ trả về tên đọc giả và địa chỉ.
create proc tendg_diachi
@madg varchar(10)
as begin
	select TenDG, DiaChi from DocGia where MaDG= @madg
end

exec tendg_diachi 'DG003'

--d/ Viết thủ tục truyền vào tham số mã sách sẽ trả về tên sách, năm xuất bản và tác giả.
create proc tenSH_namxb_tacgia
@mash varchar(10)
as begin 
	select TenSH,NamXB,TacGia from Sach where MaSH= @mash
end

exec tenSH_namxb_tacgia 'SH007'

select* from Sach

--e/ Viết thủ tục truyền vào tham số mã đọc giả sẽ trả về số lượng sách mà đọc giả đang
--mượn, nếu không có sách nào đang mượn thì trả về 0 (ghi chú: sách chưa trả thì ngày
--trả có giá trị NULL)
create proc sl_Sach
@madg varchar(10), @tongSH int output
as begin
	select @tongSH= count(*) from MuonSH where MaDG= @madg
end

--
declare @sl int
exec sl_Sach 'DG003', @sl output 
select @sl as N'Số lượng sách đang mượn'

select* from Sach
select* from MuonSH

--f/ Viết thủ tục truyền vào mã sách sẽ trả về tên đọc giả nếu đọc giả đang mượn sách
--đó, nếu sách hiện không có đọc giả nào mượn thì trả về ‘chua muon’

create proc tendg_kq_muonSH
@maSH varchar(10)
as begin
	if exists (select MaDG from MuonSH where MaSH= @mash)
		select TenDG from MuonSH m inner join DocGia dg on m.MaDG= dg.MaDG where MaSH= @mash
	else 
		print N'Chưa được mượn'
end

exec tendg_kq_muonSH 'SH003'
--exec tendg_kq_muonSH 'SH009'

--g/ Viết thủ tục truyền vào tham số mã đọc giả và ngày/tháng/năm sẽ trả số sách mà đọc
--giả mượn trong ngày/tháng/năm đó, nếu đọc giả không có mượn sách trong ngày đó
--thì trả về 0.
create proc sl_sach
@madg varchar(10), @ngMuon date
as begin
	
	if exists (select MaDG from MuonSH where MaDG= @madg )
		select count(*) as N'Số lg sách đã mượn' from MuonSH where MaDG= @madg and NgMuon= @ngMuon
	else print '0'
end

declare @ma_docgia varchar(10), @ngMuon date
exec sl_sach 'DG003', '2023-12-01'

--drop proc sl_sach

select* from DocGia
select* from MuonSH

--h/ Viết thủ tục truyền vào mã sách sẽ trả về ngày/tháng/năm mà sách đó được mượn gần nhất.
create proc ngMuon_gannhat
@mash varchar(10)
as begin
	select top 1 NgMuon from MuonSH where MaSH= @mash order by NgMuon Desc
end 

--TOP 1: câu lệnh này sẽ trả về bản ghi có NgMuon lớn nhất, tức ngày gần nhất trong các ngày mượn được xếp theo tt giảm dần
exec ngMuon_gannhat 'SH005'

---------i/ Viết lại các câu: e, f, g, h bằng cấu trúc hàm.
--e/ Viết hàm truyền vào tham số mã đọc giả sẽ trả về số lượng sách mà đọc giả đang
--mượn, nếu không có sách nào đang mượn thì trả về 0 (ghi chú: sách chưa trả thì ngày
--trả có giá trị NULL)

create function sl_sach_muon(@madg varchar(10))
returns int
as begin
	declare @sl int
	select @sl= count(*) from MuonSH where MaDG= @madg
	if(@sl is null)
		set @sl= 0
	return @sl
end
--
DECLARE @bookCount INT;
EXEC @bookCount = sl_sach_muon @MaDG = 'DG003';
SELECT @bookCount as N'Số lượng sách đang mượn';

----c2
create function sl_sach_muon_ (@madg varchar(10))
returns @result table (SoLuongSachMuon int)
as begin
	declare @sl int;
	select @sl = count(*)  from MuonSH where MaDG= @madg;
	if(@sl is null)
		set @sl= 0;
	insert into @result
	select @sl;
	return;
end
--
declare @ma_docgia varchar(10)= 'DG003'
select *from dbo.sl_sach_muon_(@ma_docgia)

select *from MuonSH

--f/ Viết hàm truyền vào mã sách sẽ trả về tên đọc giả nếu đọc giả đang mượn sách
--đó, nếu sách hiện không có đọc giả nào mượn thì trả về ‘chua muon’
create function kq_muon(@mash varchar(10))
returns table
as return
	select TenDG from MuonSH m inner join DocGia dg on m.MaDG= dg.MaDG where MaSH= @mash

--
declare @ma_sach varchar(10)= 'SH003'
select *from dbo.kq_muon(@ma_sach)

select *from MuonSH
select *from DocGia

--g/ Viết hàm truyền vào tham số mã đọc giả và ngày/tháng/năm sẽ trả số sách mà đọc
--giả mượn trong ngày/tháng/năm đó, nếu đọc giả không có mượn sách trong ngày đó
--thì trả về 0.

create function sl_sach_muon_ngMuon(@madg varchar(10), @ngMuon date)
returns int
as begin
	declare @sl int
	select @sl= count(*) from MuonSH where MaDG= @madg and NgMuon= @ngMuon
	if (@sl =0)
        set @sl = 0;
    return @sl;
end
--drop function sl_sach_muon_ngMuon

DECLARE @sl_muon INT;
SELECT @sl_muon =  dbo.sl_sach_muon_ngMuon('DG001', '2023-04-08')
SELECT @sl_muon AS N'Số lg sách mượn'

select *from MuonSH

--h/ Viết hàm truyền vào mã sách sẽ trả về ngày/tháng/năm mà sách đó được mượn gần nhất.
create function ngay_muon_gannhat(@mash varchar(10))
returns date
as begin
	declare @ngmuon date
	select @ngmuon=  Max(NgMuon) from MuonSH where MaSH= @mash 
	return @ngmuon
end

declare @ngay_muon date
select @ngay_muon= dbo.ngay_muon_gannhat('SH003')
select @ngay_muon as N'Ngày mượn gần nhất'

select *from MuonSH

--bài tập 5

create database db_banhang
use db_banhang

create table Khach(
	MaKH varchar(10) primary key, TenKH nvarchar(50), DChi nvarchar(100),DThoai varchar(20)
)

create table NhaSX(
	MaNSX varchar(10) primary key,TenNSX nvarchar(50),DChi nvarchar(100),DThoai varchar(20)
)

create table NhaCC(
  MaNCC varchar(10) primary key,TenNCC nvarchar(50),DChi nvarchar(100),DThoai varchar(20)
)

create table PhieuNhap(
 MaPN varchar(10) primary key, NgNhap date,MaNCC varchar(10) ,TienNhap float,
 foreign key (MaNCC) references NhaCC(MaNCC)
)
create table Hang(
	MaHG varchar(10) primary key, TenHG nvarchar(50),DVT nvarchar(50),SoLuong int, MaNSX varchar(10), MaNCC varchar(10),TinhTrang nvarchar(50),
	foreign key (MaNSX) references NhaSX(MaNSX),
	foreign key (MaNCC) references NhaCC(MaNCC)
)
create table ChiTietPN(
MaPN varchar(10), MaHG varchar(10),SoLuong int,GiaNhap float, ThanhTien float,
foreign key (MaHG) references Hang(MaHG),
primary key (MaPN, MaHG)
)
create table HoaDon(
MaHD varchar(10) primary key,NgayBan date, TenNV nvarchar(50),MaKH varchar(10),TienBan float,GiamGia nvarchar(50), ThanhToan nvarchar(50),
foreign key (MaKH) references Khach(MaKH)
)

create table ChiTietHD(
MaHD varchar(10), MaHG varchar(10),SoLuong int, GiaBan float, ThanhTien float,
foreign key (MaHG) references Hang (MaHG),
primary key (MaHD, MaHG)
)

create table DonGia(
MaHG varchar(10), NgayCN date , Gia float,
primary key (MaHG, NgayCN)
)

INSERT INTO Khach VALUES ('KH001', N'Nguyễn Văn A', N'123 Đường ABC, Quận 1', '0123456789');
INSERT INTO Khach VALUES ('KH002', N'Trần Thị B', N'456 Đường XYZ, Quận 2', '0987654321');
INSERT INTO Khach VALUES ('KH003', N'Lê Văn C', N'789 Đường LMN, Quận 3', '0369852147');
INSERT INTO Khach VALUES ('KH004', N'Phạm Thị D', N'101 Đường PQR, Quận 4', '0796423581');
INSERT INTO Khach VALUES ('KH005', N'Hồ Minh E', N'202 Đường UVW, Quận 5', '0542136978');

INSERT INTO NhaSX VALUES ('NSX001', N'Công ty ABC', N'789 Đường LMN, Quận 3', '0369852147');
INSERT INTO NhaSX VALUES ('NSX002', N'Công ty XYZ', N'101 Đường PQR, Quận 4', '0796423581');
INSERT INTO NhaSX VALUES ('NSX003', N'Công ty LMN', N'202 Đường UVW, Quận 5', '0542136978');
INSERT INTO NhaSX VALUES ('NSX004', N'Công ty PQR', N'303 Đường XYZ, Quận 6', '0123456789');
INSERT INTO NhaSX VALUES ('NSX005', N'Công ty UVW', N'404 Đường ABC, Quận 7', '0987654321');

INSERT INTO NhaCC VALUES ('NCC001', N'Nhà cung cấp A', N'123 Đường ABC, Quận 1', '0123456789');
INSERT INTO NhaCC VALUES ('NCC002', N'Nhà cung cấp B', N'456 Đường XYZ, Quận 2', '0987654321');
INSERT INTO NhaCC VALUES ('NCC003', N'Nhà cung cấp C', N'789 Đường LMN, Quận 3', '0369852147');
INSERT INTO NhaCC VALUES ('NCC004', N'Nhà cung cấp D', N'101 Đường PQR, Quận 4', '0796423581');
INSERT INTO NhaCC VALUES ('NCC005', N'Nhà cung cấp E', N'202 Đường UVW, Quận 5', '0542136978');

INSERT INTO PhieuNhap VALUES ('PN001', '2023-01-01', 'NCC001', 1500000.00);
INSERT INTO PhieuNhap VALUES ('PN002', '2023-02-01', 'NCC002', 2000000.00);
INSERT INTO PhieuNhap VALUES ('PN003', '2023-03-01', 'NCC003', 1800000.00);
INSERT INTO PhieuNhap VALUES ('PN004', '2023-04-01', 'NCC004', 2200000.00);
INSERT INTO PhieuNhap VALUES ('PN005', '2023-05-01', 'NCC005', 1700000.00);

INSERT INTO Hang VALUES ('HG001', N'Laptop Dell', N'Chiếc', 50, 'NSX001', 'NCC001', N'Mới');
INSERT INTO Hang VALUES ('HG002', N'Smartphone Samsung', N'Chiếc', 80, 'NSX002', 'NCC002', N'Mới');
INSERT INTO Hang VALUES ('HG003', N'Tivi Sony', N'Chiếc', 30, 'NSX003', 'NCC003', N'Mới');
INSERT INTO Hang VALUES ('HG004', N'Máy tính bảng Lenovo', N'Chiếc', 40, 'NSX004', 'NCC004', N'Cũ');
INSERT INTO Hang VALUES ('HG005', N'Điều hòa Panasonic', N'Bộ', 20, 'NSX005', 'NCC005', N'Mới');

INSERT INTO ChiTietPN VALUES ('PN001', 'HG001', 10, 1200000.00, 12000000.00);
INSERT INTO ChiTietPN VALUES ('PN001', 'HG002', 15, 8000000.00, 120000000.00);
INSERT INTO ChiTietPN VALUES ('PN002', 'HG003', 5, 15000000.00, 75000000.00);
INSERT INTO ChiTietPN VALUES ('PN003', 'HG004', 8, 2000000.00, 16000000.00);
INSERT INTO ChiTietPN VALUES ('PN004', 'HG005', 12, 1000000.00, 12000000.00);

INSERT INTO HoaDon VALUES ('HD001', '2023-01-10', N'Nguyễn Văn X', 'KH001', 15000000.00, N'5%', N'Tiền mặt');
INSERT INTO HoaDon VALUES ('HD002', '2023-02-15', N'Trần Thị Y', 'KH002', 20000000.00, N'10%', N'Tiền mặt');
INSERT INTO HoaDon VALUES ('HD003', '2023-03-20', N'Lê Văn Z', 'KH003', 18000000.00, N'3%', N'Tiền mặt');
INSERT INTO HoaDon VALUES ('HD004', '2023-04-25', N'Phạm Thị W', 'KH004', 22000000.00, N'8%', N'Tiền mặt');
INSERT INTO HoaDon VALUES ('HD005', '2023-05-30', N'Hồ Minh Q', 'KH005', 17000000.00, N'6%', N'Tiền mặt');

INSERT INTO ChiTietHD VALUES ('HD001', 'HG001', 3, 15000000.00, 45000000.00);
INSERT INTO ChiTietHD VALUES ('HD001', 'HG002', 2, 10000000.00, 20000000.00);
INSERT INTO ChiTietHD VALUES ('HD002', 'HG003', 1, 18000000.00, 18000000.00);
INSERT INTO ChiTietHD VALUES ('HD003', 'HG004', 4, 2500000.00, 10000000.00);
INSERT INTO ChiTietHD VALUES ('HD004', 'HG005', 2, 1200000.00, 2400000.00);

INSERT INTO DonGia VALUES ('HG001', '2023-01-01', 1200000.00);
INSERT INTO DonGia VALUES ('HG002', '2023-02-01', 8000000.00);
INSERT INTO DonGia VALUES ('HG003', '2023-03-01', 15000000.00);
INSERT INTO DonGia VALUES ('HG004', '2023-04-01', 2000000.00);
INSERT INTO DonGia VALUES ('HG005', '2023-05-01', 1000000.00);
INSERT INTO DonGia VALUES ('HG005', '2023-11-01', 1500000.00);

--7.3. Viết thủ tục thực hiện việc cập nhật THANHTIEN trên bảng CHITIETHD và
--TIENBAN trên bảng CHITIETHD.
create proc capnhat_thtien
@mahd varchar(10) 
as begin
	update ChiTietHD set ThanhTien=  dg.Gia*SoLuong from ChiTietHD cthd inner join DonGia dg  on dg.MaHG= cthd.MaHG where MaHD= @mahd
	update ChiTietHD set GiaBan=  dg.Gia from ChiTietHD cthd inner join DonGia dg  on dg.MaHG= cthd.MaHG where MaHD= @mahd
	update HoaDon set TienBan=   cthd.GiaBan from HoaDon hd inner join ChiTietHD cthd on hd.MaHD= cthd.MaHD where hd.MaHD= @mahd
end

--drop proc capnhat_thtien
exec capnhat_thtien 'HD001'

declare @thanh_tien float , @gia_ban float, @tien_ban float

select *from DonGia
select *from ChiTietHD
select *from HoaDon

--7.4. Viết thủ tục thực hiện cập nhật THANHTIEN trên bảng CHITIETPN và
--TIENNHAP trên bảng PHIEUNHAP.
create proc capnhat_thtien_pn
@mapn varchar(10)
as begin
	update ChiTietPN set GiaNhap = TienNhap from ChiTietPN ctpn inner join PhieuNhap pn on ctpn.MaPN= pn.MaPN where pn.MaPN= @mapn
	update ChiTietPN set ThanhTien= pn.TienNhap* ctpn.SoLuong from ChiTietPN ctpn inner join PhieuNhap pn on ctpn.MaPN= pn.MaPN where pn.MaPN= @mapn
end

exec capnhat_thtien_pn 'PN001'

select *from PhieuNhap
select *from ChiTietPN

--7.5. Viết thủ tục truyền vào tham số mã khách hàng sẽ in ra danh sách các hóa đơn (mã
--hóa đơn, tổng trị giá) của khách hàng đó.
create proc mahd_tongtien
@makh varchar(10)
as begin
	select hd.MaHD, ThanhTien from HoaDon hd inner join ChiTietHD cthd on hd.MaHD= cthd.MaHD where MaKH= @makh
end

exec mahd_tongtien 'KH002'

select *from HoaDon
select *from ChiTietHD

--7.6. Viết thủ tục truyền vào tham số mã hóa đơn sẽ trả về ngày lập và trị giá của hóa
--đơn đó.
create proc ngLap_giahh
@mahd varchar(10)
as begin
	select NgayBan from HoaDon hd inner join ChiTietHD cthd on hd.MaHD= cthd.MaHD where hd.MaHD= @mahd
end

exec ngLap_giahh 'HD002'

select *from HoaDon
select *from ChiTietHD

--7.7. Viết thủ tục truyền vào tham số mã hàng sẽ trả về tên hàng, tên nhà sản xuất và tên
--nhà cung cấp tương ứng.
--7.8. Để kiểm tra một khách hàng thuộc loại nào (‘VIP”, ‘KH thành viên”, “KH thân
--thiết”) cần viết một thủ tục truyền vào tham số mã khách hàng sẽ trả về ‘VIP’nếu
--doanh số 210.000.000; “KH thành viên nếu 6.000.000 <doanh số<10.000.000; “KH
--thân thiết” nếu doanh số <6.000.000 (ghi chú: Doanh số là số tiền mà khách mua
--hàng).
--Y
--7.9. Viết thủ tục truyền vào mã hàng sẽ trả về ngày cập nhật đơn giá gần nhất.
--7.10. Viết lại các câu g, f bằng cấu trúc hàm

--bài tập 6
create database db_sinhvien_6
use db_sinhvien_6

create table Lop(
	MaLop varchar(10) primary key,TenLop nvarchar(50), SiSo int
)

create table SinhVien(
	MaSV varchar(10) primary key, HoTen nvarchar(50),NgSinh date,GTinh nvarchar(10), QueQuan nvarchar(50), MaLop varchar(10),DiemTB float, XepLoai nvarchar(10),
	foreign key (MaLop) references Lop(MaLop)
)

create table MonHoc(
	MaMH varchar(10) primary key, TenMH nvarchar(50),SoTC int,BatBuoc nvarchar(10)
)

create table KetQua(
	MaSV varchar(10), MaMH varchar(10),HocKy varchar(20),DiemThi float,
	primary key (MaSV, MaMH, HocKy)
)

 
--9.1. Viết trigger thực hiện cập nhật sĩ số SISO trên bảng LOP mỗi khi thêm, xóa hay sửa
--dữ liệu trên bảng SINHVIEN
-----------c1
-- Trigger for INSERT
CREATE TRIGGER trg_SinhVien_Insert
ON SinhVien
AFTER INSERT
AS
BEGIN
    UPDATE Lop
    SET SiSo = SiSo + 1
    WHERE MaLop IN (SELECT MaLop FROM inserted)
END

-- Trigger for DELETE
CREATE TRIGGER trg_SinhVien_Delete
ON SinhVien
AFTER DELETE
AS
BEGIN
    UPDATE Lop
    SET SiSo = SiSo - 1
    WHERE MaLop IN (SELECT MaLop FROM deleted)
END

-- Trigger for UPDATE
CREATE TRIGGER trg_SinhVien_Update
ON SinhVien
AFTER UPDATE
AS
BEGIN
    IF UPDATE(MaLop)
    BEGIN
        UPDATE Lop
        SET SiSo = SiSo + 1
        WHERE MaLop IN (SELECT MaLop FROM inserted)

        UPDATE Lop
        SET SiSo = SiSo - 1
        WHERE MaLop IN (SELECT MaLop FROM deleted)
    END
END

-----------c2

CREATE TRIGGER trg_CapNhatSiSo
ON SINHVIEN
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Tạo bảng tạm thời
    CREATE TABLE #temp (MaLop varchar(10))

    -- Lấy danh sách các lớp bị ảnh hưởng
    INSERT INTO #temp
    SELECT DISTINCT MaLop FROM inserted
    UNION
    SELECT DISTINCT MaLop FROM deleted

    -- Cập nhật sĩ số cho từng lớp
    UPDATE LOP
    SET SiSo = (
        SELECT COUNT(*) 
        FROM SINHVIEN 
        WHERE SINHVIEN.MaLop = LOP.MaLop
    )
    WHERE MaLop IN (SELECT MaLop FROM #temp);

    -- Xóa bảng tạm thời
    DROP TABLE #temp
END;

------------------c3
CREATE TRIGGER trg_UpdateSISO
ON SinhVien
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Cập nhật sĩ số cho các lớp
    UPDATE Lop
    SET SISO = (
        SELECT COUNT(*) 
        FROM SinhVien 
        WHERE SinhVien.MaLop = Lop.MaLop
    )
    WHERE EXISTS (
        SELECT 1 
        FROM inserted i 
        WHERE i.MaLop = Lop.MaLop
    )
    OR EXISTS (
        SELECT 1 
        FROM deleted d 
        WHERE d.MaLop = Lop.MaLop
    )
END
--9.2. Viết trigger thực hiện tính điểm trung bình DIEMTB trên bảng SINHVIEN mỗi khi
--thêm, xóa hay sửa dữ liệu trên bảng KETQUA
------------c1
-- Trigger for INSERT
CREATE TRIGGER trg_KetQua_Insert
ON KetQua
AFTER INSERT
AS
BEGIN
    UPDATE SinhVien
    SET DiemTB = (SELECT AVG(DiemThi) FROM KetQua WHERE MaSV = inserted.MaSV)
    WHERE MaSV IN (SELECT MaSV FROM inserted)
END

-- Trigger for DELETE
CREATE TRIGGER trg_KetQua_Delete
ON KetQua
AFTER DELETE
AS
BEGIN
    UPDATE SinhVien
    SET DiemTB = (SELECT AVG(DiemThi) FROM KetQua WHERE MaSV = deleted.MaSV)
    WHERE MaSV IN (SELECT MaSV FROM deleted)
END

-- Trigger for UPDATE
CREATE TRIGGER trg_KetQua_Update
ON KetQua
AFTER UPDATE
AS
BEGIN
    IF UPDATE(DiemThi)
    BEGIN
        UPDATE SinhVien
        SET DiemTB = (SELECT AVG(DiemThi) FROM KetQua WHERE MaSV = inserted.MaSV)
        WHERE MaSV IN (SELECT MaSV FROM inserted)
    END
END

------------------c2
CREATE TRIGGER trg_UpdateDIEMTB
ON KetQua
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Cập nhật điểm trung bình (DIEMTB) cho sinh viên
    UPDATE SinhVien
    SET DiemTB = (
        SELECT AVG(DiemThi)
        FROM KetQua
        WHERE KetQua.MaSV = SinhVien.MaSV
    )
    WHERE EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.MaSV = SinhVien.MaSV
    )
    OR EXISTS (
        SELECT 1
        FROM deleted d
        WHERE d.MaSV = SinhVien.MaSV
    )
END
--------------c3
CREATE TRIGGER trg_CapNhatDiemTB
ON KETQUA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @MaSV varchar(10)
    
    -- Lấy danh sách các sinh viên bị ảnh hưởng
    SELECT DISTINCT @MaSV = MaSV FROM inserted
    UNION
    SELECT DISTINCT MaSV FROM deleted
    
    -- Cập nhật điểm trung bình cho từng sinh viên
    UPDATE SINHVIEN
    SET DIEMTB = (
        SELECT AVG(DiemThi) 
        FROM KETQUA 
        WHERE KETQUA.MaSV = SINHVIEN.MaSV
    )
    WHERE MaSV IN (SELECT @MaSV);
END;

--9.3. Dùng cấu trúc trigger viết ràng buộc toàn vẹn thực hiện kiểm tra mỗi sinh viên chỉ
--được đăng ký tối đa 3 môn trong mỗi học kỳ.
---------------c1
CREATE TRIGGER trg_KetQua_Insert_Update
ON KetQua
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM KetQua
        WHERE MaSV IN (SELECT MaSV FROM inserted)
        GROUP BY MaSV, HocKy
        HAVING COUNT(*) > 3
    )
    BEGIN
        RAISERROR ('Mỗi sinh viên chỉ được đăng ký tối đa 3 môn trong mỗi học kỳ.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END
----------------c2
CREATE TRIGGER trg_CheckMaxSubjects
ON KetQua
FOR INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra số lượng môn đăng ký của sinh viên
    IF EXISTS (
        SELECT MaSV
        FROM (
            SELECT MaSV, COUNT(*) AS SoMonDangKy
            FROM KetQua
            WHERE HocKy = (SELECT DISTINCT HocKy FROM inserted)
            GROUP BY MaSV
        ) AS DangKy
        WHERE DangKy.SoMonDangKy > 3
    )
    BEGIN
        RAISERROR (N'Mỗi sinh viên chỉ được đăng ký tối đa 3 môn trong mỗi học kỳ.', 16, 1)
        ROLLBACK
        RETURN
    END
END
-------------------c3
CREATE TRIGGER trg_KiemTraDangKyMon
ON KETQUA
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaSV varchar(10), @HocKy varchar(20)
    
    -- Lấy danh sách các sinh viên bị ảnh hưởng
    SELECT DISTINCT @MaSV = MaSV, @HocKy = HocKy FROM inserted
    
    -- Kiểm tra số lượng môn đăng ký của sinh viên trong học kỳ
    IF (
        SELECT COUNT(*) 
        FROM KETQUA 
        WHERE MaSV = @MaSV AND HocKy = @HocKy
    ) > 3
    BEGIN
        RAISEERROR (N'Sinh viên chỉ được đăng ký tối đa 3 môn trong mỗi học kỳ.', 16, 1)
        ROLLBACK
    END
END;

--9.4. Dùng cấu trúc trigger viết ràng buộc toàn vẹn thực hiện kiểm tra mỗi sinh viên chỉ
--đăng ký tối đa 10 tín chỉ của môn học bắt buộc trong mỗi học kỳ.
---------------c1
CREATE TRIGGER trg_KetQua_Insert_Update_TinChi
ON KetQua
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM KetQua
        INNER JOIN MonHoc ON KetQua.MaMH = MonHoc.MaMH
        WHERE KetQua.MaSV IN (SELECT MaSV FROM inserted) AND MonHoc.BatBuoc = N'Bắt buộc'
        GROUP BY KetQua.MaSV, KetQua.HocKy
        HAVING SUM(MonHoc.SoTC) > 10
    )
    BEGIN
        RAISERROR ('Mỗi sinh viên chỉ được đăng ký tối đa 10 tín chỉ của môn học bắt buộc trong mỗi học kỳ.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END
-------------------c2
CREATE TRIGGER trg_KiemTraDangKyTinChi
ON KETQUA
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaSV varchar(10), @HocKy varchar(20)
    
    -- Lấy danh sách các sinh viên bị ảnh hưởng
    SELECT DISTINCT @MaSV = MaSV, @HocKy = HocKy FROM inserted
    
    -- Kiểm tra tổng số tín chỉ đăng ký của sinh viên trong học kỳ
    IF (
        SELECT SUM(MonHoc.SoTC) 
        FROM KETQUA 
        JOIN MonHoc ON KETQUA.MaMH = MonHoc.MaMH
        WHERE KETQUA.MaSV = @MaSV AND KETQUA.HocKy = @HocKy AND MonHoc.BatBuoc = N'Có'
    ) > 10
    BEGIN
        RAISEERROR (N'Sinh viên chỉ được đăng ký tối đa 10 tín chỉ của môn học bắt buộc trong mỗi học kỳ.', 16, 1)
        ROLLBACK
    END
END;

---------------c3
CREATE TRIGGER trg_CheckMaxCreditHours
ON KetQua
FOR INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra số lượng tín chỉ của môn học bắt buộc của sinh viên
    IF EXISTS (
        SELECT MaSV
        FROM (
            SELECT MaSV, SUM(TinChi) AS TongTinChi
            FROM KetQua
            WHERE HocKy = (SELECT DISTINCT HocKy FROM inserted)
            GROUP BY MaSV
        ) AS DangKy
        WHERE DangKy.TongTinChi > 10
    )
    BEGIN
        RAISERROR (N"Mỗi sinh viên chỉ được đăng ký tối đa 10 tín chỉ của môn học bắt buộc trong mỗi học kỳ.", 16, 1)
        ROLLBACK
        RETURN
    END
END

--9.5. Viết trigger thực hiện điền giá trị vào cột XEPLOAI dựa vào cột DIEMTB với điều
--kiện như sau:
--DIEMTB<5 :yeu
--5<DIEMTB<7 :‘trung binh”
--7<DIEMTB<8: 'kha'
--DIEMTB≥8 :‘Giỏi
----------------c1
CREATE TRIGGER trg_SinhVien_Update_DiemTB
ON SinhVien
AFTER UPDATE
AS
BEGIN
    IF UPDATE(DiemTB)
    BEGIN
        UPDATE SinhVien
        SET XepLoai = CASE
            WHEN DiemTB < 5 THEN N'Yếu'
            WHEN DiemTB >= 5 AND DiemTB < 7 THEN N'Trung bình'
            WHEN DiemTB >= 7 AND DiemTB < 8 THEN N'Khá'
            ELSE N'Giỏi'
        END
        WHERE MaSV IN (SELECT MaSV FROM inserted)
    END
END
----------------c2
CREATE TRIGGER trg_DienXepLoai
ON SINHVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE SINHVIEN
    SET XEPLOAI = 
        CASE 
            WHEN DIEMTB < 5 THEN N'Yếu'
            WHEN DIEMTB >= 5 AND DIEMTB < 7 THEN N'Trung bình'
            WHEN DIEMTB >= 7 AND DIEMTB < 8 THEN N'Khá'
            WHEN DIEMTB >= 8 THEN N'Giỏi'
            ELSE NULL  -- Xử lý trường hợp khác (nếu có)
        END
    FROM inserted
    WHERE SINHVIEN.MaSV = inserted.MaSV;
END;
----------------c3
CREATE TRIGGER trg_FillXepLoai
ON SinhVien
AFTER INSERT, UPDATE
AS
BEGIN
    -- Cập nhật giá trị XEPLOAI dựa vào giá trị DIEMTB
    UPDATE SinhVien
    SET XEPLOAI = CASE
        WHEN DIEMTB < 5 THEN 'Yếu'
        WHEN DIEMTB >= 5 AND DIEMTB < 7 THEN 'Trung bình'
        WHEN DIEMTB >= 7 AND DIEMTB < 8 THEN 'Khá'
        WHEN DIEMTB >= 8 THEN 'Giỏi'
        END
    WHERE MaSV IN (SELECT DISTINCT MaSV FROM inserted)
END
