function quiverSection(sVF1,sVF2,N,varargin)
% plot a vector field along another vectorfield
%
% Syntax
%
%   N = vector3d.Z;
%   quiverSection(sVF1,v,N)
%   quiverSection(sVF1,sVF2,N,pi/3)
%
% Input
%  sVF1, sVF2 - @S2VectorField
%  v - @vector3d
%  N - normal @vector3d of the section
%
% Options
%  normalized - draw unit length vectors

[mtexFig,isNew] = newMtexFigure(varargin{:});

% where to plot - compute circle positions
omega = linspace(0,2*pi,36);
  
if nargin > 2 && isnumeric(varargin{1})
  eta = varargin{1};
else
  eta = pi/2;
end

S1 = axis2quat(N,omega)*axis2quat(orth(N),eta)*N;
circ = reshape(sVF1.eval(S1),length(S1), []);
    
% what to plot
if isa(sVF2,'function_handle')
  v = sVF2(S1);
else
  v = sVF2.eval(S1);
end
v = v(:);
if check_option(varargin,'normalized'), v = v.normalize; end

% plot the vector field v at the positions circ
if v.antipodal
  opt = {'showArrowHead','off'};
  h = quiver3(circ.x,circ.y,circ.z,-v.x,-v.y,-v.z,'parent',mtexFig.gca,opt{:});
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
else
  opt = {};
  h = [];
end
  
h = [h,quiver3(circ.x,circ.y,circ.z,v.x,v.y,v.z,'parent',mtexFig.gca,opt{:})];
  
% post process output
view(mtexFig.gca,squeeze(double(N)));
set(mtexFig.gca,'dataAspectRatio',[1 1 1]);
optiondraw(h,varargin{:});

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end
