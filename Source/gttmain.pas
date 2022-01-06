unit gttmain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.IniFiles,
  System.Actions, System.Generics.Collections, System.Threading,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Samples.Spin, Vcl.ActnList, Vcl.ExtCtrls,
  ConsoleEmulator;

type

  TGTTMainWnd = class(TForm)
    btn1: TButton;
    lst1: TListBox;
    btn2: TButton;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts3: TTabSheet;
    se1: TSpinEdit;
    grp1: TGroupBox;
    grp2: TGroupBox;
    chk1: TCheckBox;
    lbl1: TLabel;
    acts1: TActionList;
    actRefreshDev: TAction;
    actStartMonkey: TAction;
    actStopMonkey: TAction;
    btn3: TButton;
    grp3: TGroupBox;
    grp4: TGroupBox;
    GroupBox1: TGroupBox;
    btn4: TButton;
    cbb1: TComboBox;
    lbl2: TLabel;
    btn6: TButton;
    btn5: TButton;
    actGetAppList: TAction;
    lbl3: TLabel;
    actSMApp: TAction;
    actSMAppStop: TAction;
    rg1: TRadioGroup;
    rg0: TRadioGroup;
    lbl4: TLabel;
    se2: TSpinEdit;
    chk2: TCheckBox;
    chk3: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure se1Change(Sender: TObject);
    procedure se1Exit(Sender: TObject);
    procedure actRefreshDevExecute(Sender: TObject);
    procedure actStopMonkeyExecute(Sender: TObject);
    procedure actStartMonkeyExecute(Sender: TObject);
    procedure actGetAppListExecute(Sender: TObject);
    procedure cbb1Change(Sender: TObject);
    procedure actSMAppExecute(Sender: TObject);
    procedure actSMAppStopExecute(Sender: TObject);
    procedure rg1Click(Sender: TObject);
    procedure rg0Click(Sender: TObject);
    procedure se2Exit(Sender: TObject);
    procedure se2Change(Sender: TObject);
    procedure chk2Click(Sender: TObject);
    procedure chk3Click(Sender: TObject);
  private
    { Private declarations }
    MyTasks, MyAppTasks: array [0..1] of ITask;
    procedure LoadOptions;
    procedure SaveOptions;
    procedure InitializeDevicesList;
    procedure RefreshDevicesList;
    procedure FreeDevicesList;
    procedure ExecADBCmdWithParams(params: string; nosmsg: Boolean = False);
    procedure StartMonkey;
    procedure StopMonkey;
    procedure StartMonkeyApp;
    procedure StopMonkeyApp;
    procedure GetAppsList;
    procedure WriteMyLogs(const Str, FFlName : string);
  public
    FCancelMonkey: Boolean;
  end;

var
  GTTMainWnd: TGTTMainWnd;
  DevList, AppsList: TStringList;
  opts: record
    path: record   //path variables
      app: string; //application
      adb, adbc: string; //adb console
      cfg: string; //ini file
      logs, logsd: string; //logs
    end;
    monkey: record     //monkey stress test params
      apps: Integer; //apps filter - 0..4 for rg0.items
      events: Integer; //event count in monkey test
      starttime: string; //date/time of starting monkey test
      loglevel: Integer; //log level
      logcmd: string; //commands for change log level
      afcmd: string; //apps filter command
    end;
    scrjob: record
      ent1: Boolean;   //enable for monkey test
      ent2: Boolean;   //enable for monkey app test
      vlen: Integer;   //videofile length in screenrecord command
    end;
    madb: record       //adb params
      kill: Boolean;   //option to kill adb server on application close
    end;
  end;

implementation

{$R *.dfm}

procedure TGTTMainWnd.LoadOptions;
var
  ini: TIniFile;
begin
  opts.path.app :=
    IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  opts.path.cfg := opts.path.app + 'gtconfig.ini';
  opts.path.adbc := opts.path.app + 'platform-tools\adb';
  opts.path.adb := opts.path.adbc + '.exe';
  opts.path.logs := opts.path.app + 'logs';
  opts.path.logsd := opts.path.logs + '\';
  ini := TIniFile.Create(opts.path.cfg);
  try
    opts.monkey.events := ini.ReadInteger('monkeytest', 'eventcount', 1000);
    opts.monkey.loglevel := ini.ReadInteger('monkeytest', 'loglevel', 0);
    case opts.monkey.loglevel of
      1: opts.monkey.logcmd := '-v ';
      2: opts.monkey.logcmd := '-v -v ';
      3: opts.monkey.logcmd := '-v -v -v ';
      else opts.monkey.logcmd := '';
    end;
    opts.monkey.apps := ini.ReadInteger('monkeytest', 'appfilter', 0);
    case opts.monkey.apps of
      1: opts.monkey.afcmd := '-e';
      2: opts.monkey.afcmd := '-s';
      3: opts.monkey.afcmd := '-3';
      4: opts.monkey.afcmd := '-d';
      else opts.monkey.afcmd := '';
    end;
    opts.scrjob.vlen := ini.ReadInteger('screenrecord', 'timelimit', 180);
    opts.scrjob.ent1 := ini.ReadBool('screenrecord', 'enableformtest1', False);
    opts.scrjob.ent2 := ini.ReadBool('screenrecord', 'enableformtest2', False);
    opts.madb.kill := ini.ReadBool('adb', 'killonappclose', False);
  finally
    ini.Free;
  end;
end;

procedure TGTTMainWnd.SaveOptions;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(opts.path.cfg);
  try
    ini.WriteInteger('monkeytest', 'appfilter', opts.monkey.apps);
    ini.WriteInteger('monkeytest', 'eventcount', opts.monkey.events);
    ini.WriteInteger('monkeytest', 'loglevel', opts.monkey.loglevel);
    ini.WriteInteger('screenrecord', 'timelimit', opts.scrjob.vlen);
    ini.WriteBool('screenrecord', 'enableformtest1', opts.scrjob.ent1);
    ini.WriteBool('screenrecord', 'enableformtest2', opts.scrjob.ent2);
    ini.WriteBool('adb', 'killonappclose', opts.madb.kill);
    ini.UpdateFile;
  finally
    ini.Free;
  end;
end;

procedure TGTTMainWnd.InitializeDevicesList;
begin
  DevList := TStringList.Create;
  DevList.LineBreak := #13#10;
  AppsList := TStringList.Create;
  AppsList.LineBreak := #13#10;
end;

procedure TGTTMainWnd.RefreshDevicesList;
var
  I: Integer;
  s: string;
  Stmout: TStringStream;
  Strout: TStringList;
begin
  DevList.Clear;
  Stmout := TStringStream.Create;
  Strout := TStringList.Create;
  Strout.LineBreak := #13#10;
  try
    if FileExists(opts.path.adb)
    then ExecuteCons(opts.path.adbc + ' devices', '', '', nil, Stmout, 5);
    Stmout.Position := 0;
    Strout.Text := Stmout.DataString;
    if (Strout.Count > 0) and (Strout.Strings[0] = 'List of devices attached')
    then begin
      if Strout.Strings[Strout.Count - 1] = ''
      then Strout.Delete(Strout.Count - 1);
      for I := 1 to Strout.Count - 1 do
        if Pos('device', Strout.Strings[I]) > 0 then begin
          s := Strout.Strings[I];
          Delete(s, Pos(#9, s), Length(s) + 1 - Pos(#9, s));
          DevList.Add(s);
          s := '';
        end;
    end else Application.MessageBox('Не удалось запустить интерфейс ADB.',
      'Ошибка', MB_OK + MB_ICONSTOP);
  finally
    lst1.Items.Text := DevList.Text;
    Strout.Free;
    Stmout.Free;
  end;
end;

procedure TGTTMainWnd.FreeDevicesList;
begin
  DevList.Free;
  AppsList.Free;
end;

procedure TGTTMainWnd.GetAppsList;
var
  s: string;
begin
  if not FileExists(opts.path.adb) then Exit;
  AppsList.Clear;
  if DevList.Count > 1 then begin
      TTask.Run(
        procedure
        var
          I, J: Integer;
          Stmout: TStringStream;
          Strout, Strtempout: TStringList;
        begin
          Stmout := TStringStream.Create;
          Strout := TStringList.Create;
          Strout.LineBreak := #13#10;
          Strtempout := TStringList.Create;
          Strtempout.LineBreak := #13#10;
          try
            btn1.Enabled := False;
            btn2.Enabled := False;
            btn4.Enabled := False;
            btn5.Enabled := False;
            cbb1.Clear;
            cbb1.Enabled := False;
            for I := 0 to DevList.Count - 1 do begin
              Stmout.Clear;
              Strout.Clear;
              ExecuteCons(opts.path.adbc + ' -s ' + DevList.Strings[I] +
                ' shell pm list packages ' + opts.monkey.afcmd, '', '', nil,
                Stmout, 5);
              Stmout.Position := 0;
              Strout.Text := Stmout.DataString;
              if Strout.Count > 0 then for J := Strout.Count - 1 downto 0 do
                if Pos('package:', Strout.Strings[J]) = 1 then begin
                  s := Strout.Strings[J];
                  Delete(s, 1, 8);
                  Strout.Strings[J] := s;
                end else Strout.Delete(J);
              if Strout.Count > 0 then
                if Strtempout.Count > 0 then begin
                  for J := Strout.Count - 1 downto 0 do
                    if Strtempout.IndexOf(Strout.Strings[J]) < 0
                    then Strout.Delete(J);
                end;
              Strtempout.Text := Strout.Text;
            end;
            AppsList.Text := Strtempout.Text;
            cbb1.Items.Text := AppsList.Text;
            cbb1.Enabled := (cbb1.Items.Count > 0);
            btn1.Enabled := True;
            btn2.Enabled := True;
            btn4.Enabled := True;
          finally
            Stmout.Free;
            Strout.Free;
            Strtempout.Free;
          end;
        end
      );
  end else
    TTask.Run(
      procedure
      var
        I: Integer;
        Stmout: TStringStream;
      begin
         Stmout := TStringStream.Create;
        try
          btn1.Enabled := False;
          btn2.Enabled := False;
          btn4.Enabled := False;
          btn5.Enabled := False;
          cbb1.Clear;
          cbb1.Enabled := False;
          ExecuteCons(opts.path.adbc + ' -s ' + DevList.Strings[0] +
            ' shell pm list packages ' + opts.monkey.afcmd, '', '', nil, Stmout,
            5);
          Stmout.Position := 0;
          AppsList.Text := Stmout.DataString;
          if AppsList.Count > 0 then for I := AppsList.Count - 1 downto 0 do
            if Pos('package:', AppsList.Strings[I]) = 1 then begin
              s := AppsList.Strings[I];
              Delete(s, 1, 8);
              AppsList.Strings[I] := s;
            end else AppsList.Delete(I);
          cbb1.Items.Text := AppsList.Text;
          cbb1.Enabled := (cbb1.Items.Count > 0);
          btn1.Enabled := True;
          btn2.Enabled := True;
          btn4.Enabled := True;
        finally
          Stmout.Free;
        end;
      end
    );
end;

procedure TGTTMainWnd.ExecADBCmdWithParams(params: string; nosmsg: Boolean =
  False);
var
  Stmout: TStringStream;
begin
  Stmout := TStringStream.Create;
  try
    ExecuteCons(opts.path.adbc + ' ' + params, '', '', nil, Stmout, 5);
  finally
    Stmout.Free;
  end;
end;

procedure TGTTMainWnd.WriteMyLogs(const Str, FFlName : string);
var
  str2: TStringStream;
  dstr, Str1: string;
begin
  DateTimeToString(dstr, '[yyyy/mm/dd hh:nn:ss]', Now);
  Str1 := dstr + #13#10 + Str + #13#10;
  str2 := TStringStream.Create;
  try
    if FileExists(FFlName) then Str2.LoadFromFile(FFlName);
    str2.Position := str2.Size;
    str2.WriteString(str1);
    Str2.SaveToFile(FFlName);
  finally
    Str2.Free;
  end;
end;

procedure TGTTMainWnd.StartMonkey;
begin
  FCancelMonkey := False;
  MyTasks[0] := TTask.Run(
    procedure
    begin
      while not FCancelMonkey do begin
        TParallel.For(0, DevList.Count - 1,
          procedure(exVal: Integer)
          var
            smo: TStringStream;
          begin
            if FileExists(opts.path.adb) then begin
              smo := TStringStream.Create;
              try
                ExecuteCons(opts.path.adbc + ' -s ' + DevList.Strings[exVal] +
                  ' shell monkey ' + opts.monkey.logcmd +
                  IntToStr(opts.monkey.events), '', '', nil, smo, 5, True);
                if not DirectoryExists(opts.path.logs)
                then CreateDir(opts.path.logs);
                WriteMyLogs(smo.DataString, opts.path.logsd +
                  DevList.Strings[exVal] + '_' + opts.monkey.starttime +
                    '.txt');
              finally
                smo.Free;
              end;
            end;
          end);
      end;
    end);
  if opts.scrjob.ent1 = True then MyTasks[1] := TTask.Run(
    procedure
    begin
      while not FCancelMonkey do begin
        TParallel.For(0, DevList.Count - 1,
          procedure(exVal: Integer)
          var
            s: string;
            smo: TStringStream;
          begin
            if FileExists(opts.path.adb) then begin
              smo := TStringStream.Create;
              try
                DateTimeToString(s, 'yyyymmdd_hhnnss', Now);
                s := opts.path.adbc + ' -s ' + DevList.Strings[exVal] +
                  ' shell screenrecord --time-limit 10 /sdcard/Movies/' + s
                  + '.mp4';
                ExecuteConsNW(s, '', '', 5, True);
              finally
                smo.Free;
              end;
            end;
          end);
      end;
    end);
end;

procedure TGTTMainWnd.StartMonkeyApp;
begin
  FCancelMonkey := False;
  MyAppTasks[0] := TTask.Run(
    procedure
    begin
      while not FCancelMonkey do begin
        TParallel.For(0, DevList.Count - 1,
          procedure(exVal: Integer)
          var
            smo: TStringStream;
          begin
            if FileExists(opts.path.adb) then begin
              smo := TStringStream.Create;
              try
              ExecuteCons(opts.path.adbc + ' -s ' + DevList.Strings[exVal] +
                ' shell monkey -p ' + cbb1.Items[cbb1.ItemIndex] + ' ' +
                opts.monkey.logcmd + IntToStr(opts.monkey.events), '', '', nil,
                smo, 5);
              if not DirectoryExists(opts.path.logs)
              then CreateDir(opts.path.logs);
                WriteMyLogs(smo.DataString, opts.path.logsd +
                  DevList.Strings[exVal] + '_' + cbb1.Items[cbb1.ItemIndex] +
                  '_' + opts.monkey.starttime + '.txt');
              finally
                smo.Free;
              end;
            end;
          end);
      end;
    end);
  if opts.scrjob.ent2 = True then MyAppTasks[1] := TTask.Run(
    procedure
    begin
      while not FCancelMonkey do begin
        TParallel.For(0, DevList.Count - 1,
          procedure(exVal: Integer)
          var
            s: string;
            smo: TStringStream;
          begin
            if FileExists(opts.path.adb) then begin
              smo := TStringStream.Create;
              try
                DateTimeToString(s, 'yyyymmdd_hhnnss', Now);
                s := opts.path.adbc + ' -s ' + DevList.Strings[exVal] +
                  ' shell screenrecord --time-limit 180 /sdcard/Movies/' +
                  cbb1.Items[cbb1.ItemIndex] + '_' + s + '.mp4';
                ExecuteConsNW(s, '', '', 5, True);
              finally
                smo.Free;
              end;
            end;
          end);
      end;
    end);
end;

procedure TGTTMainWnd.StopMonkey;
begin
  FCancelMonkey := True;
  if Assigned(MyTasks[0]) then MyTasks[0].Cancel;
  if Assigned(MyTasks[1]) then MyTasks[1].Cancel;
end;

procedure TGTTMainWnd.StopMonkeyApp;
begin
  FCancelMonkey := True;
  if Assigned(MyAppTasks[0]) then MyAppTasks[0].Cancel;
  if Assigned(MyAppTasks[1]) then MyAppTasks[1].Cancel;
end;

procedure TGTTMainWnd.FormCreate(Sender: TObject);
begin
  InitializeDevicesList;
  LoadOptions;
  if FileExists(opts.path.adb) then
    TTask.Run(
      procedure
      begin
        ExecADBCmdWithParams('start-server');
      end
    )
  else begin
    Application.MessageBox('Failed to run ADB interface.' + #13#10#13#10
      + 'Program will be closed.', 'Error', MB_OK + MB_ICONSTOP);
    Application.Terminate;
  end;
end;

procedure TGTTMainWnd.FormDestroy(Sender: TObject);
begin
  FCancelMonkey := True;
  if Assigned(MyTasks[0]) then MyTasks[0].Cancel;
  if Assigned(MyAppTasks[0]) then MyAppTasks[0].Cancel;
  SaveOptions;
  FreeDevicesList;
  if opts.madb.kill and FileExists(opts.path.adb)
  then ExecADBCmdWithParams('kill-server', True);
end;

procedure TGTTMainWnd.FormShow(Sender: TObject);
begin
  se1.Value := opts.monkey.events;
  se2.Value := opts.scrjob.vlen;
  chk1.Checked := opts.madb.kill;
  chk2.Checked := opts.scrjob.ent1;
  chk3.Checked := opts.scrjob.ent2;
  rg0.ItemIndex := opts.monkey.apps;
  rg1.ItemIndex := opts.monkey.loglevel;
end;

procedure TGTTMainWnd.rg0Click(Sender: TObject);
begin
  opts.monkey.apps := rg0.ItemIndex;
    case opts.monkey.apps of
      1: opts.monkey.afcmd := '-e ';
      2: opts.monkey.afcmd := '-s ';
      3: opts.monkey.afcmd := '-3 ';
      4: opts.monkey.afcmd := '-d ';
      else opts.monkey.afcmd := '';
    end;
end;

procedure TGTTMainWnd.rg1Click(Sender: TObject);
begin
  opts.monkey.loglevel := rg1.ItemIndex;
  case opts.monkey.loglevel of
    1: opts.monkey.logcmd := '-v ';
    2: opts.monkey.logcmd := '-v -v ';
    3: opts.monkey.logcmd := '-v -v -v ';
    else opts.monkey.logcmd := '';
  end;
end;

procedure TGTTMainWnd.se1Change(Sender: TObject);
begin
  opts.monkey.events := se1.Value;
end;

procedure TGTTMainWnd.se1Exit(Sender: TObject);
begin
  if se1.Text = '' then se1.Value := opts.monkey.events;
end;

procedure TGTTMainWnd.se2Change(Sender: TObject);
begin
  opts.scrjob.vlen := se2.Value;
end;

procedure TGTTMainWnd.se2Exit(Sender: TObject);
begin
  if se2.Text = '' then se2.Value := opts.scrjob.vlen;
end;

procedure TGTTMainWnd.cbb1Change(Sender: TObject);
begin
  btn5.Enabled := cbb1.ItemIndex > -1;
end;

procedure TGTTMainWnd.chk1Click(Sender: TObject);
begin
  opts.madb.kill := chk1.Checked;
end;

procedure TGTTMainWnd.chk2Click(Sender: TObject);
begin
  opts.scrjob.ent1 := chk2.Checked;
end;

procedure TGTTMainWnd.chk3Click(Sender: TObject);
begin
  opts.scrjob.ent2 := chk3.Checked;
end;

procedure TGTTMainWnd.actGetAppListExecute(Sender: TObject);
begin
  RefreshDevicesList;
  GetAppsList;
end;

procedure TGTTMainWnd.actRefreshDevExecute(Sender: TObject);
begin
  RefreshDevicesList;
  AppsList.Clear;
  cbb1.Clear;
  cbb1.ItemIndex := -1;
  btn2.Enabled := DevList.Count > 0;
  btn4.Enabled := DevList.Count > 0;
  btn5.Enabled := cbb1.ItemIndex > -1;
  cbb1.Enabled := cbb1.Items.Count > 0;
end;

procedure TGTTMainWnd.actSMAppExecute(Sender: TObject);
begin
  DateTimeToString(opts.monkey.starttime, 'yyyymmdd_hhnnss', Now);
  btn1.Enabled := False;
  btn2.Enabled := False;
  btn3.Enabled := False;
  btn4.Enabled := False;
  btn5.Enabled := False;
  btn6.Enabled := True;
  cbb1.Enabled := False;
  chk3.Enabled := False;
  RefreshDevicesList;
  if DevList.Count > 0 then StartMonkeyApp else actSMAppStop.Execute;
end;

procedure TGTTMainWnd.actSMAppStopExecute(Sender: TObject);
begin
  StopMonkeyApp;
  if DevList.Count = 0 then begin
    AppsList.Clear;
    cbb1.Clear;
    cbb1.ItemIndex := -1;
  end;
  btn1.Enabled := True;
  btn2.Enabled := DevList.Count > 0;
  btn3.Enabled := False;
  btn4.Enabled := DevList.Count > 0;
  btn5.Enabled := cbb1.ItemIndex > -1;
  btn6.Enabled := False;
  cbb1.Enabled := cbb1.Items.Count > 0;
  chk3.Enabled := True;
end;

procedure TGTTMainWnd.actStartMonkeyExecute(Sender: TObject);
begin
  DateTimeToString(opts.monkey.starttime, 'yyyymmdd_hhnnss', Now);
  btn1.Enabled := False;
  btn2.Enabled := False;
  btn3.Enabled := True;
  btn4.Enabled := False;
  btn5.Enabled := False;
  btn6.Enabled := False;
  cbb1.Enabled := False;
  chk2.Enabled := False;
  RefreshDevicesList;
  if DevList.Count > 0 then StartMonkey else actStopMonkey.Execute;
end;

procedure TGTTMainWnd.actStopMonkeyExecute(Sender: TObject);
begin
  StopMonkey;
  if DevList.Count = 0 then begin
    AppsList.Clear;
    cbb1.Clear;
    cbb1.ItemIndex := -1;
  end;
  btn1.Enabled := True;
  btn2.Enabled := DevList.Count > 0;
  btn3.Enabled := False;
  btn4.Enabled := DevList.Count > 0;
  btn5.Enabled := cbb1.ItemIndex > -1;
  btn6.Enabled := False;
  cbb1.Enabled := cbb1.Items.Count > 0;
  chk2.Enabled := True;
end;

end.
