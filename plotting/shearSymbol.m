function [x,y,z] = shearSymbol(sS,varargin)
% coordinates of a shear symbold
%
% Syntax
%
%   [x,y] = shearSymbol(sS,varargin)
%   [x,y] = shearSymbol(d,n,varargin)
%
% Input
%  sS - @slipSystem
%  d - slip direction
%  n - normal direction
%  
% Output
%  x - 
%  y -
%
% Options
%  center - 
%  linewidth -
%  arrowLength -
%


if isa(sS,'slipSystem')
  n = sS.n;
  d = sS.b;
else
  d = sS;
  n = varargin{1};
end

center = get_option(varargin,'center',vector3d(0,0,0));
if ~isa(center,'vector3d'), center = vector3d(center(:,1),center(:,2),0); end

% compute the trace
t = cross(n,vector3d.Z);

% take into account the slip direction
% if its is up or down n becomes zero
n = n .* dot(t,d);

arrowLength = get_option(varargin,'arrowLength',1);
arrowWidth = arrowLength ./ 2; % arrow width 
tailWidth = arrowLength ./ 5;
dist = tailWidth ./ 3; % dist between the two errors

V = [arrowLength .* t + dist .* n, ...
  arrowWidth .* n, tailWidth .* n, tailWidth .* n - arrowLength.*t, ...
  dist .* n - arrowLength .* t,arrowLength .* t + dist .* n];

V(:,end+1) = nan;

V = center + [V,- V];

x = V.x;
y = V.y;
z = V.z;

end

function test

mtexdata titanium 
grains = ebsd.calcGrains; 
sS = slipSystem.prismaticA(ebsd('t').CS);

plot(grains('t'),grains('t').meanOrientation) 

[x,y,z] = shearSymbol(grains('t').meanOrientation .* sS,...
  'center',grains('t').centroid,'arrowLength',grains.diameter./3);

hold on 
patch(x.',y',z.');
hold off

end