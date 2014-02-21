function [odf,r,v1,v2] = centerSpecimen(odf,center,varargin)
% rotatates an odf with specime symmetry into its symmetry axes
%
% centerSpecimen(odf,center) trys to find the normal vectors of orthorhombic
% symmetry for the x mirror and y mirror plane and calculates an rotation needed
% to rotate the odf back into these mirror planes.
% the routine starts with an lookaround grid for a given center (default
% xvector) to find a starting value for newton iteration.
%
% Input
%  odf    - @ODF
%  center - look arround center for a suiteable start value (default xvector)
%
% Output
%  odf    - rotated @ODF
%  r      - its rotation rotate(odf_out,r) = odf_in
%  v1,v2  - normal vector of the mirrorplans
%
% Options
%  delta      - stepsize for evaluating the gradient
%  itermax    - maximum number of newton iterations (default 5)
%  SO3Grid    - a @SO3Grid the @ODF is evaluatete on
%  maxpolar   - specifies the opening angle for the initial search grid around input center
%  resolution - specifies the resolution for the initial search grid
%  silent     - dont verbose number of initial axes and the newton iteration
%  plot        - plot objective function around center as axis distribution
%
%  fourier    - use fourier coefficents as objective function
%
% Examples
% Starting with an synthetic odf with orthorhombic symmetry
%
%       CS = symmetry('cubic')
%       SS = symmetry('orthorhombic')
%       h = [Miller(0,0,1),Miller(0,1,1),Miller(1,1,1)];
%       r = [ rotation('euler', 90*degree,35*degree,30*degree) ...
%         rotation('euler', 90*degree,35*degree,0*degree)]
%
%       sr = SS*r;
%       odf = unimodalODF(sr,CS);
%
% we define a rotational displacement
%
%       r2 = rotation('euler', 6*degree,4*degree,0*degree)
%       odf = rotate(odf,r2);
%
%       plotPDF(odf,h,'antipodal');
%
% and now retrive the rotation back
%
%       [odr,r,v1,v2] = centerSpecimen(odf);
%       plotPDF(odr,h,'antipodal')
%
%
%

return

options.delta = get_option(varargin,'delta',0.5*degree);

if nargin < 2
  center = xvector;
end


if check_option(varargin,'Fourier')
  if ~check_option(odf,'fourier')
    L = get_option(varargin,{'bandwidth','L'},16);
    odf.SS = symmetry;
    odf = FourierODF(odf,L);
  end
  options.odf = odf;
  options.c_hat = Fourier(odf);
else
  options.odf = odf;
  options.SO3 = get_option(varargin,'SO3Grid',...
    equispacedSO3Grid(odf.CS,odf.SS,'resolution',5*degree,varargin{:}));
  options.y = eval(options.odf,options.SO3);
end

options.resolution = get_option(varargin,'resolution',5*degree);
options.maxangle = get_option(varargin,'maxpolar',15*degree);
options.verbose = ~check_option(varargin,'silent');
options.itermax = get_option(varargin,'itermax',5);
options.plot = check_option(varargin,'plot');



if options.plot
  initialSearch(center,options);
  return
end

v1 = newton(initialSearch(center,options),options);
v2 = newton(initialSearch(orth(v1),options),options);

r = inv(rotation('map',v1,xvector,v2,yvector));
if all(isfinite(double(r)))
  odf = rotate(odf,r);
end



function v_start = initialSearch(center, options)

if options.plot
  %   v = S2Grid('plot','resolution',options.resolution,'maxtheta',110*degree,'mintheta',80*degree)
  v = plotS2Grid('resolution',options.resolution,'maxtheta',options.maxangle);
else
  v = equispacedS2Grid('resolution',options.resolution,'maxtheta',options.maxangle);
end

q = hr2quat(zvector,center);
vc = q*vector3d(v);

if options.verbose
  fprintf(' looking at %d rotational axes\n', numel(v))
end

n = length(vc);
val = zeros(size(vc));
global mtex_progress
mtex_progress = 1;
progress(0,n);
for k=1:length(vc)
  progress(k,n);
  val(k) = f(vc(k),options);
end

if options.plot
  figure, imagesc(reshape(val,size(v)))
  figure, plot(v,val,'smooth');
else
  [valm,i] = min(val);
  v_start = vector3d(vc(i));
end

function v = newton(v, options)

p = zeros(2,1);
[p(1),p(2)] = polar(vector3d(v));

fval = f(p,options);

if options.verbose
  fprintf(' starting at %f\n', fval)
end

oldfval = 0;
iter = 0;

while  iter < options.itermax  %&& (fval-oldfval) > 0
  oldfval = fval;
  iter = iter + 1;
  
  % jacobian
  jf = jacobian(p,options);
  
  % defect
  df = gradient(p,options);
  
  p = p - jf\df;
  
  fval = f(p,options);
  
  if options.verbose
    fprintf(' defect at iteration %d: %f\n',iter, fval );
  end
end

v = sph2vec(p(1),p(2));


function jf = jacobian(j,options)
% the jacobian

if isa(j,'vector3d')
  [j(1) j(2)] = polar(j);
end

delta = options.delta;

jf = zeros(2,2);
for k=1:2
  jp = j; jm = j;
  
  jp(k) = j(k) + delta/2;
  jm(k) = j(k) - delta/2;
  
  jf(:,k) = (gradient(jp,options) - gradient(jm,options));
end
jf = jf./delta;


function df = gradient(d,options)
% the gradient

if isa(d,'vector3d')
  [d(1) d(2)] = polar(d);
end

delta = options.delta;

df = zeros(2,1);
for k=1:2
  dp = d; dm = d;
  
  dp(k) = d(k) + delta/2;
  dm(k) = d(k) - delta/2;
  
  df(k) = (f(dp,options) - f(dm,options));
end
df = df./delta;


function y = f(v,options)
% objective function

if isnumeric(v)
  r = axis2quat(sph2vec(v(1),v(2)),pi);
else
  r = axis2quat(v,pi);
end

% y = textureindex(rotate(options.odf,r)-options.odf);
if isfield(options,'c_hat')
  D2 = options.c_hat;
  L = dim2deg(numel(D2));
  D1 = wignerD(r,'bandwidth',L);
  
  D3  = zeros(deg2dim(L+1),1);
  
  for l = 0:L
    d2d = deg2dim(l)+1:deg2dim(l+1);
    s = 2*l+1;
    D3(d2d) = ...
      reshape(D1(d2d),s,s) * ...
      reshape(D2(d2d),s,s);
  end
  y = sum(abs(D3-D2).^2);
  
  % y = abs(sum(D3-D2));
  % odf = FourierODF(D3-D2,get(options.SO3,'CS'),get(options.SO3,'CS'));
  % y = sum((eval(odf,options.SO3)).^2);
else
  odf = rotate(options.odf,r);
  yo = options.y;
  yr = eval(odf,options.SO3);
  
  y = sum((yo - yr).^2);
end



