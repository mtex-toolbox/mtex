function W = weightedBurgersVec(ebsd,varargin)
% computes the weighted Burgers vector
%
% Syntax
%
%   % weighted Burgers vector in specimen coordinates
%   W = weightedBurgersVec(ebsd)
%
%   % weighted Burgers vector in crystal coordinates
%   W = inv(ebsd.orientations) .* weightedBurgersVec(ebsd)
%
%   % weighted Burgers vector using the integral methods
%   W = weightedBurgersVec(ebsd,'integral')
%
% Input
%  ebsd - @EBSD
%
% Output
%  W - @vector3d weighted Burgers vector in specimen coordinates
%
% Options
%  integral - use integral method
%  windowSize - size of the integral window (default = 1)
%
% References
%
% * <https://doi.org/10.1111/j.1365-2818.2009.03136.x The weighted Burgers
% vector: a new quantity for constraining dislocation densities and types
% using electron backscatter diffraction on 2D sections through crystalline
% materials>, J. Microscopy, 2009.
%

error('not yet implemented')

if check_option(varargin,'integral') % the integral method

  % ensure orientations 
  ebsd = ebsd.project2FundamentalRegion;

  wS = get_option(varargin,'windowSize',1);

  oriX = ebsd.orientations .\ xvector;
  oriY = ebsd.orientations .\ yvector;

  % the filters
  fY = repmat([-1 zeros(1,2*wS-1) 1],1+2*wS,1);
  fX = -fY.';

  W = Miller.nan(size(ebsd),ebsd.CS);
  W.x = filter2(fX,oriX.x) + filter2(fY,oriY.x);
  W.y = filter2(fX,oriX.y) + filter2(fY,oriY.y);
  W.z = filter2(fX,oriX.z) + filter2(fY,oriY.z);

  % set everything to nan where the loop crosses a grain or outer domain boundary
  sq = 2*wS-1;
  W((ordfilt2(ebsd.grainId,sq^2,ones(sq,sq)) ~= ordfilt2(ebsd.grainId,1,ones(sq+2,sq+2))) | ...
    (ordfilt2(ebsd.grainId,1,ones(sq,sq)) ~= ordfilt2(ebsd.grainId,(sq+2)^2,ones(sq+2,sq+2)))) = NaN;


  W = ebsd.orientations .* W;

else

  % the incomplete curvature tensor
  kappa = curvature(ebsd,varargin{:});

  % the incomplete Nye tensor
  alpha = dislocationDensity(kappa);

  % the weigthed Burgers vector is simply its last column
  W = vector3d(alpha.M(1,3,:,:),alpha.M(2,3,:,:),alpha.M(3,3,:,:));
  W = reshape(W,size(ebsd));
  
end

end
