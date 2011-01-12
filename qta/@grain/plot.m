function plot(varargin)
% visualisation of grains
%
%% Syntax
%  plot(grains)
%  plot(grains, ...)
%
%% Input
%  grains - @grain
%
%% Options
%  BOUNDARY      - plot grainboundaries
%  SUBFRACTIONS  - subfractions plot
%  ELLIPSE       - ellipse plot
%
%% See also
% grain/plotboundary grain/plotgrains grain/plotsubfractions
%

% plot only grain boundaries
if check_option(varargin,'boundary')
  
  varargin = delete_option(varargin,'boundary',0);
  plotboundary(varargin{:});
  
% plot only subractions  
elseif check_option(varargin,'subfractions')
  
  varargin = delete_option(varargin,'subfractions',0);
  plotsubfractions(grains,varargin{:});
  
% plot ellipse  
elseif check_option(varargin,'ellipse')
  
  varargin = delete_option(varargin,'ellipse',0);
  plotellipse(varargin{:}); 
  
% default grain plot  
else 
  plotgrains(varargin{:});
end
