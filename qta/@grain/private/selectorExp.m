function selector = selectorExp(hFig)

selector = findall(0,'Tag','MTEX.selectByExpression');

layers = getappdata(hFig,'layers');

w = 350;
h = 450;
b = 10;

if isempty(selector)  
  fig = dialog('Name','Select By Expression',...
    'Tag','MTEX.selectByExpression',...
    'Color',get(0,'defaultUicontrolBackgroundColor'),...  
    'WindowStyle','normal' ); 
  
  set(gca,'Visible','off')
  pos = get(fig,'Position');
  set(fig,'Position',[pos(1:2) w h]);
  
	iconMTEX(fig);
  
  
  uicontrol(fig,'Style','text','String','Method:',...
    'HorizontalAlignment','left',...
    'Position',[b h-b-34 50 20]);
  
  uicontrol(fig,'Style','popupmenu', 'String',...
   {'Create a new Selection',...
    'Add to current Selection',...
    'Remove from current Selection',...
    'Select from current Selection'},...
    'BackgroundColor',[1 1 1],...
    'Tag','operation',...
    'Position',[b+50 h-b-30 w-2*b-50 20]);
 
  txth = 16;  
  uicontrol(fig,'Style','text',...
    'HorizontalAlignment','left',...
    'String','Select from Layer',...
    'Position',[b h-b-txth-50 w-2*b txth]);
  
	uicontrol(fig,'Style','text',...
    'HorizontalAlignment','left',...
    'String','Select from below by Right-Click',...
    'Position',[b+w/2-5 h-b-txth-50 w-2*b txth]);
  
 
  uicontrol(fig,'Style','listbox',...
    'String',evalProperties(layers),...
    'BackgroundColor',[1 1 1],...
    'Tag','layer',...
    'Position',[b h-b-130 w/2-b-3 65],...
    'Callback',{@updateselectfrom,length(layers)});  

  uicontrol(fig,'Style','listbox',...
    'String',functionlist,...
    'BackgroundColor',[1 1 1],...
    'Position',[b+w/2-b+3 h-b-210 w/2-b-3 145],'ButtonDownFcn',{@addexp,'(grains)'});
  
	uicontrol(fig,'Style','text',...
    'HorizontalAlignment','left',...
    'Tag','selfrom',...
    'String', ['SELECT grains FROM ''' num2str(length(layers)) '. layer'' WHICH fullfill'],...
    'Position',[b h-b-txth-225 w-2*b txth]);
    
	uicontrol(fig,'Style','edit', ...
    'String',...
    'Enter Expression',...
    'Tag','input',...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1],...
    'FontSize',10,...
    'FontName','Courier New',...
    'Max',2,...
    'Tooltip','Enter a logical expression',...
    'Position',[b h-b-340 w-2*b 100]);
  
  uicontrol(fig,'Style','text',...
    'HorizontalAlignment','left',...
    'String',...
    {'Enter a matlab-like Syntax, it must be a locigal statement',...
     'If a corresponding EBSD-Dataset is set-up, type ''ebsd'' for access',...
     'see grainfun(...)'},...
    'Position',[b h-b-txth-375 w-2*b txth*3]);
  
 
  op = { '==' '~=' '>' '&' '|' '>=' '<' '<=' '&&' '||' '+' '-' '*' '/'};
  btnh = 22;
  btnt = 27;
  for k=1:length(op)
    uicontrol(fig,'Style','pushbutton', 'String',op{k},...
      'Position',[b+mod(k-1,5)*btnt h-175-fix((k-1)/5)*btnh btnt btnh],...
      'Callback',{@(ev,src) insertexp(op{k})});
  end
  
  fl = 65;
    uicontrol(fig,'Style','pushbutton', 'String','Ok',...
    'Position',[w-2*b-3*fl 10 fl 24],'Callback',@ok);


  uicontrol(fig,'Style','pushbutton', 'String','Apply',...
    'Position',[w-2*b-2*fl 10 fl 24],'Callback',@apply);

  uicontrol(fig,'Style','pushbutton', 'String','Cancel',...
    'Position',[w-b-fl 10 fl 24],'Callback','close');

  selector = fig;
 
else
  %set only focus
  feval( get(selector,'type'),double(selector));
end

setappdata(selector,'plot',hFig);



function ok(e,h)

status = evalselection;
if status, close, end


function apply(e,h)
evalselection;


function status = evalselection

status = false;
cFig = gcf;
set(cFig,'Pointer','watch')
drawnow
hFig = getappdata(gcf,'plot');
evalstatement = get(findall(gcf,'Tag','input'),'String');

ly = findall(gcf,'Tag','layer');
ly = length(get(ly,'String'))-get(ly,'Value')+1;
method = get(findall(gcf,'Tag','operation'),'Value');

invoke = getappdata(hFig,'eva');

try
  invoke(hFig,evalstatement,ly,method);
  figure(cFig);
  status = true;
catch  
  figure(cFig);
  errordlg({'An Error occurred during evaluation','please correct your Syntax'});
end

set(cFig,'Pointer','arrow');



function addexp(e,h,p)

ind = get(e,'Value');
txt = get(e,'String');
insertexp( [txt{ind} p] );


function insertexp(expr)

[a b] = curpos;
field = findall(gcf,'Tag','input');
str = get(field,'String');
if strcmpi(str,'Enter Expression'), 
  str = expr;
else
  str = [str(1:a) ' ' expr ' ' str(b+1:end)];
end;


set(field,'String', str);



function [a b] = curpos

try 
  % dirty?
  jFrame = get(gcf,'JavaFrame');
  jFigPanel = get(jFrame,'FigurePanelContainer');
  jRootPane = jFigPanel.getComponent(0);
  jEditPanel = jRootPane.getComponent(18);
  cmpt = handle(jEditPanel.getComponent(0).getComponent(0).getComponent(0),'callbackproperties');
   
  a = cmpt.Caret.getDot;
  b = cmpt.Caret.getMark;
  if ( a > b), [a b] = swap(a,b);end
catch
  a = 0;
  b = 0;
end

function props = evalProperties(layers)

props = cell(1,length(layers));
for k= 1:length(layers)
  props{k} = [num2str(length(layers)-k+1) '. layer'];
end

function updateselectfrom(e,v,k)

selfrom = findall(get(e,'parent'),'Tag','selfrom');
ly = k-get(e,'Value')+1;

set(selfrom,'String', ['SELECT grains FROM ''' num2str(ly) '. layer'' WHICH fullfill']);



function list = functionlist

s1 = what('grain');
s2 = what('polygon');
list = regexprep([s2.m; s1.m], '\.m', '');

ignoreFunctions = {'Contents','centroid','display','eq','get','grain','grainfun','calcODF','copyproperty','misorientation',...
  'hullcentroid','hullprincipalcomponents','joincount','polygon','set','mean',...
  'principalcomponents','plot','plotellipse','plotgrains','plotsubfractions','toebsd','variogram'};

list = list( ~cellfun(@(x) any(strcmpi(x, ignoreFunctions)), list) );



  