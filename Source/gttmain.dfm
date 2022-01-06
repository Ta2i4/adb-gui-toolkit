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
      Caption = #1057#1090#1088#1077#1089#1089'-'#1090#1077#1089#1090' Monkey'
      object grp3: TGroupBox
        Left = 0
        Top = 0
        Width = 300
        Height = 372
        Align = alLeft
        Caption = #1057#1087#1080#1089#1086#1082' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1085#1099#1093' '#1091#1089#1090#1088#1086#1081#1089#1090#1074
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
          Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1091#1089#1090#1088#1086#1081#1089#1090#1074
          TabOrder = 0
        end
      end
      object grp4: TGroupBox
        Left = 310
        Top = 0
        Width = 270
        Height = 110
        Caption = #1056#1077#1078#1080#1084' "'#1057#1083#1091#1095#1072#1081#1085#1099#1077' '#1076#1077#1081#1089#1090#1074#1080#1103'"'
        TabOrder = 1
        object btn2: TButton
          Left = 10
          Top = 20
          Width = 250
          Height = 25
          Action = actStartMonkey
          Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1090#1077#1089#1090
          Enabled = False
          TabOrder = 0
        end
        object btn3: TButton
          Left = 10
          Top = 50
          Width = 250
          Height = 25
          Action = actStopMonkey
          Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1090#1077#1089#1090
          Enabled = False
          TabOrder = 1
        end
        object chk2: TCheckBox
          Left = 10
          Top = 80
          Width = 250
          Height = 17
          Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1074#1080#1076#1077#1086#1079#1072#1087#1080#1089#1100' '#1090#1077#1089#1090#1072
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
        Caption = #1056#1077#1078#1080#1084' "'#1042#1099#1073#1088#1072#1085#1085#1086#1077' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1077'"'
        TabOrder = 2
        object lbl2: TLabel
          Left = 10
          Top = 50
          Width = 130
          Height = 13
          Caption = #1042#1099#1073#1088#1072#1090#1100' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1077' [*]:'
        end
        object lbl3: TLabel
          Left = 10
          Top = 160
          Width = 249
          Height = 36
          Caption = 
            '[*] '#1042' '#1101#1090#1086#1090' '#1089#1087#1080#1089#1086#1082' '#1074#1099#1074#1086#1076#1103#1090#1089#1103' '#1090#1086#1083#1100#1082#1086' '#1090#1077' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103', '#1082#1086#1090#1086#1088#1099#1077' '#1086#1076#1085#1086#1074#1088 +
            #1077#1084#1077#1085#1085#1086' '#1091#1089#1090#1072#1085#1086#1074#1083#1077#1085#1099' '#1085#1072' '#1074#1089#1077#1093' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1085#1099#1093' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072#1093'.'
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
          Caption = #1055#1086#1083#1091#1095#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1081
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
          Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1090#1077#1089#1090
          Enabled = False
          TabOrder = 3
        end
        object btn5: TButton
          Left = 10
          Top = 100
          Width = 250
          Height = 25
          Action = actSMApp
          Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1090#1077#1089#1090
          Enabled = False
          TabOrder = 2
        end
        object chk3: TCheckBox
          Left = 10
          Top = 205
          Width = 250
          Height = 17
          Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1074#1080#1076#1077#1086#1079#1072#1087#1080#1089#1100' '#1090#1077#1089#1090#1072
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          OnClick = chk3Click
        end
      end
    end
    object ts3: TTabSheet
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      ImageIndex = 2
      object grp1: TGroupBox
        Left = 10
        Top = 10
        Width = 330
        Height = 295
        Caption = #1057#1090#1088#1077#1089#1089'-'#1090#1077#1089#1090' Monkey'
        TabOrder = 0
        object lbl1: TLabel
          Left = 10
          Top = 20
          Width = 159
          Height = 13
          Caption = #1050#1086#1083'-'#1074#1086' '#1086#1087#1077#1088#1072#1094#1080#1081' '#1085#1072' '#1080#1090#1077#1088#1072#1094#1080#1102':'
        end
        object lbl4: TLabel
          Left = 10
          Top = 45
          Width = 157
          Height = 13
          Caption = #1044#1083#1080#1085#1072' '#1074#1080#1076#1077#1086#1092#1072#1081#1083#1072' ('#1089#1077#1082#1091#1085#1076#1099'):'
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
          Caption = #1059#1088#1086#1074#1077#1085#1100' '#1083#1086#1075#1080#1088#1086#1074#1072#1085#1080#1103
          ItemIndex = 0
          Items.Strings = (
            #1041#1072#1079#1086#1074#1099#1081
            #1056#1072#1089#1096#1080#1088#1077#1085#1085#1099#1081
            #1044#1077#1090#1072#1083#1080#1079#1080#1088#1086#1074#1072#1085#1085#1099#1081
            #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1099#1081)
          TabOrder = 2
          OnClick = rg1Click
          ExplicitTop = 218
        end
        object rg0: TRadioGroup
          Left = 2
          Top = 68
          Width = 326
          Height = 125
          Align = alBottom
          Caption = #1060#1080#1083#1100#1090#1088' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1081
          ItemIndex = 0
          Items.Strings = (
            #1042#1089#1077' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
            #1058#1086#1083#1100#1082#1086' '#1074#1082#1083#1102#1095#1077#1085#1085#1099#1077
            #1058#1086#1083#1100#1082#1086' '#1089#1080#1089#1090#1077#1084#1085#1099#1077
            #1058#1086#1083#1100#1082#1086' '#1089#1090#1086#1088#1086#1085#1085#1080#1077
            #1058#1086#1083#1100#1082#1086' '#1086#1090#1082#1083#1102#1095#1077#1085#1085#1099#1077)
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
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' ADB'
        TabOrder = 1
        object chk1: TCheckBox
          Left = 16
          Top = 24
          Width = 289
          Height = 17
          Hint = #1055#1088#1080' '#1074#1082#1083#1102#1095#1077#1085#1085#1086#1081' '#1086#1087#1094#1080#1080' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1077' '#1084#1086#1078#1077#1090' '#1079#1072#1087#1091#1089#1082#1072#1090#1100#1089#1103' '#1076#1086#1083#1100#1096#1077'.'
          Caption = #1059#1073#1080#1074#1072#1090#1100' '#1089#1077#1088#1074#1077#1088' '#1087#1088#1080' '#1079#1072#1082#1088#1099#1090#1080#1080' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
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
