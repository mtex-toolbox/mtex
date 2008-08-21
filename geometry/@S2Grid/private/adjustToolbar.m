function adjustToolbar(varargin)

tbh = findall(gcf,'Type','uitoolbar');
uitools = [findall(tbh,'Type','uipushtool');findall(tbh,'Type','uitoggletool')];
uitags = get(uitools,'tag');
deltags = {'Standard.FileOpen',...
  'Plottools.PlottoolsOff',...
  'Plottools.PlottoolsOn',...
  'Exploration.DataCursor',...
  'Exploration.Rotate',...
  'Standard.EditPlot'
};

if check_option(varargin,'norotate')
  deltags = {deltags{:},'Exploration.Rotate'};
end

for i = 1:length(uitags)
  if any(strmatch(uitags{i},deltags))
    set(uitools(i),'visible','off');
  end
end

%uitoggletool(tbh,'CData',rand(20,20,3),...
%            'Separator','on',...
%            'ToolTipString','Plot Options',...
%            'HandleVisibility','off');
