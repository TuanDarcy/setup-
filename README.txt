==========================================
  KAITUN TOOL SUITE - Huong dan cai dat
  Build: 2026-07-24
==========================================

Repo GitHub: https://github.com/TuanDarcy/setup-

==========================================
  HUONG DAN TAI & CAI DAT (1 LENH DUY NHAT)
==========================================

Mo CMD (Command Prompt) voi quyen Administrator, sau do copy & paste dong lenh duoi day roi nhan Enter:

  powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest 'https://raw.githubusercontent.com/TuanDarcy/setup-/main/setup.bat' -OutFile '$env:TEMP\kaitun-setup.bat' -UseBasicParsing; Start-Process -FilePath '$env:TEMP\kaitun-setup.bat' -Verb RunAs"

==========================================
  CAC BUOC SETUP SE TU DONG CHAY
==========================================

Sau khi chay lenh tren, script se tu dong thuc hien:

1. KIEM TRA FARMSYNC
   - Neu chua co folder FarmSync tren Desktop => hoi nhap FarmSync Key
   - Tu dong cai dat FarmSync neu co key

2. CAU HINH VOLTX
   - Hoi nhap voltUser va voltPass
   - Tu dong dien thong tin vao file config.json cua VoltX

3. CAI DAT SET RAM (monitor_ram.exe)
   - Tai file SET_RAM.zip tu GitHub ve thu muc Downloads
   - Giai nen vao %USERPROFILE%\Downloads\SET_RAM
   - Tao shortcut monitor_ram.exe ra Desktop
   - Them monitor_ram.exe vao Startup (tu dong chay khi mo may)
   - Mo monitor_ram.exe len chay ngay sau khi cai dat

4. CAI DAT VOLTX
   - Tai VoltX.zip tu GitHub ve thu muc Downloads
   - Giai nen vao %USERPROFILE%\Downloads\VoltX
   - Tu dong dien voltUser/voltPass vao config.json
   - Them volt-headless-p2.exe vao Startup (tu dong chay khi mo may)
   - Mo volt-headless-p2.exe len chay ngay sau khi cai dat

5. TAI VOLT.EXE & 1.1.1.1
   - Tai volt.exe ve Desktop
   - Tai 1.1.1.1 (Cloudflare WARP) ve Desktop

==========================================
  CAU TRUC REPO GITHUB
==========================================

Repo: https://github.com/TuanDarcy/setup-

  setup.bat              <- Script cai dat chinh (1 lenh)
  SET_RAM.zip            <- Bo SET RAM (chua monitor_ram.exe)
  VoltX.zip              <- Bo VoltX (chua volt-headless-p2.exe + config.json)
  volt.exe               <- Volt executable
  Cloudflare_WARP.exe    <- 1.1.1.1 WARP installer

==========================================
  GHI CHU
==========================================

- Phai chay CMD duoi quyen Administrator
- VoltX yeu cau license key (voltXkey) trong config.json
- FarmSync yeu cau key neu cai moi
- Tat ca shortcut deu duoc them vao Startup de tu dong chay khi boot
