function PF = measurePoleFigure(odf,h,varargin)
% simulate a polefigure measurement
%
%% Syntax
%  pf = measurePoleFigure(odf,h,@S2Grid,...)
%  pf = measurePoleFigure(odf,h,'integral','steps',30,'drho',5*degree,...)
%  pf = measurePoleFigure(odf,h,'path',@vector3d,@vector3d,...)
%
%% Options
%  S2Grid    - perform a point measure
%  integral  - integrate over small circle while measuring
%    mintheta/minrho
%    maxtheta/maxrho
%    dtheta
%    drho    - length of integral way
%  path      - integrate from A to B, where data is cummulated to B
%  steps     - number of measures

npos = [find_type(varargin,'S2Grid') find_type(varargin,'vector3d')];
steps = get_option(varargin,'steps',50);
rnd = @(sz) 1-rand(sz)*0.5;

if ~isempty(npos) && ~check_option(varargin,'path') % point measurement

  r = vector3d(varargin{npos(1)}); 
 
  gl = numel(r);
  F = zeros(gl, 1);
  F0 = pdf(odf,h,r);
  for k=1:steps
    F = F + F0.*rnd([gl 1]);  % maybe we count something
  end
  PF = PoleFigure(h,S2Grid(r),round(F),get(odf,'CS'),get(odf,'SS'));
  
elseif check_option(varargin,'integral') %along smallcircles
  
  mintheta = get_option(varargin,'mintheta',0*degree);
  maxtheta = get_option(varargin,'maxtheta',90*degree);
  dtheta = get_option(varargin,'dtheta',10*degree);
  
  minrho = get_option(varargin,'minrho',0*degree);
  maxrho = get_option(varargin,'maxrho',360*degree);
  drho = get_option(varargin,'drho',10*degree);
  
  %output grid
  dtheta = mintheta:dtheta:maxtheta;
  r = S2Grid('theta',dtheta,'rho',minrho:drho:maxrho);
  
  inc = drho/steps;
  np = floor((maxrho-minrho)./drho);
  
  drho = minrho-drho/2:inc:maxrho+drho/2;
  tmp = S2Grid('theta',dtheta,'rho',drho);
  
  f = reshape(pdf(odf,h,tmp), GridSize(tmp));
  f = f.*rnd(size(f)); % maybe we count something

  %cummulate
  F = zeros(GridSize(r));
  for k=1:np
    ind = k*steps+1:(k+1)*steps;
    F(k,:) = sum( f(ind,:),1);
  end
  
  PF = PoleFigure(h,r,round(F),get(odf,'CS'),get(odf,'SS'));
 
elseif check_option(varargin,'path') % along a defined great circle
    
  if ~isempty(find_type(varargin,'vector3d'))
    pos = find_type(varargin,'vector3d');
  elseif find_type(varargin,'S2Grid')
    pos = find_type(varargin,'S2Grid');
  end
  A = vector3d(varargin{pos});
  B = vector3d(varargin{pos+1});
  A = A./norm(A);
  B = B./norm(B);
  sz = size(A);
  A = A(:);
  B = B(:);
  rotaxis = cross(A,B); % rot about orthodrome
  ww = angle(A,B);      % distance to perform
  
  n = numel(A);
  w = zeros(n,steps);
  for k=1:n
    w(k,:) = linspace(0,ww(k),steps);
  end
  
  v = repmat(vector3d,n,steps);
  for l=1:steps
    q = axis2quat(rotaxis, w(:,l));
    v(:,l) = q(:).*A;
  end
  
  v(~isfinite(v.x(:)))= zvector;
  v = reshape(v,n,steps);
  
  F = reshape(pdf(odf,h,v),size(v));
  F = F.*rnd(size(v));
  F = reshape(sum(F,2),sz);
  
  PF = PoleFigure(h,S2Grid(B),floor(F),get(odf,'CS'),get(odf,'SS'));

end

maxtheta = get_option(varargin,'maxtheta',90*degree,'double');
PF = delete(PF, getTheta(getr(PF)) > maxtheta);

