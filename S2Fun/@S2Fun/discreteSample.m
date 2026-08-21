function v = discreteSample(S2F,n,varargin)
% takes a random sample of n directions from S2Fun
%
% Syntax
%   v = discreteSample(S2Fun,n)
%
% Input
%  sF - @S2Fun
%  n - number of points
%
% Output
%  v -  @vector3d
%    -  @Miller in case of S2Fun is of type @S2FunHarmonicSym
%
% Options
%  compact - generate almost perfectly aligned sampling points
%

if check_option(varargin,{'compact','compactify','optimal'})
  v = optimalSample(S2F,n,varargin{:});
  return
end


res = get_option(varargin,'resolution',0.5*degree);

% take global random samples at grid points
S2G = equispacedS2Grid('resolution',res);
d = eval(S2F,S2G);

% take global random samples
d(d<0) = 0;   
v = S2G(discretesample(d,n));

% some local distortions
v = rotation.rand(n,'maxAngle',res*1.5) .* v(:);

% the sample lives in the reference frame of the function
if isa(S2F,'S2FunHarmonicSym') && isa(S2F.CS,'crystalSymmetry')
  v = Miller(v,S2F.CS);
elseif isa(S2F.frame,'crystalFrame')
  v = Miller(v, crystalSymmetry(S2F.frame));
else
  v.frame = S2F.frame;
end

% set antipodal if function is antipodal
if S2F.antipodal == 1; v.antipodal = 1; end
