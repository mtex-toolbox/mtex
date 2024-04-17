function [values,modes] = max(SO3F,varargin)
% global, local and pointwise maxima of functions on SO(3)
%
% Syntax
%   [v,pos] = max(SO3F) % the position where the maximum is atained
%
%   [v,pos] = max(SO3F,'numLocal',5) % the 5 largest local maxima
%
%   SO3F = max(SO3F, c) % maximum of a rotational functions and a constant
%   SO3F = max(SO3F1, SO3F2) % maximum of two rotational functions
%   SO3F = max(SO3F1, SO3F2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the maximum of a multivariate function along dim
%   SO3F = max(SO3Fmulti,[],dim)
%
% Input
%  SO3F, SO3F1, SO3F2 - @SO3Fun
%  SO3Fmulti          - a multivariate @SO3Fun
%  c                  - double
%
% Output
%  v - double
%  pos - @rotation / @orientation
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @rotation / @orientation
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%
% Example
%
%   %find the local maxima of the <SantaFe.html SantaFe> ODF
%   [value,ori] = max(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,ori.CS))
%   annotate(ori)
%
% See also
% SO3Fun/min

modes=[];

% max(SO3F1, SO3F2)
if ( nargin > 1 ) && ( isa(varargin{1}, 'SO3Fun') )
  SO3F2 = varargin{1};
  ensureCompatibleSymmetries(SO3F,SO3F2);
  values = SO3FunHandle(@(rot) max(SO3F.eval(rot),SO3F2.eval(rot)),SO3F.CS,SO3F.SS);
  if isa(SO3F,'SO3FunHarmonic') || isa(SO3F2,'SO3FunHarmonic')
    values = SO3FunHarmonic(values,'bandwidth', ...
        min(getMTEXpref('maxSO3Bandwidth'),max(SO3F.bandwidth,SO3F2.bandwidth)));  
  end
  
elseif ( nargin > 1 ) && ( isnumeric(varargin{1}) ) % max(SO3F1, SO3F2)

  values = SO3FunHandle(@(rot) max(SO3F.eval(rot),varargin{1}),SO3F.CS,SO3F.SS);
  if isa(SO3F,'SO3FunHarmonic')
    values = SO3FunHarmonic(values,'bandwidth',min(getMTEXpref('maxSO3Bandwidth'),SO3F.bandwidth));
  end
  
else

  % initial resolution
  res0 = get_option(varargin,'resolution',5*degree);

  % target resolution
  targetRes = get_option(varargin,'accuracy',0.25*degree);

  % initial seed
  S3G = get_option(varargin,'startingNodes');
  
  if isempty(S3G)
    antiFlag = {[],'antipodal'};
    S3G = equispacedSO3Grid(SO3F.CS,SO3F.SS,'resolution',res0,antiFlag{1+SO3F.antipodal});
  end
  S3G = reshape(S3G,[],1);

  % evaluate function on grid
  f = eval(SO3F,S3G,varargin{:});

  % take only local minima as starting points
  ind = isLocalMinD(-f,S3G,1.5*res0,varargin{:});
  modes = S3G(ind);
  values = f(ind);

  % the total walking distance
  sumOmega = zeros(size(modes));

  numLocal = get_option(varargin, 'numLocal',1);

  % local refinement
  res = res0;
  while res > targetRes
    res = res / 1.25;

    % neighborhood search
    S3Glocal = localOrientationGrid(SO3F.SLeft,SO3F.SLeft,2*res,'resolution',res/2);
    newModes = (S3Glocal * modes).';
    f = eval(SO3F,newModes,varargin{:});
  
    if numLocal == 1

      [values,id] = max(f(:));
      modes = newModes(id);
        
    else
      [values,id] = max(f,[],2);
      modes = newModes(sub2ind(size(newModes),(1:length(modes)).',id));

      % keep track of the walking distance
      omega = S3Glocal.angle;
      sumOmega = sumOmega + omega(id);

      % maybe we can reduce the number of points a bit
      [~,~,I] = unique(modes, 'tolerance', 1.5*res0,'noSymmetry');
      modes = normalize(accumarray(I,modes));
      values = accumarray(I,values,[],@mean);
      sumOmega = accumarray(I,sumOmega,[],@min);

      % consider only points that did not walked too far
      values(sumOmega>5*res0) = [];
      modes(sumOmega>5*res0) = [];
      sumOmega(sumOmega>5*res0) = [];
    end
  end

  [modes,~,I] = unique(modes, 'tolerance', 1.5*res0);
  values = accumarray(I,values,[],@mean);

  % format output
  [values, I] = sort(values,'descend');
  numLocal = min(length(values), numLocal);
  values = values(1:numLocal);
  modes = modes(I(1:numLocal));
  
end
