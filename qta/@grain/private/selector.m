function selector( h, grains, p )
%% Grain Selector

% convert to cells for layers
grains = {grains};
p = {p};
c = {'r'};
oldgrains = getappdata(h,'grains');

if ~isempty(oldgrains) 
  % select 
  oldpolygons = getappdata(h,'polygons');
  c =  [c getappdata(h,'selectioncolor')];
  grains = [grains oldgrains ]; %remove double entries or make layers?
  p = [ p oldpolygons];
end

%the menu
addmenu2(h);

% 
set(h,'Toolbar','none')
set(h,'Toolbar','figure')
delete(uigettool(gcf,'Exploration.Brushing')) % 
%toolsbar
th=findobj(allchild(h),'type','uitoolbar');

  img=im2java(selectorIcon('layer')); 
  icon=javax.swing.ImageIcon(img);
  label=javax.swing.JLabel(icon);
  label.setMinimumSize(java.awt.Dimension(24,22));

  
  fd = cell(1,length(grains));
  for k= 1:length(grains)
    fd{k} = [num2str(length(grains)-k+1) '. layer'];
  end
  
  jcb1 =javax.swing.JComboBox(fd);
  jcb1.setMaximumSize(java.awt.Dimension(100,22));
      
  ly1 = javacomponent(label,[],th);
  ly2 = javacomponent(jcb1,[],th); 
  set(ly2,'ItemStateChangedCallback',{@(e,h)setappdata(gcf,'currentlayer',length(grains)-get(e,'SelectedIndex'));})

  hti = uitoggletool(th,'Tag','MTEX.grainidentify','Separator','on','CData',selectorIcon('identify'),'TooltipString','Identify Grain','OnCallback',{@grainselector,'startidentify'},'OffCallback',{@grainselector,'stopidentify'});

  oldtools = verLessThan('matlab','7.5');

  if ~oldtools
    hts = uitogglesplittool(th,'Tag','MTEX.grainselector','CData',selectorIcon('select'),'TooltipString','Select Grains','OnCallback',{@grainselector,'startrecord'},'OffCallback',{@grainselector,'stoprecord'});
    htsm(1) = uimenu(hts,'Label','Single selection','Callback',{@updateSelmode,'single'});
    htsm(2) = uimenu(hts,'Label','Add to current selection','Callback',{@updateSelmode,'add'});
    htsm(3) = uimenu(hts,'Tag','onsel','Label','Remove from current selection','Callback',{@updateSelmode,'rem'});
  else
    hts = uitoggletool(th,'Tag','MTEX.grainselector','CData',selectorIcon('select'),'TooltipString','Select Grains','OnCallback',{@grainselector,'startrecord'},'OffCallback',{@grainselector,'stoprecord'});
   
    menu = findall(allchild(h),'Label','Grains');
    if isempty(findall(menu,'Label','Single selection'))
      htsm(1) = uimenu(menu,'Label','Single selection','Callback',{@updateSelmode,'single'},'Separator','on');
      htsm(2) = uimenu(menu,'Label','Add to current selection','Callback',{@updateSelmode,'add'});
      htsm(3) = uimenu(menu,'Tag','onsel','Label','Remove from current selection','Callback',{@updateSelmode,'rem'});
    end
  end
  
  htu = uipushtool(th,'Tag','MTEX.grainunselector','CData',selectorIcon('unselect'),'TooltipString','Unselect all Grains','ClickedCallback',@unSelectAll);
   
  chlds = allchild(th);
  added = [hti hts htu]'; 
  justadded = ismember(chlds, added ); 
  chlds = [ chlds(~justadded) ; chlds(justadded)];% permutate positions
  set(th,'Children',chlds);
  set(chlds(end-length(added)),'Separator','on');
  

set([hti hts],'State','off');

  if ~oldtools
      mod = allchild(hts);
  else
      mod = findall(allchild(h),'Label','Single selection');
  end
  
updateSelmode(mod(end),[],'single');

k = cell(size(grains));
setappdata(h,'selected',k);
setappdata(h,'selectioncolor',c);

setappdata(h,'grains',grains);
setappdata(h,'polygons',p);

setappdata(h,'currentlayer',length(grains));

updateSelectionPlot;
updateMenus;




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
  uimenu(gmao,'Label','Convert Selection to Plot','Callback',@extracttolayer);
  uimenu(gmao,'Tag','onsel','Label','Plot ODF','Separator','on','Callback',@plotODFs);
  uimenu(gmao,'Tag','onsel','Label','Plot ODF with Neighbours','Callback',{@plotODFs,'neighbours'});
  uimenu(gmao,'Tag','onsel','Label','Variogram on Property','Separator','on','Callback',@variogrammplot);
  
  uimenu(gm,'Label','Setup corresponding EBSD-Data','Separator','on','Callback',@updateEBSD);
  uimenu(gm,'Tag','onsel','Label','Export Selection to Workspace Variable','Separator','on','Callback',@exporttoWS);
 % gma(6) = uimenu(gm,'Label','Export Selection to M-File via Clipboard','enable','off');
  
  % let be the grain menu on second position
  mnchlds = allchild(h);
  p = findall(mnchlds,'Tag','figMenuFile');  
  mnchlds = [mnchlds(2:find(p == mnchlds)-1) ; mnchlds(1) ; p]; % permutate positions
  set(gcf,'Children',mnchlds)


%--------------------------------------------------------------------------
function changenSelectionColor(empt,eventdata)

c = uisetcolor;
if length(c)>1
  co = getappdata(gcf,'selectioncolor');
  ly = getappdata(gcf,'currentlayer');
  co{ly} = c; 
  setappdata(gcf,'selectioncolor',co);
  updateSelectionPlot;
end

%--------------------------------------------------------------------------
function updateSelmode(hObject,eventdata,mode)

set(allchild(get(hObject,'Parent')),'Checked','off');
set(hObject,'Checked','on');
 
setappdata(gcf,'selmode', mode);


function selectByExpression(hObject,eventdata)

hFig = gcf;
grainso = getappdata(hFig,'grains');

h = selectorExp(grainso);

while h
  try
    waitfor(h,'UserData','eval'); 
   
    field = get(findall(h,'Tag','input'),'String');
    
    ly = length(grainso)-get(findall(h,'Tag','layer'),'Value')+1;
    grains = grainso{ly}; %restrict to layer
    
    set(h,'UserData','');
    try
      idok = get(gco,'String');   
      
      %you'll never know !
      ebsd = getappdata(hFig,'ebsd');
      
      k = eval(field);
     
      if ~islogical(k),
        errordlg({'must be a locigal Statement'})
      else      
        k = find(k);
        ks = getappdata(hFig,'selected');
        switch get(findall(h,'Tag','operation'),'Value')
          case 2
            k = union(ks{ly},k);
          case 3
            k = ks{ly}( ~ismember(ks{ly},k));
          case 4
            k = intersect(ks{ly},k);
        end
        ks{ly} = k;
        setappdata(hFig,'selected',ks);
        feval( get(hFig,'type'),double(hFig));
        updateSelectionPlot;
        updateMenus,
      end
    
      if strcmpi(idok,'Ok')
        close(h);
      else
        feval( get(h,'type'),double(h));
      end
    catch
      errordlg({'An Error occurred during evaluation','please correct your Syntax'})
    end
   
  catch
     break; %cancel
  end
end



function [grains p ks ly tks] = getcurrentlayer

grains = getappdata(gcf,'grains');
p = getappdata(gcf,'polygons');
tks = getappdata(gcf,'selected');
ly = getappdata(gcf,'currentlayer');
ks = tks{ly};
grains = grains{ly};
p = p{ly};

%--------------------------------------------------------------------------
function [h sel] = spatialSelection(src,eventdata,modus) %#ok<INUSL>


[grains p ks ly tks] = getcurrentlayer;

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
          if strcmpi(get(src,'SelectionType'),'alt'), mode = 'rem'; end
          switch mode
            case 'single'
              tks{ly} = k;
              setappdata(gcf,'selected',tks);
            case 'add'
              if ~any(ks == k)
                tks{ly} = [ks k];
                setappdata(gcf,'selected',tks);
              end
            case 'rem'    
              ls = ks ~= k;
              if any(~ls)
                 tks{ly} = ks(ls);
                setappdata(gcf,'selected',tks);            
              end
          end
        case 'ident'
          c = getappdata(gcf,'selectioncolor');     
         
          hold on
            h = fill(X,Y,c{ly}); drawnow;            
            pause(0.1);
            delete(h); drawnow;
            pause(0.1);
            h = fill(X,Y,c{ly}); drawnow; 
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

tks = getappdata(gcf,'selected');
setappdata(gcf,'selected',cell(size(tks)));
updateSelectionPlot;
updateMenus;

function unSelectLayer(empt,eventdata)

[grains p ks ly tks] = getcurrentlayer; 

tks{ly} = [];
setappdata(gcf,'selected',tks);
updateSelectionPlot;
updateMenus;


%--------------------------------------------------------------------------
function [h sel] = invertSelection(empt,eventdata)

[grains p ks ly tks] = getcurrentlayer;

tks{ly} = find(~ismember(1:length(grains),ks));
setappdata(gcf,'selected',tks);

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

hFig = gcf;
delete(getappdata(hFig,'selection')); %clean up previous

c = getappdata(hFig,'selectioncolor');

tks = getappdata(hFig,'selected');
p = getappdata(hFig,'polygons');
h = [];
for k=1:length(tks)
  ps = p{k}(tks{k}); %restrict to needed
  
	if ~isempty(ps)
    if ~numel(p),
      setappdata(hFig,'selection',[]);
      return, end; %nothing to do

    xy = cell2mat(arrayfun(@(x) [x.xy ; NaN NaN],ps,'UniformOutput',false));
    [X Y] = fixMTEXscreencoordinates( xy(:,1), xy(:,2) );

    hold on
    
    h(end+1) = plot(X(:),Y(:),'color',c{k},'linewidth',2);

    holes = ~cellfun('isempty',{ps.hxy});
    if any(holes)
       xy = cell2mat(arrayfun( @(x) ...
            cell2mat(cellfun(@(h) [h;  NaN NaN], x.hxy,'uniformoutput',false)') ,...
            ps(holes),'uniformoutput',false));

      [X,Y] = fixMTEXscreencoordinates(xy(:,1),xy(:,2));
      h(end+1) = plot(X(:),Y(:),'color',c{k},'linewidth',1);
    end
  end
end
hold off


setappdata(hFig,'selection',h);


%--------------------------------------------------------------------------
function grainselector(hObject, eventdata,state)

activateuimode(gcf,[]);

hP = get(hObject,'Parent');
tts(1) = findall(allchild(hP),'Tag','MTEX.grainidentify');
tts(2) = findall(allchild(hP),'Tag','MTEX.grainselector');

switch state
  case 'startidentify'    
    set(tts(2),'State','off');
    set(gcf,'WindowButtonDownFcn',{@spatialSelection,'ident'});
    set(gcf,'Pointer','custom','PointerShapeCData',selectorIcon('ident'));
  case 'stopidentify'
    set(gcf,'WindowButtonDownFcn',[]);
    set(gcf,'Pointer','arrow');
    hold off
  case 'startrecord'        
    set(tts(1),'State','off');
    set(gcf,'WindowButtonDownFcn',{@spatialSelection,'record'});
    set(gcf,'Pointer','cross');
  case 'stoprecord'
    set(gcf,'WindowButtonDownFcn',[])
    set(gcf,'Pointer','arrow');
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

props = fields(grain.properties);
if ~isempty(props)
  for k=1:length(props)
    p = grain.properties.(props{k});
    if isa(p,'quaternion')
        disp(['  ' props{k} ':   quaternion(' num2str([p.a p.b p.c p.d],'%1.4f,') ')']);
    elseif isa(p,'double')
        disp(['  ' props{k} ':  ' num2str(p)]);
    end
  end
end

disp(' ')

%--------------------------------------------------------------------------
function exporttoWS(e, h)

[grains p k ly] = getcurrentlayer;
name = inputdlg({'Enter Variable name:'},'Grains to Workspace',1,{['grain_selection_layer_' num2str(ly)]});
  if ~isempty(name), assignin('base', name{1}, grains(k) ); end
  
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

[grains p ks] = getcurrentlayer;
grains = grains(ks);
      
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

function variogrammplot(e,h)

[grains p ks] = getcurrentlayer;

properties = [grains.properties];
if ~isempty(properties)
  fnames = fields(properties);
  fnames = fnames(structfun(@(x) isfloat(x), properties(1)));

  [sel ok] = listdlg('Name','Variogramm',...
    'SelectionMode','single',...
    'ListSize',[170 70],...
    'PromptString','Select a Property','ListString',fnames,'fus',2,'ffs',2);      
  
  if ok
    figure, variogram(grains(ks),fnames{sel});
  else
    return
  end  
  
end



function extracttolayer(e,h)

[grains p ks ly] = getcurrentlayer;
c = getappdata(gcf,'selectioncolor');

hold on, plotgrains( grains(ks), 'color', c{ly});



