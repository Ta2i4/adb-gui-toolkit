unit ConsoleEmulator;

interface

uses
  System.Classes, System.SysUtils, System.StrUtils,
  Winapi.Windows, Winapi.Messages, Winapi.TlHelp32, Vcl.Dialogs,
  Utils;

type
  THandles = (ehStdIn,     // STDIN pipe handle
              ehStdOut,    // STDOUT pipe handle
              ehProcess);  // Process handle for checking state

  TConsEmulState = (cesWaiting, cesRunning, cesFinished, cesTerminated,
    cesTerminatedByTimeout);

  TIODir = (ioInput, ioOutput);

const
  ErrSignName = 'ConEm_Err';  // имя переменной окружения, содержащей сигнатуру ошибки
  ErrSign = '*ERROR*';        // сигнатура ошибки. Если запускаемая программа выводит сообщение
                              //   с этой сигнатурой, это сообщение будет распознано эмулятором
                              //   и занесено в поле ErrorMsg

function ExecuteCons(CmdLine: string; CurrDir: string; EnvVars: string;
  InputStm: TStream; OutputStm: TStream; Timeout: Cardinal; IsTest: Boolean = False): DWORD;

function ExecuteConsNW(CmdLine: string; CurrDir: string; EnvVars: string;
  Timeout: Cardinal; IsTest: Boolean = False): DWORD;

implementation

uses gttmain;

const // localizable
  S_AlreadyLaunched = 'Launch: процесс уже запущен!';
  S_NotLaunched = 'SendCmd: Процесс не запущен!';

// Функция завершает процесс вместе со всеми дочерними
function ConsKillProcessTree(ProcId: DWORD): Integer;
var
  Snapshot: Cardinal;
  PrEntry: PROCESSENTRY32;
  hProc: Cardinal;
begin
  // получаем слепок
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then begin
    Result := GetLastError;
    Exit;
  end;
  // получаем первый процесс
  PrEntry.dwSize := SizeOf(PrEntry);
  if not Process32First(Snapshot, PrEntry) then begin
    Result := GetLastError; CloseHandle(Snapshot);
    Exit;
  end;
  // убиваем все процессы, порождённые текущим
  repeat
    if PrEntry.th32ParentProcessID = ProcId
    then begin
      ConsKillProcessTree(PrEntry.th32ProcessID);
    end;
  until not Process32Next(Snapshot, PrEntry);
  CloseHandle(Snapshot);
  // и завершаем исходный процесс
  hProc := OpenProcess(PROCESS_TERMINATE, False, ProcId);
  if hProc <> 0 then TerminateProcess(hProc, High(DWORD)-1);
  Result := GetLastError;
  CloseHandle(hProc);
end;

function ExecuteCons(CmdLine: string; CurrDir: string; EnvVars: string;
  InputStm: TStream; OutputStm: TStream; Timeout: Cardinal; IsTest: Boolean): DWORD;
const
  BufSize = 16*1024;
  MaxLoopTime = 100; // [ms] максимальное время
var  // общие для всех процедур переменные
  ProcessId: THandle;
  InputBuf, OutputBuf: TBytes;
  Handles: array[THandles] of THandle;
  LastActiveTick: Cardinal;

  procedure Launch(CmdLine: string; CurrDir: string; EnvVars: string);
  var
    si: TStartupInfo;
    pi: TProcessInformation;
    sa: TSecurityAttributes;
    pOldEnv, tmp: PChar;
    OldEnvLen, NewEnvLen, err: Integer;
    hStdOut, hStdIn: THandle;
    mode: DWORD;
    IntCmdLine: string;
  begin
    ZeroMem(si, SizeOf(si));
    ZeroMem(pi, SizeOf(pi));
    try
      // TSecurityAttributes для процесса и труб
      ZeroMem(sa, SizeOf(sa));
      sa.nLength := SizeOf(sa);
      sa.lpSecurityDescriptor := nil;
      sa.bInheritHandle := True;
      // create pipes
      mode := PIPE_READMODE_BYTE or PIPE_NOWAIT;
      // STDOUT
      if not CreatePipe(Handles[ehStdOut], hStdOut, @sa, 1)
      then Error('CreatePipe: '+LastErrMsg);
      // Ensure the read handle to the pipe for STDOUT is not inherited (from MSDN example)
      SetHandleInformation(Handles[ehStdOut], HANDLE_FLAG_INHERIT, 0);
      // Set non-blocking R/W mode for the pipe (!)
      //    SetNamedPipeHandleState(Handles[ehStdOut], mode, nil, nil);
      // STDIN
      if not CreatePipe(hStdIn, Handles[ehStdIn], @sa, 1)
      then Error('CreatePipe: '+LastErrMsg);
      // Ensure the write handle to the pipe for STDIN is not inherited (from MSDN example)
      SetHandleInformation(Handles[ehStdIn], HANDLE_FLAG_INHERIT, 0);
      // Set non-blocking R/W mode for the pipe (!)
      SetNamedPipeHandleState(Handles[ehStdIn], mode, nil, nil);
      // заполняем структуры для создания процесса
      si.cb          := SizeOf(si);
      si.dwFlags     := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      si.wShowWindow := SW_HIDE;
      si.hStdInput   := hStdIn;
      si.hStdOutput  := hStdOut;
      si.hStdError   := hStdOut;
      if CurrDir = '' then CurrDir := GetCurrentDir;
      // Конструируем новое окружение из переданной в параметре строки, сразу добавляя
      // и сигнатуру сообщения об ошибке. Соответственно EnvVars у нас всегда непуст,
      // и проверки if (EnvVars <> '') можно убрать
      EnvVars := ErrSignName + '=' + ErrSign + ';' + EnvVars;
      if EnvVars[Length(EnvVars)] <> ';' then EnvVars := EnvVars + ';';
      EnvVars := StringReplace(EnvVars, ';', #0, [rfReplaceAll]);
      NewEnvLen := Length(EnvVars);
      // Получаем старые переменные окружения, определяем их длину
      // (НЕ включая завершающий второй ноль, чтобы обработать случай пустой строки)
      pOldEnv := GetEnvironmentStrings;
      if pOldEnv <> nil then begin
        tmp := pOldEnv;
        while not ((tmp^ = #0) and (CharNext(tmp)^ = #0))
          do Inc(tmp, StrLen(tmp)+1);
        OldEnvLen := tmp - pOldEnv;
      end else OldEnvLen := 0;
      // Собираем новый список переменных окружения, в конец вручную добавляем второй ноль
      SetLength(EnvVars, NewEnvLen + OldEnvLen + 1);
      Move(pOldEnv^, EnvVars[NewEnvLen + 1], OldEnvLen*SizeOf(Char));
      EnvVars[Length(EnvVars)] := #0;
      FreeEnvironmentStrings(pOldEnv);
      IntCmdLine := CmdLine; // обеспечиваем изменяемость комстроки - особенности CreateProcessW
      UniqueString(IntCmdLine);
      if not CreateProcess(nil, PChar(IntCmdLine), @sa, nil, True,
        CREATE_NEW_CONSOLE{$IFDEF UNICODE}
        or CREATE_UNICODE_ENVIRONMENT{$ENDIF}, PChar(EnvVars), PChar(CurrDir),
        si, pi)
      then begin
        err := GetLastError;
        Error('CreateProcess: ' + SysErrorMessage(err) + ' [' + IntToStr(err) +
          '], "' + IntCmdLine + '"');
      end;
      ProcessId := pi.dwProcessId;
      //showmessage(ProcessId.ToString);
      Handles[ehProcess] := pi.hProcess;
    finally
      // освобождаем хэндлы потока и уже унаследованных концов труб
      CloseAndZeroHandle(hStdIn);
      CloseAndZeroHandle(hStdOut);
      CloseAndZeroHandle(pi.hThread);
    end;
  end;

  procedure TryWrite(InputStm: TStream);
  var
    InputPtr: PByte;
    ToWrite: Integer;
    bytes, StartTick: Cardinal;
    res: Boolean;
  begin
    if Handles[ehStdIn] <> 0 then begin
      // copy input data from stream to buffer
      ToWrite := InputStm.Read(InputBuf[0], Length(InputBuf));
      if ToWrite <= 0 then begin// nothing to write
        CloseAndZeroHandle(Handles[ehStdIn]);
        Exit;
      end;
      InputPtr := @InputBuf[0];
      StartTick := GetTickCount;
      // write data in a loop
      repeat
        res := WriteFile(Handles[ehStdIn], InputPtr^, ToWrite, bytes, nil);
        if not res then
          case GetLastError of
            ERROR_NO_DATA, ERROR_BROKEN_PIPE:
              CloseAndZeroHandle(Handles[ehStdIn]);   // here: pipe closed
            // pipe closed on the other end
            else begin               // other error - report & close
              CloseAndZeroHandle(Handles[ehStdIn]);
              Error('TryWrite: ' + LastErrMsg);
            end;
          end; // case
        if bytes = 0 then Break;
        // if something was read, regardless the error, process it
        LastActiveTick := GetTickCount;
        Inc(InputPtr, bytes);
        Dec(ToWrite, bytes);
        if not res then Break; // if WriteFile failed, break
        // control loop execution time
        if TicksSince(StartTick) > MaxLoopTime then Break;
      until False;
      // ToWrite is amount of data unwritten so rewind the stream (hoping it supports that!)
      if ToWrite > 0 then InputStm.Seek(-ToWrite, soCurrent);
    end; // if
  end;

  procedure TryRead(OutputStm: TStream);
  var
    bytes, StartTick: Cardinal;
    res: Boolean;
  begin
  //WriteLnToFile('console.log', FormatDateTime('hh:mm:ss.zzz', now)+ ' << TryRead');
    // read data from pipe in a loop
    if Handles[ehStdOut] <> 0 then begin
      StartTick := GetTickCount;
      repeat
      // read data, on error close the {}handle and break the loop
        //зависает прога вот здесь
        res := ReadFile(Handles[ehStdOut], OutputBuf[0], Length(OutputBuf), bytes,
          nil);
        //выше нужен отдельный цикл-ожидание
        if not res then
          case GetLastError of
            ERROR_NO_DATA:      // here: pipe is currently empty, that's OK
              ;
            ERROR_BROKEN_PIPE:  // pipe closed on the other end
              CloseAndZeroHandle(Handles[ehStdOut]);
            else                // other error - report & close
            begin
              CloseAndZeroHandle(Handles[ehStdOut]);
              Error('TryRead: '+LastErrMsg);
            end;
          end; // case
        if bytes = 0 then Break;
  //WriteLnToFile('console.log', FormatDateTime('hh:mm:ss.zzz', now)+ ' read '+itos(bytes));
        // if something was read, regardless the error, process it
        LastActiveTick := GetTickCount;
        OutputStm.Write(OutputBuf[0], bytes);
        if not res then Break; // if ReadFile failed, break
        // control loop execution time
        if TicksSince(StartTick) > MaxLoopTime then Break;
      until False;
    end; // if
  //WriteLnToFile('console.log', FormatDateTime('hh:mm:ss.zzz', now)+ ' TryRead >>');
  end;

var
  h: THandles;

begin
  Result := 0;
  Launch(CmdLine, CurrDir, EnvVars);
  LastActiveTick := GetTickCount;
  if InputStm <> nil then SetLength(InputBuf, BufSize);
  SetLength(OutputBuf, BufSize);
  // основной цикл
  Sleep(200);
  repeat
    if InputStm <> nil then TryWrite(InputStm);
    TryRead(OutputStm);
    if (not GetExitCodeProcess(Handles[ehProcess], Result)) or
      (Result <> STILL_ACTIVE)
    then Break else begin
    // если нет - проверяем, не истёк ли таймаут неактивности
      if Timeout <> 0 then begin
        if (GTTMainWnd.FCancelMonkey = True) and (IsTest = True) then begin
          ConsKillProcessTree(ProcessId);
          Break
        end;
        if (TicksSince(LastActiveTick) >= Timeout*MSecsPerSec) then begin
          ConsKillProcessTree(ProcessId);
          Result := 1;
        end;
      end;
    end;
    Sleep(200);
  until False;
  for h := Low(THandles) to High(THandles) do CloseAndZeroHandle(Handles[h]);
end;




function ExecuteConsNW(CmdLine: string; CurrDir: string; EnvVars: string;
  Timeout: Cardinal; IsTest: Boolean): DWORD;
var  // общие для всех процедур переменные
  ProcessId: THandle;
  Handles: array[THandles] of THandle;

  procedure Launch(CmdLine: string; CurrDir: string; EnvVars: string);
  var
    si: TStartupInfo;
    pi: TProcessInformation;
    sa: TSecurityAttributes;
    pOldEnv, tmp: PChar;
    OldEnvLen, NewEnvLen, err: Integer;
    hStdOut, hStdIn: THandle;
    mode: DWORD;
    IntCmdLine: string;
  begin
    ZeroMem(si, SizeOf(si));
    ZeroMem(pi, SizeOf(pi));
    try
      // TSecurityAttributes для процесса и труб
      ZeroMem(sa, SizeOf(sa));
      sa.nLength := SizeOf(sa);
      sa.lpSecurityDescriptor := nil;
      sa.bInheritHandle := True;
      // create pipes
      mode := PIPE_READMODE_BYTE or PIPE_NOWAIT;
      // STDOUT
      if not CreatePipe(Handles[ehStdOut], hStdOut, @sa, 1)
      then Error('CreatePipe: '+LastErrMsg);
      // Ensure the read handle to the pipe for STDOUT is not inherited (from MSDN example)
      SetHandleInformation(Handles[ehStdOut], HANDLE_FLAG_INHERIT, 0);
      // Set non-blocking R/W mode for the pipe (!)
      //    SetNamedPipeHandleState(Handles[ehStdOut], mode, nil, nil);
      // STDIN
      if not CreatePipe(hStdIn, Handles[ehStdIn], @sa, 1)
      then Error('CreatePipe: '+LastErrMsg);
      // Ensure the write handle to the pipe for STDIN is not inherited (from MSDN example)
      SetHandleInformation(Handles[ehStdIn], HANDLE_FLAG_INHERIT, 0);
      // Set non-blocking R/W mode for the pipe (!)
      SetNamedPipeHandleState(Handles[ehStdIn], mode, nil, nil);
      // заполняем структуры для создания процесса
      si.cb          := SizeOf(si);
      si.dwFlags     := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      si.wShowWindow := SW_HIDE;
      si.hStdInput   := hStdIn;
      si.hStdOutput  := hStdOut;
      si.hStdError   := hStdOut;
      if CurrDir = '' then CurrDir := GetCurrentDir;
      // Конструируем новое окружение из переданной в параметре строки, сразу добавляя
      // и сигнатуру сообщения об ошибке. Соответственно EnvVars у нас всегда непуст,
      // и проверки if (EnvVars <> '') можно убрать
      EnvVars := ErrSignName + '=' + ErrSign + ';' + EnvVars;
      if EnvVars[Length(EnvVars)] <> ';' then EnvVars := EnvVars + ';';
      EnvVars := StringReplace(EnvVars, ';', #0, [rfReplaceAll]);
      NewEnvLen := Length(EnvVars);
      // Получаем старые переменные окружения, определяем их длину
      // (НЕ включая завершающий второй ноль, чтобы обработать случай пустой строки)
      pOldEnv := GetEnvironmentStrings;
      if pOldEnv <> nil then begin
        tmp := pOldEnv;
        while not ((tmp^ = #0) and (CharNext(tmp)^ = #0))
          do Inc(tmp, StrLen(tmp)+1);
        OldEnvLen := tmp - pOldEnv;
      end else OldEnvLen := 0;
      // Собираем новый список переменных окружения, в конец вручную добавляем второй ноль
      SetLength(EnvVars, NewEnvLen + OldEnvLen + 1);
      Move(pOldEnv^, EnvVars[NewEnvLen + 1], OldEnvLen*SizeOf(Char));
      EnvVars[Length(EnvVars)] := #0;
      FreeEnvironmentStrings(pOldEnv);
      IntCmdLine := CmdLine; // обеспечиваем изменяемость комстроки - особенности CreateProcessW
      UniqueString(IntCmdLine);
      if not CreateProcess(nil, PChar(IntCmdLine), @sa, nil, True,
        CREATE_NEW_CONSOLE{$IFDEF UNICODE}
        or CREATE_UNICODE_ENVIRONMENT{$ENDIF}, PChar(EnvVars), PChar(CurrDir),
        si, pi)
      then begin
        err := GetLastError;
        Error('CreateProcess: ' + SysErrorMessage(err) + ' [' + IntToStr(err) +
          '], "' + IntCmdLine + '"');
      end;
      ProcessId := pi.dwProcessId;
      Handles[ehProcess] := pi.hProcess;
    finally
      // освобождаем хэндлы потока и уже унаследованных концов труб
      CloseAndZeroHandle(hStdIn);
      CloseAndZeroHandle(hStdOut);
      CloseAndZeroHandle(pi.hThread);
    end;
  end;

var
  h: THandles;

begin
  Result := 0;
  Launch(CmdLine, CurrDir, EnvVars);
  repeat
    if (not GetExitCodeProcess(Handles[ehProcess], Result)) or
      (Result <> STILL_ACTIVE)
    then Break
    else begin
      if Timeout <> 0 then begin
        if (GTTMainWnd.FCancelMonkey = True) and (IsTest = True) then begin
          ConsKillProcessTree(ProcessId);
          Break;
        end;
      end;
    end;
  until False;
  for h := Low(THandles) to High(THandles) do CloseAndZeroHandle(Handles[h]);
end;






end.
