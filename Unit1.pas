unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ImgList, StdCtrls, ComCtrls, XPMan;

type
  TForm1 = class(TForm)
    Image1: TImage;
    ImageListGround: TImageList;
    ImageListObject: TImageList;
    ImageListPlayer: TImageList;
    ImageListEnemy: TImageList;
    Timer1: TTimer;
    Timer2: TTimer;
    ImageListHeightP: TImageList;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    ImageListWater: TImageList;
    Edit1: TEdit;
    Image2: TImage;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    TrackBar1: TTrackBar;
    RadioGroup1: TRadioGroup;
    Label2: TLabel;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    Edit3: TEdit;
    CheckBox2: TCheckBox;
    Button3: TButton;
    ImageListA: TImageList;
    Button4: TButton;
    CheckBox3: TCheckBox;
    ImageListRock: TImageList;
    ImageListWaterBorder: TImageList;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Panel1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CheckBox3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  TPlayer = object
    X, Y : integer;
    TX,TY,
    HP,
    DMG  : integer;
    procedure Calc;
            end;
type
  TCell = record
    GrassID  : integer;
    ObjectID
             : Shortint;
          end;
const
  ssF : array[0..9]  of string = ( 'Ко','Аш','Ке','Ли','Ан','Ди','Сол','Род','Ти','Ан' );
  ssC : array[0..16] of string = ( 'ре','ен','фа','сон','со','мур','то','ку','ки','ре','аб','об','ку','до','по','ра','ша');
  ssE : array[0..15] of string = ( 'ос','тон','руд','рис','си','кон','фат','ман','ан','пан','ис','пон','рон','ишь','кишь','шь');
type
  TActivePoint = object
  X,Y          : integer;
  Name         : String;
                 end;



const
  WorldMapSize = 500;
type
  TMap = array[-WorldMapSize-10..WorldMapSize+100,-WorldMapSize-100..WorldMapSize+10] of TCell;

var
  Form1 : TForm1;
  WorldMap   : TMap;
  ShowingImage, BImage, bufi : TBitmap;
  Player : TPlayer;
  Enemy  : TPlayer;
  MovingUp, MovingDown, MovingLeft, MovingRight : boolean;
  ClearGenGUI,mmMouseDown : boolean;
  MXmm,MYmm,Mx,My :   integer;
  RidgeNo : array [ 1..WorldMapSize*2 ] of array[ 1..25 ] of TPoint;


const
  CountOfSprites = 50;
var
  Grass : array [0..CountOfSprites] of TBitmap;
  Dirt  : array [0..CountOfSprites+50] of TBitmap;
  Water : array [-CountOfSprites..0] of TBitmap;

implementation

uses StrUtils, Math;
{$R *.dfm}

function GenName : string;
var c,e : byte;
    S : string;
begin
  S := ssF[random(length(ssF))];
  C := random(31) div 10 ;
  if c > 0 then
  for E := 1 to C do
  S := S + ssC[Random(length(ssC))]
  else
  S := S + ssE[Random(length(ssE))];
  E := random(20) div 10;
  if E = 1 then S := S + ssE[Random(length(ssE))];
  Result := S;
end;

function DarkerColor(const Color: TColor; Percent: Integer): TColor;
var
  R, G, B: Byte;
begin
  Result := Color;
  if Percent <= 0 then
    Exit;
  if Percent > 100 then
    Percent := 100;
  Result := ColorToRGB(Color);
  R := GetRValue(Result);
  G := GetGValue(Result);
  B := GetBValue(Result);
  R := R - R * Percent div 100;
  G := G - G * Percent div 100;
  B := B - B * Percent div 100;
  Result := RGB(R, G, B);
end;

function LighterColor(const Color: TColor; Percent: Integer): TColor;
var
  R, G, B: Byte;
begin
  Result := Color;
  if Percent <= 0 then
    Exit;
  if Percent > 100 then
    Percent := 100;
  Result := ColorToRGB(Result);
  R := GetRValue(Result);
  G := GetGValue(Result);
  B := GetBValue(Result);
  R := R + (255 - R) * Percent div 100;
  G := G + (255 - G) * Percent div 100;
  B := B + (255 - B) * Percent div 100;
  Result := RGB(R, G, B);
end;

function Min : integer;
var i,j,a : integer;
begin
result := 0;
  for i := 1 to WorldMapSize do
    for j := 1 to WorldMapSize do
      if result > WorldMap[i,j].GrassID then Result := WorldMap[i,j].GrassID;
end;

function Max : integer;
var i,j,a : integer;
begin
result := 0;
  for i := 1 to WorldMapSize do
    for j := 1 to WorldMapSize do
      if result < WorldMap[i,j].GrassID then Result := WorldMap[i,j].GrassID;
end;
function YellowToBrown(Height : integer) : TColor;
var i : integer;
begin
  Result := RGB( height * 5 , 255 - height*3, height );
end;

procedure MakeLightingImages;
var i,x,y,m : integer;
begin
  for i := -CountOfSprites to CountOfSprites do
   begin
    Grass[i] := TBitmap.Create;
    Dirt[i]  := TBitmap.Create;
    Water[i] := TBitmap.Create;
    Grass[i].Height := 20;
    Grass[i].Width  := 20;
    Water[i].Height := 20;
    Water[i].Width  := 20;
    Dirt[i].Height  := 20;
    Dirt[i].Width   := 20;
    Form1.ImageListGround.Draw(grass[i].Canvas,0,0,1);
    Form1.ImageListGround.Draw(Water[i].Canvas,0,0,4);
    Form1.ImageListGround.Draw(Dirt[i].Canvas ,0,0,0);
   end;
   m := 3;
  for i := 1 to CountOfSprites do
    begin
      for x := 0 to 20 do
      for y := 0 to 20 do
        begin
          Water[i].Canvas.Pixels[x,y] := DarkerColor(Water[0].Canvas.Pixels[x,y],i*3);
        end;
    end;
   m := 2;
  for i := -CountOfSprites to 1 do
    begin
      for x := 0 to 20 do
      for y := 0 to 20 do
        begin
          Grass[i].Canvas.Pixels[x,y] := LighterColor(Grass[0].Canvas.Pixels[x,y],abs(i*m));
           Dirt[i].Canvas.Pixels[x,y] := LighterColor( Dirt[0].Canvas.Pixels[x,y],abs(i*m));
        end;
    end;


end;

function MixColors(const Colors: array of TColor): TColor;
var
  R, G, B: Integer;
  i: Integer;
  L: Integer;
begin
  R := 0;
  G := 0;
  B := 0;
  for i := Low(Colors) to High(Colors) do
  begin
    Result := ColorToRGB(Colors[i]);
    R := R + GetRValue(Result);
    G := G + GetGValue(Result);
    B := B + GetBValue(Result);
  end;
  L := Length(Colors);
  Result := RGB(R div L, G div L, B div L);
end;

function GrayColor(Color: TColor): TColor;
var
  Gray: Byte;
begin
  Result := ColorToRGB(Color);
  Gray := (GetRValue(Result) + GetGValue(Result) + GetBValue(Result)) div 3;
  Result := RGB(Gray, Gray, Gray);
end;

procedure AnalogGenerator;
var i,j : integer;
begin
  for i := 1 to WorldMapSize do
  for j := 1 to WorldMapSize do
    WorldMap[i,j].GrassID := Random(6);

end;

procedure GenerateWorld;
var i,j,h       : Longint;
    AverageVal  : Real;
    Md,NV       : Shortint;
begin

 WorldMap[1,1].GrassID := Random(Form1.ImageListGround.Count);  // Starting cell;
 for h := 2 to WorldMapSize do                     // First horizontal string
  begin
    AverageVal := WorldMap[h-1,1].GrassID;
    Md := Random(3);
    case Md of
      0:  NV := Round(AverageVal) - 1;
      1:  NV := Round(AverageVal);
      2:  NV := Round(AverageVal) + 1;
    end;
    if NV < 0 then NV := Form1.ImageListGround.Count - 1;
    if NV > Form1.ImageListGround.Count-1 then NV := 0;
    WorldMap[h,1].GrassID := NV;
  end;

 for h := 2 to WorldMapSize do                     // First vertical string
  begin
    AverageVal := WorldMap[1,h-1].GrassID;
    Md := Random(3);
    case Md of
      0:  NV := Round(AverageVal) - 1;
      1:  NV := Round(AverageVal);
      2:  NV := Round(AverageVal) + 1;
    end;
    if NV < 0 then NV := Form1.ImageListGround.Count - 1;
    if NV > Form1.ImageListGround.Count-1 then NV := 0;
    WorldMap[1,h].GrassID := NV;
  end;
 for i := 2 to WorldMapSize do
 begin
 Form1.ProgressBar1.Position := round((i / WorldMapSize ) * 100);

  for h := 2 to WorldMapSize do
    begin
      AverageVal := (WorldMap[h-1,i].GrassID   +
                     WorldMap[h-1,i-1].GrassID +
                     WorldMap[h,i-1].GrassID)  /3;
      Md := Random(3);
      case Md of
        0:  NV := Round(AverageVal) - 1;
        1:  NV := Round(AverageVal);
        2:  NV := Round(AverageVal) + 1;
      end;
      if NV < 0 then NV := Form1.ImageListGround.Count - 1;
      if NV > Form1.ImageListGround.Count-1 then NV := 0;
      WorldMap[h,i].GrassID := NV;
    end;
  end;  

end;

procedure GenerateWorld2;
  var i,j,h,k,p,X,Y,Height :longint;
  var pointsC, PMPer : longint;
begin
  form1.Timer1.Enabled := false;
  form1.Timer2.Enabled := false;

  RandSeed := strtoint(form1.edit1.text);
  form1.Label1.Caption := 'Seed : ' + inttostr(RandSeed);
  pointsC := (WorldMapSize*WorldMapSize)div (14 * (1+random(13))); // Присваиваем общее кол-во опорных точек

  if Form1.CheckBox1.Checked then
    begin
      PMPer := Form1.TrackBar1.Position * 10;               
    end
  else
  PMPer := 10 * (random(6)+4);            // определяем процент земля/вода

  for h := 1 to pointsC do
    begin
      Form1.ProgressBar1.Position := round((h / pointsC ) * 100);

      X := Random(WorldMapSize);               // Координаты о.т.
      Y := Random(WorldMapSize);

      if Random(100) < PMPer
      then Height := Random(6) + 3                  // определяем какой будет эта точка (+/-)
      else Height :=-Random(8) - 3;

      if Height > 0 then
      for k := 1 to Height do
        begin
          Form1.ProgressBar2.Position := round((k / Height ) * 100);

          for i := X - k - random(3) to X + k + random(3) do
          for j := Y - k - random(3) to Y + k + random(3) do
            begin
              WorldMap[i,j].GrassID := WorldMap[i,j].GrassID + 1;
              Application.ProcessMessages;
            end;
        end
      else
      for k := -1 downto Height do
        begin
          Form1.ProgressBar2.Position := round((k / Height ) * 100);

          for i := X + k - random(3) to X - k + random(3) do
          for j := Y + k - random(3) to Y - k + random(3) do
            begin
              WorldMap[i,j].GrassID := WorldMap[i,j].GrassID - 1;
              Application.ProcessMessages;
            end;
        end;
    end;
  form1.Timer1.Enabled := true;
  form1.Timer2.Enabled := true;
end;

procedure GenerateWorld3;
var h,k,x,y,ActivePointCount,Leng,Angle,AngleArc,MaxM,distance,noval,rad : integer;
procedure MakeProminency(Mo,radi : integer);
var t,i,j : integer;
begin
  if mo >= 0 then
   begin
     for t := Mo downto 0 do
      begin
       for i := -radi + X - t to X + radi + t do
       for j := -radi + Y - t to Y + radi + t do
        begin
          WorldMap[i,j].GrassID := WorldMap[i,j].GrassID + 1;
           if ( i = -radi + X - t )
           or ( i =  X + radi + t )
           or ( j = -radi + Y - t )
           or ( j =  Y + radi + t )
           then
          if random(100) < 30 then
          WorldMap[i,j].GrassID := WorldMap[i,j].GrassID - 1;
        end;
      end;
   end;
end;
procedure MakeProminencyM(Mo,radi : integer);
var t,i,j : integer;
begin
  if mo >= 0 then
   begin
     for t := Mo downto 0 do
      begin
       for i := -radi + X - t to X + radi + t do
       for j := -radi + Y - t to Y + radi + t do
        begin
          WorldMap[i,j].GrassID := WorldMap[i,j].GrassID - 1;
           if ( i = -radi + X - t )
           or ( i =  X + radi + t )
           or ( j = -radi + Y - t )
           or ( j =  Y + radi + t )
           then
          if random(100) < 30 then
          WorldMap[i,j].GrassID := WorldMap[i,j].GrassID + 1;
        end;
      end;
   end;
end;
begin

  Form1.Timer1.Enabled := false;
  Form1.Timer2.Enabled := false;
  ActivePointCount := WorldMapSize;



  for k := 1 to ActivePointCount do
    begin
      X := Random(WorldMapSize-32) + 16;
      Y := Random(WorldMapSize-32) + 16;
          begin
           RidgeNo[k][1].X := X;
           RidgeNo[k][1].Y := Y;
          end;
      AngleArc := 60;              // "Default"
      Leng := 3 + random (11);     // Length of ridge
      MaxM := random(2);           // Type of ridge
      rad  := random(4) + 1;
      case MaxM of
      0:  begin if random(100)<5 then begin MaxM := random(5) + 17; distance := 20; end else begin MaxM := random(5) + 9; distance := 9;end; Leng := 5 + random(7); AngleArc := 45; end; // Mountains
      1:  begin MaxM := random(3);      distance := 5; end; // Hills
      end;
       for h := 1 to Leng do
       begin
          if x > WorldMapSize then x := WorldMapSize ;
          if y > WorldMapSize then y := WorldMapSize ;
        MakeProminency(Random(MaxM),rad);
          Angle := Random(AngleArc) + Angle - AngleArc div 2;
          if Angle >= 360 then Angle := Angle - 360;
          X := X + Round( ( random( 3 ) + distance ) * Cos (Angle * Pi / 180));
          Y := Y + Round( ( random( 3 ) + distance ) * Sin (Angle * Pi / 180));
          if h < Leng then          
          begin
           RidgeNo[k][h+1].X := X;
           RidgeNo[k][h+1].Y := Y;
          end;
        Form1.ProgressBar2.Position := Round ( h / Leng * 100 );
       end;
      for h := Leng to 25 do
          begin
           RidgeNo[k][h+1].X := X;
           RidgeNo[k][h+1].Y := Y;
          end;
      Form1.ProgressBar1.Position := Round ( k / ActivePointCount * 100 );
    end;

  ActivePointCount := WorldMapSize*3 div 5;
  // Starting new cycle for water gen
  for k := 1 to ActivePointCount do
    begin
      X := Random(WorldMapSize-32) + 16;
      Y := Random(WorldMapSize-32) + 16;
      AngleArc := 60;              // "Default"
      Leng := 3 + random (11);     // Length of ridge
      MaxM := random(2);           // Type of ridge
      rad  := random(4) + 1;
      case MaxM of
      0:  begin MaxM := random(5) + 6; distance := 9; Leng := 5 + random(7); AngleArc := 45; end; // Mountains
      1:  begin MaxM := random(3);      distance := 5; end; // Hills
      end;
      for h := 1 to Leng do
       begin
          if x > WorldMapSize then x := WorldMapSize ;
          if y > WorldMapSize then y := WorldMapSize ;
          MakeProminencyM(Random(MaxM),rad);
          Angle := Random(AngleArc) + Angle - AngleArc div 2;
          if Angle >= 360 then Angle := Angle - 360;
          X := X + Round( ( random( 3 ) + distance ) * Cos (Angle * Pi / 180));
          Y := Y + Round( ( random( 3 ) + distance ) * Sin (Angle * Pi / 180));
          Form1.ProgressBar2.Position := Round ( h / Leng * 100 );
       end;
       Form1.ProgressBar1.Position := Round ( k / ActivePointCount * 100 );
    end;

 end;


procedure GenerateWorld4;
  var
    h, k, x, y, ActivePointCount,
    Leng, Angle, AngleArc, MaxM,
    distance, noval, rad, AngleArcMod : integer;
procedure MakeProminency(Mo,radi : integer);
var t,i,j : integer;
begin
  if mo >= 0 then
   begin
     for t := Mo downto 0 do
      begin
       for i := -radi + X - t to X + radi + t do
       for j := -radi + Y - t to Y + radi + t do
        begin
          WorldMap[i,j].GrassID := WorldMap[i,j].GrassID + 1;
           if ( i = -radi + X - t )
           or ( i =  X + radi + t )
           or ( j = -radi + Y - t )
           or ( j =  Y + radi + t )
           then
          if random(100) < 30 then
          WorldMap[i,j].GrassID := WorldMap[i,j].GrassID - 1;
        end;
      end;
   end;
end;

procedure MakeProminencyM(Mo,radi : integer);
var t,i,j : integer;
begin
  if mo >= 0 then
   begin
     for t := Mo downto 0 do
      begin
       for i := -radi + X - t to X + radi + t do
       for j := -radi + Y - t to Y + radi + t do
        begin
          WorldMap[i,j].GrassID := WorldMap[i,j].GrassID - 1;
           if ( i = -radi + X - t )
           or ( i =  X + radi + t )
           or ( j = -radi + Y - t )
           or ( j =  Y + radi + t )
           then
          if random(100) < 30 then
          WorldMap[i,j].GrassID := WorldMap[i,j].GrassID + 1;
        end;
      end;
   end;
end;

begin
  Form1.Timer1.Enabled := false;
  Form1.Timer2.Enabled := false;

  ActivePointCount := WorldMapSize;

  for k := 1 to ActivePointCount do
    begin
      X := Random(WorldMapSize-32) + 16;
      Y := Random(WorldMapSize-32) + 16;
      RidgeNo[k][1].X := X;
      RidgeNo[k][1].Y := Y;

      AngleArc := 60;              // "Default"
      Leng := 3 + random (11);     // Length of ridge
      MaxM := random(2);           // Type of ridge
      rad  := random(4) + 1;
      AngleArcMod := AngleArc div 2;
      case MaxM of
      0:  begin if random(100)<5 then begin MaxM := random(5) + 5; distance := 20; end else begin MaxM := random(5) + 5; distance := 9;end; Leng := 5 + random(3); AngleArc := 45;AngleArcMod := 0; end; // Mountains
      1:  begin MaxM := random(3);      distance := 5; end; // Hills
      end;
       for h := 1 to Leng do
       begin
          if x > WorldMapSize then x := WorldMapSize ;
          if y > WorldMapSize then y := WorldMapSize ;
          MakeProminency(Random(MaxM),rad);
          Angle := Random(AngleArc) + Angle - AngleArcMod;
          if Angle >= 360 then Angle := Angle - 360;
          X := X + Round( ( random( 3 ) + distance ) * Cos (Angle * Pi / 180));
          Y := Y + Round( ( random( 3 ) + distance ) * Sin (Angle * Pi / 180));
          if h < Leng then begin
            RidgeNo[k][h+1].X := X;
            RidgeNo[k][h+1].Y := Y;
          end;
        Form1.ProgressBar2.Position := Round ( h / Leng * 100 );
       end;
      for h := Leng to 25 do
          begin
           RidgeNo[k][h+1].X := X;
           RidgeNo[k][h+1].Y := Y;
          end;

      Form1.ProgressBar1.Position := Round ( k / ActivePointCount * 100 );
    end;


  ActivePointCount := WorldMapSize*1 div 10;
  // Starting new cycle for water gen
  for k := 1 to ActivePointCount do
    begin
      X := Random(WorldMapSize-32) + 16;
      Y := Random(WorldMapSize-32) + 16;
      AngleArc := 60;              // "Default"
      Leng := 3 + random (11);     // Length of ridge
      MaxM := random(2);           // Type of ridge
      rad  := random(4) + 1;

      case MaxM of
      0:  begin MaxM := random(4) + 3; distance := 9; Leng := 15 + random(6); AngleArc := 20;AngleArcMod := 10; end; // Dip 
      1:  begin MaxM := random(3);     distance := 4; end; // little dip
      end;

      for h := 1 to Leng do
       begin
          if x > WorldMapSize then x := WorldMapSize ;
          if y > WorldMapSize then y := WorldMapSize ;
          MakeProminencyM(Random(MaxM),rad);
          Angle := Random(AngleArc) + Angle - AngleArcMod;
          if Angle >= 360 then Angle := Angle - 360;
          X := X + Round( ( random( 3 ) + distance ) * Cos (Angle * Pi / 180));
          Y := Y + Round( ( random( 3 ) + distance ) * Sin (Angle * Pi / 180));
          Form1.ProgressBar2.Position := Round ( h / Leng * 100 );
       end;
       Form1.ProgressBar1.Position := Round ( k / ActivePointCount * 100 );
    end;

 end;



procedure TPlayer.Calc;
begin
  if ( tx <> x ) or ( ty <> y ) then // Moving calculations
   begin
     if tx > x then x := x + 1;
     if tx < x then x := x - 1;
     if ty > y then y := y + 1;
     if ty < y then y := y - 1;  
   end;
end;

procedure SwitchImage;
begin
  ShowingImage := BImage;         // Впихиваем в рисующую процедуру картинку, которую нарисовали
end;

procedure ShowImage;
begin
  Form1.Image1.Canvas.Draw(0,0,ShowingImage);  // Рисуем картинку
end;

procedure ClearImage;
begin
  BImage.Canvas.FillRect(rect(0,0,640,480));   // Чистим какбы картинку
end;

procedure DrawMap;
var i,j : integer;
begin
  if Form1.RadioGroup1.ItemIndex < 2 then
   for i := 1 to 32 do
   for j := 1 to 24 do
    Form1.ImageListGround.Draw(BImage.Canvas, (i-1)*20, (j-1)*20, WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID)
  else
  for i := 1 to 32 do
  for j := 1 to 24 do
   begin
   if WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID > Form1.ImageListHeightP.Count-1 then
    Form1.ImageListHeightP.Draw(BImage.Canvas,(i-1)*20,(j-1)*20,Form1.ImageListHeightP.Count-1,true)
   else
   if WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID < 0 then
    Form1.ImageListWater.Draw(BImage.Canvas,(i-1)*20,(j-1)*20,abs(WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID)-1,true)
   else
    Form1.ImageListHeightP.Draw(BImage.Canvas,(i-1)*20,(j-1)*20,WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID,true);
   if WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID < -Form1.ImageListWater.Count+1 then
    Form1.ImageListWater.Draw(BImage.Canvas,(i-1)*20,(j-1)*20,Form1.ImageListWater.Count-1,true)
    end;
end;

procedure DrawMap2;
var i,j,x,y : integer;

procedure onBorder;
var u : integer;
type tchck = array [1..4] of byte;
var a : tchck;
const a0 : tchck = (1,0,0,0);
      a1 : tchck = (0,1,0,0);
      a2 : tchck = (0,0,1,0);
      a3 : tchck = (0,0,0,1);
      a4 : tchck = (1,1,0,0);
      a5 : tchck = (0,1,1,0);
      a6 : tchck = (0,0,1,1);
      a7 : tchck = (1,0,0,1);
      a8 : tchck = (1,1,1,0);
      a9 : tchck = (0,1,1,1);
      a10: tchck = (1,0,1,1);
      a11: tchck = (1,1,0,1);
      a12: tchck = (1,0,1,0);
      a13: tchck = (0,1,0,1);
      a14: tchck = (1,1,1,1);

function eq(q : tchck) : boolean;
begin
  Result := False;
  if a[1] = q[1] then
  if a[2] = q[2] then
  if a[3] = q[3] then
  if a[4] = q[4] then
  Result := True;
end;

begin

  if WorldMap[Player.X - 17 + i-1,Player.Y - 13 + j].GrassID >= 0 then
    a[4] := 1 Else a[4] := 0;
  if WorldMap[Player.X - 17 + i+1,Player.Y - 13 + j].GrassID >= 0 then
    a[2] := 1 Else a[2] := 0;
  if WorldMap[Player.X - 17 + i,Player.Y - 13 + j-1].GrassID >= 0 then
    a[1] := 1 Else a[1] := 0;
  if WorldMap[Player.X - 17 + i,Player.Y - 13 + j+1].GrassID >= 0 then
    a[3] := 1 Else a[3] := 0;

  if eq( a0)  then u := 0;
  if eq( a1)  then u := 1;
  if eq( a2)  then u := 2;
  if eq( a3)  then u := 3;
  if eq( a4)  then u := 4;
  if eq( a5)  then u := 5;
  if eq( a6)  then u := 6;
  if eq( a7)  then u := 7;
  if eq( a8)  then u := 8;
  if eq( a9)  then u := 9;
  if eq( a10) then u := 10;
  if eq( a11) then u := 11;
  if eq( a12) then u := 12;
  if eq( a13) then u := 13;
  if eq( a14) then u := 14;

  Form1.ImageListWaterBorder.Draw(BImage.Canvas,(i-1)*20,(j-1)*20,u);

end;

begin
  for i := 1 to 32 do
  for j := 1 to 24 do
    begin
      // Let's draw by Height!

      case WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID of
       0..18         : BImage.Canvas.Draw((i-1)*20,(j-1)*20,Grass[-WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID]);
       -1000..-1     :
       begin
         BImage.Canvas.Draw((i-1)*20,(j-1)*20,Water[-WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID]);
         onBorder;
       end;  
       19..1000      :
          begin
            BImage.Canvas.Draw((i-1)*20,(j-1)*20, Dirt[-WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID]);
            if WorldMap[Player.X - 17 + i,Player.Y - 13 + j].GrassID >= CountOfSprites then
              Form1.ImageListRock.Draw(BImage.Canvas,(i-1)*20,(j-1)*20,1);
          end;
      end
    end;
  if (Player.X <> player.TX) or (Player.Y <> player.TY)
  then
  Form1.ImageListA.Draw(BImage.Canvas, (16 - Player.X + PLayer.TX ) * 20,  (12 - Player.Y + PLayer.TY ) * 20 , 0 );
end;

procedure Fog;
var x,y :integer;
begin
      for x := 0 to 213 do
      begin
      for y := 0 to 160 do
       begin
        BImage.Canvas.Pixels[x*3  , y*3]  :=
         DarkerColor( BImage.Canvas.Pixels[x*3,y*3] ,
      Round( sqrt ( sqr ( x*3 - 320 ) + sqr ( y*3 - 240 ) ) ) div 3 );
        BImage.Canvas.Pixels[x*3+1,y*3+1] := BImage.Canvas.Pixels[x*3,y*3];
        BImage.Canvas.Pixels[x*3  ,y*3+1] := BImage.Canvas.Pixels[x*3,y*3];
        BImage.Canvas.Pixels[x*3+1,y*3  ] := BImage.Canvas.Pixels[x*3,y*3];
        BImage.Canvas.Pixels[x*3+2,y*3+2] := BImage.Canvas.Pixels[x*3,y*3];
        BImage.Canvas.Pixels[x*3  ,y*3+2] := BImage.Canvas.Pixels[x*3,y*3];
        BImage.Canvas.Pixels[x*3+2,y*3  ] := BImage.Canvas.Pixels[x*3,y*3];
        BImage.Canvas.Pixels[x*3+2,y*3+1] := BImage.Canvas.Pixels[x*3,y*3];
        BImage.Canvas.Pixels[x*3+1,y*3+2] := BImage.Canvas.Pixels[x*3,y*3];
       end;
      Form1.Caption := inttostr ( Round ( x / 213 * 100 ) );
      end;
end;      


procedure DrawImage;
Begin
  ClearImage;
  DrawMap2;
  if WorldMap[Player.X,Player.Y].GrassID < 0 then
  begin
  if WorldMap[Player.X,Player.Y].GrassID < -30 then
  Form1.ImageListPlayer.Draw(BImage.Canvas,16*20,12*20,10)else
  if WorldMap[Player.X,Player.Y].GrassID < -18 then
  Form1.ImageListPlayer.Draw(BImage.Canvas,16*20,12*20,9) else
  Form1.ImageListPlayer.Draw(BImage.Canvas,16*20,12*20,abs(WorldMap[Player.X,Player.Y].GrassID div 2 + 1 ));

  end
  else
  Form1.ImageListPlayer.Draw(BImage.Canvas,16*20,12*20,0);
  SwitchImage;
  //Form1.Timer1.Enabled := false;
End;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
//  Image2.Width := Form1.Width - 620;
//  Image2.Height := Form1.Height-30;
Player.Calc;


 if mmMouseDown then
  begin
    Player.X := MXmm;
    player.Y := MYmm;
    Player.tX := Player.X;
    Player.tY := Player.Y;
  end;  

  If MovingUp     then Player.Y := Player.Y - 1;
  If MovingDown   then Player.Y := Player.Y + 1;
  If MovingLeft   then Player.X := Player.X - 1;
  If MovingRight  then Player.X := Player.X + 1;

   if player.X < 16 then player.X := 16;
   if player.X > WorldMapSize-16 then player.X := WorldMapSize-16;
   if player.Y < 12 then player.Y := 12;
   if player.Y > WorldMapSize-12 then player.Y := WorldMapSize-12;


  Caption := inttostr(player.X) + ' ' + inttostr(player.Y) + ':' + inttostr(WorldMap[player.X,player.Y].GrassID);
  DrawImage;

end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin

  ShowImage;
  Form1.Image2.Canvas.Draw(0,0,bufi);
  Form1.Image2.Canvas.MoveTo(player.x-16,player.Y-12);//,player.x+16,player.Y+12);
  Form1.Image2.Canvas.LineTo(player.x+16,player.Y-12);
  Form1.Image2.Canvas.LineTo(player.x+16,player.Y+12);
  Form1.Image2.Canvas.LineTo(player.x-16,player.Y+12);
  Form1.Image2.Canvas.LineTo(player.x-16,player.Y-12);
  if ClearGenGUI then
   begin
     ProgressBar1.Top := ProgressBar1.Top + 4;
     ProgressBar2.Top := ProgressBar2.Top + 3;
//     Panel1.Top := Panel1.Top + 2;
     Edit1.Top := Edit1.Top + 2;
     CheckBox1.Top := CheckBox1.Top + 2;
     TrackBar1.Top := TrackBar1.Top + 2;

     if ProgressBar1.Top > 640 then
      begin
       ClearGenGUI :=  false;
       ProgressBar1.Visible := false;
       ProgressBar2.Visible := false;
       //Panel1.Visible := false;
       Edit1.Visible := false;
       TrackBar1.Visible := false;
       CheckBox1.Visible := False;
      end;
   end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key = VK_DOWN  then MovingDown := true;
   if key = VK_UP    then MovingUp := true;
   if key = VK_LEFT  then MovingLeft := true;
   if key = VK_RIGHT then MovingRight := true;
end;

procedure ResetMap;
var i,j :integer;
begin
  for i := 1 to WorldMapSize do
  for j := 1 to WorldMapSize do
  WorldMap[i,j].GrassID := 0;
end;

procedure DrawGlobalMap;
var i,j : integer;
begin
bufi := TBitmap.Create;
bufi.Height := WorldMapSize;
bufi.Width  := WorldMapSize;

  for i := 1 to WorldMapSize do
  for j := 1 to WorldMapSize do
   begin
     if WorldMap[i,j].GrassID >=0 then
          BUFI.Canvas.Pixels[i-1,j-1] :=  YellowToBrown(WorldMap[i,j].GrassID)
     else
          BUFI.Canvas.Pixels[i-1,j-1] :=  DarkerColor(clAqua,-WorldMap[i,j].GrassID*2);
   end;
if Form1.CheckBox2.Checked then 
For i := 1 to WorldMapSize do
begin
  bufi.Canvas.Polyline(ridgeNo[i]);
end;

form1.Image2.Canvas.Draw(0,0,bufi);

end;

procedure ChangeWaterLevel(Amount : integer);
var i,j : integer;
begin
  Form1.Edit3.Text := inttostr ( strtoint( Form1.Edit3.Text ) + Amount );

  for i := 1 to WorldMapSize do
  for j := 1 to WorldMapSize do
    WorldMap[i,j].GrassID := WorldMap[i,j].GrassID + Amount;

DrawGlobalMap
end;

procedure GenerateClick;
var i,j,seed : integer;
begin

form1.ProgressBar1.Visible := true;
form1.ProgressBar2.Visible := true;

form1.Timer1.Enabled := false;
form1.Timer2.Enabled := false;
ResetMap;
seed := 0;
for i := 1 to length(form1.Edit1.Text) do
  begin
    if ( ord( form1.Edit1.Text[i] ) < 58 ) and ( ord( form1.Edit1.Text[i] ) > 47 ) then
    seed := seed*10 + strtoint(form1.Edit1.Text[i]);
  end;
  RandSeed := Seed;
  Form1.Label1.Caption := 'Seed : ' + inttostr(Seed);

case Form1.RadioGroup1.ItemIndex of
0 : AnalogGenerator;
1 : for i :=  1 to strtoint(form1.Edit2.Text) do GenerateWorld;
2 : for i :=  1 to strtoint(form1.Edit2.Text) do GenerateWorld2;
3 : for i :=  1 to strtoint(form1.Edit2.Text) do GenerateWorld3;
4 : for i :=  1 to strtoint(form1.Edit2.Text) do GenerateWorld4;
end;


form1.Button1.Enabled := true;
form1.Button2.Enabled := true;
form1.Edit3.Text := '0';
form1.label2.Caption := 'Min : ' + inttostr(min) + ' Max: '+ inttostr(max);

form1.ProgressBar1.Visible := false;
form1.ProgressBar2.Visible := false;

DrawGlobalMap;

  form1.Timer1.Enabled := true;
  form1.Timer2.Enabled := true;

end;

procedure TForm1.Panel1Click(Sender: TObject);
var i,j,seed : integer;
begin
GenerateClick;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key = VK_DOWN  then MovingDown := False;
   if key = VK_UP    then MovingUp := False;
   if key = VK_LEFT  then MovingLeft := False;
   if key = VK_RIGHT then MovingRight := False;

end;

procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MXmm := X;
  MYmm := Y;
end;

procedure TForm1.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
mmMouseDown := true;
end;

procedure TForm1.Image2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
mmMouseDown := false;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  TrackBar1.Enabled := CheckBox1.Checked;
end;



procedure TForm1.Button1Click(Sender: TObject);
begin
 ChangeWaterLevel(-1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 ChangeWaterLevel(1);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Fog;
end;

procedure TForm1.FormCreate(Sender: TObject);
var names : TStringList;  i : integer;
begin
//  button5.


  Randomize;
  names := TStringList.Create;
  for i := 1 to 10 do
  names.Add(GenName);
  names.SaveToFile('names.txt');

  MakeLightingImages;
  DoubleBuffered := True;
  Player.X := 30;
  Player.Y := 20;
  Player.tX := Player.X;
  Player.tY := Player.Y;

  BImage := TBitmap.Create;
  BImage.Height := 480;
  BImage.Width  := 640;
  ShowingImage := TBitmap.Create;
  ShowingImage.Height := 480;
  ShowingImage.Width  := 640;
  Edit1.Text :=
  inttostr(
  Random
  (
  MaxInt
  ))
  ;



 GenerateClick;
 ChangeWaterLevel(-5);

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  GenerateClick;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  player.TX := player.X - 16 + Mx div 20 ;
  player.TY := player.Y - 12 + My div 20 ;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Mx := x;
  My := y;
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
  If CheckBox3.Checked then ClientWidth := 1158
  else ClientWidth := 640;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  halt;
end;

end.








