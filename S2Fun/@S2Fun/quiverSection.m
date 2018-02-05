function quiverSection(sF,sVF,sec,varargin)
%
% Syntax
%   quiverSection(sF,v,vector3d.Z)
%   quiverSection(sF,sVF,vector3d.Z)
%   quiverSection(sF,v,vector3d.Z,pi/3)
%
% Input
%  sF  - @S2Fun
%  v   - @vector3d 
%  sVF - @S2VectorField
%
% Output

[mtexFig,isNew] = newMtexFigure(varargin{:});

omega = linspace(0,2*pi,36);
  
if nargin > 3 && isnumeric(varargin{1})
  eta = varargin{1};
else
  eta = pi/2;
end

S2 = axis2quat(sec,omega) * axis2quat(orth(sec),eta) * sec;
if isa(sVF,'function_handle')
  v = sVF(S2);
else
  v = sVF.eval(S2);
end
v = v(:);
    
d = reshape(sF.eval(S2),length(S2), []);

h = [];
for j = 1:length(sF)
  if j > 1, mtexFig.nextAxis; end

  x = d(:, j).*sin(omega(:));
  y = d(:, j).*cos(omega(:));
    
  h = quiver(x,y,v.x,v.y,'parent',mtexFig.gca);
  h = [h,quiver(x,y,-v.x,-v.y,'parent',mtexFig.gca)]; %#ok<AGROW>
  
end
axis equal
optiondraw(h,varargin{:});

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
