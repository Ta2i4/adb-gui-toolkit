object GTTMainWnd: TGTTMainWnd
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'ADB GUI ToolKit'
  ClientHeight = 400
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 0
    Top = 0
    Width = 600
    Height = 400
    ActivePage = ts1
    Align = alClient
    TabOrder = 0
    object ts1: TTabSheet
      Caption = 'Monkey stress test'
      object grp3: TGroupBox
        Left = 0
        Top = 0
        Width = 300
        Height = 372
        Align = alLeft
        Caption = 'List of connected devices'
        TabOrder = 0
        object lst1: TListBox
          Left = 2
          Top = 15
          Width = 296
          Height = 330
          Align = alClient
          ItemHeight = 13
          MultiSelect = True
          TabOrder = 1
        end
        object btn1: TButton
          Left = 2
          Top = 345
          Width = 296
          Height = 25
          Action = actRefreshDev
          Align = alBottom
          Caption = 'Update list of devices'
          TabOrder = 0
        end
      end
      object grp4: TGroupBox
        Left = 310
        Top = 0
        Width = 270
        Height = 110
        Caption = '"Random actions" mode'
        TabOrder = 1
        object btn2: TButton
          Left = 10
          Top = 20
          Width = 250
          Height = 25
          Action = actStartMonkey
          Caption = 'Run the test'
          Enabled = False
          TabOrder = 0
        end
        object btn3: TButton
          Left = 10
          Top = 50
          Width = 250
          Height = 25
          Action = actStopMonkey
          Caption = 'Stop the test'
          Enabled = False
          TabOrder = 1
        end
        object chk2: TCheckBox
          Left = 10
          Top = 80
          Width = 250
          Height = 17
          Caption = 'Enable screen recording'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = chk2Click
        end
      end
      object GroupBox1: TGroupBox
        Left = 310
        Top = 115
        Width = 270
        Height = 240
        Caption = '"Selected app" mode'
        TabOrder = 2
        object lbl2: TLabel
          Left = 10
          Top = 50
          Width = 160
          Height = 13
          Caption = 'Please, select the application [*]:'
        end
        object lbl3: TLabel
          Left = 10
          Top = 160
          Width = 232
          Height = 24
          Caption = 
            '[*] This list displays only those applications that are simultan' +
            'eously installed on all connected devices.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -10
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object btn4: TButton
          Left = 10
          Top = 20
          Width = 250
          Height = 25
          Action = actGetAppList
          Caption = 'Load applications list'
          Enabled = False
          TabOrder = 0
        end
        object cbb1: TComboBox
          Left = 10
          Top = 70
          Width = 250
          Height = 21
          Enabled = False
          TabOrder = 1
          OnChange = cbb1Change
        end
        object btn6: TButton
          Left = 10
          Top = 130
          Width = 250
          Height = 25
          Action = actSMAppStop
          Caption = 'Stop the test'
          Enabled = False
          TabOrder = 3
        end
        object btn5: TButton
          Left = 10
          Top = 100
          Width = 250
          Height = 25
          Action = actSMApp
          Caption = 'Run the test'
          Enabled = False
          TabOrder = 2
        end
        object chk3: TCheckBox
          Left = 10
          Top = 205
          Width = 250
          Height = 17
          Caption = 'Enable screen recording'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          OnClick = chk3Click
        end
      end
    end
    object ts3: TTabSheet
      Caption = 'Settings'
      ImageIndex = 2
      object grp1: TGroupBox
        Left = 10
        Top = 10
        Width = 330
        Height = 295
        Caption = 'Monkey stress test'
        TabOrder = 0
        object lbl1: TLabel
          Left = 10
          Top = 20
          Width = 162
          Height = 13
          Caption = 'Count of operations per iteration:'
        end
        object lbl4: TLabel
          Left = 10
          Top = 45
          Width = 103
          Height = 13
          Caption = 'File length (seconds):'
        end
        object se1: TSpinEdit
          Left = 195
          Top = 20
          Width = 120
          Height = 22
          MaxValue = 10000
          MinValue = 10
          TabOrder = 0
          Value = 1000
          OnChange = se1Change
          OnExit = se1Exit
        end
        object rg1: TRadioGroup
          Left = 2
          Top = 193
          Width = 326
          Height = 100
          Align = alBottom
          Caption = 'Logging level'
          ItemIndex = 0
          Items.Strings = (
            'Default'
            'Advanced'
            'Detailed'
            'Maximal')
          TabOrder = 2
          OnClick = rg1Click
        end
        object rg0: TRadioGroup
          Left = 2
          Top = 68
          Width = 326
          Height = 125
          Align = alBottom
          Caption = 'Apps filter'
          ItemIndex = 0
          Items.Strings = (
            'All apps'
            'Ony enabled apps'
            'Only system apps'
            'Only third-party apps'
            'Only disabled apps')
          TabOrder = 1
          OnClick = rg0Click
        end
        object se2: TSpinEdit
          Left = 195
          Top = 45
          Width = 120
          Height = 22
          MaxValue = 180
          MinValue = 10
          TabOrder = 3
          Value = 180
          OnChange = se2Change
          OnExit = se2Exit
        end
      end
      object grp2: TGroupBox
        Left = 10
        Top = 310
        Width = 330
        Height = 60
        Caption = 'ADB settings'
        TabOrder = 1
        object chk1: TCheckBox
          Left = 16
          Top = 24
          Width = 289
          Height = 17
          Hint = #1055#1088#1080' '#1074#1082#1083#1102#1095#1077#1085#1085#1086#1081' '#1086#1087#1094#1080#1080' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1077' '#1084#1086#1078#1077#1090' '#1079#1072#1087#1091#1089#1082#1072#1090#1100#1089#1103' '#1076#1086#1083#1100#1096#1077'.'
          Caption = 'Kill ADB server when this application closing'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnClick = chk1Click
        end
      end
    end
  end
  object acts1: TActionList
    Left = 256
    Top = 120
    object actRefreshDev: TAction
      Caption = 'Refresh devices list'
      OnExecute = actRefreshDevExecute
    end
    object actStartMonkey: TAction
      Caption = 'actStartMonkey'
      OnExecute = actStartMonkeyExecute
    end
    object actStopMonkey: TAction
      Caption = 'actStopMonkey'
      OnExecute = actStopMonkeyExecute
    end
    object actGetAppList: TAction
      Caption = 'actGetAppList'
      OnExecute = actGetAppListExecute
    end
    object actSMApp: TAction
      Caption = 'actSMApp'
      OnExecute = actSMAppExecute
    end
    object actSMAppStop: TAction
      Caption = 'actSMAppStop'
      OnExecute = actSMAppStopExecute
    end
  end
end
