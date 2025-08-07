{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}
{							}
{ Контролы:                                             } 
{ TListCtrl - виртуальный класс                         }
{ TStringListCtrl - контрол много-колоночного списка    }
{ TDBListCtrl - контрол взаимодействия с TDataSet       }
{							}
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}

unit ListCtrl;

{$mode objfpc}{$H+}

interface

uses 
  Objects, Views, Drivers, Dialogs,
  Db,
  strfunc;

const
  DEFAULT_DELIMETER = '|';

  // Поддерживаемые типы колонок
  STRING_COLUMNTYPE = 'string';
  INTEGER_COLUMNTYPE = 'integer';
  FLOAT_COLUMNTYPE = 'float';
  DATETIME_COLUMNTYPE = 'datetime';
  BOOLEAN_COLUMNTYPE = 'boolean';

  // Поддерживаемое выравнивание
  LEFT_ALIGN = 'left';
  RIGHT_ALIGN = 'right';

type

  { Список строк контрола }
  PListItems = ^TListItems;
  TListItems = object(TStringCollection)
    constructor Init;
  end;


  { Описание колонки ListCtrl }
  TListCtrlColumn = record
    Name: String;		// Латинское наименование колонки 
    Caption: AnsiString;	// Заголовок колонки
    Width: Integer;	// Ширина колонки
    Fmt: String;	// Формат колонки
    ValueType: String;	// Тип колонки
    Align: String;	// Выравнивание
  end;


  { TListCtrl - виртуальный класс }
  PListCtrl = ^TListCtrl;
  TListCtrl = object(TListBox)
  protected
    FDelimeter: Char;
    FItems: PListItems;
    FColumnDefs: Array Of TListCtrlColumn;
    
  public
    constructor Init (Var Bounds: TRect; ANumCols: Sw_Word; AScrollBar: PScrollBar);

    { Добавить колонку }
    procedure AddColumn(AName: String; ACaption: AnsiString; AWidth: Integer; AFmt: String; AValueType: String; AAlign: String);

    { Добавить строку }
    procedure AddRow(ARow: AnsiString);

    { Удалить строку по индексу }
    procedure DelRow(AIndex: Integer);

    { Удалить все строки }
    procedure Clear();

    { Инициализация списка строк }
    procedure ReleaseItems;

    { Разделитель колонок в строке }
    property Delimeter: Char read FDelimeter write FDelimeter;
    { Список строк компонента }
    property Items: PListItems read FItems;
  end;


  { TStringListCtrl - контрол много-колоночного списка }
  PStringListCtrl = ^TStringListCtrl;
  TStringListCtrl = object(TListCtrl)
    // constructor Init;
  end;


  { TDBListCtrl - контрол взаимодействия с TDataSet }
  PDbListCtrl = ^TDbListCtrl;
  TDbListCtrl = object(TStringListCtrl)
  protected
    FDataSet: TDataSet;

    // constructor Init;

    { Инициализация списка строк }
    procedure SetDataSet(ADataSet: TDataSet);

  public
    { Набор записей }
    property DataSet: TDataSet read FDataSet write SetDataSet;

  end;

  
implementation

{ Список строк контрола }
constructor TListItems.Init;
begin
  inherited Init(10, 10);
  //Insert(NewStr('Иван Иванов'));
  //Insert(NewStr('Петр Петров'));
  //Insert(NewStr('Сидр Сидоров'));
end;

{ === TListCtrl - виртуальный класс === }
constructor TListCtrl.Init(Var Bounds: TRect; ANumCols: Sw_Word; AScrollBar: PScrollBar);
begin
inherited Init(Bounds, ANumCols, AScrollBar);

FDelimeter := DEFAULT_DELIMETER;

// FItems
FItems := New(PListItems, Init);
// Self.NewList(FItems); 

end;


{ Добавить колонку }
procedure TListCtrl.AddColumn(AName: String; ACaption: AnsiString; AWidth: Integer; AFmt: String; AValueType: String; AAlign: String);
var
  i: Integer;
begin
  i := Length(FColumnDefs);
  SetLength(FColumnDefs, i + 1);
  FColumnDefs[i].Name := AName;
  FColumnDefs[i].Caption := ACaption;
  FColumnDefs[i].Width := AWidth;
  FColumnDefs[i].Fmt := AFmt;
  FColumnDefs[i].ValueType := AValueType;
  FColumnDefs[i].Align := AAlign;
end;


{ Добавить строку }
procedure TListCtrl.AddRow(ARow: AnsiString);
var
  parse_string: TArrayOfString;
  i_column: Integer;
  row, value: String;
begin
  parse_string := strfunc.SplitStr(ARow, FDelimeter);
  // Форматируем строку
  for i_column := 0 to Length(FColumnDefs) - 1 do
  begin
    value := strfunc.ClipStr(parse_string[i_column], FColumnDefs[i_column].Width);
    if FColumnDefs[i_column].Align = RIGHT_ALIGN then
      parse_string[i_column] := strfunc.RightAlignStr(value)
    else 
      parse_string[i_column] := strfunc.LeftAlignStr(value);
  end;
  row := strfunc.JoinStr(parse_string, FDelimeter);

  FItems^.Insert(NewStr(row));
end;


{ Удалить строку по индексу }
procedure TListCtrl.DelRow(AIndex: Integer);
begin
  FItems^.AtDelete(AIndex);
end;

{ Удалить все строки }
procedure TListCtrl.Clear();
begin
  FItems^.DeleteAll();
end;


{ Инициализация списка строк }
procedure TListCtrl.ReleaseItems;
begin
  Self.NewList(FItems); 
end;


{ === TDbListCtrl === }

{ Инициализация списка строк }
procedure TDbListCtrl.SetDataSet(ADataSet: TDataSet);
var
  i_column: Integer;
  row: AnsiString;
  
begin
  FDataSet := ADataSet;
  Clear();
  if FDataSet <> nil then
  begin
    FDataSet.First;

    while not FDataSet.Eof do 
    begin
      // Формируем строку для добавления
      row := '';
      for i_column := 0 to Length(FColumnDefs) - 1 do
      begin
        row := row + FDataSet.FieldByName(FColumnDefs[i_column].Name).AsString;
        if i_column < (Length(FColumnDefs) - 1) then
          row := row + DEFAULT_DELIMETER;
      end;
      // Добавляем строку
      AddRow(row);

      FDataSet.Next;
    end;
    ReleaseItems;
  end;
end;

end.