function [options] = generic_wizard(varargin)
% generic data import helper
%
%% Input
%  data   - input data
%  header - header of data file
%  type   - data type ('EBSD','PoleFigure')
%
%% Output
%  options - list of potions to be past to loadEBSD_generic or loadPoleFigure_generic
%
%% See also
% loadEBSD_generic loadPoleFigure_generic

%% -------- parameter overload -------------------------------------------

if length(varargin) < 4, disp('need more arguments');
 return
end

options = {};

if check_option(varargin,'data')
 data = get_option(varargin,'data');
else return
end

header = get_option(varargin,'header',[]);

if check_option(varargin,'type')
 type = get_option(varargin,'type');
 switch type
  case 'EBSD'
    values = {'Ignore','Alpha','Beta','Gamma','phi 1','Phi','phi 2','x','y','Phase'};
  case 'PoleFigure'
    values = {'Ignore','Polar Angle','Azimuth Angle','Intensity','Background'};
  otherwise
    disp('wrong option');
  return
 end
end


%% -------- init gui -----------------------------------------------------

% window dimension
w = 466;
tb = 250; %table size
h = tb+310; 
dw = 10;
cw = (w-3*dw)/4;

% data size
[x,y] = size(data);
htp = import_gui_empty('type',type,'width',w,'height',h,'name','generic import');

uicontrol(...
  'Parent',htp,...
  'FontSize',12,...
  'ForegroundColor',[0.3 0.3 0.3],...
  'FontWeight','bold',...
  'BackgroundColor',[1 1 1],...
  'HorizontalAlignment','left',...
  'Position',[10 h-37 w-150 20],...
  'Style','text',...
  'HandleVisibility','off',...
  'String','Select Data Format',...
  'HitTest','off');

% static text
uicontrol('Style','Text','Position',[dw,h-120,w-2*dw,50],...
 'HorizontalAlignment','left',...
 'string',['The data format could not automatically detected. ',...
 'However the following ',int2str(size(data,1)) 'x' int2str(size(data,2)) ...
 ' data matrix was extracted from the file.']);

% table

for k=1:y, colnames{k} = ['Column ' int2str(k)]; end;

if ~strcmp(version('-release'),'2008a')
  uitable('Data',data(1:min(size(data,1),100),:),...
   'ColumnNames',colnames,...
   'Position',[dw,h-(tb+110),w-2*dw,tb]);
else
  uitable('Data',data(1:min(size(data,1),100),:),...
 'ColumnName',colnames,...
 'Position',[dw,h-(tb+110),w-2*dw,tb]);
end

% input selection

uicontrol('Style','Text','Position',[dw,h-(tb+120+25),w-2*dw,20],...
  'HorizontalAlignment','left',...
  'String','Please specify for each column how it should be interpreted!');

cdata = repmat(values(1),1,size(data,2));
colums = strcat('Column  ',num2str((1:length(cdata)).'));

try
  mtable = createTable([],cellstr(colums).',cdata,false,'units','pixel','position',[dw-1,h-(tb+120+85),w-2*dw,55]);
  jtable = mtable.getTable;
  cb = javax.swing.JComboBox(values);
  cb.setEditable(true);
  editor = javax.swing.DefaultCellEditor(cb);
  for i = 1:length(values)
    jtable.getColumnModel.getColumn(i-1).setCellEditor(editor);
  end
catch
end

% checkboxes
chk_angle = uibuttongroup('title','Angle Convention','units','pixels',...
  'position',[dw h-(tb+260) cw*2 45]);

uicontrol('Style','Radio','String','Degree',...
  'Position',[dw dw 80 15],'Parent',chk_angle,'HandleVisibility','off');
uicontrol('Style','Radio','String','Radiant',...
  'Position',[dw+cw dw 80 15],'Parent',chk_angle,'HandleVisibility','off');

if (~strcmp(type,'PoleFigure'))
 h3 = uipanel('title','Restrict to Phase(s)','units','pixels',...
   'position',[2*cw+2*dw h-tb-260 cw*2 46]);
 phaseopt = uicontrol('Style','Edit',...
   'BackgroundColor',[1 1 1],...
   'HorizontalAlignment','left',...
   'String','' ,...
   'Position',[dw 5 cw*2-2*dw 23],'Parent',h3,'HandleVisibility','off');
end

if ~isempty(header)
  uicontrol('Style','PushButton','String','Show File Header','Position',[dw,dw,130,25],...
    'CallBack',{@showFileHeader,header});
end

uicontrol('Style','PushButton','String','Proceed ','Position',[w-70-dw,dw,70,25],...
 'CallBack','uiresume(gcbf)');

uicontrol('Style','PushButton','String','Cancel ','Position',[w-2*70-2*dw,dw,70,25],...
 'CallBack','close');

%% -------- retun statement ----------------------------------------------
uiwait(htp);

if ishandle(htp)

  options = {};
  
  % get column association
  data = cell(mtable.getData);

  if any(strcmpi(data,'Alpha'))
    layout(1) = find(strcmpi(data,'Alpha'),1);
    layout(2) = find(strcmpi(data,'Beta'),1);
    layout(3) = find(strcmpi(data,'Gamma'),1);
    options = {options{:},'ABG'};
  elseif any(strcmpi(data,'Phi'))
    layout(1) = find(strcmpi(data,'phi 1'),1);
    layout(2) = find(strcmpi(data,'Phi'),1);
    layout(3) = find(strcmpi(data,'phi 2'),1);
    options = {options{:},'Bunge'};
  else
    layout(1) = find(strcmpi(data,'Polar Angle'),1);
    layout(2) = find(strcmpi(data,'Azimuth Angle'),1);
    layout(3) = find(strcmpi(data,'Intensity'),1);
  end
  
  if any(strcmpi(data,'Background'))
    layout(4) = find(strcmpi(data,'Background'),1);
  elseif any(strcmpi(data,'Phase'))
    layout(4) = find(strcmpi(data,'Phase'),1);
  end
  
  options = {options{:},'layout',layout};
 
  % coordinates
  if any(strcmpi(data,'x')) && any(strcmpi(data,'y'))
    options = {options{:},'xy',...
      [find(strcmpi(data,'x'),1),find(strcmpi(data,'y'),1)]};
  end
  
  %phase
  if strcmpi(type,'EBSD')
    phase = str2num(get(phaseopt,'string'));
    if ~isempty(phase)
      options = {options{:},'phase',phase};
    end
  end   
  
  close
end

%% Callbacks

function showFileHeader(x,y,header) %#ok<INUSL>

h = figure('MenuBar','none',...
 'Name','Header Preview',...
 'NumberTitle','off');

uicontrol(...
  'Parent',h,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','left',...
  'Max',2,...
  'String',header,...
  'units','normalized',...
  'position',[0 0 1 1],...
  'Style','edit',...
  'Enable','inactive');
