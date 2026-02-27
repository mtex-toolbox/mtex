function W = weightedBurgersVec(ebsd,varargin)
% computes the weighted Burgers vector
% using the integral(default) or gradient method
%
% Syntax
%
%   % weighted Burgers vector in specimen coordinates
%   W = weightedBurgersVec(ebsd)
%
%   % weighted Burgers vector in specimen coordinates in a 5-by-5 loop
%   W = weightedBurgersVec(ebsd, 'windowSize', 2)
%
%   % weighted Burgers vector in crystal coordinates
%   W = inv(ebsd.orientations) .* weightedBurgersVec(ebsd)
%
%   % weighted Burgers vector using the gradient method, just considering
%   % nearest neighbor pixels
%   W = weightedBurgersVec(ebsd,'gradient')
%
% Input
%  ebsd - @EBSD
%
% Output
%  W - @vector3d weighted Burgers vector in specimen coordinates                
%
% Options
%  gradient   - use the gradient (Note, windowSize is always 1!)
%  windowSize - radius of the integral window (default = 1),
%               only used with integral method 
%
% References
%
% * <https://doi.org/10.1111/j.1365-2818.2009.03136.x Wheeler J.et al.,
% The weighted Burgers vector: a new quantity for constraining dislocation
% densities and types using electron backscatter diffraction on 2D sections 
% through crystalline materials>, J. Microscopy, 2009.
%

if ~(isa(ebsd,'EBSDsquare') | isa(ebsd,'EBSDhex'))
    mtexError(['This function requires an input of type EBSSDsquare' newline ...
               'run "ebsd=ebsd.gridify" first'])
end

if check_option(varargin,'gradient') % use the gradient method
  
  % the incomplete curvature tensor
  kappa = curvature(ebsd,varargin{:});

  % the incomplete Nye tensor
  alpha = dislocationDensity(kappa);

  % the weighted Burgers vector is simply its last column
  W = vector3d(alpha.M(1,3,:,:),alpha.M(2,3,:,:),alpha.M(3,3,:,:));
  W = reshape(W,size(ebsd));
  
else % use the integral method

  % ensure orientations 
  ebsd = ebsd.project2FundamentalRegion;

  wS = get_option(varargin,'windowSize',1);

  oriX = ebsd.orientations .\ xvector;
  oriY = ebsd.orientations .\ yvector;

  % the filters
  fY = repmat([-1 zeros(1,2*wS-1) 1],1+2*wS,1);
  fY([1 end],1) = -0.5; 
  fY([1 end],end) = 0.5;
  fX = -fY.';

  W = Miller.nan(size(ebsd),ebsd.CS);
  W.x = filter2(fX,oriX.x) + filter2(fY,oriY.x);
  W.y = filter2(fX,oriX.y) + filter2(fY,oriY.y);
  W.z = filter2(fX,oriX.z) + filter2(fY,oriY.z);

  % set everything to NaN where the loop crosses a grain or outer domain boundary
  sq = 2*wS-1;
  W((ordfilt2(ebsd.grainId,sq^2,ones(sq,sq)) ~= ordfilt2(ebsd.grainId,1,ones(sq+2,sq+2))) | ...
    (ordfilt2(ebsd.grainId,1,ones(sq,sq)) ~= ordfilt2(ebsd.grainId,(sq+2)^2,ones(sq+2,sq+2)))) = NaN;

  W = ebsd.orientations .* W;
  
  %normalize to area
  d = min(norm(ebsd.unitCell(1) - ebsd.unitCell(2:end)));
  W = W/(4 * wS^2 * d);

end

end
