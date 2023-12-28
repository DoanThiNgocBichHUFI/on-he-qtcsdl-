-----bài tập 10
create database db_thisinh
use db_thisinh

create table ThiSinh(
	SBD varchar(10) primary key, HoTen nvarchar(50),KhuVuc int, DiemThem float
)
insert into ThiSinh (SBD,HoTen,KhuVuc,DiemThem) values
		('A1001',N'Tran Thanh Nam',1,null),
		('B1002',N'Nguyen Ngoc Phu',2,null),
		('C1001',N'Vo Van Viet',1,null),
		('A1002',N'Trinh Dinh Dong',3,null)

--Dùng cấu trúc cursor để cập nhật giá trị vào cột DIEMTHEM với điều kiện như sau:
--KHUVUC = 1: DIEMTHEM = 0
--KHUVUC = 2: DIEMTHEM = 0.5
--KHUVUC = 3: DIEMTHEM = 1
DECLARE @SBD VARCHAR(10), @KhuVuc INT
DECLARE cursor_ThiSinh CURSOR FOR 
SELECT SBD, KhuVuc FROM ThiSinh

OPEN cursor_ThiSinh

FETCH NEXT FROM cursor_ThiSinh INTO @SBD, @KhuVuc

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE ThiSinh
	SET DiemThem = CASE 
		WHEN @KhuVuc = 1 THEN 0
		WHEN @KhuVuc = 2 THEN 0.5
		WHEN @KhuVuc = 3 THEN 1
		ELSE DiemThem
	END
	WHERE SBD = @SBD

	FETCH NEXT FROM cursor_ThiSinh INTO @SBD, @KhuVuc
END

CLOSE cursor_ThiSinh
DEALLOCATE cursor_ThiSinh

select *from ThiSinh
