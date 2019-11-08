function h = plotSection(sF,sec,varargin)
% plot a section through a spherical function
%
% Syntax
%   N = vector3d.Z; % normal direction
%   plotSection(sF,N) % plot in equator plane
%
%   theta = pi/3;   % polar angle 
%   plotSection(sF,N,theta) % plot small circle at 30 degree from the north pole
%
%   rho = linspace(0,pi); % azimuthal angle
%   plotSection(sF,N,theta,rho) % plot half small circle at 30 degree
%
% Input
%  sF - @S2Fun
%  N  - normal direction of the intersection plane
%  theta - polar angle of the intersection plane
%  rho   - azimuthal angle of the points to be plotted  
%
% Output
%
%

[mtexFig,isNew] = newMtexFigure(varargin{:});
 
% extract polar angle of section
eta = pi/2; omega = linspace(0,2*pi,361);
if nargin > 2 && isnumeric(varargin{1})
  eta = varargin{1};
  
  % extract azimuthal angle of section
  if nargin > 3 && isnumeric(varargin{2}), omega = varargin{2}; end  
end

S2 = [axis2quat(sec,omega),quaternion.nan(numel(sec))]*axis2quat(orth(sec),eta)*sec;

d = reshape(sF.eval(S2),length(S2), []);
delta = getappdata(mtexFig.gca,'delta');
if isempty(delta)
  delta = nanmax(d) / 200 ;
  setappdata(mtexFig.gca,'delta',delta);
end
delta = delta * get_option(varargin,'linewidth',1);

if isa(d,'double') && ~isreal(d), d = real(d);end
for j = 1:length(sF)
  if j > 1, mtexFig.nextAxis; end

  if strcmpi(get_option(varargin,'color'),'interp')
    varargin = delete_option(varargin,'color',1);
    
    dOuter = d(:, j)+delta;
    dInner = d(:, j)-delta;
    
    x = [dOuter .* S2.x, dInner .* S2.x];
    y = [dOuter .* S2.y, dInner .* S2.y];
    z = [dOuter .* S2.z, dInner .* S2.z];
    
    h{j} = surface(x,y,z,[d,d],'parent',mtexFig.gca,'edgecolor','none','facecolor','interp');
    
  else
    x = d(:, j).*S2.x;
    y = d(:, j).*S2.y;
    z = d(:, j).*S2.z;
    
    h{j} = plot3(x,y,z,'parent',mtexFig.gca);
  end
  view(mtexFig.gca,squeeze(double(sec)));
  set(mtexFig.gca,'dataAspectRatio',[1 1 1]);
  axis(mtexFig.gca,'off');
  optiondraw(h{j},varargin{:});
end

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end

if nargout == 0
  clear h
else
  h = [h{:}];
end
