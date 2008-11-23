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

if length(varargin) < 4, error('need more arguments');end

options = {};

if check_option(varargin,'data')
 data = get_option(varargin,'data');
else return
end

header = get_option(varargin,'header',[]);
colums = get_option(varargin,'colums',[]);

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

newversion = ~verLessThan('matlab','7.6');

%% -------- init gui -----------------------------------------------------

% window dimension
w = 466;
tb = 250+10*newversion; %table size
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
uicontrol('Parent',htp,'Style','Text','Position',[dw,h-120,w-2*dw,50],...
 'HorizontalAlignment','left',...
 'string',['The data format could not automatically detected. ',...
 'However the following ',int2str(size(data,1)) 'x' int2str(size(data,2)) ...
 ' data matrix was extracted from the file.']);

% table

if ~isempty(colums) && length(colums) == y
  colnames = colums;
else
  %colums = strcat('Column  ',num2str((1:length(cdata)).'));
  %cellstr(colums).'
  for k=1:y, colnames{k} = ['Column ' int2str(k)]; end;
end

if newversion
  uitable('Parent',htp,'Data',data(1:min(size(data,1),100),:),...
    'ColumnName',colnames,...
    'Position',[dw,h-(tb+110),w-2*dw,tb]);
else
  uitable('Parent',htp,'Data',data(1:min(size(data,1),100),:),...
    'ColumnNames',colnames,...
    'Position',[dw,h-(tb+110),w-2*dw,tb]);
end

% input selection

uicontrol('Parent',htp,'Style','Text','Position',[dw,h-(tb+120+25),w-2*dw,20],...
  'HorizontalAlignment','left',...
  'String','Please specify for each column how it should be interpreted!');

cdata = guessColNames(values,size(data,2),colnames);

if newversion
  mtable = uitable('Parent',htp,'Data',cdata,...
    'ColumnName',colnames,...
    'ColumnEditable',true,...
    'ColumnFormat',repcell(values,[length(colnames),1]).',...
    'Position',[dw-1,h-(tb+120+85),w-2*dw,65]);
else
  try
    mtable = createTable([],colnames,cdata,false,'units','pixel','position',[dw-1,h-(tb+120+85),w-2*dw,55]);
    jtable = mtable.getTable;
    cb = javax.swing.JComboBox(values);
    cb.setEditable(true);
    editor = javax.swing.DefaultCellEditor(cb);
    for i = 1:length(values)
      jtable.getColumnModel.getColumn(i-1).setCellEditor(editor);
    end
  catch
  end
end
% checkboxes
chk_angle = uibuttongroup('Parent',htp,'title','Angle Convention','units','pixels',...
  'position',[dw h-(tb+260) cw*2 45]);

uicontrol('Style','Radio','String','Degree',...
  'Position',[dw dw 80 15],'Parent',chk_angle,'HandleVisibility','off');
rad_box = uicontrol('Style','Radio','String','Radians',...
  'Position',[dw+cw dw 80 15],'Parent',chk_angle,'HandleVisibility','off');

if (~strcmp(type,'PoleFigure'))
 h3 = uipanel('Parent',htp,'title','Restrict to Phase(s)','units','pixels',...
   'position',[2*cw+2*dw h-tb-260 cw*2 46]);
 phaseopt = uicontrol('Style','Edit',...
   'BackgroundColor',[1 1 1],...
   'HorizontalAlignment','left',...
   'String','' ,...
   'Position',[dw 5 cw*2-2*dw 23],'Parent',h3,'HandleVisibility','off');
end

if ~isempty(header)
  uicontrol('Parent',htp,'Style','PushButton','String','Show File Header','Position',[dw,dw,130,25],...
    'CallBack',{@showFileHeader,header});
end

uicontrol('Parent',htp,'Style','PushButton','String','Proceed ','Position',[w-70-dw,dw,70,25],...
 'CallBack','uiresume(gcbf)');

uicontrol('Parent',htp,'Style','PushButton','String','Cancel ','Position',[w-2*70-2*dw,dw,70,25],...
 'CallBack','close');

%% -------- retun statement ----------------------------------------------
uiwait(htp);

if ishandle(htp)

  options = {};
  
  % get column association
  if newversion
    data = get(mtable,'data');
  else
    data = cell(mtable.getData);
  end
  
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

  % degree / radians
  if get(rad_box,'value'), options = {'RADIANS',options{:}};end
  
  %phase
  if strcmpi(type,'EBSD')
    phase = str2num(get(phaseopt,'string'));
    if ~isempty(phase)
      options = {options{:},'phase',phase};
    end
  end   
  
  close(htp);
  pause(0.3);
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

%% Private Functions

function cdata = guessColNames(values,l,colnames)

cdata = repmat(values(1),1,l);
for i = 1:length(values)
  ind = strmatch(lower(values(i)),lower(colnames));
  if ~isempty(ind), cdata(ind(1)) = values(i); end
end

% Euler Angle=
ind = strmatch('euler',lower(colnames));
if length(ind)==3
  cdata{ind(1)} = 'phi 1';
  cdata{ind(2)} = 'Phi';
  cdata{ind(3)} = 'phi 2';
end
