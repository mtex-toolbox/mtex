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
% odf/volume

v = nnz(find(ebsd.orientations,center,radius,varargin{:})) / ...
    sum(GridLength(ebsd.orientations));