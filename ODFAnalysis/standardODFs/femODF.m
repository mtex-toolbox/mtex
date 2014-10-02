function odf = femODF(center, weights, varargin)
% defines an ODF by finite elements
%
% Syntax
%   odf = femODF(center, weights)
%
% Input
%  center - @DSO3
%  weights - double
%
% Output
%  odf - @ODF
%
% See also
% ODF/ODF uniformODF fibreODF unimodalODF
                 
odf = ODF(femComponent(center,weights));
