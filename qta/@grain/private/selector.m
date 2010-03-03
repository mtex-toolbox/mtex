function selector( h, grains, p,lya )
%% Grain Selector

% convert to cells for layers



if nargin == 1
  

  %the menu
  addmenu2(h);

  % check whether tools already exists
  th=findobj(allchild(h),'type','uitoolbar');
  ly2 = getappdata(th, 'childhandles');
  for k=1:length(ly2)
    if  strcmpi(get(ly2(k),'Name'), 'MTEX.combolayer') && ishold      
      return
    end
  end
  
  
  set(h,'Toolbar','none')
  set(h,'Toolbar','figure')
  delete(uigettool(gcf,'Exploration.Brushing')) % 
  %toolsbar
  th=findobj(allchild(h),'type','uitoolbar');

  htk = uitoggletool(th,'Tag','MTEX.layervis','CData',selectorIcon('layer'),'TooltipString','Layer Visebility','OnCallback',{@grainselector,'show_layer'},'OffCallback',{@grainselector,'hide_layer'});

  jcb1 =javax.swing.JComboBox({''});
  jcb1.setMaximumSize(java.awt.Dimension(100,22));
%   
  ly2 = javacomponent(jcb1,[],th); 
  
  set(ly2,'Name','MTEX.combolayer')
  set(ly2,'ItemStateChangedCallback',{@layerSelChanged})

  hti = uitoggletool(th,'Tag','MTEX.grainidentify','CData',selectorIcon('identify'),'Separator','on','TooltipString','Identify Grain','OnCallback',{@grainselector,'startidentify'},'OffCallback',{@grainselector,'stopidentify'});

  oldtools = verLessThan('matlab','7.5');

  if ~oldtools
    hts = uitogglesplittool(th,'Tag','MTEX.grainselector','CData',selectorIcon('select'),'TooltipString','Select Grains','OnCallback',{@grainselector,'startrecord'},'OffCallback',{@grainselector,'stoprecord'});
    htsm(1) = uimenu(hts,'Tag','MTEX.selmode','Label','Single selection','Callback',{@updateSelmode,'single'});
    htsm(2) = uimenu(hts,'Tag','MTEX.selmode','Label','Add to current selection','Callback',{@updateSelmode,'add'});
    htsm(3) = uimenu(hts,'Tag','MTEX.selmode','Tag','onsel','Label','Remove from current selection','Callback',{@updateSelmode,'rem'});
     
    htp = uitogglesplittool(th,'Tag','MTEX.polygonselector','CData',selectorIcon('polygonal'),'TooltipString','Unselect all Grains','OnCallback',{@grainselector,'startpolygonrecord'},'OffCallback',{@grainselector,'stoppolygonrecord'});
    htsm(1) = uimenu(htp,'Tag','MTEX.pselmode','Label','Centroid within','Callback',{@updateSelP,'centroids'});
    htsm(2) = uimenu(htp,'Tag','MTEX.pselmode','Label','Complete within','Callback',{@updateSelP,'complete'});
    htsm(3) = uimenu(htp,'Tag','MTEX.pselmode','Label','Intersects','Callback',{@updateSelP,'intersect'});
       
    htsm(4) = uimenu(htp,'Tag','MTEX.selmode','separator','on','Label','Single selection','Callback',{@updateSelmode,'single'});
    htsm(5) = uimenu(htp,'Tag','MTEX.selmode','Label','Add to current selection','Callback',{@updateSelmode,'add'});
    htsm(6) = uimenu(htp,'Tag','MTEX.selmode','Tag','onsel','Label','Remove from current selection','Callback',{@updateSelmode,'rem'});
    htsm(7) = uimenu(htp,'separator','on','Tag','MTEX.exportselpoly','Label','Export last Polygon to Workspace','Enable','off','Callback',@exportLastState);
  else
    hts = uitoggletool(th,'Tag','MTEX.grainselector','CData',selectorIcon('select'),'TooltipString','Select Grains','OnCallback',{@grainselector,'startrecord'},'OffCallback',{@grainselector,'stoprecord'});
    htp = uitoggletool(th,'Tag','MTEX.polygonselector','CData',selectorIcon('polygonal'),'TooltipString','Unselect all Grains','OnCallback',{@grainselector,'startpolygonrecord'},'OffCallback',{@grainselector,'stoppolygonrecord'});
 
    menu = findall(allchild(h),'Label','Grains');
    if isempty(findall(menu,'Label','Single selection'))
      htsm(1) = uimenu(menu,'Tag','MTEX.selmode','Label','Single selection','Callback',{@updateSelmode,'single'},'Separator','on');
      htsm(2) = uimenu(menu,'Tag','MTEX.selmode','Label','Add to current selection','Callback',{@updateSelmode,'add'});
      htsm(3) = uimenu(menu,'Tag','MTEX.selmode','Tag','onsel','Label','Remove from current selection','Callback',{@updateSelmode,'rem'});
            
      htsm(4) = uimenu(menu,'Tag','MTEX.pselmode','Label','Polygon Centroid within','separator','on','Callback',{@updateSelP,'centroids'});
      htsm(5) = uimenu(menu,'Tag','MTEX.pselmode','Label','Polygon Complete within','Callback',{@updateSelP,'complete'});
      htsm(6) = uimenu(menu,'Tag','MTEX.pselmode','Label','Polygon Intersects','Callback',{@updateSelP,'intersect'});
      htsm(7) = uimenu(menu,'separator','on','Tag','MTEX.exportselpoly','Label','Export last Polygon to Workspace','Enable','off','Callback',@exportLastState);
    end
  end
  
  htu = uipushtool(th,'Tag','MTEX.grainunselector','CData',selectorIcon('unselect'),'TooltipString','Unselect all Grains','ClickedCallback',@unSelectAll);
  
 
  chlds = allchild(th);
  added = [htk hti hts htu htp]'; 
  justadded = ismember(chlds, added ); 
  chlds = [ chlds(~justadded) ; chlds(justadded)];% permutate positions
  set(th,'Children',chlds);
  set(chlds(end-length(added)),'Separator','on');
  

  set([hti hts],'State','off');

    if ~oldtools
        mod = allchild(hts);
        mod2 = allchild(htp);
    else
        mod = findall(allchild(h),'Label','Single selection');
        mod2 = findall(allchild(h),'Label','Polygon Centroid within');
    end

  updateSelmode(mod(end),[],'single');
  updateSelP(mod2(end),[],'centroids');


  set(h,'CloseRequestFcn',@closeit);

 
else
  newlayer.grains = grains;
  newlayer.polygon = p;
  newlayer.boxes   = get(p,'envelope');
  newlayer.selected = false(size(grains));
  newlayer.selectioncolor = 'r';
  newlayer.handles = lya;
  
  
  layers = getappdata(h,'layers');
  if isempty(layers)
    layers = newlayer;
  else  
    layers = [layers newlayer];
  end
  setappdata(h,'layers',layers);
  setappdata(h,'currentlayer',length(layers));

  updateSelectionPlot;
  updateMenus;
  setVisStatus('on') 
  
  if ~isempty(layers)
    th=findobj(allchild(h),'type','uitoolbar');

    n=length({layers.grains});

    ly2 = getappdata(th, 'childhandles');
    for k=1:length(ly2)
      if  strcmpi(get(ly2(k),'Name'), 'MTEX.combolayer')
        ly2(k).removeAllItems;
        for l=1:n,          
          t = [num2str(n-l+1) '. layer'];  
          ly2(k).addItem(t)
        end
      end
    end
  end
  
  
  
end


%--------------------------------------------------------------------------
function addmenu2(h)

if any(findall(allchild(h),'Label','Grains')), return, end;
 
  gm = uimenu(h,'Label','Grains');
  uimenu(gm,'Label','Select by Expression','Callback',@selectByExpression);
  % TODO grain selector with eval expression
  uimenu(gm,'Tag','onsel','Label','Invert Selection of Current Layer','Callback',@invertSelection);
  uimenu(gm,'Tag','onsel','Label','Unselect all Grains of Current Layer','Callback',@unSelectLayer);
  uimenu(gm,'Tag','onsel','Label','Unselect all Grains','Callback',@unSelectAll);
  uimenu(gm,'Label','Change Layer-Selection Color','Callback',@changenSelectionColor);
  
  gmao = uimenu(gm,'Label','Operations on Layer-Selection','Separator','on');
  uimenu(gmao,'Tag','onsel','Label','Convert Selection to Plot','Callback',@extracttolayer);
  uimenu(gmao,'Tag','onsel','Separator','on','Label','Plot ODF','Callback',@plotODFs);
  uimenu(gmao,'Tag','onsel','Label','Plot PDF','Callback',@plotPDFs);
  uimenu(gmao,'Tag','onsel','Label','Plot in Rodrigues Space','Callback',@plotRodrigues);
  
  uimenu(gm,'Label','Setup corresponding EBSD-Data','Separator','on','Callback',@updateEBSD);
  uimenu(gm,'Tag','onsel','Label','Export Selection to Workspace Variable','Separator','on','Callback',@exporttoWS);
 % gma(6) = uimenu(gm,'Label','Export Selection to M-File via Clipboard','enable','off');
  
  % let be the grain menu on second position
  mnchlds = allchild(h);
  p = findall(mnchlds,'Tag','figMenuFile');  
  mnchlds = [mnchlds(2:find(p == mnchlds)-1) ; mnchlds(1) ; p]; % permutate positions
  set(gcf,'Children',mnchlds)

function layerSelChanged(e,h)

layer = getcurrentlayer;
state = get(layer.handles,'Visible');
if iscell(state), state = state{1};end

setVisStatus(state);
setappdata(gcf,'currentlayer', get(e,'ItemCount')-get(e,'SelectedIndex'))


function setVisStatus(state)

f = findall(gcf,'Tag','MTEX.layervis');

layer = getcurrentlayer;
% hs = getappdata(gcf,'layer');
set(layer.handles,'Visible',state);
set(f,'State',state);  
  
%--------------------------------------------------------------------------
function changenSelectionColor(empt,eventdata)

c = uisetcolor;
if length(c)>1  
  layers = getappdata(gcf,'layers');
  l = getappdata(gcf,'currentlayer');
  layers(l).selectioncolor = c; 
  setappdata(gcf,'layers',layers);
  updateSelectionPlot;
end

%--------------------------------------------------------------------------
function updateSelmode(hObject,eventdata,mode)

set(findall(gcf,'Tag','MTEX.selmode'),'Checked','off');
set(findall(gcf,'Label',get(hObject,'Label')),'Checked','on');
setappdata(gcf,'selmode', mode);


function updateSelP(hObject,eventdata,mode)

set(findall(gcf,'Tag','MTEX.pselmode'),'Checked','off');
set(hObject,'Checked','on');
 
setappdata(gcf,'pselmode', mode);


function selectByExpression(hObject,eventdata)

hFig = gcf;
% layers = getappdata(hFig,'layers');

h = selectorExp(hFig);
setappdata(hFig,'eva',@evalByExpression);
setappdata(hFig,'evafig',h);



function evalByExpression(hFig, evalstatement, ly,method)

layers = getappdata(hFig,'layers');
l = getappdata(hFig,'currentlayer');
ebsd = getappdata(hFig,'ebsd');
% ks = getappdata(hFig,'selected');

grains = layers(l).grains;
% grains = grains{ly}; %selected layer

ind =  eval( evalstatement );

if ~islogical(ind), error, end;

switch method
  case 1 
    layers(l).selected      = false(size( layers(l).selected ));
    layers(l).selected(ind) = true; 
  case 2
    layers(l).selected(ind) = true; 
  case 3
    layers(l).selected(ind) = false; 
  case 4
    layers(l).selected = layers(l).selected & ind; 
end

setappdata(hFig,'layers',layers);

figure(hFig);
updateSelectionPlot;
updateMenus;


function closeit(e,h)

try, delete(getappdata(gcf,'evafig')), catch, end

delete(gcbf);




function [layer l] = getcurrentlayer

layers = getappdata(gcf,'layers');
l = getappdata(gcf,'currentlayer');

layer = layers(l);

% function [grains p ks ly tks] = getcurrentlayer
% 
% 
% layers = getappdata(gcf,'layers');
% l = getappdata(gcf,'currentlayer');
% 
% layers(l)


% grains = getappdata(gcf,'grains');
% p = getappdata(gcf,'polygons');
% tks = getappdata(gcf,'selected');
% ly = getappdata(gcf,'currentlayer');
% ks = tks{ly};
% grains = grains{ly};
% p = p{ly};

%--------------------------------------------------------------------------
function [h sel] = spatialSelection(src,eventdata,modus) %#ok<INUSL>


layer = getcurrentlayer;
grains = layer.grains;
p = layer.polygon;

cp = get(gca,'CurrentPoint');
[xp yp] = fixMTEXscreencoordinates( cp(1,1), cp(1,2) );

xy = layer.boxes;

candits = xy(:,1) <= xp & xp <= xy(:,2) & xy(:,3) <= yp & yp <= xy(:,4);
candits = find(candits);

isit = false(size(candits));
for k=1:length(candits)
  pl = p(candits(k));
  
  inhole = false;
  
  h = hashole(pl);
  if any(h)
    hp = get(pl,'holes');
    
    
    for l=1:length(hp)
      hxy = get(hp(l),'xy');
      inhole = inhole | inpolygon(xp,yp,hxy(:,1),hxy(:,2));
    end
  end
  
  if ~inhole
    xy = get(pl,'xy');
    isit(k) = inpolygon(xp,yp,xy(:,1),xy(:,2));
  end
end

current = candits(isit);

switch modus
  case 'record'
    if strcmpi(get(src,'SelectionType'),'alt'),
      treatSelmode(current,'rem'); 
    else
      treatSelmode(current);
    end
  case 'ident'
    c = getappdata(gcf,'selectioncolor');     
        
    identdlg( grains(current) );
    xy = get(p(current),'xy');
    [X Y] = fixMTEXscreencoordinates( xy(:,1), xy(:,2) ); 
    h = patch(X,Y,layer.selectioncolor); pause(0.1);
    delete(h); pause(0.1);
    h = patch(X,Y,layer.selectioncolor); pause(0.1);
    delete(h); pause(0.1);
    waitfor(h);
        
    return
end

updateSelectionPlot;
updateMenus;

return

function treatSelmode(current,alt)


layers = getappdata(gcf,'layers');
t = getappdata(gcf,'currentlayer');
mode = getappdata(gcf,'selmode');
% 
if nargin > 1 
  mode = alt;
end
switch mode
  case 'single'
    layers(t).selected = false(size(layers(t).selected));
    layers(t).selected(current) = true;
  case 'add'
    layers(t).selected(current) = true;
  case 'rem'
    layers(t).selected(current) = false;
end

setappdata(gcf,'layers',layers)


%--------------------------------------------------------------------------
function unSelectAll(empt,eventdata)

layers = getappdata(gcf,'layers');

for k=1:length(layers)
  layers(k).selected = false(size(layers(k).selected));
end
setappdata(gcf,'layers',layers);
cleanupPolygonSelection;

updateSelectionPlot;
updateMenus;

%--------------------------------------------------------------------------
function unSelectLayer(empt,eventdata)

% [grains p ks ly tks] = getcurrentlayer; 
layers = getappdata(gcf,'layers');
l = getappdata(gcf,'currentlayer');
layers(l).selected = false(size(layers(l).selected));

setappdata(gcf,'layers',layers);
updateSelectionPlot;
updateMenus;


%--------------------------------------------------------------------------
function [h sel] = invertSelection(empt,eventdata)

layers = getappdata(gcf,'layers');
l = getappdata(gcf,'currentlayer');
layers(l).selected = ~layers(l).selected;

setappdata(gcf,'layers',layers);

updateSelectionPlot;
updateMenus;

%--------------------------------------------------------------------------
function updateMenus(empt,eventdata)

hs = getappdata(gcf,'selection');
ks = getappdata(gcf,'selected');

if ~isempty(hs), state = 'on'; else state = 'off'; end

treat = [findall(gcf,'Tag','onsel'); findall(gcf,'Tag','MTEX.grainunselector')];
set(treat,'enable',state);




%--------------------------------------------------------------------------
function updateSelectionPlot(varargin)

layers = getappdata(gcf,'layers');
delete(getappdata(gcf,'selection'));

h = [];
for k=1:length(layers)
  p = layers(k).polygon(layers(k).selected);
  
  if ~isempty(p)
    h(end+1) = plot(p,'noholes','color',layers(k).selectioncolor,'linewidth',2,'nofix');
    
    p = p(hashole(p));
    if ~isempty(p)
      h(end+1) = plot(get(p,'holes'),'noholes','color',layers(k).selectioncolor,'linewidth',1,'nofix');
    end
  end
end
setappdata(gcf,'selection',h);




%--------------------------------------------------------------------------
function grainselector(hObject, eventdata,state)

activateuimode(gcf,[]);

hP = get(hObject,'Parent');
tts(1) = findall(allchild(hP),'Tag','MTEX.grainidentify');
tts(2) = findall(allchild(hP),'Tag','MTEX.grainselector');
tts(3) = findall(allchild(hP),'Tag','MTEX.polygonselector');

switch state
  
  case 'startidentify'    
    set(tts(2:3),'State','off');
    set(gcf,'WindowButtonDownFcn',{@spatialSelection,'ident'});
    set(gcf,'Pointer','custom','PointerShapeCData',selectorIcon('ident'));
  case 'stopidentify'
    set(gcf,'WindowButtonDownFcn',[]);
    set(gcf,'Pointer','arrow');
  case 'startrecord'        
    set(tts([1 3]),'State','off');
    set(gcf,'WindowButtonDownFcn',{@spatialSelection,'record'});
    set(gcf,'Pointer','cross');
  case 'stoprecord'
    set(gcf,'WindowButtonDownFcn',[])
    set(gcf,'Pointer','arrow');
  case 'startpolygonrecord'        
    set(tts(1:2),'State','off');
    set(gcf,'WindowButtonDownFcn',{@polygonSelection,'complete'});
    set(gcf,'WindowButtonMotionFcn',{@polygonSelection,'lastline'});
    set(gcf,'Pointer','crosshair');    
    setappdata(gcf,'selector_ply',[]);
  case 'stoppolygonrecord'
    set(gcf,'WindowButtonDownFcn',[])
    set(gcf,'WindowButtonMotionFcn',[]);
    set(gcf,'Pointer','arrow');
    setappdata(gcf,'selector_ply',[]);
  case 'hide_layer'
    setVisStatus('off');
  case 'show_layer'
    setVisStatus('on');    
end


%--------------------------------------------------------------------------
function identdlg(grain)

pos = get(gca,'CurrentPoint');

disp(['on (x,y): ' num2str( pos(1,1:2))])

  checksums = ['grain_id'  dec2hex(grain.checksum)];  
disp(['  grain id: ' num2str(grain.id)])
disp(['  from grainset: ' checksums ])
disp('---------------------------------')
disp(['  area:         ' num2str(area(grain))])
disp(['  perimeter:    ' num2str(perimeter(grain))])
yesno = {'no','yes'};
disp(['  holes:        ' yesno{hashole(grain)+1}])
disp(['  subfractions: ' yesno{hassubfraction(grain)+1}])

props = fields(grain.properties);
if ~isempty(props)
  for k=1:length(props)
    p = grain.properties.(props{k});
    if isa(p,'quaternion')
        disp(['  ' props{k} ':   quaternion(' num2str(double(grain.properties.orientation),'%1.4f ') ')']);
    elseif isa(p,'double')
        disp(['  ' props{k} ':  ' num2str(p)]);
    end
  end
end

disp(' ')

%--------------------------------------------------------------------------
function exporttoWS(e, h)

[layer l]= getcurrentlayer;
name = inputdlg({'Enter Variable name:'},'Grains to Workspace',1,{['grain_selection_layer_' num2str(l)]});
  if ~isempty(name), assignin('base', name{1}, layer.grains(layer.selected) ); end
  

%--------------------------------------------------------------------------
function ebsd = updateEBSD(e,h)  

vars = evalin('base','who');
pre = cellfun(@(x) isa(evalin('base',x),'EBSD'), vars);
vars = vars(pre);

[sel ok] = listdlg('Name','Select EBSD',...
  'PromptString','choose the associated EBSD-Data',...
  'ListString',vars,'ListSize',[170 70],...
  'SelectionMode','single','fus',2,'ffs',2);
if ok
  ebsd = evalin('base', vars{sel});
  setappdata(gcf,'ebsd',ebsd);
end

 
%--------------------------------------------------------------------------
function obj = choosePlotObject(varargin)

obj = [];

layer = getcurrentlayer;
grains1 = layer.grains(layer.selected);

props = [grains1.properties];
propnames = fieldnames(props);
odf_pos = find(cellfun('isclass',struct2cell(props(1)),'ODF'));

if ~isempty(odf_pos) && ~check_option(varargin,'ebsd')
  types = strcat('property : ', propnames(odf_pos));
   
  ebsd = getappdata(gcf,'ebsd');
  if ~isempty(ebsd)
    types = [types ;{'corresponding EBSD'}];
  end
 
  [sel2, ok] = listdlg('Name','Plot Object',...
  'SelectionMode','single',...
  'ListSize',[170 70],...
  'PromptString','Object','ListString',types,'fus',2,'ffs',2);  

  if ok
    if sel2 > length(odf_pos)
      obj = link(ebsd,grains1);
    else
      obj = [ props.(propnames{odf_pos(sel2)}) ];
    end
  end
else
  ebsd = getappdata(gcf,'ebsd');
  if isempty(ebsd)
   ebsd = updateEBSD;
  end
  obj = link(ebsd,grains1);
end

%--------------------------------------------------------------------------
function plotPDFs(e,h,varargin)
 
obj = choosePlotObject;
 
if ~isempty(obj)
  f = figure; plotpdf(obj,Miller(0,0,1));
  set(f,'renderer','opengl');
end

%--------------------------------------------------------------------------
function plotODFs(e,h,varargin)
    
obj = choosePlotObject;

if ~isempty(obj)
  types = {'SIGMA','ALPHA','GAMMA','PHI1','PHI2'};
  [sel2, ok] = listdlg('Name','Plotting options',...
    'SelectionMode','single',...
    'ListSize',[170 70],...
    'PromptString','Plot type','ListString',types,'fus',2,'ffs',2);   

  if ok,
    f = figure;
    hold on, plot(obj,types{sel2},'SECTIONS',6); 
  end  
end

%--------------------------------------------------------------------------
function plotRodrigues(e,h,varargin)
 
obj = choosePlotObject('ebsd');

if ~isempty(obj)
  f = figure;  plot(obj,'rodrigues');
  set(f,'renderer','opengl');
end

%--------------------------------------------------------------------------
function extracttolayer(src,h)

layer = getcurrentlayer;

ih = ishold;
if ~ih, hold on; end
  plotgrains( layer.grains, 'color', layer.selectioncolor);
if ~ih, hold off; end


function polygonSelection(src,h,lastline)

cp = get(gca,'CurrentPoint');
xp = cp(1,1);
yp = cp(1,2);

pys = getappdata(gcf,'selector_ply');

if strcmp(lastline,'lastline')
  updateLastLine(pys, xp, yp);
  return
end

if strcmpi(get(src,'SelectionType'),'alt')
  if length(pys)>2    
    if (pys(1,:) ~= pys(end,:))
      pys(end+1,:) =  pys(1,:);
    end
       
    updateLastState(pys);
    updatePolyLine(pys);
        
    pys = [];
   
    updateLastLine(pys, xp, yp)
  end
else  
  pys(end+1,:) = [xp,yp];
  
  updatePolyLine(pys);
end
setappdata(gcf,'selector_ply',pys);


function updatePolyLine(pys)

ply_h = getappdata(gcf,'selector_ply_handle');
if ~isempty(pys)
  if ~isempty(ply_h)
    set(ply_h,'XData',pys(:,1), 'YData',pys(:,2))
  else
    ply_h = line('XData',pys(:,1), 'YData',pys(:,2),'color','r','Marker','o','MarkerSize',3);
  end
end
setappdata(gcf,'selector_ply_handle',ply_h);


function updateLastLine(pys, xp, yp)

ll = getappdata(gcf,'lastline');
  
if ~isempty(ll) && ~isempty(pys)
  set(ll,'XData',[pys(end,1) xp],'YData',[pys(end,2) yp ],'Color','r');
elseif ~isempty(pys)
 ll = line('XData',[pys(end,1) xp],'YData',[pys(end,2) yp ],'Color','r');
 setappdata(gcf,'lastline',ll);
else
 delete(ll);
 setappdata(gcf,'lastline',[]);
end  

function updateLastState(pys)

setappdata(gcf,'selector_ply_last',pys);

if ~isempty(pys)
  [xy(:,1),xy(:,2)] = fixMTEXscreencoordinates(pys(:,1),pys(:,2));

  layer = getcurrentlayer;
  ind = inpolygon(layer.polygon,xy,getappdata(gcf,'pselmode'));
%   [grains ind] = inpolygon(layer.polygon,xy,getappdata(gcf,'pselmode'));

  treatSelmode(find(ind));
  
  set(findall(gcf,'Tag','MTEX.exportselpoly'),'Enable','on')
else
  set(findall(gcf,'Tag','MTEX.exportselpoly'),'Enable','off')
end
 
updateSelectionPlot;
updateMenus;

function cleanupPolygonSelection

ply_h = getappdata(gcf,'selector_ply_handle');
updateLastState([])
if ~isempty(ply_h),
  delete(ply_h); 
  setappdata(gcf,'selector_ply_handle',[]); 
end


function exportLastState(e, h)

pys = getappdata(gcf,'selector_ply_last');
pys = polygon(pys);

hh = figure('visible','off'); % bad, but apparently nescessary if polygon mode active
name = inputdlg({'Enter Variable name:'},'last Polygon to Workspace',1,{'polygon_selection'});
if ~isempty(name), assignin('base', name{1}, pys); end

close(hh)

