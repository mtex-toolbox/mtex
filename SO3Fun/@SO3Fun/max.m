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
%   mode = calcModes(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,mode.CS))
%   annotate(mode)
%
% See also
% SO3Fun/min

% find multiple modes
if check_option(varargin,'numLocal')
  [values, modes] = maxLocal(SO3F,varargin{:});
  return
end

if ( nargin > 1 ) && ( isa(varargin{1}, 'SO3Fun') )
  SO3F2 = varargin{1};
  ensureCompatibleSymmetries(SO3F,SO3F2);
  values = SO3FunHandle(@(rot) max(SO3F.eval(rot),SO3F2.eval(rot)),SO3F.CS,SO3F.SS);
  if isa(SO3F,'SO3FunHarmonic') || isa(SO3F2,'SO3FunHarmonic')
    values = SO3FunHarmonic(values,'bandwidth', ...
        min(getMTEXpref('maxSO3Bandwidth'),max(SO3F.bandwidth,SO3F2.bandwidth)));  
  end
  modes=[];
  return
end

if ( nargin > 1 ) && ( isnumeric(varargin{1}) )
  f = SO3FunHandle(@(rot) max(SO3F.eval(rot),varargin{1}),SO3F.CS,SO3F.SS);
  if isa(SO3F,'SO3FunHarmonic')
    values = SO3FunHarmonic(f,'bandwidth',min(getMTEXpref('maxSO3Bandwidth'),SO3F.bandwidth));
  end
  modes=[];
  return
end


% initial resolution
res = get_option(varargin,'resolution',5*degree);

% target resolution
targetRes = get_option(varargin,'accuracy',0.25*degree);

% initial seed
ori = get_option(varargin,'startingNodes');
  
if isempty(ori)
  ori = equispacedSO3Grid(SO3F.CS,SO3F.SS,'resolution',res);
  ori = orientation(ori);
end

% first evaluation
f = eval(SO3F,ori,varargin{:});

% extract 20 largest values
oriNextSeed = ori(f>=quantile(f(:),-20));

% TODO: check for constant function or two much orientations
while res > targetRes

  % new grid
  ori = [oriNextSeed(:).';...
    localOrientationGrid(SO3F.CS,SO3F.SS,res,'center',oriNextSeed,'resolution',res/4)];
    
  % evaluate ODF
  f = eval(SO3F,ori,varargin{:});
  
  % extract largest values
  if sum(f(:)>=quantile(f(:),0))>1e4 %&& var(f(:))==0
    warning(['The function has lots off possible minima. Thatswhy iterative gridify folds. ' ...
      'Possibly the function is constant.'])
    break
  end
  oriNextSeed = ori(f>=quantile(f(:),0));
  
  res = res / 2; 
end

[values,ind] = max(f(:));
modes = ori(ind);

end

% -------------------------------------------------------

function [values,modes] = maxLocal(SO3F,varargin)

% initial resolution
res0 = get_option(varargin,'resolution',5*degree);

% target resolution
targetRes = get_option(varargin,'accuracy',0.25*degree);

% initial seed
S3G = get_option(varargin,'startingNodes');
  
if isempty(S3G)
  S3G = equispacedSO3Grid(SO3F.CS,SO3F.SS,'resolution',res0);
end
S3G = reshape(S3G,[],1);

% evaluate function on grid
f = eval(SO3F,S3G,varargin{:});

% the neighbours
T = find(S3G,S3G,res0*1.5) - speye(length(S3G));
[ix, iy] = find(T);

% consider only local exatrema
ind = f > accumarray(iy,f(ix),[],@max);
modes = S3G(ind);
values = f(ind);

% the total walking distance
sumOmega = zeros(size(modes));

% local refinement
res = res0;
while res > targetRes
  res = res / 1.25;

  S3Glocal = localOrientationGrid(crystalSymmetry,crystalSymmetry,2*res,'resolution',res/2);
  omega = S3Glocal.angle;
  newModes = (S3Glocal * modes).';

  f = eval(SO3F,newModes,varargin{:});
  
  [values,id] = max(f,[],2);
  modes = newModes(sub2ind(size(newModes),(1:length(modes)).',id));

  % keep track of the walking distance
  sumOmega = sumOmega + omega(id);

  %[max(omega(id))./degree, max(sumOmega ./degree)]

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

[modes,~,I] = unique(modes, 'tolerance', 1.5*res0);
values = accumarray(I,values,[],@mean);

% format output
[values, I] = sort(values,'descend');
if check_option(varargin, 'numLocal')
  n = get_option(varargin, 'numLocal');
  n = min(length(values), n);
  values = values(1:n);
else
  %n = sum(f-f(1) < 1e-4);
  n = 1;
  values = values(1);
end
modes = modes(I(1:n));

end
