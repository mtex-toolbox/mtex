function v = volume(ebsd,center,radius,varargin)
% ratio of orientations with a certain orientation
%
%% Description
% returns the ratio of mass of the ebsd that is close to 
% one of the orientations as radius
%
%% Syntax
%  v = volume(ebsd,center,radius,<options>)
%
%% Input
%  ebsd   - @EBSD
%  center - @quaternion
%  radius - double
%
%% See also
% ODF/volume

% extract weights
if isfield(ebsd(1).options,'weight')
  weight = get(ebsd,'weight');  
else
  weight = ones(1,GridLength(ebsd.orientations));
end
weight = weight ./ sum(weight(:));

g = getgrid(ebsd,'checkPhase',varargin{:});

v = sum(weight(find(g,center,radius,varargin{:})));
