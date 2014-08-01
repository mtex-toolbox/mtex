function MTEXFigureMenu(mtexFig,varargin)

% create a menu MTEX
m = uimenu('label','MTEX');

% make it second position
mnchlds = allchild(gcf);
p = findall(mnchlds,'Tag','figMenuFile');
mnchlds = [mnchlds(2:find(p == mnchlds)-1) ; mnchlds(1) ; p]; % permutate positions
set(gcf,'Children',mnchlds)
  
uimenu(m,'label','Export Image','callback',@Export);
uimenu(m,'label','Colorbar','callback',@mtexFig.colorbar);
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

an = uimenu(m,'label','Anotations');
uimenu(an,'label','Show min/max','checked','on','callback',{@setVisible,'minmax'});
uimenu(an,'label','Show labels','checked','on','callback',{@setVisible,'labels'});
uimenu(an,'label','Show ticks','checked','off','callback',{@setVisible,'ticks'});
uimenu(an,'label','Show grid','checked','off','callback',{@setVisible,'grid'});




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





function [cm,cmd] = getColormaps

fnd = dir([mtex_path filesep 'tools' filesep 'colormaps' filesep '*ColorMap.m']);

% remove extension to create command
cmd = cellfun(@(x) x(1:end-2),{fnd.name},'UniformOutput',false);

% remove ColorMap
cm = cellfun(@(x) x(1:end-8),cmd,'UniformOutput',false);

end

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
function setVisible(obj,event,element)

if strcmp(get(obj,'checked'),'on')
  onoff = 'off';
else
  onoff = 'on';
end

set(obj,'checked',onoff);

% for all axes
ax = findobj(gcf,'type','axes');
for a = 1:numel(ax)

  switch element
    case 'minmax'
      if ~isappdata(ax(a),'annotation'), continue;end
      an = getappdata(ax(a),'annotation');
      set(an.h([1,3]),'visible',onoff);
  
    case 'labels'
      la = [get(ax(a),'xlabel'),get(ax(a),'ylabel')];
      set(la,'visible',onoff);
          
    otherwise
    
    if ~isappdata(ax(a),'sphericalPlot'), continue;end
    sP = getappdata(ax(a),'sphericalPlot');
    if isempty(sP.grid)
      set(ax(a),'XGrid',onoff,'YGrid',onoff);
    else
      set(sP.(element),'visible',onoff);
    end
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
