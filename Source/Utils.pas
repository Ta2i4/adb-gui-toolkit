unit Utils;

interface

uses
  System.SysUtils, System.StrUtils, System.DateUtils, System.Classes,
  Winapi.Windows, Winapi.Messages;

type

  {$IFNDEF UNICODE}RawByteString = AnsiString;{$ENDIF}

  TFNChanged = procedure(Sender: TObject; const OldFN, NewFN: string) of object;

  {$IFDEF MSWINDOWS}
  // AllocWnd types
  TWndProcMethod = function(wnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT of object;
  TWndProc       = function(wnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
  {$ENDIF}

const
  NL = #13#10;

  function IfTh(AValue: Boolean; const ATrue: string; const AFalse: string = ''): string; overload; inline;
  function IfTh(AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0): Integer; overload; inline;
  function IfTh(AValue: Boolean; const ATrue: Cardinal; const AFalse: Cardinal = 0): Integer; overload; inline;
  function IfTh(AValue: Boolean; const ATrue: Pointer; const AFalse: Pointer = nil): Pointer; overload; inline;
  function IfTh(AValue: Boolean; const ATrue: Double; const AFalse: Double = 0): Double; overload; inline;
  {$IFDEF MSWINDOWS}
  // window message
  function AllocateMsgWnd(Handler: TWndProcMethod): HWND; overload;
  function AllocateMsgWnd(Handler: TWndProc): HWND; overload;
  procedure DeallocateMsgWnd(Wnd: HWND); inline;
  {$ENDIF}
  // strings
  function StrIsStartingFrom(const Str, SubStr: string): Boolean; overload;
  function StrSize(const Str: string): Int64; overload; inline;
  function StrSize(const Str: RawByteString): Int64; overload; inline;
  // binary
  procedure ZeroMem(var Dest; count: Integer); inline;
  // classes and stuff
  procedure Error(const msg: string); inline;
  procedure CloseAndZeroHandle(var Handle: THandle); inline;
  function LastErrMsg: string; inline;
  {$IFDEF MSWINDOWS}
  function TickDiff(StartTick, EndTick: Cardinal): Cardinal;
  function TicksSince(Tick: Cardinal): Cardinal; inline;
  {$ENDIF}

implementation

procedure Error(const msg: string);
begin
  raise Exception.Create(msg);
end;

// Вычисляет разницу между значениями, полученными через GetTickCount,
// даже когда разрядная сетка переполняется
function TickDiff(StartTick, EndTick: Cardinal): Cardinal;
begin
  if EndTick >= StartTick
    then Result := EndTick - StartTick
    else Result := High(Cardinal) - StartTick + EndTick;
end;

// сколько прошло тиков с момента Tick до текущего времени
//@
function TicksSince(Tick: Cardinal): Cardinal;
begin
  Result := TickDiff(Tick, GetTickCount);
end;

// ********* AllocWnd *********** \\

// Служит для создания окна, предназначенного для отправки/получения сообщений.
// ! Хэндл окна должен быть закрыт посредством DestroyWindow/DeallocateMsgWnd !
// Метод-обработчик сообщений можно и не указывать, в этом случае сообщения
// будут приходить в message loop потока-владельца

type
  TWndProcType = (wpMethod, wpProc);
  TWndProcInst = record
    case ProcType: TWndProcType of
      wpMethod: (WndProcMethod: TWndProcMethod);
      wpProc  : (WndProc      : TWndProc);
  end;
  PWndProcInst = ^TWndProcInst;

const WndProcProp = 'WndProcProp';

// Новая оконная процедура, извлекающая указатель на метод-обработчик из свойства окна
function DefWndProc(wnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var pInst: PWndProcInst;
begin
  pInst := PWndProcInst(GetProp(wnd, PChar(WndProcProp)));

  // вызываем обработчик: метод класса/сохранённая процедура либо дефолтная функция
  if pInst = nil
    then Result := DefWindowProc(wnd, msg, wParam, lParam)
    else case pInst.ProcType of
           wpMethod: Result := pInst.WndProcMethod(wnd, msg, wParam, lParam);
           wpProc  : Result := pInst.WndProc(wnd, msg, wParam, lParam);
           else      Result := 0; // make compiler happy
         end;

  // если окно уничтожается - удалить свойство и освободить память, выделенную под запись
  if msg = WM_DESTROY then
  begin
    RemoveProp(wnd, PChar(WndProcProp));
    if pInst <> nil then FreeMem(pInst);
  end;

end;

// Создание окна-обработчика сообщений
function InnerAllocateMsgWnd(pInst: PWndProcInst): HWND;
var err: Integer;
begin
  Result := CreateWindowEx(0, 'Button', nil,0,0,0,0,0, HWND_MESSAGE, 0, HInstance, nil);
  if Result = 0 then Exit;
  // сохранить указатель на метод класса - обработчик сообщений
  if (not SetProp(Result, PChar(WndProcProp), THandle(pInst))) or
  // заменить оконную процедуру
     (SetWindowLongPtr(Result, GWL_WNDPROC, LONG_PTR(@DefWndProc)) = 0) then
  begin
    err := GetLastError;
    DestroyWindow(Result);
    Result := 0;
    SetLastError(err);
  end;
end;

function AllocateMsgWnd(Handler: TWndProcMethod): HWND;
var pInst: PWndProcInst;
begin
  if not Assigned(Handler) then
    pInst := nil
  else
  begin
    pInst := AllocMem(SizeOf(TWndProcInst));
    pInst.ProcType := wpMethod;
    pInst.WndProcMethod := Handler;
  end;

  Result := InnerAllocateMsgWnd(pInst);
  if (Result = 0) and (pInst <> nil) then FreeMem(pInst);
end;

function AllocateMsgWnd(Handler: TWndProc): HWND;
var pInst: PWndProcInst;
begin
  if not Assigned(Handler) then
    pInst := nil else
  begin
    pInst := AllocMem(SizeOf(TWndProcInst));
    pInst.ProcType := wpProc;
    pInst.WndProc := Handler;
  end;
  Result := InnerAllocateMsgWnd(pInst);
  if (Result = 0) and (pInst <> nil) then FreeMem(pInst);
end;

// просто обертка для тех, кому привычнее
procedure DeallocateMsgWnd(Wnd: HWND);
begin
  DestroyWindow(Wnd);
end;

// ********* костыли тернарного оператора ********* \\

function IfTh(AValue: Boolean; const ATrue: string; const AFalse: string = ''): string;
begin
  if AValue then Result := ATrue else Result := AFalse;
end;

function IfTh(AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0): Integer;
begin
  if AValue then Result := ATrue else Result := AFalse;
end;

function IfTh(AValue: Boolean; const ATrue: Cardinal; const AFalse: Cardinal = 0): Integer;
begin
  if AValue then Result := ATrue else Result := AFalse;
end;

function IfTh(AValue: Boolean; const ATrue: Pointer; const AFalse: Pointer = nil): Pointer;
begin
  if AValue then Result := ATrue else Result := AFalse;
end;

function IfTh(AValue: Boolean; const ATrue: Double; const AFalse: Double = 0): Double;
begin
  if AValue then Result := ATrue else Result := AFalse;
end;

// Короткая функция для определения размера строки в байтах
function StrSize(const Str: string): Int64;
begin
  Result := Length(Str)*{$IFDEF UNICODE}StringElementSize(Str){$ELSE}SizeOf(Char){$ENDIF};
end;

function StrSize(const Str: RawByteString): Int64;
begin
  Result := Length(Str)*{$IFDEF UNICODE}StringElementSize(Str){$ELSE}SizeOf(AnsiChar){$ENDIF};
end;

// побайтовое сравнение памяти
function StrIsStartingFrom(const Str, SubStr: string): Boolean;
begin
  Result := False;
  if ((Str = '') or (SubStr = '')) or (Length(SubStr) > Length(Str)) then Exit;
  Result := CompareMem(@Str[1], @SubStr[1], StrSize(SubStr));
end;

// Заполнение буфера нулями, отличие от ZeroMemory - inline и другие типы параметров
procedure ZeroMem(var Dest; count: Integer);
begin
  FillChar(Dest, count, 0);
end;

// Закрытие и обнуление хэндла. Не производит проверку на успешность!
procedure CloseAndZeroHandle(var Handle: THandle);
begin
  if Handle > 0 then CloseHandle(Handle);
  Handle := 0;
end;

function LastErrMsg: string;
begin
  Result := SysErrorMessage(GetLastError);
end;

end.
