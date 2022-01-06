program adbgtk;

uses
  Vcl.Forms,
  gttmain in 'gttmain.pas' {GTTMainWnd},
  ConsoleEmulator in 'ConsoleEmulator.pas',
  Utils in 'Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGTTMainWnd, GTTMainWnd);
  Application.Run;

end.
