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
%  SO3Grid    - a @SO3Grid the @ODF is evaluatete on
%  delta      - specifies the opening angle for the initial search grid around input center
%  resolution - specifies the resolution for the initial search grid
%  silent     - dont verbose number of initial axes and the newton iteration
%
%  fourier    - use fourier coefficents as objective function
%
% Example:
% 
%   %Starting with an synthetic odf with orthorhombic symmetry
%   CS = crystalSymmetry('cubic')
%   SS = specimenSymmetry('orthorhombic')
%   ori = [orientation.byEuler(135*degree,45*degree,120*degree,CS,SS) ...
%          orientation.byEuler( 60*degree, 54.73*degree, 45*degree,CS,SS) ...
%          orientation.byEuler(70*degree,90*degree,45*degree,CS,SS)...
%          orientation.byEuler(0*degree,0*degree,0*degree,CS,SS)];
%
%   odf = unimodalODF(SS*ori);
%
%   %we define a rotational displacement
%   r2 = rotation.byEuler( 6*degree,4*degree,0*degree)
%   odf = rotate(odf,r2);
%   h = [Miller(0,0,1,CS),Miller(0,1,1,CS),Miller(1,1,1,CS)];
%   plotPDF(odf,h,'antipodal','complete');
%
%   %and now retrive the rotation back
%   [odr,r,v1,v2] = centerSpecimen(odf);
%   plotPDF(odr,h,'antipodal')
%


% get options
if nargin < 2, v0 = xvector; end
delta = get_option(varargin,'delta',45*degree);

% the ODF should not yet have a specimen symmetry
odf.SS = specimenSymmetry;

% two different algorithms
useFourier = check_option(varargin,'Fourier') || odf.isFourier;
% first Fourier based
if useFourier
  L = get_option(varargin,{'bandwidth','L'},16);
  odf = FourierODF(odf,'bandwidth',L);
else
  SO3 = get_option(varargin,'SO3Grid',...
    equispacedSO3Grid(odf.CS,odf.SS,varargin{:}));
  y0 = odf.eval(SO3);
end

vdisp('  searching for a first two fold symmetry axes',varargin{:});
v0 = hr2quat(zvector,v0) * ...
  equispacedS2Grid('maxtheta',delta,'resolution',5*degree,varargin{:});
v1 = initialSearch(v0);
v1 = hr2quat(zvector,v1) * ...
  equispacedS2Grid('maxtheta',2.5*degree,'resolution',0.75*degree);
v1 = initialSearch(v1);

vdisp('  searching for a second two fold symmetry axes',varargin{:});
v0 = rotation.byAxisAngle(v1,(-45:5:45)*degree) * orth(v1);
v2 = initialSearch(v0);
% refine search
v2 = rotation.byAxisAngle(v1,(-5:.5:5)*degree) * v2;
v2 = initialSearch(v2);

rot = rotation.map(v1,closesAxis(v1),v2,closesAxis(v2));
odf = rotate(odf,rot);

% ------------------- local functions -----------------------------------
% -----------------------------------------------------------------------

  function a = closesAxis(u)
    
    aa = [xvector,yvector,zvector]; aa = [aa,-aa];
    [~,i] = min(angle(u,aa));
    a = aa(i);
    
  end

  function v = initialSearch(v)
    
    progress(0,length(v));

    val = zeros(size(v));
    for k=1:length(v)
      progress(k,length(v));
      val(k) = f(v(k));
    end

    [fval,i] = min(val); v = v(i);

    vdisp(['  fit: ', xnum2str((1-fval)*100) '%']);
    
  end

  function y = f(v)
    % objective function - compare original ODF with the ODF rotate along v
    % about 180 degree
    
    if isnumeric(v), v = vector3d('theta',v(1),'rho',v(2));end
    rot = axis2quat(v,pi);
    
    % y = textureindex(rotate(odf,r) - odf);
    if useFourier
      
      y = norm(odf-rotate(odf,rot));
      
    else
      
      % TODO: maybe one can use interpolation here instead of evaluating the
      % ODF again
      yr = eval(rotate(odf,rot),SO3,'silent');
      y = sum((y0(:) - yr(:)).^2) ./ sum(y0(:).^2);
    end

  end

end
