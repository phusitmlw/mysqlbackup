:: ============== MySQL backup ==============================
:: V3.2 2014/03/14 - by PM
:: ให้แยกการ dump ลงไฟล์ ถ้าไม่ได้ใส่ time stamp
:: V3.1 Bata - 2013/11/21 - by PM
:: ใส่ timestamp folder ก่อนแยก databases
:: เปลี่ยน setfolder เป็น multiFile
:: V3.0 Bata - 2013/10/29 - by PM
:: ใส่ ^ ก่อนหน้า |  ใน Loop FOR
:: เปลี่ยน --uroot เป็น -uroot ตอนไม่ได้ใส่ user
:: ทำให้ใช้ dataexcept ได้เมื่อ setfolder=no
:: function :dump ทำให้ backup ต่อไฟล์ชื่อเดิม (>>) กรณีที่ไม่ต้องการการแยก folder
:: V2.9 - 2013/09/18 - PM
:: ย้าย -B ที่ใส่ตอน V2.4 ไปใส่ตอน call :dump แทน
:: เปลี่ยนชื่อ pmtemp เป็น backuplist
:: เพิ่ม database ที่ไม่เอาใน dataexcept
:: V2.8 - 2013/08/21 - PM
:: ใส่ database ที่ไม่เอาได้
:: V2.7 - 2013/06/28 - PM
:: set path แทน mysql แทนการใส่ตอนใช้ command
:: V2.6
:: เพิ่มให้เลือกใส่แบบ 7 วันได้
:: เอาส่วนที่ไม่ได้ใช้ออก
:: v2.5
:: include mysqldumppath at command position.
:: error settime.
:: v2.4
:: include -B to mysqldump
:: v2.3
:: leave -x from mysqldump
:: 2012/06/22
:: By phusit@bizpotential.com
:: ======================== Setup ============================
@ECHO OFF
SET host=localhost
SET mysqluser=root
SET mysqlpass=LibF2011
SET mysqlport=3306

:: ชื่อ database ที่จะ backup , ใส่ได้มากกว่า 1 ขั้นด้วย ,
::set databak=ipa,kpi,ss
SET databak=
:: ใส่ database ที่ไม่เอา
SET dataexcept=information_schema performance_schema test

:: ตำแหน่งปลายทางที่จะเก็บ
SET pathbak=E:\backup_db

:: สร้าง folder หรือไม่ (yes/no)
SET multiFile=yes

:: ใส่ Time stamp ลง ไฟล์ .sql (yes/no) และ เลือกว่าจะใส่ วันที่ หรือ วันในสัปดาห์
SET timestp=yes
call :settime 
::call :sevenday

:: ตำแหน่งไฟล์ mysqldump บนเครื่องที่สั่งทำงาน ****สำคัญ****
::set mysqldumppath=C:\wamp\bin\mysql\mysql5.1.32\bin\
SET mysqldumppath=


:: ======================== Process ==========================
SET PATH=%mysqldumppath%;%PATH%
IF NOT "%mysqluser%" == "" ( SET "mysqluser=-u%mysqluser%" ) ELSE ( SET "mysqluser=-uroot" )
IF NOT "%mysqlpass%" == "" ( SET "mysqlpass=-p%mysqlpass%" )
IF NOT "%mysqlport%" == "" ( SET "mysqlport=-P%mysqlport%" ) ELSE ( SET "mysqlport=-P3306" )

SET backuplist=backuplist
IF EXIST %backuplist% ( Del %backuplist% )

::call external script
::CALL deltree %pathbak%\

	IF /i "%multiFile%"=="no" (
		SET "create=%pathbak%\databases" 
		IF "%databak%" == "" ( 
			FOR /f %%a IN ('mysql -h%host% %mysqlport% %mysqluser% %mysqlpass% -e  "show databases" ^| findstr /v  "Database %dataexcept%" ') DO  CALL :dump -B %%a
		) ELSE ( 
			CALL :dump -B %databak:,= %
		)
	)
	
	IF /i "%multiFile%" == "yes" (
		IF "%databak%" == "" ( 
			FOR /f %%a IN ('mysql -h%host% %mysqlport% %mysqluser% %mysqlpass% -e  "show databases" ^| findstr /v  "Database %dataexcept%" ') DO  ECHO %%a >> %backuplist%  
		) ELSE (
			FOR %%a IN (%databak%) DO ECHO.%%a >> %backuplist% 
		)
		
		FOR /f  %%j IN (%backuplist%) DO (
			IF NOT EXIST "%pathbak%\%timestamp%" ( MD "%pathbak%\%timestamp%" )
			SET "create=%pathbak%\%timestamp%\%%j"
			CALL :dump -B %%j
		)
	 )
	::CALL calcSize %pathbak%\
	ECHO Backup Complete!
	ECHO.
	goto :eof

:dump
	SET dbbak=%*
	SET dumpopt=-f -h%host% %mysqlport% %mysqluser% %mysqlpass% %dbbak%
	IF /i "%timestp%" == "no" ( 
		"mysqldump"  %dumpopt% > "%create%.sql"
	) ELSE (
		"mysqldump"  %dumpopt% >> "%create%.sql"
	)
	goto :eof
	
:settime
echo %date%
IF /i "%timestp%" == "no" ( 
	SET timestamp=
) ELSE (
	call :settime2
)
goto :eof

:settime2
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do ( set dt=%%c-%%a-%%b)
SET tm=%time: =0%
SET tm=%tm:~0,5%
SET tm=%tm::=-%
SET timestamp=%dt%_%tm%
::echo time = %timestamp%
goto :eof

:sevenday
	SET  da=%date:~0,3%
	SET  timestamp=%da%
	goto :eof