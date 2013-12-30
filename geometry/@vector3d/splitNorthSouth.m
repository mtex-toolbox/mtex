function [ax,v,varargout] = splitNorthSouth(v,varargin)
% split plot in upper and lower hemisphere
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
    
    if isnumeric(extend.maxTheta) && ...
        extend.maxTheta > pi/2 + 1e-3 && extend.minTheta < pi/2 - 1e-3 && ...
        ~check_option(varargin,'plain')

      extend.maxTheta = pi/2;  
%      warning(['You can only plot one hemisphere in an axis. ' ...
%        ' Consider restricting by using one of the options ''upper'', or, ''lower''!']);
      
    end
    setappdata(ax,'extend',extend);
  end
  
%% case 2: axis is hold and has extend
elseif ~newMTEXplot && isappdata(gca,'extend')
  
  v = multiplot([],v,varargin{:});
        
  ax = {};

%% case 3: create new axes  
else
  
  % get polar plot region
  extend = getPlotRegion(v,varargin{:});
  
  % hemisphere names
  upperlower = {'upper','lower'};

  % for plain projection do not split
  if check_option(varargin,'plain')
    v = multiplot(1,v,varargin{:});
  
  elseif isnumeric(extend.maxTheta) && ...
      extend.maxTheta > pi/2 + 1e-3 && extend.minTheta < pi/2 - 1e-3
    % if two hemispheres - split plot
  
    minTheta = {0,pi/2};
    maxTheta = {pi/2,pi};
  
    v = multiplot(2,v,@(i) varargin{1},varargin{2:end},...
      'TR',@(i) upperlower{i},...
      'minTheta',@(i) minTheta{i},'maxTheta',@(i) maxTheta{i});
    
  else
  
    v = multiplot(1,v,varargin{:},...
      'TR',@(i) upperlower{1+(extend.minTheta > pi/2 - 1e-3)});
  
  end
  
  ax = {};
end

varargout(1:nargout-3) = varargin(1:nargout-3);
varargout{nargout-2} = varargin(nargout-2:end);