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

[o,ind] = getgrid(ebsd,'checkPhase',varargin{:});

% extract weights
if isfield(ebsd(1).options,'weight')
  weight = get(ebsd(ind),'weight');  
else
  weight = ones(1,numel(o));
end
weight = weight ./ sum(weight(:));

v = sum(weight(find(o,center,radius,varargin{:})));
