{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}
{							}
{ Пример использования контрола TListCtrl               }
{							}
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}

program samples;
 
uses 
  Objects, Views, Dialogs, App, Drivers,
  Db, csvdataset,
  ListCtrl;

type

  PMainWindow = ^TMainWindow;
  TMainWindow = object(TDialog)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
 
    //procedure DoDelete;
    //procedure DoSearch;
    //procedure DoEdit;
    //procedure DoAdd;
 
  end;

  TMyApp = object(TApplication)
    MainWindow: PMainWindow;
    constructor Init;
  end;


constructor TMainWindow.Init;
{const
  X = 10;
  btnWidth = 12;
  sz = 4;
  btn : array [1 .. sz] of string[btnWidth] =
  ('~2~ Delete ','~3~ Find ','~4~ Edit ','~5~ Add ');
}
var
  R: TRect;
  Control: PView;
  ScrollBarV: PScrollBar;
  CsvDataSet: TCsvDataSet;
 
  //i : Integer;

begin
  R.Assign(0, 0, 140, 24);
  inherited Init(R, 'Пример использования ListCtrl');
  // Options := Options or ofCentered;
  R.Assign(137, 2, 138, 20);
  New(ScrollBarV, Init(R));
  Insert(ScrollBarV);
  R.Assign(2, 2, 137, 20);
  // Control := New(PStringListCtrl, Init(R, 1, ScrollBar));
  Control := New(PDbListCtrl, Init(R, 1, ScrollBarV));

  Insert(Control);

  CSVDataset := TCsvDataSet.Create(nil);
  // CSVDataset.Close;
  //CsvDataSet.LoadFromCSVFile('/home/xhermit/dev/prj/misc/pascal/fvlistctrl/hosts.csv');
  //CsvDataSet.LoadFromCSVFile('/home/xhermit/dev/prj/misc/pascal/fvlistctrl/hosts.csv');
  CsvDataSet.CSVOptions.Delimiter := ';';
  CsvDataSet.CSVOptions.FirstLineAsFieldNames := True;
  CsvDataSet.LoadFromCSVFile('./hosts.csv');

  PDbListCtrl(Control)^.AddColumn('GROUPNAME', 'Группа', 30, 'S', 'string', 'left');
  PDbListCtrl(Control)^.AddColumn('HOSTNAME', 'Наименование', 30, 'S', 'string', 'left');
  PDbListCtrl(Control)^.AddColumn('HOST', 'Хост', 10, 'S', 'string', 'right');
  PDbListCtrl(Control)^.AddColumn('USERNAME', 'Пользователь', 30, 'S', 'string', 'left');

  PDbListCtrl(Control)^.DataSet := CsvDataSet;

  CsvDataSet.Free;

//  PStringListCtrl(Control)^.AddRow('Сидор|Сидоров');
//  PStringListCtrl(Control)^.AddRow('Иван|Иванов');
//  PStringListCtrl(Control)^.AddRow('Петр|Петров');
//  PStringListCtrl(Control)^.ReleaseItems;

  // PListBox(Control)^.NewList(New(PItemsColl, Init)); 
  //R.Assign(X, 20, X + Pred(btnWidth), 22);
  //Insert(New(PButton, Init(R, '~1~ Exit', cmQuit, bfNormal)));
 
  //for i := 1 to 4 do
  //begin
  //  R.Assign(X + i * btnWidth, 20, X + i * btnWidth + Pred(btnWidth), 22);
  //  Insert(New(PButton, Init(R, btn[i], cmDelete + i - 1, bfNormal)));
  //end;
  SelectNext(False);
end;


procedure TMainWindow.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
{
  if Event.what = evCommand then
    case Event.Command of
       cmDelete :
       begin
         DoDelete;
         ClearEvent(Event);
       end;
       cmSearch :
       begin
         DoSearch;
         ClearEvent(Event);
       end;
       cmEdit :
       begin
         DoEdit;
         ClearEvent(Event);
       end;
       cmAdd :
       begin
         DoAdd;
         ClearEvent(Event);
       end;
    end;
}
end;


constructor TMyApp.Init;
begin
  inherited Init;
  MainWindow := New(PMainWindow, Init);
  InsertWindow(MainWindow);
end;

var
  TheApp: TMyApp;
begin
  TheApp.Init;
  TheApp.Run;
  TheApp.Done;
end.