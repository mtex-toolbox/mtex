function g = grad(component,ori,varargin)
% gradient at orientation g
%
% Syntax
%   g = grad(component,ori)
%
% Input
%  component - @unimodalComponent
%  ori - @orientation
%
% Output
%  g - @vector3d
%

delta = get_option(varargin,'delta',1*degree);

rot = rotation('axis',[xvector,yvector,zvector],'angle',delta);

%f = component.eval([ori(:),(rot*ori).']);
f = component.eval([ori(:),ori*rot]);

g = vector3d(f(:,2)-f(:,1),f(:,3)-f(:,1),f(:,4)-f(:,1)) ./ delta;
