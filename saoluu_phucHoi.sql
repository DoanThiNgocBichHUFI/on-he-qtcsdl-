------chg 3: sao lưu và phục hồi dữ liệu
---bài tập 1
create database db_sv_saoluu
use db_sv_saoluu

create table SinhVien(
	MaSV varchar(10) primary key ,HoTen nvarchar(50), NgSinh date,DChi nvarchar(50), Lop nvarchar(10)
)

insert into SinhVien values ('330011',N'Nguyen Van A','12/05/2003',N'Dia chi 1','03dhth')

-- t1: Full Backup
BACKUP DATABASE SinhVien TO DISK = 'SinhVien_t1.bak' WITH FORMAT

-- t2: Log Backup
BACKUP LOG SinhVien TO DISK = 'SinhVien_t2.trn'

-- t3: Differential Backup
BACKUP DATABASE SinhVien TO DISK = 'SinhVien_t3.bak' WITH DIFFERENTIAL

--bài tập 2
--a.
--Giả sử cơ sở dữ liệu QL_BANHANG được sao lưu theo lịch trình sau:
--Thời điểm sao lưu                               Sự kiện
--t1 (lúc 5pm thứ 7)                                Full Backup
--t2 (lúc 5pm thứ 2)                                   Log Backup
--t3 (lúc 5pm thứ 4)                                 Differential Backup
--t4 (lúc 5pm thứ 6)                                       Log Backup

--Tại mỗi thời điểm ti (i≥1) sinh viên tự thêm một dòng dữ liệu vào bảng HOADON để
--đảm bảo có sự thay đổi dữ liệu trong cơ sở dữ liệu và thực hiện backup bằng lệnh.
--b. Giả sử sự cố xảy ra lúc 8 giờ sáng thứ 7. Viết lệnh phục hồi cơ sở dữ liệu trên.
-----c1
-- t1: Full Backup
BACKUP DATABASE QL_BANHANG TO DISK = 'QL_BANHANG_t1.bak' WITH FORMAT

-- t2: Log Backup
BACKUP LOG QL_BANHANG TO DISK = 'QL_BANHANG_t2.trn'

-- t3: Differential Backup
BACKUP DATABASE QL_BANHANG TO DISK = 'QL_BANHANG_t3.bak' WITH DIFFERENTIAL

-- t4: Log Backup
BACKUP LOG QL_BANHANG TO DISK = 'QL_BANHANG_t4.trn'
-- Phục hồi từ Full Backup (t1)
RESTORE DATABASE QL_BANHANG FROM DISK = 'QL_BANHANG_t1.bak' WITH NORECOVERY

-- Phục hồi từ Differential Backup (t3)
RESTORE DATABASE QL_BANHANG FROM DISK = 'QL_BANHANG_t3.bak' WITH NORECOVERY

-- Phục hồi từ Log Backup cuối cùng (t4)
RESTORE LOG QL_BANHANG FROM DISK = 'QL_BANHANG_t4.trn' WITH RECOVERY

----------c2
-- Thêm dữ liệu vào bảng HOADON tại thời điểm t1
INSERT INTO QL_BANHANG.dbo.HOADON (Column1, Column2, ...) VALUES (Value1, Value2, ...);
-- Thực hiện full backup
BACKUP DATABASE QL_BANHANG TO DISK = 'path_to_backup_folder\FullBackup_t1.bak';

-- Thêm dữ liệu vào bảng HOADON tại thời điểm t2
INSERT INTO QL_BANHANG.dbo.HOADON (Column1, Column2, ...) VALUES (Value1, Value2, ...);
-- Thực hiện log backup
BACKUP LOG QL_BANHANG TO DISK = 'path_to_backup_folder\LogBackup_t2.bak';

-- Thêm dữ liệu vào bảng HOADON tại thời điểm t3
INSERT INTO QL_BANHANG.dbo.HOADON (Column1, Column2, ...) VALUES (Value1, Value2, ...);
-- Thực hiện differential backup
BACKUP DATABASE QL_BANHANG TO DISK = 'path_to_backup_folder\DifferentialBackup_t3.bak';

-- Thêm dữ liệu vào bảng HOADON tại thời điểm t4
INSERT INTO QL_BANHANG.dbo.HOADON (Column1, Column2, ...) VALUES (Value1, Value2, ...);
-- Thực hiện log backup
BACKUP LOG QL_BANHANG TO DISK = 'path_to_backup_folder\LogBackup_t4.bak';

-- Phục hồi từ full backup (lúc t1)
RESTORE DATABASE QL_BANHANG FROM DISK = 'path_to_backup_folder\FullBackup_t1.bak' WITH NORECOVERY;

-- Phục hồi từ differential backup (lúc t3)
RESTORE DATABASE QL_BANHANG FROM DISK = 'path_to_backup_folder\DifferentialBackup_t3.bak' WITH RECOVERY;

-- Phục hồi từ log backup (lúc t4)
RESTORE LOG QL_BANHANG FROM DISK = 'path_to_backup_folder\LogBackup_t4.bak' WITH RECOVERY;
