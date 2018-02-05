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

omega = linspace(0,2*pi,361);
  
if nargin > 2 && isnumeric(varargin{1})
  eta = varargin{1};
else
  eta = pi/2;
end

S2 = axis2quat(sec,omega)*axis2quat(orth(sec),eta)*sec;
    
d = reshape(sF.eval(S2),length(S2), []);
delta = max(d) / 20;

if isa(d,'double') && ~isreal(d), d = real(d);end
for j = 1:length(sF)
  if j > 1, mtexFig.nextAxis; end

  if check_option(varargin,'pcolor')
    x = [d(:, j)+delta,d(:, j)-delta] .* sin(omega(:));
    y = [d(:, j)+delta,d(:, j)-delta] .* cos(omega(:));
    
    h = surface(x,y,zeros(size(x)),[d,d],'parent',mtexFig.gca,'edgecolor','none','facecolor','interp');
  else
    x = d(:, j).*cos(omega(:));
    y = d(:, j).*sin(omega(:));
    
    h = plot(x,y,'parent',mtexFig.gca);
  end
  axis equal
  optiondraw(h,varargin{:});
end

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
