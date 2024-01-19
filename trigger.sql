create database buoi4
use buoi4

--bai 8
CREATE TABLE KHACHHG(
    MAKH VARCHAR(255),
    TENKH VARCHAR(255),
    DCHI VARCHAR(255),
    DTHOAI VARCHAR(255)
);

CREATE TABLE NHASX(
    MANSX VARCHAR(255),
    TENNSX VARCHAR(255),
    DCHI VARCHAR(255),
    DTHOAI VARCHAR(255)
);

CREATE TABLE NHACC(
    MANCC VARCHAR(255),
    TENNCC VARCHAR(255),
    DCHI VARCHAR(255),
    DTHOAI VARCHAR(255)
);

CREATE TABLE PHIEUNHAP(
    MAPN VARCHAR(255),
    NGAYNHAP DATE,
    MANCC VARCHAR(255),
    TIENNHAP FLOAT
);

CREATE TABLE HANG(
    MAHG VARCHAR(255),
    TENHG VARCHAR(255),
    DVT VARCHAR(255),
    SOLUONG INT,
    MANSX VARCHAR(255),
    TINHTRANG VARCHAR(255)
);

CREATE TABLE CHITIETPN(
    MAPN VARCHAR(255),
    MAHG VARCHAR(255),
    SOLUONG INT,
    GIANHAP FLOAT,
    THANHTIEN FLOAT
);

CREATE TABLE HOADON(
    MAHD VARCHAR(255),
    NGAYBAN DATE,
    TENNV VARCHAR(255),
    MAKH VARCHAR(255),
    TIENBAN FLOAT,
    GIAMGIA FLOAT,
    THANHTOAN FLOAT
);

CREATE TABLE CHITIETHD(
    MAHD VARCHAR(255),
    MAHG VARCHAR(255),
    SOLUONG INT,
    GIABAN FLOAT,
    THANHTIEN FLOAT
);

CREATE TABLE DONGIA(
    MAHG VARCHAR(255),
    NGAYCN DATE,
    GIA FLOAT
);

--a/ Viết trigger thực hiện tự động cập nhật lại THANHTIEN trên bảng CHITIETHD và
--bảng CHITIETPN đồng thời cập nhật TIENNHAP và TIENBAN trên bảng
--PHIEUNHAP và HOADON mỗi khi thêm dữ liệu vào bảng CHITIETPN hay bảng
--CHITIETHD
create trigger update_thanhtien_chhd
after insert on CHITIETPN
for each row 
begin	
	update CHITIETPN set THANHTIEN= new.SOLUONG*new.GIANHAP where MAPN= new.MAPN and MAHG= new.MAHG
	update PHIEUNHAP set TIENNHAP= (select sum(THANHTIEN) from CHITIETPN where MAPN=new.MAPN) and MAPN= new.MAPN
end;

create trigger update_thanhtien_chpn
after insert on CHITIETHD
for each row
begin
	update CHITIETHD set THANHTIEN= new.SOLUONG*new.GIANHAP where MAHD= newMAHD and  MAHG= new.MAHG
	update HOADON set TIENBAN= (select sum(thanhtien)from CHITIETHD where MAHD= new.MAHD) where MAHD= new.MAHD
end;

--b/ Viết trigger thực hiện việc cập nhật TINHTRANG trong bảng HANG thành ‘Da ban’
--mỗi khi bán mặt hàng đó ra (thêm dữ liệu vào bảng CHITIETHD). Nếu SOLUONG
--của mặt hàng đó trên bảng HANG bằng 0 thì TINHTRANG chuyển thành “Het
--hang’. Nếu số lượng bán ra lớn hơn số lượng hiện có (trên bảng HANG) thì xuất ra
--câu thông báo’Khong du hang ban.

create trigger update_tinhtrang
after insert on HANG
for each row
begin 
	declare @soluong int;
	
	select @soluong= SOLUONG from HANG where MAHG= new.MAHG

	if @soluong < new.SOLUONG then 
	update HANG set TINHTRANG= 'Ko du hang ban'
	else 
		update hang set SOLUONG= SOLUONG- new.SOLUONG where MAHG= new.MAHG
		if(select SOLUONG from HANG where MAHG= new.MAHG) =0  then 
		update hang set TINHTRANG= 'Het hang' where MAHG= new.MAHG;
		else update HANG set TINHTRANG= 'Da ban' where MAHG= new.MAHG	;
		end if;
	end if;
	end;
	
--c/ Viết trigger thực hiện việc tăng SOLUONG trên bảng HANG mỗi khi nhập mặt hàng
--đó vào(nhập dữ liệu vào bảng CHITIETPN).

create trigger tang_sl
after insert on HANG
for each row
begin 
	update HANG  set SOLUONG= SOLUONG+ new.SOLUONG where MAHG= new.MAHG
end
--d/ Viết trigger thực hiện việc giảm SOLUONG trên bảng HANG mỗi khi bán mặt hàng
--đó ra(nhập dữ liệu vào bảng CHITIETHD).
create trigger update_sl
after insert on CHITIETHD
for each row
begin
	update HANG  set SOLUONG= SOLUONG- new.SOLUONG where MAHG= new.MAHG
end;
--e/ Viết trigger thực hiện lấy ngày hiện tại cho cột NGAYNHAP mỗi khi thêm dữ liệu
--vào bảng PHIEUNHAP.
create trigger update_ngay
after insert on PHIEUNHAP
for each row
begin
	set new.NGAYNHAP= CURDATE();
end;

--f/ Viết trigger thực hiện lấy ngày hiện tại cho cột NGAYBAN mỗi khi thêm dữ liệu
--vào bảng HOADON.
CREATE CREATE TRIGGER update_GIAMGIA_and_THANHTOAN_after_insert
BEFORE INSERT ON HOADON
FOR EACH ROW
BEGIN
    IF NEW.TIENBAN < 200000 THEN
        SET NEW.GIAMGIA = 0;
    ELSEIF NEW.TIENBAN < 500000 THEN
        SET NEW.GIAMGIA = 5;
    ELSE
        SET NEW.GIAMGIA = 10;
    END IF;
    SET NEW.THANHTOAN = NEW.TIENBAN - NEW.TIENBAN * NEW.GIAMGIA / 100;
END; update_NGAYBAN_after_insert
BEFORE INSERT ON HOADON
FOR EACH ROW
BEGIN
    SET NEW.NGAYBAN = CURDATE();
END;
--g/ Viết trigger thực hiện việc lấy đơn giá mới nhất cho cột GIABAN trên bảng
--CHITIETHD mỗi khi thêm dữ liệu vào bảng này (dựa vào MAHG, NGAYCN và
--GIA trên bảng DONGIA)
CREATE TRIGGER update_GIABAN_after_insert
BEFORE INSERT ON CHITIETHD
FOR EACH ROW
BEGIN
    DECLARE @GIA FLOAT;
    SELECT @GIA = GIA FROM DONGIA WHERE MAHG = NEW.MAHG ORDER BY NGAYCN DESC LIMIT 1;
    SET NEW.GIABAN = @GIA;
END;

--h/ Viết trigger thực hiện điền vào cột giảm giá trên bảng HOADON mỗi khi bán hàng
--là ‘5% nếu 200000 < TIENBAN< 500000. Nếu TIENBAN ≥ 500000 thì điền vào
--‘10%. Nếu TIENBAN <200000 thì điền vào ‘0’. Đồng thời tính tiền cho cột
--THANHTOAN = TIENBAN- TIENBAN* (tỉ lệ giảm giá)
CREATE TRIGGER update_GIAMGIA_and_THANHTOAN_after_insert
BEFORE INSERT ON HOADON
FOR EACH ROW
BEGIN
    IF NEW.TIENBAN < 200000 THEN
        SET NEW.GIAMGIA = 0;
    ELSEIF NEW.TIENBAN < 500000 THEN
        SET NEW.GIAMGIA = 5;
    ELSE
        SET NEW.GIAMGIA = 10;
    END IF;
    SET NEW.THANHTOAN = NEW.TIENBAN - NEW.TIENBAN * NEW.GIAMGIA / 100;
END;

-- bai 10
CREATE TABLE Students (
    SBD VARCHAR(255),
    HOTEN VARCHAR(255),
    KHUVUC INT,
    DIEMTHEM FLOAT
);

INSERT INTO Students (SBD, HOTEN, KHUVUC, DIEMTHEM)
VALUES 
('A1001', 'Tran Thanh Nam', 1, NULL),
('B1002', 'Nguyen Ngoc Phu', 2, NULL),
('C1001','Vo Van Viet',1, NULL),
('A1002','Trinh Dinh Dong',3, NULL)

--Dùng cấu trúc cursor để cập nhật giá trị vào cột DIEMTHEM với điều kiện 

declare @sbd VARCHAR(255), @khuvuc int
declare cursor_capnhat cursor
dynamic for
select SBD,DIEMTHEM from Students

open cursor_capnhat

fetch next from cursor_capnhat into @diemthem, @sbd
while(@@Fetch_status =0)
begin
	if @khuvuc= 1
	update Students set DIEMTHEM= 0 where SBD= @sbd	
	else if @khuvuc= 2
	update Students set DIEMTHEM= 0.5 where SBD= @sbd	
	else if @khuvuc= 3
	update Students set DIEMTHEM= 1 where SBD= @sbd	
	fetch next from cursor_capnhat into @diemthem, @sbd
end	

close cursor_capnhat
deallocate cursor_capnhat

CREATE TABLE Diem (
    MASV VARCHAR(255),
    HOTEN VARCHAR(255),
    DIEM_KT FLOAT,
    DIEM_GK FLOAT,
    DIEM_CK FLOAT,
    DIEM_TK FLOAT
);
--bai 11
INSERT INTO Diem (MASV, HOTEN, DIEM_KT, DIEM_GK, DIEM_CK, DIEM_TK)
VALUES 
('3001090113', 'Lam Bich Van', 8.0, 7.0, 8.0),
('3001090344', 'Nguyen Thanh Nam', 3.0, 5.0, 7.0),
('3001100021','Le Mi Nuong',8,2,9),
('3001100022','Tran Dinh Trong',6,4,5),
('3001100023',' Le Van Khanh',7,3,8),
('3001090345','Chu Bao Chau',6,5,9)

-- Mỗi khi cursor di chuyển đến mẫu tin kế tiếp thì tính điểm tổng kết môn (DIEM_TK)
--của sinh viên tương ứng theo công thức:

declare @masv VARCHAR(255), @diemkt float, @diemgk float, @diemck float
declare cursor_TinhDiem cursor
dynamic for
 select MASV, HOTEN, DIEM_KT,DIEM_GK,DIEM_CK from Diem
 open cursor_TinhDiem

 fetch next from cursor_TinhDiem into @masv, @diemkt, @diemgk,@diemck
 while(@@FETCH_STATUS = 0)
 begin
	declare @diem_tk float 
	set @diem_tk= (@diemkt*0.2+ @diemgk*0.3 + @diemck*0.5) 
	update Diem set DIEM_TK=@diem_tk where MASV= @masv
	
	fetch next from cursor_TinhDiem into  @masv, @diemkt, @diemgk,@diemck
end
close cursor_TinhDiem
deallocate cursor_TinhDiem

