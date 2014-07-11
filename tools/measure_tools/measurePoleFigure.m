function PF = measurePoleFigure(odf,h,varargin)
% simulate a polefigure measurement
%
% Syntax
%   pf = measurePoleFigure(odf,h,@S2Grid,...) - 
%   pf = measurePoleFigure(odf,h,'integral','steps',30,'drho',5*degree,...) -
%   pf = measurePoleFigure(odf,h,'path',@vector3d,@vector3d,...) - 
%
% Input
% 
% Options
%  S2Grid     - perform a point measure
%  integral   - integrate over small circle while measuring
%  mintheta/minrho - S2Grid parameter
%  maxtheta/maxrho - 
%  dtheta   - 
%  drho     - length of integral way
%  path       - integrate from A to B, where data is cummulated to B
%  domega   - cummulate after a certain way
%  dpoints  - fill the path A to B with d--points
%  midpoint - cummulate to midpoint / else to endpoint of route
%  steps     - number of measures
%


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
  PF = PoleFigure(h,r,round(F),odf.CS,odf.SS);
  
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
  
  PF = PoleFigure(h,r,round(F),odf.CS,odf.SS);
 
elseif check_option(varargin,'path') % along a defined great circle
    
  domega  = get_option(varargin,'domega',[]);
  dpoints = get_option(varargin,'dpoints',1);
 
  if ~isempty(find_type(varargin,'vector3d'))
    pos = find_type(varargin,'vector3d');
  elseif find_type(varargin,'S2Grid')
    pos = find_type(varargin,'S2Grid');
  end
  
  A = vector3d(varargin{pos});  B = vector3d(varargin{pos+1});
  A = A./norm(A);  B = B./norm(B);
  sz = max(size(A),size(B));
  n = max(sz);
  A = A(:);  B = B(:);
  
  rotaxis = cross(A,B); % rot about orthodrome
  ndx = norm(rotaxis)==0;% no rotation
  rotaxis(ndx) = A(ndx); 
  ww = angle(A,B);      % distance to perform
    
  if ~isempty(domega) % point every omega
    inc = domega/steps;    
    dw = 0; dm = max(ww);
    iter = 1;
    v = repmat(vector3d(0,0,0),n,ceil(dm/inc));   
   	cs = [1:steps:ceil(dm/inc) ceil(dm/inc)];
    while dw <= dm
      sel =  dw <= ww;
      q = axis2quat(rotaxis, dw);
      if numel(A) == 1
        v(sel,iter) = q(sel).*A; 
      else
        v(sel,iter) = q(sel).*A(sel);
      end
      dw = dw+inc;
      iter = iter+1;
    end    
  else  %
    w = zeros(n,steps*dpoints);
    for k=1:n
      w(k,:) = linspace(0,ww(k),steps*dpoints);
    end

    v = repmat(vector3d(0,0,0),n,steps*dpoints);
    for l=1:steps*dpoints
      q = axis2quat(rotaxis, w(:,l));
      v(:,l) = q(:).*A;
    end
    cs = [1:steps:steps*dpoints steps*dpoints];
  end
  
  F = reshape(pdf(odf,h,v),size(v));
  F = F.*rnd(size(v)); % if randomize  
  Ff = zeros(n,length(cs)-1);
  for k=1:numel(cs)-1
    Ff(:,k) = sum(F(:,cs(k)+1:cs(k+1)),2);
  end

  % endpoints / midpoints
  if check_option(varargin,'midpoint')
    points = cs(2:end)-floor(steps/2)+1;
  else 
    points = cs(2:end);
  end
  
  v = v(:,points);
  ndx = isfinite(Ff) & ~isnull(v); 
  r = S2Grid(v(ndx));
  F = floor(Ff(ndx));
  
  PF = PoleFigure(h,r,F,get(odf,'CS'),get(odf,'SS'));

end

% restrict to upper hemisphere
maxtheta = get_option(varargin,'maxtheta',90*degree,'double');
PF = delete(PF, getTheta(getr(PF)) > maxtheta);

