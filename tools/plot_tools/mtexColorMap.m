function mtexColorMap(name,varargin)

if ischar(name)
  if isempty(which(name))
    name = [name,'ColorMap'];
    if isempty(which(name))
      error('unknown colormap name');      
    end
    name = feval(name);
  end
  colormap(name);
end

