unit Uex6W;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.GstPad.DOO,
  G2D.Gst.Types,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.API,
  G2D.Glib.API,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Label1: TLabel;
    REInstructions: TRichEdit;
    Panel4: TPanel;
    Label2: TLabel;
    Logger: TRichEdit;
    Panel5: TPanel;
    Label3: TLabel;
    ComboElements: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboElementsChange(Sender: TObject);
  private
    GStreamer: TGstFramework;
    procedure LoadElementList;
    procedure InspectElement(const AElementName: string);
    procedure PrintPadTemplates(AFactory: TGstElementFactoryRef);
    procedure PrintPadCapabilities(AElement: TGstElementRef; const APadName: string);
    procedure PrintCaps(ACaps: TGstCapsRef; const AIndent: string);
    procedure PrintStructure(AStructure: TGstStructureRef; const AIndent: string);
    procedure Log(const AText: string);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

const
  ELEMENT_LIST: array[0..25] of string = (
    'filesrc',
    'videotestsrc',
    'audiotestsrc',
    'autovideosrc',
    'autoaudiosrc',
    'filesink',
    'autovideosink',
    'autoaudiosink',
    'fakesink',
    'decodebin',
    'uridecodebin',
    'playbin',
    'matroskademux',
    'avidemux',
    'x264enc',
    'vorbisenc',
    'oggmux',
    'matroskamux',
    'avimux',
    'videoconvert',
    'audioconvert',
    'videoscale',
    'audioresample',
    'capsfilter',
    'queue',
    'tee'
  );

{ Callback for gst_structure_foreach - prints each field }
function print_field(field_id: GQuark; value: PGValue; user_data: gpointer): gboolean; cdecl;
var
  Form: TForm1;
  FieldName: string;
  ValueStr: string;
begin
  Form := TForm1(user_data);

  FieldName := DGQuarkToString(field_id);
  ValueStr := DGstValueSerialize(value);

  if ValueStr <> '' then
    Form.Log('          ' + FieldName + ': ' + ValueStr)
  else
    Form.Log('          ' + FieldName + ': (could not serialize)');

  Result := GTRUE;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialize GStreamer
  GStreamer := TGstFramework.Create(False);
  if not GStreamer.Started then
  begin
    ShowMessage('Failed to initialize GStreamer');
    Application.Terminate;
    Exit;
  end;

  // Load element list
  LoadElementList;

  // Select audiotestsrc by default and run inspection
  ComboElements.ItemIndex := 2; // audiotestsrc
  InspectElement('audiotestsrc');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  GStreamer.Free;
end;

procedure TForm1.LoadElementList;
var
  I: Integer;
begin
  ComboElements.Items.Clear;
  for I := Low(ELEMENT_LIST) to High(ELEMENT_LIST) do
    ComboElements.Items.Add(ELEMENT_LIST[I]);
end;

procedure TForm1.ComboElementsChange(Sender: TObject);
begin
  if ComboElements.ItemIndex < 0 then
    Exit;
  InspectElement(ComboElements.Text);
end;

procedure TForm1.Log(const AText: string);
begin
  Logger.Lines.Add(AText);
end;

procedure TForm1.InspectElement(const AElementName: string);
var
  Factory: TGstElementFactoryRef;
  Element: TGstElementRef;
  PipelineDesc: string;
begin
  Logger.Lines.Clear;

  // Find the element factory
  Factory := TGstElementFactoryRef.Find(AElementName);
  if Factory = nil then
  begin
    Log('Error: Element factory "' + AElementName + '" not found');
    Exit;
  end;

  try
    Log('Inspecting element: ' + AElementName);
    Log('');

    // Print pad templates
    PrintPadTemplates(Factory);

    // For elements with pads, show capability negotiation through states
    // Build a simple test pipeline based on element type
    if (AElementName = 'audiotestsrc') or (AElementName = 'videotestsrc') then
    begin
      // Source element - connect to appropriate sink
      if AElementName = 'audiotestsrc' then
        PipelineDesc := 'audiotestsrc name=source ! autoaudiosink name=sink'
      else
        PipelineDesc := 'videotestsrc name=source ! autovideosink name=sink';

      GStreamer.Close;
      if GStreamer.BuildAndPlay(PipelineDesc) then
      begin
        // Get the sink element
        Element := GStreamer.FindElement('sink');
        if Element <> nil then
        begin
          Log('');
          Log('---- State is NULL to READY');
          GStreamer.Ready;
          Application.ProcessMessages;
          Sleep(100);
          PrintPadCapabilities(Element, 'sink');

          Log('---- State is READY to PAUSED');
          GStreamer.Pause;
          Application.ProcessMessages;
          Sleep(100);
          PrintPadCapabilities(Element, 'sink');

          Log('---- State is PAUSED to PLAYING');
          GStreamer.Play;
          Application.ProcessMessages;
          Sleep(100);
          PrintPadCapabilities(Element, 'sink');
        end;
        GStreamer.Close;
      end;
    end
    else if (AElementName = 'autoaudiosink') or (AElementName = 'autovideosink') then
    begin
      // Sink element - connect from appropriate source
      if AElementName = 'autoaudiosink' then
        PipelineDesc := 'audiotestsrc ! ' + AElementName + ' name=sink'
      else
        PipelineDesc := 'videotestsrc ! ' + AElementName + ' name=sink';

      GStreamer.Close;
      if GStreamer.BuildAndPlay(PipelineDesc) then
      begin
        Element := GStreamer.FindElement('sink');
        if Element <> nil then
        begin
          Log('');
          Log('---- State is NULL to READY');
          GStreamer.Ready;
          Application.ProcessMessages;
          Sleep(100);
          PrintPadCapabilities(Element, 'sink');

          Log('---- State is READY to PAUSED');
          GStreamer.Pause;
          Application.ProcessMessages;
          Sleep(100);
          PrintPadCapabilities(Element, 'sink');

          Log('---- State is PAUSED to PLAYING');
          GStreamer.Play;
          Application.ProcessMessages;
          Sleep(100);
          PrintPadCapabilities(Element, 'sink');
        end;
        GStreamer.Close;
      end;
    end;
  finally
    Factory.Free;
  end;
end;

procedure TForm1.PrintPadTemplates(AFactory: TGstElementFactoryRef);
var
  Templates: PGList;
  Current: PGList;
  StaticTemplate: PGstStaticPadTemplate;
  Caps: TGstCapsRef;
  Direction: GstPadDirection;
  Presence: GstPadPresence;
  Name: string;
  DirStr, PresStr: string;
begin
  Templates := AFactory.GetStaticPadTemplates;
  if Templates = nil then
  begin
    Log('  No pad templates found');
    Exit;
  end;

  Current := Templates;
  while Current <> nil do
  begin
    StaticTemplate := PGstStaticPadTemplate(Current^.data);
    if StaticTemplate <> nil then
    begin
      Name := string(StaticTemplate^.name_template);
      Direction := StaticTemplate^.direction;
      Presence := StaticTemplate^.presence;

      // Convert direction to string
      case Direction of
        GST_PAD_SRC:  DirStr := 'SRC';
        GST_PAD_SINK: DirStr := 'SINK';
        else          DirStr := 'UNKNOWN';
      end;

      // Convert presence to string
      case Presence of
        GST_PAD_ALWAYS:    PresStr := 'Always';
        GST_PAD_SOMETIMES: PresStr := 'Sometimes';
        GST_PAD_REQUEST:   PresStr := 'Request';
        else               PresStr := 'Unknown';
      end;

      Log('Pad Template: ' + Name);
      Log('  Direction: ' + DirStr);
      Log('  Availability: ' + PresStr);

      // Get and print capabilities
      Caps := TGstCapsRef.Wrap(DGstStaticPadTemplateGetCaps(StaticTemplate), True);
      if Caps <> nil then
      begin
        try
          Log('---- Capabilities ----');
          PrintCaps(Caps, '	');
          Log('----------------------');
        finally
          Caps.Free;
        end;
      end;
      Log('------End of ' + Name + ' capabilities----------------');
      Log('');
    end;

    Current := Current^.next;
  end;
end;

procedure TForm1.PrintPadCapabilities(AElement: TGstElementRef; const APadName: string);
var
  Pad: PGstPad;
  PadRef: TGstPadRef;
  Caps: TGstCapsRef;
begin
  Pad := AElement.GetStaticPad(APadName);
  if Pad = nil then
  begin
    Log('Could not retrieve pad: ' + APadName);
    Exit;
  end;

  try
    PadRef := TGstPadRef.Wrap(Pad, False, False);
    try
      Log('Capabilities for ' + APadName + ' Pad:');

      Caps := PadRef.GetCurrentCaps;
      if Caps <> nil then
      begin
        try
          PrintCaps(Caps, '	');
        finally
          Caps.Free;
        end;
      end
      else
      begin
        // If no current caps, try template caps
        Caps := PadRef.GetPadTemplateCaps;
        if Caps <> nil then
        begin
          try
            PrintCaps(Caps, '	');
          finally
            Caps.Free;
          end;
        end
        else
          Log('	Could not get capabilities');
      end;
    finally
      PadRef.Free;
    end;
  finally
    DGstObjectUnref(Pad);
  end;
end;

procedure TForm1.PrintCaps(ACaps: TGstCapsRef; const AIndent: string);
var
  I: Integer;
  NumStructures: Integer;
  Structure: TGstStructureRef;
begin
  if not ACaps.IsValid then
  begin
    Log(AIndent + 'NULL caps');
    Exit;
  end;

  if ACaps.IsAny then
  begin
    Log(AIndent + 'Caps = "Any"');
    Exit;
  end;

  if ACaps.IsEmpty then
  begin
    Log(AIndent + 'Caps = "EMPTY"');
    Exit;
  end;

  NumStructures := ACaps.GetSize;
  for I := 0 to NumStructures - 1 do
  begin
    Structure := ACaps.GetStructure(I);
    if Structure <> nil then
    begin
      try
        PrintStructure(Structure, AIndent);
      finally
        Structure.Free;
      end;
    end;
  end;
end;

procedure TForm1.PrintStructure(AStructure: TGstStructureRef; const AIndent: string);
var
  StructName: string;
begin
  if not AStructure.IsValid then
    Exit;

  StructName := AStructure.GetName;
  Log(AIndent + StructName);

  // Iterate through all fields in the structure
  AStructure.ForEach(@print_field, Self);
end;

end.
