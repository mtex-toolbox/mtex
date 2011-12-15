function ebsd = calcMis2Mean(ebsd,grains,varargin)
% misorientation of grains
%
%% Description
% compute the misorientation of ebsd data to mean of grains and add the
% result to the properties of the ebsd variable
%
%% Syntax
% ebsd = misorientation(ebsd,grains)
%
%% Input
%  grains   - @grain
%  ebsd     - @EBSD
%
%% Output
%  ebsd    - @EBSD
%  
%% See also
% EBSD/calcODF EBSD/hist grain/neighbours 

% extract mean orientations of the grains
id = get(grains,'id');
m(id) = get(grains,'quaternion');

% expand to EBSD data
m = m(ebsd.options.grain_id);
  
% compute misorientation  
ebsd.options.mis2mean = inverse(ebsd.rotations) .* m(:);
