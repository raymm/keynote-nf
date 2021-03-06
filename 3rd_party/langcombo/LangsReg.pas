{
   TLanguagesCombo
   Author: Alexander Obukhov
   Minsk, Belarus
   E-mail alex@niiomr.belpak.minsk.by
}
{* ----------------------------------- 
  + Changes by Daniel Prado Velasco <dprado.keynote@gmail.com> (Spain) [dpv] [^]

   [^] To use Langs.pas from the package rxctl2006 without having to refer to 
       DesignIDE package I have broken the original file Langs.pas in two, 
	   leaving it exclusively on tasks related to the registration and design.
   
   >> Changes to original source code available in KeyNote NF project.
   >> Fore more information, please see 'README.md' and 'doc/README_SourceCode.txt'
      in https://github.com/dpradov/keynote-nf 
  
 ****************************************************************}

unit LangsReg;

interface
{$I DFS.INC}

uses
  Windows, SysUtils, Graphics, Classes, Langs;

procedure Register;

implementation

uses
{$IFDEF DFS_NO_DSGNINTF}     // [dpv]
    DesignIntf,
    DesignEditors;
{$ELSE}
    DsgnIntf;
{$ENDIF}

type
  TLanguageProperty = class(TIntegerProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TLanguage), nil, '', TLanguageProperty);
end;

function LanguageToIdent(Language: Longint; var Ident: string): Boolean;
var
  Buf: array[0..255]of Char;
begin
  Result:= IsValidLocale(Language, LCID_INSTALLED);
  if Result then
    begin
      GetLocaleInfo(Language, LOCALE_SLANGUAGE, Buf, 255);
      SetString(Ident, Buf, StrLen(Buf));
    end;
end;

var
  SearchId: String;
  SearchLang: Integer;
  LCType: Integer;

function EnumGetLang(LocaleStr: LPSTR): Integer;
stdcall;
var
  Buf: array[0..255]of Char;
  Locale: LCID;
  Z: Integer;
begin
  Val('$'+StrPas(LocaleStr), Locale, Z);
  Result:= 1;
  GetLocaleInfo(Locale, LCType, Buf, 255);
  if AnsiCompareText(SearchId, Buf)=0 then
    begin
      SearchLang:= Locale;
      Result:= 0;
    end;
end;

function IdentToLanguage(const Ident: string; var Language: Longint): Boolean;
begin
  SearchId:= Ident;
  SearchLang:= -1;
  LCType:= LOCALE_SLANGUAGE;
  EnumSystemLocales(@EnumGetLang, LCID_INSTALLED);
  if SearchLang<0 then
    begin
      LCType:= LOCALE_SENGLANGUAGE;
      EnumSystemLocales(@EnumGetLang, LCID_INSTALLED);
    end;
  if SearchLang<0 then
    begin
      LCType:= LOCALE_SABBREVLANGNAME;
      EnumSystemLocales(@EnumGetLang, LCID_INSTALLED);
    end;
  Result:= SearchLang>-1;
  if Result then
    Language:= SearchLang;
end;

function TLanguageProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paSortList, paValueList];
end;

function TLanguageProperty.GetValue: string;
begin
  if not LanguageToIdent(TLanguage(GetOrdValue), Result) then
    FmtStr(Result, '%d', [GetOrdValue]);
end;

var
  GetStrProc: TGetStrProc;

function EnumGetValues(LocaleStr: LPSTR): Integer;
stdcall;
var
  Buf: array[0..255]of Char;
  Locale: LCID;
  Z: Integer;
begin
  Val('$'+StrPas(LocaleStr), Locale, Z);
  GetLocaleInfo(Locale, LOCALE_SLANGUAGE, Buf, 255);
  GetStrProc(Buf);
  Result:= 1;
end;

procedure TLanguageProperty.GetValues(Proc: TGetStrProc);
begin
  GetStrProc:= Proc;
  EnumSystemLocales(@EnumGetValues, LCID_INSTALLED);
end;

procedure TLanguageProperty.SetValue(const Value: string);
var
  NewValue: Longint;
begin
  if IdentToLanguage(Value, NewValue) then
    SetOrdValue(NewValue)
  else inherited SetValue(Value);
end;

end.
