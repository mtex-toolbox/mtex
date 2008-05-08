function [options] = generic_wizard(varargin)
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

options = {};

if check_option(varargin,'data')
 data = get_option(varargin,'data');
else return
end

if check_option(varargin,'type')
 type = get_option(varargin,'type');
 switch type
  case 'EBSD'
    dscrpt = {'Alpha','Beta','Gamma','Phase'};
  case 'PoleFigure'
    dscrpt = {'Polar Angle','Azimuth Angle','Intensity','Background'};
  otherwise
    disp('wrong option');
  return
 end
end


%% -------- init gui -----------------------------------------------------

% window dimension
w = 466;
tb = 250; %table size
if (~strcmp(type,'PoleFigure')), h = tb+355; else h = tb+300; end;
dw = 10;
cw = (w-3*dw)/4;

% data size
[x,y] = size(data);
htp = import_frame('type',type,'width',w,'height',h,'name','generic import');

% static text
uicontrol('Style','Text','Position',[dw,h-120,w-2*dw,60],...
 'HorizontalAlignment','left',...
 'string',['The data format could not automatically detected. ',...
 'However the following ',int2str(size(data,1)) 'x' int2str(size(data,2)) ...
 ' data matrix could extracted from the file. ',...
 'Please specify the column numbers that coresponds to the' ...
 'required quantities.']);

% table

for k=1:y, colnames{k} = ['Column ' int2str(k)]; end;
uitable('Data',data(1:min(size(data,1),100),:),...
 'ColumnNames',colnames,...
 'Position',[dw,h-(tb+120),w-2*dw,tb]);

% input selection
cols = [' ',colnames] ;
h0 = uipanel('title','Column Association','units','pixels','position',[dw h-tb-190 w-2*dw 65]);
for k=1:length(dscrpt)
 colspos = [(dw+cw*(k-1)) -20 cw-dw 50];
 dscrptpos = [(dw+cw*(k-1)) 35 cw-dw 12];
 uicontrol(...
 'HorizontalAlignment','left',...
 'Position',dscrptpos,...
 'String',dscrpt{k},...
 'Style','text',...
 'HandleVisibility','off',...
  'Parent',h0,...
 'HitTest','off');
 if (k <= length(colnames))
 col_nb{k} = uicontrol('Style', 'popup',...
  'BackgroundColor',[1 1 1],...
  'String',cols ,...
   'Parent',h0,...
  'Position', colspos); %#ok<AGROW>
  set(col_nb{k},'Value',1+mod(k,4));
 end
end

% checkboxes
h1 = uibuttongroup('title','Angle Convention','units','pixels',...
  'position',[dw h-(tb+260) cw*2 65]);
chktxt_angle = {'Degree','Radiant'};
chkpos = {[dw dw 100 15],[dw dw+20 100 15]};
if ~strcmp(type,'PoleFigure')
 h2 = uibuttongroup('title','Euler Angle Convention','units',...
   'pixels','position',[cw*2+2*dw h-(tb+260) cw*2 65]);
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
 h3 = uipanel('title','Phase(s)','units','pixels','position',[dw h-tb-310 w-2*dw 46]);
 phaseopt = uicontrol('Style','Edit',...
   'BackgroundColor',[1 1 1],...
   'HorizontalAlignment','left',...
   'String','' ,...
    'Position',[dw 5 w-4*dw 23],'Parent',h3,'HandleVisibility','off');
end

uicontrol('Style','PushButton','String','Proceed ','Position',[w-70-dw,dw,70,25],...
 'CallBack','uiresume(gcbf)');

uicontrol('Style','PushButton','String','Cancel ','Position',[w-2*70-2*dw,dw,70,25],...
 'CallBack','close');

%% -------- retun statement ----------------------------------------------
uiwait(htp);

if ishandle(htp)

 for k=1:length(col_nb)
   layout(k) = get(col_nb{k},'Value')-1;
 end
 if  length(layout)==4 && layout(4) == 0
   layout = layout(1:3);
 end
 
 options = {'layout',layout,...
   get(get(h1,'SelectedObject'),'String')};
 
 if ~strcmp(type,'PoleFigure')
   options = {options{:},get(get(h2,'SelectedObject'),'String')};
   if ~isempty(str2num(get(phaseopt,'String')))
     options = {options{:},'phase',str2num(get(phaseopt,'String'))};
   end
 end;
end
close

function wizard = import_frame( varargin )
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here

type = get_option(varargin,'type');
w = get_option(varargin,'width',450,'double');
h = get_option(varargin,'height',400,'double');
name = get_option(varargin,'name','Wizard');

scrsz = get(0,'ScreenSize');
wizard = figure('MenuBar','none',...
 'Name',[type ' ' name],...
 'Resize','off',...
 'WindowStyle','modal',...
 'NumberTitle','off',...
 'Position',[(scrsz(3)-w)/2 (scrsz(4)-h)/2 w h]);
uipanel;
 
uicontrol('BackgroundColor',[1 1 1],...
 'Parent',wizard,...
 'Position',[-3 h-45 w+5 50],...
 'String','',...
 'Style','text',...
 'HandleVisibility','off',...
 'HitTest','off');
uicontrol(...
 'Parent',wizard,...
 'FontSize',12,...
 'FontWeight','bold',...
 'BackgroundColor',[1 1 1],...
 'HorizontalAlignment','right',...
 'Position',[w-100 h-37 90 20],...
 'String',type,...
 'Style','text',...
 'HandleVisibility','off',...
 'HitTest','off');
