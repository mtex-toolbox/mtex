function p = axialSymbol(center,v,symbolSize,varargin)
% generates a patch object to be included into a grain or EBSD plot
%
% Syntax
%
%   p = axialSymbol(center,v,symbolSize)
%
% Input
%  center - [x,y] of symbol center
%  v - axial direction
%  symbolSize - size of the symbol
%
% Output
%  p - patch object

% ensure input is column vector
v = v(:);
n = length(v);

% get color
color = get_option(varargin,'symbolColor',[1 1 1]);

symbolSize  = symbolSize / 10;

dxy = symbolSize .* (1+3*sin(v.theta)) .* [cos(v.rho) sin(v.rho)] ;
nxy = symbolSize .* [sin(v.rho) -cos(v.rho)] ;

p = struct;
p.Vertices = [center + dxy; center - dxy; center + nxy; center - nxy ];
p.Faces = (1:n).' +[0 2*n n 3*n 0];
p.FaceVertexCData = color .* [0.5 + 0.5*cos(v.theta);0.5 - 0.5*cos(v.theta) ; 0.5 * ones(2*n,1)];
p.FaceColor ='interp';
p.Parent = [];
p = patch(p,'parent',gca);

%h = rectangle('Position',[center-r,2*r,2*r],'Curvature',1,'FaceColor',color)

end