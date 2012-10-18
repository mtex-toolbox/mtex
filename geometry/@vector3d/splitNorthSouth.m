function [ax,v,varargin] = splitNorthSouth(v,varargin)
% split plot in north and south plot
%
% 1: axis given -> no extend stored -> compute extend -> finish
% 2: axis is hold and has extend -> use multiplot
% 3: new multiplot

%% case 1: predefined axis
if ishandle(v)
  ax = v;
  v = varargin{1};
  varargin(1) = [];
  if ~isappdata(ax,'extend')
    extend = getPlotRegion(v,varargin{:});
    setappdata(ax,'extend',extend);
  end
  return
end

%% case 2: axis is hold and has extend

if ~newMTEXplot && isappdata(gca,'extend')
  
  v = multiplot([],v,varargin{:});
        
  ax = {};
  return
end

%% case 3: create new axes  
   
% get polar plot region
extend = getPlotRegion(v,varargin{:});
  
% hemisphere names
upperlower = {'north','south'};

% if two hemispheres - split plot
if isnumeric(extend.maxTheta) && ...
    extend.maxTheta > pi/2 + 1e-3 && extend.minTheta < pi/2 - 1e-3
  
  
  minTheta = {0,pi/2};
  maxTheta = {pi/2,pi};
  
  v = multiplot(2,v,varargin{:},...
    'TR',@(i) upperlower{i},...
    'minTheta',@(i) minTheta{i},'maxTheta',@(i) maxTheta{i});
  
else
  
    v = multiplot(1,v,varargin{:},...
    'TR',@(i) upperlower{1+(extend.minTheta > pi/2 - 1e-3)});
  
end
  
ax = {};
    