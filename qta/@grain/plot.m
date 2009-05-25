function plot(grains,varargin)
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
%  SUBFRACTIONS  - subfractions plot
%  ELLIPSE       - ellipse plot
%
%% See also
% grain/plot grain/plotgrains grain/plotsubfractions
%

if check_option(varargin,'subfractions')
  varargin = delete_option(varargin,'subfractions',0);
  plotsubfractions(grains,varargin{:});
elseif check_option(varargin,'ellipse')
  varargin = delete_option(varargin,'ellipse',0);
  plotellipse(grains,varargin{:}); 
else 
  plotgrains(grains,varargin{:});
end

