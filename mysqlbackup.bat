:: ============== MySQL backup ==============================
:: V3.2 2014/03/14 - by PM
:: ����¡��� dump ŧ��� ����������� time stamp
:: V3.1 Bata - 2013/11/21 - by PM
:: ��� timestamp folder ��͹�¡ databases
:: ����¹ setfolder �� multiFile
:: V3.0 Bata - 2013/10/29 - by PM
:: ��� ^ ��͹˹�� |  � Loop FOR
:: ����¹ --uroot �� -uroot �͹�������� user
:: ������� dataexcept ������� setfolder=no
:: function :dump ����� backup ������������ (>>) �óշ������ͧ��á���¡ folder
:: V2.9 - 2013/09/18 - PM
:: ���� -B ������͹ V2.4 ����͹ call :dump ᷹
:: ����¹���� pmtemp �� backuplist
:: ���� database ���������� dataexcept
:: V2.8 - 2013/08/21 - PM
:: ��� database �����������
:: V2.7 - 2013/06/28 - PM
:: set path ᷹ mysql ᷹������͹�� command
:: V2.6
:: ����������͡���Ẻ 7 �ѹ��
:: �����ǹ�����������͡
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

:: ���� database ���� backup , ������ҡ���� 1 ��鹴��� ,
::set databak=ipa,kpi,ss
SET databak=
:: ��� database ���������
SET dataexcept=information_schema performance_schema test

:: ���˹觻��·ҧ������
SET pathbak=E:\backup_db

:: ���ҧ folder ������� (yes/no)
SET multiFile=yes

:: ��� Time stamp ŧ ��� .sql (yes/no) ��� ���͡��Ҩ���� �ѹ��� ���� �ѹ��ѻ����
SET timestp=yes
call :settime 
::call :sevenday

:: ���˹���� mysqldump ������ͧ�����觷ӧҹ ****�Ӥѭ****
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