function import_gui_generic(wzrd)
% generic import wizard page

pos = get(wzrd,'Position');
h = pos(4);
w = pos(3);

handles = getappdata(wzrd,'handles');
handles.pages = [];

%% page title
handles.name = uicontrol(...
'Parent',wzrd,...
 'FontSize',12,...
 'ForegroundColor',[0.3 0.3 0.3],...
 'FontWeight','bold',...
 'BackgroundColor',[1 1 1],...
 'HorizontalAlignment','left',...
 'Position',[10 h-37 w-150 20],...
 'Style','text',...
 'HandleVisibility','off',...
 'HitTest','off');

%% navigation
handles.next = uicontrol(...
  'Parent',wzrd,...
  'String','Next >>',...
  'CallBack',@next_callback,...
  'Position',[w-30-80*2 10 80 25]);

handles.prev = uicontrol(...
  'Parent',wzrd,...
  'String','<< Previous',...
  'CallBack',@prev_callback,...
  'Position',[w-30-80*3 10 80 25]);

handles.finish = uicontrol(...
  'Parent',wzrd,...
  'String','Finish',...
  'Enable','off',...
  'CallBack',@finish_callback,...
  'Position',[w-90 10 80 25]);

handles.plot = uicontrol(...
  'Parent',wzrd,...
  'String','Plot',...
  'CallBack',@plot_callback,...
  'Position',[10 10 80 25],...
  'Visible','on');

uipanel(...
  'units','pixel',...
  'HighlightColor',[0 0 0],...
  'Position',[10 50 w-20 1]);

handles.proceed = [handles.next handles.prev handles.finish,handles.plot];
setappdata(wzrd,'handles',handles);


%% ----------------- Callbacks ----------------------------------

function next_callback(varargin)

switch_page(gcbf,+1);


function prev_callback(varargin)
  
switch_page(gcbf,-1);


function plot_callback(varargin)

page = getappdata(gcbf,'page');
handles = getappdata(gcbf,'handles');

if page == 1
  
  tab = getappdata(handles.tabs,'value');
  
  
handles = getappdata(gcbf,'handles');
pane = handles.datapane;
t= find(strcmpi(get(pane,'visible'),'on'),1,'last');
  
  data = getappdata(handles.listbox(t),'data');
  if isempty(data)
    errordlg('Nothing to plot! Add files to import first!');
    return;    
  end
else
  leavecallback = getappdata(handles.pages(page),'leave_callback');
  try
    leavecallback();
  catch 
    errordlg(errortext);
    return
  end
    
  data = getappdata(gcbf,'data');
  
end

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/8 scrsz(4)/8 6*scrsz(3)/8 6*scrsz(4)/8]);

switch class(data)
  case 'EBSD'
    plot_EBSD(gcbf,data);
  case 'PoleFigure'
    plot_pf(gcbf,data);
  case 'ODF'
    plot_ODF(gcbf,data);
end


function finish_callback(varargin)

handles = getappdata(gcbf,'handles');
lb = handles.listbox;

data = getappdata(gcbf,'data');

switch class(data)
  case 'EBSD'
    vname = 'ebsd';
  case 'PoleFigure'
    data = modifypf(gcbf,data);
    vname = 'pf';
  case 'ODF'
    vname = 'odf';
end

%% copy to workspace
if ~get(handles.runmfile,'Value');

  a = inputdlg({'Enter name of workspace variable'},'MTEX Import Wizard',1,{vname});
  if isempty(a), return;end
  assignin('base',a{1},data);
  if isempty(javachk('desktop')) 
    
    disp(' ');
    disp('generated variable: ');
    display(data,'vname',a{1});
    disp(' ');
    
    switch class(data)
      case 'EBSD'    
        disp(['- <a href="matlab:plot(',a{1},',''silent'')">Plot EBSD Data</a>']);
        disp(['- <a href="matlab:odf = calcODF(',a{1},')">Calculate ODF</a>']);
        disp(' ');
      case 'PoleFigure'
        disp(['- <a href="matlab:plot(',a{1},',''silent'')">Plot Pole Figure Data</a>']);
        disp(['- <a href="matlab:odf = calcODF(',a{1},')">Calculate ODF</a>']);
        disp(' ');
      case 'ODF'
        disp(['- <a href="matlab:plot(',a{1},',''silent'')">Plot ODF Data</a>']);
        disp(' ');
    end
  end
  
%% write to file
else 
    
  % extract file names
  fn = arrayfun(@(x) getappdata(x,'filename'),lb,'UniformOutput',false);
    
  switch class(data)
    case 'EBSD'
      str = generateScript('EBSD',fn{5},data,getappdata(lb(5),'interface'),...
        getappdata(lb(5),'options'), handles);
    case 'PoleFigure'
      fn(2:3) = [];
      if all(cellfun('isempty',fn(2:end)))
        fn = fn{1};
      end      
      str = generateScript('PoleFigure',fn,data,getappdata(lb(1),'interface'),...
        getappdata(lb(1),'options'), handles);
    case 'ODF'
      str = generateScript('ODF',fn{6},data,getappdata(lb(6),'interface'),...
        getappdata(lb(6),'options'), handles);
  end
       
  str = generateCodeString(str);
  openuntitled(str);
end

close


%% ------------ Private Functions ----------------------------------

function switch_page(wzrd,delta)
% switch between pages

page = getappdata(wzrd,'page');
handles = getappdata(wzrd,'handles');
leavecallback = getappdata(handles.pages(page),'leave_callback');
try
  leavecallback();
  data = getappdata(wzrd,'data');
  if isa(data,'EBSD')
    c = getappdata(wzrd,'cs_count');
    if (((page+delta == 3) && (c < numel(data))) || ((page+delta == 1) && (c > 1)))
      setappdata(wzrd,'cs_count',c+delta);
      delta = 0;
    end
  end 
  page = page + delta;
  gotocallback = getappdata(handles.pages(page),'goto_callback');
  gotocallback();
  set_page(wzrd,page);
catch  %#ok<*CTCH>
  errordlg(errortext);
end


function str = generateCodeString(strCells)

str = [];
for n = 1:length(strCells)
  str = [str, strCells{n}, sprintf('\n')]; %#ok<AGROW>
end


function plot_ODF(wzrd,odf) %#ok<INUSL>

cs = get(odf,'CS');
h = unique([Miller(1,0,0,cs),Miller(0,1,0,cs),Miller(0,0,1,cs),Miller(1,1,0),Miller(2,1,0)]);
plotpdf(odf,h(1:min(3,end)),'antipodal','silent');

function plot_EBSD(wzrd,ebsd)  %#ok<INUSL>

plot(ebsd);


function plot_pf(wzrd,pf)

pf = modifypf(wzrd,pf);
plot(pf,'silent');
annotate([xvector,yvector,zvector],...
  'labeled','Backgroundcolor','w','Marker','s',...
  'MarkerFaceColor','k','MarkerEdgeColor','w');


function pf = modifypf(wzrd,pf)
% Modify ODF before exporting or plotting

handles = getappdata(wzrd,'handles');
if get(handles.rotate,'value')
  pf = rotate(pf,str2num(get(handles.rotateAngle,'string'))*degree); %#ok<ST2NM>
end

if get(handles.flipud,'value'), pf = flipud(pf);end

if get(handles.fliplr,'value'), pf = fliplr(pf);end

function odf = modifyodf(wzrd,odf)
% Modify ODF before exporting or plotting

handles = getappdata(wzrd,'handles');





