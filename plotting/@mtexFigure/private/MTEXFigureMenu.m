function MTEXFigureMenu(mtexFig,varargin)

%if strcmpi(isVisible(mtexFig.parent),'off'), return; end

try
  if isempty(mtexFig.parent.MenuBar), return; end
end

% create a menu MTEX
m = uimenu('label','MTEX');

% make it second position
mnchlds = allchild(gcf);
p = find(mnchlds==findall(mnchlds,'Tag','figMenuFile'));
mnchlds = [mnchlds(2:p-1) ; mnchlds(1) ; mnchlds(p:end)]; % permutate positions
set(gcf,'Children',mnchlds)
  
uimenu(m,'label','Export Image','callback',@Export);
uimenu(m,'label','Colorbar','callback',@(a,b) mtexFig.colorbar);
cm = uimenu(m,'label','Colormap');

% Colormap submenu
maps = getColormaps;

for i = 1:length(maps)
  uimenu(cm,'label',maps{i},'callback',@setColorMap);
end


% colorcoding
cc = uimenu(m,'label','Colorcoding');
uimenu(cc,'label','Equal','callback',@setColorCoding);
uimenu(cc,'label','Tight','callback',@setColorCoding,'checked','on');


% axis alignment
xlabel = get_option(varargin,'xlabel','X');
zlabel = get_option(varargin,'zlabel','Z');

xlabel = regexprep(xlabel,'[$_\\]','');
xlabel = regexprep(xlabel,'var','');

xdirection = uimenu(m,'label',[xlabel ' axis direction']);
uimenu(xdirection,'label','East','callback',@setXAxisDirection);
uimenu(xdirection,'label','North','callback',@setXAxisDirection,'checked','on');
uimenu(xdirection,'label','West','callback',@setXAxisDirection);
uimenu(xdirection,'label','South','callback',@setXAxisDirection);

zdirection = uimenu(m,'label',[zlabel ' axis direction']);
uimenu(zdirection,'label','Out of plane','callback',@setZAxisDirection,'checked','on');
uimenu(zdirection,'label','Into plane','callback',@setZAxisDirection);

% spacing

uimenu(m,'label','Set Inner Margin','callback',{@setMargin,'inner'});
uimenu(m,'label','Set Outer Margin','callback',{@setMargin,'outer'});  

% annotations

an = uimenu(m,'label','Annotations');
uimenu(an,'label','Min/Max','checked',isVisible('minmax'),'callback',{@setVisible,'minmax'});
uimenu(an,'label','Labels','checked',isVisible('labels'),'callback',{@setVisible,'labels'});
uimenu(an,'label','Coordinates','checked',isVisible('ticks'),'callback',{@setVisible,'ticks'});
uimenu(an,'label','Grid','checked','off','callback',{@setVisible,'grid'});
uimenu(an,'label','Micronbar','checked','on','callback',{@setVisible,'micronBar'});




% fontsize

fs = uimenu(m,'label','Fontsize');
uimenu(fs,'label','10 points','callback',{@setFontSize,10},'checked','on');
uimenu(fs,'label','11 points','callback',{@setFontSize,11});
uimenu(fs,'label','12 points','callback',{@setFontSize,12});
uimenu(fs,'label','13 points','callback',{@setFontSize,13});
uimenu(fs,'label','14 points','callback',{@setFontSize,14});
uimenu(fs,'label','15 points','callback',{@setFontSize,15});
uimenu(fs,'label','16 points','callback',{@setFontSize,16});
uimenu(fs,'label','17 points','callback',{@setFontSize,17});
uimenu(fs,'label','18 points','callback',{@setFontSize,18});
uimenu(fs,'label','19 points','callback',{@setFontSize,19});
uimenu(fs,'label','20 points','callback',{@setFontSize,20});

% -------------- Callbacks ---------------------------

% export
function Export(obj,event) %#ok<INUSD>

saveFigure;

end

% FontSize
function setFontSize(obj,event,fs) %#ok<INUSL>

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');

o = findobj(gcf,'type','text');
set(o,'FontSize',fs);
set(obj,'checked','on');

end

% Grid Visibility
function setVisible(obj,event,varargin)

if strcmp(get(obj,'checked'),'on')
  onoff = 'off';
else
  onoff = 'on';
end

set(obj,'checked',onoff);

% for all axes
ax = findobj(gcf,'type','axes');
for a = 1:numel(ax)

  for element = cellstr(varargin)
    switch char(element)

      case 'minmax'
      
        sP = getappdata(ax(a),'sphericalPlot');

        if ~isempty(sP)
          sP.dispMinMax = strcmp(get(obj,'checked'),'on');
          sP.updateMinMax;
        end
      
      case 'micronBar'
        
        mP  = getappdata(ax(a),'mapPlot');
        if ~isempty(mP), mP.micronBar.visible = onoff;end
      
      case 'labels'
        la = [get(ax(a),'xlabel');get(ax(a),'ylabel');...
          findobj(ax(a),'tag','axesLabels')];
        set(la,'visible',onoff);
        
        sP = getappdata(ax(a),'sphericalPlot');
        if ~isempty(sP) && ~isempty(sP.labels)
          set(sP.labels,'visible',onoff);          
        end
        
      case 'ticks'
      
        if strcmp(onoff,'on')
          set(ax(a),'xtickLabelMode','auto','ytickLabelMode','auto');
          set(ax(a),'tickLength',[0.01,0.01]);
        else
          set(ax(a),'xtickLabel',{},'ytickLabel',{});
          set(ax(a),'tickLength',[0,0]);
        end
      
      otherwise
    
        if isappdata(ax(a),'sphericalPlot')
          sP = getappdata(ax(a),'sphericalPlot');
          if isempty(sP.grid)
            set(ax(a),'XGrid',onoff,'YGrid',onoff);
          else
          set(sP.(char(element)),'visible',onoff);
          end
        else
        end
    end
  end

  mtexFig.drawNow

end
end

% Grid Visibility
function onOff = isVisible(element)

  onOff = 'off';
  if isempty(mtexFig.children), return; end
  ax = mtexFig.children(1);

switch element
  case 'minmax'
    if isappdata(ax(a),'annotation')
      hh = getappdata(ax,'annotation');
      hh = hh.h;
      onOff = get(hh(1),'visible');
    end
  
  case 'labels'
    xl = get(gca,'xlabel');    
    onOff = get(xl,'visible');
    
  case 'ticks'
    
    if isempty(get(ax,'xtickLabel'))
      onOff = 'off';
    else
      onOff = 'on';
    end
      
  otherwise
    
    if isappdata(ax(a),'sphericalPlot')
      sP = getappdata(ax(a),'sphericalPlot');
      if isempty(sP.grid)
        set(ax(a),'XGrid',onoff,'YGrid',onoff);
      else
        set(sP.(element),'visible',onoff);
      end
    else
        
    end

end
end


% X Axis Direction
function setXAxisDirection(obj,event)

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');
set(obj,'checked','on');

mtexFig.setCamera('xAxisDirection',get(obj,'label'));

end

% Z Axis Direction
function setZAxisDirection(obj,event)

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');
set(obj,'checked','on');
zAxis = get(obj,'label');
zAxis(zAxis==' ')=[];

mtexFig.setCamera('zAxisDirection',zAxis);

end

% Margins
function setMargin(obj,event,type) %#ok<INUSL>

[h,fig] = gcbo; %#ok<ASGLU>
m = mtexFig.([type 'PlotSpacing']);

prompt = {['Enter ' type ' margin :']};
dlg_title = 'Set Margin';
num_lines = 1;
m = str2double(inputdlg(prompt,dlg_title,num_lines,{num2str(m)}));

mtexFig.([type 'PlotSpacing']) = m;

resizeFcn = get(fig,'resizeFcn');
resizeFcn(fig,event);

end

% Color coding
function setColorCoding(obj,event) %#ok<INUSD>

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');

if strcmpi(get(obj,'label'),'tight')
  mtexFig.CLim('tight');
else
  mtexFig.CLim('equal');
end


set(obj,'checked','on');

end


function setColorMap(obj,event) %#ok<INUSD>

uncheck = findobj(gcf,'parent',get(obj,'parent'));
set(uncheck,'checked','off');
map = get(obj,'label');
map = feval([map 'ColorMap']);
for ii=1:numel(mtexFig.children),
  colormap(mtexFig.children(ii),map);
end
set(obj,'checked','on');

end

end
