object Principal: TPrincipal
  Left = 387
  Top = 258
  BorderStyle = bsNone
  Caption = 'Principal'
  ClientHeight = 33
  ClientWidth = 218
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 6
    Top = 10
    Width = 11
    Height = 13
    Caption = 'kill'
    Font.Charset = ANSI_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object pnl1: TPanel
    Left = 26
    Top = 6
    Width = 181
    Height = 21
    Caption = 'pnl1'
    Color = clBtnText
    TabOrder = 1
  end
  object edt1: TEdit
    Left = 28
    Top = 8
    Width = 177
    Height = 17
    AutoSize = False
    BorderStyle = bsNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnKeyDown = edt1KeyDown
  end
end
