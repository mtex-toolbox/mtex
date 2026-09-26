classdef EBSDFilter < handle
% abstract class for denoising EBSD data
%
% A filter replaces the orientation of every pixel of a gridded @EBSD map
% by one computed from its neighbours. Deriving classes only implement
% smooth; which neighbours exist and how far apart they are is told to them
% through isHex and dx.
%
% Syntax
%   ebsd = smooth(ebsd,F)
%   ebsd = smooth(ebsd,F,'fill',grains)
%
% Input
%  F - @EBSDFilter
%
% Class Properties
%  isHex - is the map on a hexagonal grid
%  dx    - the distance of neighbouring pixels
%
% Derived Classes
%  @splineFilter              - smoothing spline, the MTEX default
%  @meanFilter                - convolution with a weight matrix
%  @medianFilter              - median of the neighbours
%  @KuwaharaFilter            - mean of the most homogeneous subwindow
%  @l1TVFilter                - total variation, keeps steps
%  @infimalConvolutionFilter  - first and second order TV combined
%
% See also
% EBSD/smooth splineFilter EBSDDenoising
%

properties (SetObservable)
  isHex = false;
  dx = 1;
end

methods (Abstract = true)
  q = smooth(q,varargin)
end
  
end