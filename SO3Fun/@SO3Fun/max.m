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

while res > targetRes

  % new grid
  ori = [oriNextSeed(:).';...
    localOrientationGrid(SO3F.CS,SO3F.SS,res,'center',oriNextSeed,'resolution',res/4)];
    
  % evaluate ODF
  f = eval(SO3F,ori,varargin{:});
  
  % extract largest values
  oriNextSeed = ori(f>=quantile(f(:),0));
  
  res = res / 2; 
end

[values,ind] = max(f(:));
modes = ori(ind);

end

% -------------------------------------------------------

function [values,modes] = maxLocal(SO3F,varargin)

% initial resolution
res = get_option(varargin,'resolution',5*degree);

% target resolution
targetRes = get_option(varargin,'accuracy',0.25*degree);

% initial seed
S3G = get_option(varargin,'startingNodes');
  
if isempty(S3G)
  S3G = equispacedSO3Grid(SO3F.CS,SO3F.SS,'resolution',res);
end

f = eval(SO3F,S3G,varargin{:});

% eliminate zeros
del = f>0;
qa = S3G(del);
f = f(del);

% the search grid
S3Gs = subGrid(S3G,del);
T = find(S3Gs,qa,res*1.5);

[f, ndx] = sort(f,'descend');
qa = qa(ndx);

T = T(ndx,:);
T = T(:,ndx);
T = T -speye(size(T));

% look for maxima
nn = numel(f);
ls = false(1,nn);
ids = false(1,nn);

[ix, iy] = find(T);
cx = [0 ; find(diff(iy))];

num = get_option(varargin,'numLocal',1);

for k=1:length(cx)-1
  id = ix(cx(k)+1:cx(k+1));
  ls(id) = true;  
  ids(k) = ls(:,k)==0;
  
  if nnz(ids)>=num, break,end
end

% the retrived maximas
q = qa(ids);
values = f(ids);

%centering of local max
for k=1:length(q)
  res2 = res/2;
  while res2 > targetRes
    res2 = res2/2;
    S3G = localOrientationGrid(SO3F.CS,SO3F.SS,res2*4,'center',q(k),'resolution',res2);
    f = eval(SO3F,S3G,varargin{:});
    
    [mo, ndx] = max(f);
    q(k) = S3G(ndx);
    values(k) = mo;
  end
end

modes = orientation(q,SO3F.CS,SO3F.SS);

end
