function [options] = generic_wizard(varargin)
% generic data import helper
%
%% Input
%  data   - input data
%  header - header of data file
%  type   - data type ('EBSD','PoleFigure','ODF')
%
%% Output
%  options - list of potions to be past to loadEBSD_generic or loadPoleFigure_generic
%
%% See also
% loadEBSD_generic loadPoleFigure_generic

%% -------- parameter overload -------------------------------------------

if length(varargin) < 4, error('need more arguments');end

if check_option(varargin,'data')
  data = get_option(varargin,'data');
else
  return
end

header = get_option(varargin,'header',[]);
colums = get_option(varargin,'colums',[]);

if check_option(varargin,'type')
  type = get_option(varargin,'type');
  switch type
    case 'EBSD'
      values = {'Ignore','Euler 1','Euler 2','Euler 3','x','y','Phase','Quat real','Quat i','Quat j','Quat k','Weight'};
      mandatory = {values(2:4),values(8:11)};
    case 'PoleFigure'
      values = {'Ignore','Polar Angle','Azimuth Angle','Intensity','Background','x','y','z'};
      mandatory = {values(2:4)};
    case 'ODF'
      values = {'Ignore','Euler 1','Euler 2','Euler 3','Quat real','Quat i','Quat j','Quat k','Weight'};
      mandatory = {values([2:4,9]),values(5:9)};
    otherwise
      disp('wrong option');
      return
  end
end

newversion = ~verLessThan('matlab','7.6');
if ~newversion,  v0 = {}; else  v0 = {'v0'}; end

%% -------- init gui -----------------------------------------------------

% window dimension
w = 466;
tb = 250+10*newversion; %table size

h = tb+310 + 60 * any(strcmp(type,{'EBSD','ODF'})); 
dw = 10;
cw = (w-3*dw)/4;

% data size
[x,y] = size(data);
htp = import_gui_empty('type',type,'width',w,'height',h,'name','generic import');
iconMTEX(htp);

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
  'However the following ', ...
 ' data matrix was extracted from the file.']);

if ~isempty(colums) && length(colums) == y
  colnames = colums;
else
  for k=1:y, colnames{k} = ['Column ' int2str(k)]; end; %#ok<AGROW>
end

uitable(v0{:},'Parent',htp,'Data',data(1:end<101,:),...
  'ColumnNames',colnames,'Position',[dw,h-(tb+110),w-2*dw,tb]);

% input selection

uicontrol('Parent',htp,'Style','Text','Position',[dw,h-(tb+120+25),w-2*dw,20],...
  'HorizontalAlignment','left',...
  'String','Please specify for each column how it should be interpreted!');

cdata = guessColNames(values,size(data,2),colums);

mtable = uitable(v0{:},'Parent',htp,'Data',cdata,'ColumnNames',colnames,'Position',[ dw-1 h-(tb+200) w-2*dw 60],'rowheight',20); 

try
  mtable.getTable.setShowHorizontalLines(0);
  cb = javax.swing.JComboBox(values);
  cb.setEditable(true);
  editor = javax.swing.DefaultCellEditor(cb);
  for i = 1:length(colnames)
    mtable.getTable.getColumnModel.getColumn(i-1).setCellEditor(editor);
  end
catch %#ok<CTCH>
end

%% checkboxes
if strcmp(type,'PoleFigure')
  chk_angle = uibuttongroup('Parent',htp,'title','Angle Convention','units','pixels',...
    'position',[dw h-(tb+260) cw*2 45]);
  
  uicontrol('Style','Radio','String','Degree',...
    'Position',[dw dw 80 15],'Parent',chk_angle,'HandleVisibility','off');
  rad_box = uicontrol('Style','Radio','String','Radians',...
    'Position',[dw+cw dw 80 15],'Parent',chk_angle,'HandleVisibility','off');

else

  % Euler Angles
  chk_angle = uibuttongroup('Parent',htp,'title','Euler Angles','units','pixels',...
    'position',[dw h-(tb+260) 4*cw+dw 45]);
 
  euler_convention = uicontrol('Style', 'popup',...
    'String', 'ZXZ  Bunge (phi1 Phi phi2)|ZYZ  Matthies (alpha,beta,gamma)',...
    'Position',[dw 5 2*cw-2*dw 23],'Parent',chk_angle,'HandleVisibility','off');  
  
  uicontrol('Style','Radio','String','Degree',...
    'Position',[2*cw+2*dw dw 80 15],'Parent',chk_angle,'HandleVisibility','off');
  rad_box = uicontrol('Style','Radio','String','Radians',...
    'Position',[2*dw+3*cw dw 80 15],'Parent',chk_angle,'HandleVisibility','off');
  
  
  if strcmp(type,'EBSD')
    h3 = uipanel('Parent',htp,'title','Ignore Phase(s)','units','pixels',...
      'position',[dw h-tb-320 cw*2 46]);
    phaseopt = uicontrol('Style','Edit',...
      'BackgroundColor',[1 1 1],...
      'HorizontalAlignment','left',...
      'String','0' ,...
      'Position',[dw 5 cw*2-2*dw 23],'Parent',h3,'HandleVisibility','off');
  end
  
  h3 = uibuttongroup('Parent',htp,'title','Rotation','units','pixels',...
    'position',[2*cw+2*dw h-tb-320 cw*2 46]);
 
  uicontrol('Style','Radio','String','Active',...
    'Position',[dw dw 80 15],'Parent',h3,'HandleVisibility','off');
  passive_box = uicontrol('Style','Radio','String','Passive',...
    'Position',[dw+cw dw 80 15],'Parent',h3,'HandleVisibility','off');
      
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

while ishandle(htp)

  options = {};
  uiwait(htp);
  
  if ishandle(htp)

    % get column association
    if verLessThan('matlab','7.4')
      data = cellstr(char(get(mtable,'data')));
    else
      data = cellstr(char(mtable.getData));
    end

    ind = find(~strcmpi(data,'Ignore'));
    options = {'ColumnNames',data(ind)};
    if length(ind) < length(data)
      options = [options,{'Columns',ind}];
    end

    % check for mandatory columnnames
    for i = 1:length(mandatory)
      pass = true;
      for j = 1:length(mandatory{i})
        if sum(strcmp(stripws(data(ind)),stripws(mandatory{i}{j}))) ~= 1
          pass = false;
          break
        end
      end
    
      if pass, break;end      
    end
    if ~pass
      errordlg(['Not all of the mandatory columnnames ',...
        sprintf('%s, ', mandatory{1}{:}) 'has been specified!'],...
        'Error in generic wizzard','modal');
      continue;
    end
    
    % degree / radians
    if get(rad_box,'value'), options = [{'RADIANS'},options];end
    
    if ~strcmp(type,'PoleFigure')
    
      % Eule angle convention
      conventions = {'Bunge','ABG'};
      options = [options,conventions(get(euler_convention,'value'))];
      
      % active / pasive rotation
      if get(passive_box,'value')
        options = [options,{'passive rotation'}];
      end
      
      if strcmp(type,'EBSD')
        phase = str2num(get(phaseopt,'string')); %#ok<ST2NM>
        if ~isempty(phase)
          options = [options,{'ignorePhase',phase}];
        end
      end
      
    end
    
    close(htp);
    pause(0.3);
  end
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

if length(colnames) == l
  cdata = colnames;
else
  cdata = repmat(values(1),1,l);
end

if isempty(colnames), return;end

for i = 1:length(values)
  ind = strmatch(lower(values(i)),lower(colnames));
  if ~isempty(ind), cdata(ind(1)) = values(i); end
end

% volume
ind = strmatch('volume',lower(colnames));
if length(ind) == 1,cdata{ind} = 'weight';end

% Euler Angle
ind = regexp(lower(colnames),'phi|Euler');
ind = find(~cellfun('isempty',ind));

if length(ind)==3
  cdata{ind(1)} = 'Euler 1';
  cdata{ind(2)} = 'Euler 2';
  cdata{ind(3)} = 'Euler 3';
end

if ~isempty(strmatch('alpha',lower(colnames))) && ...
    ~isempty(strmatch('beta',lower(colnames))) && ...
    ~isempty(strmatch('gamma',lower(colnames)))
  
  cdata{strmatch('alpha',lower(colnames))}='Euler 1';
  cdata{strmatch('beta',lower(colnames))}='Euler 2';
  cdata{strmatch('gamma',lower(colnames))}='Euler 3';
end

if ~isempty(strmatch('phi1',lower(colnames))) && ...
    ~isempty(strmatch('phi2',lower(colnames),'exact')) && ...
    ~isempty(strmatch('phi',lower(colnames)))
  
  cdata{strmatch('phi1',lower(colnames))}='Euler 1';
  cdata{strmatch('phi',lower(colnames),'exact')}='Euler 2';
  cdata{strmatch('phi2',lower(colnames))}='Euler 3';
end

function str = stripws(str)

str = strrep(str,' ','');
