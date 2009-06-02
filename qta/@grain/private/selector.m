function selector( h, grains, p )
%% Grain Selector

%the menu
addmenu2(h);

oldtools = verlessThan('matlab','7.5');


%toolsbar
th=findobj(allchild(h),'type','uitoolbar');
if ~any(strcmpi(get(allchild(th),'tag'),'MTEX.grainselector'))
  
  hti = uitoggletool(th,'Tag','MTEX.grainidentify','CData',selectorIcon('identify'),'TooltipString','Identify Grain','OnCallback',{@grainselector,'startidentify'},'OffCallback',{@grainselector,'stopidentify'});
  
  if ~oldtools
    hts = uitogglesplittool(th,'Tag','MTEX.grainselector','CData',selectorIcon('select'),'TooltipString','Select Grains','OnCallback',{@grainselector,'startrecord'},'OffCallback',{@grainselector,'stoprecord'});
    htsm(1) = uimenu(hts,'Label','Single selection','Callback',{@updateSelmode,'single'});
    htsm(2) = uimenu(hts,'Label','Add to current selection','Callback',{@updateSelmode,'add'});
    htsm(3) = uimenu(hts,'Tag','onsel','Label','Remove from current selection','Callback',{@updateSelmode,'rem'});
  else
    hts = uitoggletool(th,'Tag','MTEX.grainselector','CData',selectorIcon('select'),'TooltipString','Select Grains','OnCallback',{@grainselector,'startrecord'},'OffCallback',{@grainselector,'stoprecord'});
   
    menu = findall(allchild(h),'Label','Grains');
    htsm(1) = uimenu(menu,'Label','Single selection','Callback',{@updateSelmode,'single'},'Separator','on');
    htsm(2) = uimenu(menu,'Label','Add to current selection','Callback',{@updateSelmode,'add'});
    htsm(3) = uimenu(menu,'Tag','onsel','Label','Remove from current selection','Callback',{@updateSelmode,'rem'});
  end
  
  htu = uipushtool(th,'Tag','MTEX.grainunselector','CData',selectorIcon('unselect'),'TooltipString','Unselect all Grains','ClickedCallback',@unSelectAll);
  added = [hti hts htu]';
  chlds = allchild(th);  
  justadded = ismember(chlds, added ); 
  chlds = [ chlds(~justadded) ; chlds(justadded)];% permutate positions

  set(chlds(end-length(added)),'Separator','on');
  set(th,'Children',chlds);
end

tts(1) = findall(allchild(th),'Tag','MTEX.grainidentify');
tts(2) = findall(allchild(th),'Tag','MTEX.grainselector');
set(tts,'State','off');

if ~oldtools
    mod = allchild(tts(2));
else
    mod = findall(allchild(h),'Label','Single selection');
end
updateSelmode(mod(end),[],'single')

setappdata(h,'selection',[]);
setappdata(h,'selected',[]);

oldgrains = getappdata(h,'grains');
oldpolygons = getappdata(h,'polygons');
if ~isempty(oldgrains)  
  grains = [oldgrains(:)' grains(:)']; %remove double entries or make layers?
  p = [oldpolygons(:)' p(:)'];
end
setappdata(h,'grains',grains);
setappdata(h,'polygons',p);
setappdata(h,'selectioncolor','r');


updateMenus;


%--------------------------------------------------------------------------
function addmenu2(h)

if any(findall(allchild(h),'Label','Grains')), return, end;
 
  gm = uimenu(h,'Label','Grains');
  gma(1) = uimenu(gm,'Label','Select by Expression','enable','off');
  % TODO grain selector with eval expression
  gma(2) = uimenu(gm,'Tag','onsel','Label','Invert Selection','Callback',@invertSelection);
  gma(3) = uimenu(gm,'Tag','onsel','Label','Unselect all Grains','Callback',@unSelectAll);
  gma(4) = uimenu(gm,'Label','Change selection Color','Callback',@changenSelectionColor);
  gmao = uimenu(gm,'Label','Operations','Separator','on');
  
  gmas(1) = uimenu(gmao,'Label','Convert Selection to Plot','enable','off');
  gmas(2) = uimenu(gmao,'Tag','onsel','Label','Plot ODF','Separator','on','Callback',@plotODFs);
  gmas(3) = uimenu(gmao,'Tag','onsel','Label','Plot ODF with Neighbours','Callback',{@plotODFs,'neighbours'});
  gmas(4) = uimenu(gmao,'Label','Setup corresponding EBSD-Data','Separator','on','Callback',@updateEBSD);
    
  gma(5) = uimenu(gm,'Tag','onsel','Label','Export Selection to Workspace Variable','Separator','on','Callback',@exporttoWS);
  gma(6) = uimenu(gm,'Label','Export Selection to M-File via Clipboard','enable','off');
  
  mnchlds = allchild(h);  
  mnchlds = [mnchlds(2:end-1) ; mnchlds(1) ; mnchlds(end)]; % permutate positions
  set(gcf,'Children',mnchlds)


%--------------------------------------------------------------------------
function changenSelectionColor(empt,eventdata)

c = uisetcolor;
if length(c)>1
  setappdata(gcf,'selectioncolor',c);
  updateSelectionPlot('color');
end

%--------------------------------------------------------------------------
function updateSelmode(hObject,eventdata,mode)

set(allchild(get(hObject,'Parent')),'Checked','off');
set(hObject,'Checked','on');
 
setappdata(gcf,'selmode', mode);


%--------------------------------------------------------------------------
function [h sel] = spatialSelection(empt,eventdata,modus) %#ok<INUSL>

grains = getappdata(gcf,'grains');
p = getappdata(gcf,'polygons');
hs = getappdata(gcf,'selection');
ks = getappdata(gcf,'selected');

cp = get(gca,'CurrentPoint');
xp = cp(1,1);
yp = cp(1,2);

pl = cellfun('length',{p.xy});
cpl = [0 cumsum(pl)];

xy = vertcat(p.xy);
[X Y] = fixMTEXscreencoordinates( xy(:,1), xy(:,2) );

dist = sqrt((X-xp).^2 + (Y-yp).^2);
[dist ndx] = sort(dist);
pp =  ndx(1:10);

for k=length(pl):-1:1
	if any( cpl(k)+1 < pp & cpl(k+1) > pp)
  	[X Y] = fixMTEXscreencoordinates( p(k).xy(:,1), p(k).xy(:,2) );
    if inpolygon(xp,yp,X,Y) 
      switch modus
        case 'record'
          mode = getappdata(gcf,'selmode');
          switch mode
            case 'single'
              setappdata(gcf,'selected',k);
            case 'add'
              if ~any(ks == k)
                setappdata(gcf,'selected',[ks k]);
              end
            case 'rem'    
              ls = ks ~= k;
              if any(~ls)
                setappdata(gcf,'selected',ks(ls));            
              end
          end
        case 'ident'
          c = getappdata(gcf,'selectioncolor');          
          
          hold on
            h = fill(X,Y,c); drawnow;            
            pause(0.1);
            delete(h); drawnow;
            pause(0.1);
            h = fill(X,Y,c); drawnow; 
            pause(0.1);
            delete(h); drawnow;
            
            pause(0.1);
            waitfor(h);
          
            identdlg( grains(k) )
            return
      end
      
      updateSelectionPlot;
      updateMenus;
      return
    end
  end
end

%--------------------------------------------------------------------------
function unSelectAll(empt,eventdata)

setappdata(gcf,'selected',[]);
updateSelectionPlot;
updateMenus;

%--------------------------------------------------------------------------
function [h sel] = invertSelection(empt,eventdata)

k = getappdata(gcf,'selected');
grains = getappdata(gcf,'grains');
setappdata(gcf,'selected', find(~ismember(1:length(grains),k)));

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

c = getappdata(gcf,'selectioncolor');

if check_option(varargin,'color')
  set(getappdata(gcf,'selection'),'Color',c);
  return
end

delete(getappdata(gcf,'selection')); %clean up previous




p = getappdata(gcf,'polygons');
ks = getappdata(gcf,'selected');
p = p(ks); %restrict to needed

if ~numel(p),
  setappdata(gcf,'selection',[]);
  return, end; %nothing to do

xy = cell2mat(arrayfun(@(x) [x.xy ; NaN NaN],p,'UniformOutput',false));
[X Y] = fixMTEXscreencoordinates( xy(:,1), xy(:,2) );

hold on

h(1) = plot(X(:),Y(:),'color',c,'linewidth',2); 

holes = ~cellfun('isempty',{p.hxy});
if any(holes)
   xy = cell2mat(arrayfun( @(x) ...
        cell2mat(cellfun(@(h) [h;  NaN NaN], x.hxy,'uniformoutput',false)') ,...
        p(holes),'uniformoutput',false));
      
  [X,Y] = fixMTEXscreencoordinates(xy(:,1),xy(:,2));
  h(2) = plot(X(:),Y(:),'color',c,'linewidth',1);
end

hold off


setappdata(gcf,'selection',h);


%--------------------------------------------------------------------------
function grainselector(hObject, eventdata,state)

hP = get(hObject,'Parent');

tts(1) = findall(allchild(hP),'Tag','MTEX.grainidentify');
tts(2) = findall(allchild(hP),'Tag','MTEX.grainselector');

switch state
  case 'startidentify'     
    set(tts(2),'State','off');
    set(gcf,'WindowButtonDownFcn',{@spatialSelection,'ident'})
    set(gcf,'Pointer','custom','PointerShapeCData',selectorIcon('ident'));
  case 'stopidentify'
    set(gcf,'WindowButtonDownFcn',[])
    set(gcf,'Pointer','arrow')
  case 'startrecord'        
    set(tts(1),'State','off')
    set(gcf,'WindowButtonDownFcn',{@spatialSelection,'record'})
    set(gcf,'Pointer','cross')
  case 'stoprecord'
    set(gcf,'WindowButtonDownFcn',[])
    set(gcf,'Pointer','arrow')
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
disp(['  holes:        ' yesno{hasholes(grain)+1}])
disp(['  subfractions: ' yesno{hassubfraction(grain)+1}])

disp(' ')

%--------------------------------------------------------------------------
function exporttoWS(e, h)

ks = getappdata(gcf,'selected');
grains = getappdata(gcf,'grains'); 
name = inputdlg({'Enter Variable name:'},'Grains to Workspace',1,{'grain_selection'});
  if ~isempty(name), assignin('base', name{1}, grains(ks) ); end
  
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
function plotODFs(e,h,varargin)
    
ebsd = getappdata(gcf,'ebsd');
if isempty(ebsd)
 ebsd = updateEBSD;
end

grains = getappdata(gcf,'grains');
grains = grains(getappdata(gcf,'selected'));
      
types = {'SIGMA','ALPHA','GAMMA','PHI1','PHI2'};
[sel2, ok] = listdlg('Name','Plotting options',...
  'SelectionMode','single',...
  'ListSize',[170 70],...
  'PromptString','Plot type','ListString',types,'fus',2,'ffs',2);      
if ok, 
   oldfig = gcf;
   figure
   eb = get(ebsd,grains);      
        
   if check_option(varargin,'neighbours')
     org_grains = getappdata(oldfig,'grains');
     org_grains = org_grains(ismember(vertcat(org_grains(:).id),vertcat(grains(:).neighbour)));
          
     pha = get(eb,'phase');
     phb = get(ebsd,'phase');         
          
     eb2 = get(ebsd(phb == pha(1)),org_grains);          
        
     plot(eb2,types{sel2},'SECTIONS',6,'markercolor','r','MarkerSize',1); 
   end
      
   hold on, plot(eb,types{sel2},'SECTIONS',6); 
end

