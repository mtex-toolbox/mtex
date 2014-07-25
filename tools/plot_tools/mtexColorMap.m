function mtexColorMap(name,varargin)

if ischar(name)
  if isempty(which(name))
    name = [name,'ColorMap'];
    if isempty(which(name))
      error('unknown colormap name');      
    end
    map = feval(name);
  else
    map = colormap(name);
  end
else
  map = name;
end

if isappdata(gcf,'mtexFig')
  mtexFig = getappdata(gcf,'mtexFig');
  for i = 1:numel(mtexFig.children)
    colormap(mtexFig.children(i),map);
  end  
  %colormap(mtexFig.cBarAxis,map);
else
  colormap(map);
end

  
