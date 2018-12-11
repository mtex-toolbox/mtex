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

delta = get_option(varargin,'delta',0.05*degree);

rot = rotation.byAxisAngle([xvector,yvector,zvector],delta/2);

%f = component.eval([ori(:),(rot*ori).']);
f = reshape(component.eval([ori*inv(rot),ori*rot]),length(ori),[]);

g = vector3d(f(:,4)-f(:,1),f(:,5)-f(:,2),f(:,6)-f(:,3)) ./ delta;
