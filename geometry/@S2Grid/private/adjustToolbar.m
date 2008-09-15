function adjustToolbar(varargin)

tbh = findall(gcf,'Type','uitoolbar');
uitools = [findall(tbh,'Type','uipushtool');findall(tbh,'Type','uitoggletool')];
uitags = get(uitools,'tag');
deltags = {'Standard.FileOpen',...
  'Plottools.PlottoolsOff',...
  'Plottools.PlottoolsOn',...
  'Exploration.DataCursor',...
  'Exploration.Rotate',...
  'Standard.EditPlot',...
  'Plottools.edit'...
};

if check_option(varargin,'norotate')
  deltags = {deltags{:},'Exploration.Rotate'};
end

for i = 1:length(uitags)
  if any(strmatch(uitags{i},deltags))
    set(uitools(i),'visible','off');
  end
end

try
  [pic,map] = imread([toolboxdir('matlab') filesep 'icons/tool_align.gif']);
  pic = ind2rgb(pic,map);
catch
  a = .20:.05:0.95;
  pic(:,:,1) = repmat(a,16,1)';
  pic(:,:,2) = repmat(a,16,1);
  pic(:,:,3) = repmat(flipdim(a,2),16,1);
end

uipushtool(tbh,'CData',pic,...
            'Separator','on',...
            'ToolTipString','Plot Options',...
            'clickedCallback','plot_gui',...
            'tag','Plottools.edit',...
            'HandleVisibility','off');
