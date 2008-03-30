function [options] = genericimport(varargin)
% generic data import helper
%
%% Input
%  data  - input data
%  type  - data type ('EBSD','PoleFigure')
%
%% Output
%  col   -  vector of columns
%  deg   -  (optional) type 'Degree','Radiant'
%  sys   -  (if EBSD optional) 'Bunge','Matthis'
%  phase - 
%
%% See also
% loadEBSD_generic loadPoleFigure_generic

%% -------- parameter overload -------------------------------------------

if length(varargin) < 4, disp('need more arguments');
 return
end

if check_option(varargin,'data')
 data = get_option(varargin,'data');
else return
end

if check_option(varargin,'type')
 type = get_option(varargin,'type');
 switch type
   case 'EBSD'
     dscrpt = {'alpha','beta','gamma','phase'};
   case 'PoleFigure'
     dscrpt = {'angle 1','angle 2','intensity','background'};
   otherwise
     disp('wrong option');
   return
 end
end


%% -------- init gui -----------------------------------------------------

% window dimension
w = 466;
tb = 250; %table size
if (~strcmp(type,'PoleFigure')) h = tb+355; else h = tb+300; end;
dw = 10;
cw = (w-2*dw-20)/4;

% data size
[x,y] = size(data);
htp = import_frame('type',type,'width',w,'height',h,'name','generic import');

% static text
uicontrol('Style','Text','Position',[dw,h-120,w-2*dw,60],...
  'HorizontalAlignment','left',...
  'string',['The data format could not automatically detected.',...
  'However the following ',int2str(size(data,1)) 'x' int2str(size(data,2)) ...
  ' data matrix could extracted from the file. ',...
  'Please specify the column numbers that coresponds to the' ...
  'required quantities.']);

% table
for k=1:y, colnames{k} = ['Column ' int2str(k)]; end;
uitable('Data',data,...
 'ColumnNames',colnames,...
 'Position',[dw,h-(tb+120),w-2*dw,tb]);

% input selection
cols = [' ',colnames] ;
h0 = uipanel('title','Column Association','units','pixels','position',[dw h-tb-190 w-2*dw 65]);
for k=1:length(dscrpt)
 colspos = [(dw+cw*(k-1)) -20 cw-5 50];
 dscrptpos = [(dw+cw*(k-1)) 35 cw-5 12];
 uicontrol(...
  'HorizontalAlignment','left',...
  'Position',dscrptpos,...
  'String',dscrpt{k},...
  'FontWeight','bold',...
  'Style','text',...
  'HandleVisibility','off',...
   'Parent',h0,...
  'HitTest','off');
 if (k <= length(colnames))
  col_nb{k} = uicontrol('Style', 'popup',...
   'BackgroundColor',[1 1 1],...
   'String',cols ,...
    'Parent',h0,...
   'Position', colspos);
   set(col_nb{k},'Value',k+1);
 end
end

% checkboxes

chktxt_angle = {'Degree','Radiant'};
chkpos = {[dw dw 100 15],[dw dw+20 100 15]};
if ~strcmp(type,'PoleFigure')
 h2 = uibuttongroup('title','Euler Angle Convention','units','pixels','position',[cw*2+2.5*dw h-(tb+260) cw*2+.5*dw 65]);
 chktxt_sys = {'Bunge','Matthis'};
end;

for k=1:2
 chk_angle{k} = uicontrol('Style','Radio','String',chktxt_angle{k},...
   'Position',chkpos{k},'Parent',h1,'HandleVisibility','off');
 if ~strcmp(type,'PoleFigure')
   chk_sys{k} = uicontrol('Style','Radio','String',chktxt_sys{k},...
     'Position',chkpos{k},'Parent',h2,'HandleVisibility','off');
 end
end

if (~strcmp(type,'PoleFigure'))
  h3 = uipanel('title','Phase Convention','units','pixels','position',[dw h-tb-310 w-2*dw 46]);
  phaseopt = uicontrol('Style','Edit',...
    'BackgroundColor',[1 1 1],...
    'HorizontalAlignment','left',...
    'String',' insert Phase types here' ,...
     'Position',[dw 5 w-4*dw 23],'Parent',h3,'HandleVisibility','off');
end

ex = uicontrol('Style','PushButton','String','Proceed ','Position',[w-80,dw,70,25],...
 'CallBack','uiresume(gcbf)');


%% -------- retun statement ----------------------------------------------
uiwait(htp);
if ishandle(htp)
  for k=1:length(dscrpt)
    if (k <= length(colnames)), val = get(col_nb{k},'Value'); end
    if val > 1, layout(k) = val-1; end;
  end
  options = {'layout',layout,...
    get(get(h1,'SelectedObject'),'String')};

  if ~strcmp(type,'PoleFigure')
    options = {options{:},get(get(h2,'SelectedObject'),'String')};
    if ~isempty(str2num(get(phaseopt,'String')))
      options = {options{:},str2num(get(phaseopt,'String'))};
    end
  end;
end
close
