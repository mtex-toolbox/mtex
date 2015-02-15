function [odf,rot,v1,v2] = centerSpecimen(odf,v0,varargin)
% rotatates an odf with specimen symmetry into its symmetry axes
%
% centerSpecimen(odf,center) trys to find the normal vectors of orthorhombic
% symmetry for the x mirror and y mirror plane and calculates an rotation needed
% to rotate the odf back into these mirror planes.
% the routine starts with an lookaround grid for a given center (default
% xvector) to find a starting value for newton iteration.
%
% Input
%  odf - @ODF
%  v0  - @vector3d initial gues for a symmetry axis (default xvector)
%
% Output
%  odf    - rotated @ODF
%  rot    - @rotation such that rotate(odf_out,r) = odf_in
%  v1,v2  - normal vector of the two fold symmetry axes
%
% Options
%  delta      - stepsize for evaluating the gradient
%  itermax    - maximum number of newton iterations (default 5)
%  SO3Grid    - a @SO3Grid the @ODF is evaluatete on
%  maxpolar   - specifies the opening angle for the initial search grid around input center
%  resolution - specifies the resolution for the initial search grid
%  silent     - dont verbose number of initial axes and the newton iteration
%
%  fourier    - use fourier coefficents as objective function
%
% Example:
% Starting with an synthetic odf with orthorhombic symmetry
%
%       CS = crystalSymmetry('cubic')
%       SS = specimenSymmetry('orthorhombic')
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

% get options
if nargin < 2, v0 = xvector; end
delta = get_option(varargin,'delta',0.5*degree);
maxangle = get_option(varargin,'maxpolar',15*degree);
verbose = ~check_option(varargin,'silent');
itermax = get_option(varargin,'itermax',5);

% the ODF should not yet have a specimen symmetry
odf.SS = specimenSymmetry;

% two different algorithms
useFourier = check_option(varargin,'Fourier') || odf.isFourier;
% first Fourier based
if useFourier
  L = get_option(varargin,{'bandwidth','L'},16);
  D0 = odf.calcFourier(L);
else
  SO3 = get_option(varargin,'SO3Grid',...
    equispacedSO3Grid(odf.CS,odf.SS,varargin{:}));
  y0 = odf.eval(SO3);
end

vdisp('  searching for first two fold symmetry axes',varargin{:});
v0 = hr2quat(zvector,v0) * ...
  equispacedS2Grid('maxtheta',maxangle,'resolution',5*degree,varargin{:});
v1 = initialSearch(v0);
v1 = hr2quat(zvector,v1) * ...
  equispacedS2Grid('maxtheta',2.5*degree,'resolution',0.75*degree);
v1 = initialSearch(v1);
%v1 = newton(v1);

vdisp('  searching for second two fold symmetry axes',varargin{:});
v0 = rotation('axis',v1,'angle',(-45:5:45)*degree) * orth(v1);
v2 = initialSearch(v0);
% refine search
v2 = rotation('axis',v1,'angle',(-5:.5:5)*degree) * v2;
v2 = initialSearch(v2);

rot = inv(rotation('map',v1,xvector,v2,yvector));
if all(isfinite(double(rot))), odf = rotate(odf,rot); end

% ------------------- local functions -----------------------------------
% -----------------------------------------------------------------------

  function v = initialSearch(v)
    
    global mtex_progress, mtex_progress = 1;
    progress(0,length(v));

    val = zeros(size(v));
    for k=1:length(v)
      progress(k,length(v));
      val(k) = f(v(k));
    end

    [fval,i] = min(val); v = v(i);

    if verbose, fprintf('  fit: %f\n', fval); end
    
  end

  function v = newton(v)
    % perform newton iteration on the polar coordinates of v such that v
    % becomes a two fold symmetry axis

    p = zeros(2,1);
    [p(1),p(2)] = polar(vector3d(v));

    iter = 0;
    while  iter < itermax
  
      iter = iter + 1;
  
      % jacobian
      jf = jacobian(p);
  
      % defect
      df = gradient(p);
  
      p = p - jf \ df;
  
      fval = f(p);
      
      if verbose, fprintf('  fit at iteration %d: %f\n',iter, fval ); end
    end

    v = vector3d('theta',p(1),'rho',p(2));

  end

  function jf = jacobian(p)
    % the jacobian

    jf = zeros(2,2);
    for k=1:2
      jp = p; jm = p;
      
      jp(k) = p(k) + delta/2;
      jm(k) = p(k) - delta/2;
      
      jf(:,k) = gradient(jp) - gradient(jm);
    end
    jf = jf./delta;
    
  end

  function df = gradient(d)
    % discrete  gradient

    df = zeros(2,1);
    for k=1:2
      dp = d; dm = d;
      
      dp(k) = d(k) + delta/2;
      dm(k) = d(k) - delta/2;
      
      df(k) = f(dp) - f(dm);
    end
    df = df./delta;

  end

  function y = f(v)
    % objective function - compare original ODF with the ODF rotate along v
    % about 180 degree
    
    if isnumeric(v), v = vector3d('theta',v(1),'rho',v(2));end
    rot = axis2quat(v,pi);
    
    % y = textureindex(rotate(odf,r) - odf);
    if useFourier
      
      DRot = wignerD(rot,'bandwidth',L);
      
      D1  = zeros(deg2dim(L+1),1);
      for l = 0:L
        d2d = deg2dim(l)+1:deg2dim(l+1);
        s = 2*l+1;
        D1(d2d) = reshape(DRot(d2d),s,s) * reshape(D0(d2d),s,s);
      end
      y = sum(abs(D1-D0).^2) ./ sum(abs(D0).^2);
      
    else
      
      % TODO: maybe one can use interpolation here instead of evaluating the
      % ODF again
      yr = eval(rotate(odf,rot),SO3); %#ok<EVLC>
      y = sum((y0 - yr).^2) ./ sum(y0.^2);
    end

  end

end
