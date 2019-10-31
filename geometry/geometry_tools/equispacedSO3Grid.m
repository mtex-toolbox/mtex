function S3G = equispacedSO3Grid(CS,SS,varargin)
% defines a equispaced grid in the orientation space
%
% Syntax
%   S3G = equispacedSO3Grid(CS,SS,'points',n)
%   S3G = equispacedSO3Grid(CS,'resolution',res)
%
%   % fill only a ball with radius of 20 degree
%   S3G = equispacedSO3Grid(CS,'maxAngle',20*degree)
%
% Input
%  CS  - @crystalSymmetry
%  SS  - @specimenSymmetry
%   n  - approximate number of points
%  res - resolution in radiant
%
% Output
%  S3G - @SO3Grid
%
% Options
%  maxAngle - radius of the ball to be filles
%  center - center of the ball
%
% See also
% equispacedS2Grid, SO3Grid/SO3Grid

% extract specimen symmetry if provided
if nargin == 1
  SS = specimenSymmetry('1');
elseif ~isa(SS,'symmetry')
  varargin = [{SS},varargin];
  SS = specimenSymmetry('1');
end

% may be we should populate only a ball
maxAngle = get_option(varargin,'maxAngle',2*pi);

if maxAngle < pi/2/CS.multiplicityZ
  S3G = localOrientationGrid(CS,SS,maxAngle,varargin{:});
  return
end

% get fundamental region
[maxAlpha,maxBeta,maxGamma] = fundamentalRegionEuler(CS,SS,'SO3Grid',varargin{:});
maxGamma = maxGamma/2; % we will consider the interval -maxGamma/2 .. maxGamma/2
if ~check_option(varargin,'center'), maxGamma = min(maxGamma,maxAngle);end

% determine resolution
if check_option(varargin,'points')

  points = get_option(varargin,'points');

  switch CS.LaueName  % special case: cubic symmetry
    case 'm-3'
      points = 3*points;
    case 'm-3m'
      points = 2*points;
  end

  % calculate number of subdivisions for the angles alpha,beta,gamma
  res = 2/(points/( maxBeta*maxGamma))^(1/3);

  if  maxAngle < pi * 2 && maxAngle < maxBeta
    res = res * maxAngle; % bug: does not work properly for all syms
  end

else

  res = get_option(varargin,'resolution',5*degree);

end

alphabeta = equispacedS2Grid('resolution',res,...
  'maxTheta',maxBeta,'minRho',0,'maxRho',maxAlpha,...
  no_center(res),'restrict2minmax');

ap2 = round(2*maxGamma/res);

[beta,alpha] = polar(alphabeta);

% calculate gamma shift
re = cos(beta).*cos(alpha) + cos(alpha);
im = -(cos(beta)+1).*sin(alpha);
dGamma = atan2(im,re);
dGamma = repmat(reshape(dGamma,1,[]),ap2,1);
gamma = -maxGamma + (0:ap2-1) * 2 * maxGamma / ap2;

% arrange alpha, beta, gamma
gamma  = dGamma+repmat(gamma.',1,length(alphabeta));
alpha = repmat(reshape(alpha,1,[]),ap2,1);
beta  = repmat(reshape(beta,1,[]),ap2,1);

ori = orientation.byEuler(alpha,beta,gamma,'ZYZ',CS,SS,varargin{:});

gamma = S1Grid(gamma,-maxGamma+dGamma(1,:),...
  maxGamma+dGamma(1,:),'periodic','matrix');

res = 2 * maxGamma / ap2;

% eliminiate 3 fold symmetry axis of cubic symmetries
% TODO: this should be done better!!
ind = fundamental_region(ori,CS,specimenSymmetry);

if nnz(ind) ~= 0
  % eliminate those rotations
  ori(ind) = [];

  % eliminate from index set
  gamma = subGrid(gamma,~ind);
  alphabeta  = subGrid(alphabeta,GridLength(gamma)>0);
  gamma(GridLength(gamma)==0) = [];

end


S3G = SO3Grid(ori,alphabeta,gamma,'resolution',res);

if check_option(varargin,'maxAngle')
  center = get_option(varargin,'center',quaternion.id);
  S3G = subGrid(S3G,center,maxAngle);
end


end

% ----------------------------------------------------------------
function s = no_center(res)

if mod(round(2*pi/res),2) == 0
  s = 'no_center';
else
  s = '';
end
end

% ---------------------------------------------------------------
function ind = fundamental_region(q,cs,ss)

if isempty(q), ind = []; return; end

c = {};

% eliminiate 3 fold symmetry axis of cubic symmetries
switch cs.LaueName

  case   {'m-3m','m-3'}

    c{end+1}.v = vector3d([1 1 1 1 -1 -1 -1 -1],[1 1 -1 -1 1 1 -1 -1],[1 -1 1 -1 1 -1 1 -1]);
    c{end}.h = sqrt(3)/3;

    if strcmp(cs.LaueName,'m-3m')
      c{end+1}.v = vector3d([1 -1 0 0 0 0],[0 0 1 -1 0 0],[0 0 0 0 1 -1]);
      c{end}.h = sqrt(2)-1;
    end
end

switch ss.LaueName
  case 'mmm'
   c{end+1}.v = vector3d([-1 0],[0 -1],[0 0]);
   c{end}.h = 0;
end

% find rotation not part of the fundamental region
rodrigues = Rodrigues(q); clear q;
ind = false(length(rodrigues),1);
for i = 1:length(c)
  for j = 1:length(c{i}.v)
    p = dot(rodrigues,1/norm(c{i}.v(j)) * c{i}.v(j));
    ind = ind | (p(:)>c{i}.h);
  end
end

end
