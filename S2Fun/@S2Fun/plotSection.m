function plotSection(sF,sec,varargin)
%
% Syntax
%   plotSection(sF,vector3d.Z)
%   plotSection(sF,vector3d.Z,pi/3)
%
% Input
%  sF - @S2Fun
%
% Output

[mtexFig,isNew] = newMtexFigure(varargin{:});

omega = linspace(-pi,pi,361);
  
if nargin > 2 && isnumeric(varargin{1})
  eta = varargin{1};
else
  eta = pi/2;
end

S2 = axis2quat(sec,omega)*axis2quat(orth(sec),eta)*sec;
    
d = sF.eval(S2);
    
if isa(d,'double') && ~isreal(d), d = real(d);end

x = d(:).*cos(omega(:));
y = d(:).*sin(omega(:));
  
h = plot(x,y);
axis equal
optiondraw(h,varargin{:});

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
