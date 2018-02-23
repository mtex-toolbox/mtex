function plotSection(sVF,sec,varargin)
%
% Syntax
%   plotSection(sVF,vector3d.Z)
%   plotSection(sVF,vector3d.Z,pi/3)
%
% Input
%  sVF - @S2Fun
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
    
d = reshape(sVF.eval(S2),length(S2), []);
delta = getappdata(mtexFig.gca,'delta');
if isempty(delta)
  delta = 1 / 100 ;
  setappdata(mtexFig.gca,'delta',delta);
end
delta = delta * get_option(varargin,'linewidth',1);

if isa(d,'double') && ~isreal(d), d = real(d);end

if strcmpi(get_option(varargin,'color'),'interp')
  varargin = delete_option(varargin,'color',1);
  x = [d.x .* (1+delta),d.x .* (1-delta)];
  y = [d.y .* (1+delta),d.y .* (1-delta)];
  z = [d.z .* (1+delta),d.z .* (1-delta)];
  
  h = surface(x,y,z,[norm(d),norm(d)],'parent',mtexFig.gca,'edgecolor','none','facecolor','interp');
  
else
  
  h = plot3(d.x,d.y,d.z,'parent',mtexFig.gca);
end

view(mtexFig.gca,squeeze(double(sec)));
set(mtexFig.gca,'dataAspectRatio',[1 1 1]);
optiondraw(h,varargin{:});

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
