function [ori,omega] = orientation(f,varargin)
% generate a list of orientation out of a fibre
%
% Syntax
%   ori = orientations(f,'points',1000)
%
% Input
%  f - @fibre
%
% Output
%  ori - @orientation
%
% Options
%  points - number of points that are generated
%

[ori,omega] = rotation(f,varargin{:});

if isa(f.CS,'crystalSymmetry') || isa(f.SS,'crystalSymmetry')
  ori = orientation(ori,f.CS,f.SS);
end

end