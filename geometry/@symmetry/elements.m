function [axes,mult] = elements(cs,multiplicity)
% extract symmetry elements by multiplicity
%
% Syntax
%
%   axes = elements(cs,multiplicity) % rotational axes with fixed multiplicity
%   [axes,multiplicity] = elements(cs) % all rotational axes with multiplicity
%
% Input
%  cs - @crystalSymmetry
%  multiplicity - double
%
% Output
%  axes - rotational axes vector3d
%  multiplicity - double
%

rot = cs.rot(cs.rot.angle>1*degree);
axes =  rot.axis;
mult = round(2*pi ./ rot.angle);
[axes, ~, id] = unique(axes,'tolerance',1e-3,'antipodal');
mult = accumarray(id,mult,[],@max);

axes = [axes;-axes];
mult = [mult;mult];

if nargin == 2
  axes = axes(mult == multiplicity);
end
