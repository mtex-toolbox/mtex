function [modes, values] = calcModes(SO3F,varargin)
% heuristic to find modal orientations
%
% Syntax
%   [modes, values] = calcModes(odf,'numLocal',n)
%
% Input
%  odf - @SO3Fun 
%  n   - number of modes
%
% Output
%  modes - modal @orientation
%  values - values of the ODF at the modal @orientation
%
% Options
%  resolution  - search--grid resolution
%  accuracy    - in radians
%
% Example
%
%   %find the local maxima of the <SantaFe.html SantaFe> ODF
%   mode = calcModes(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,mode.CS))
%   annotate(mode)
%
% See also
% SO3Fun/max

if nargin > 1 && isnumeric(varargin{1})
  error('Please use the option "numLocal" to specify multiple maxima!')
end

% find multiple modes
if check_option(varargin,'numLocal')
  [modes, values] = findMultipleModes(SO3F,varargin{:});
  return
end

% initial resolution
res = get_option(varargin,'resolution',5*degree);

% target resolution
targetRes = get_option(varargin,'accuracy',0.25*degree);

% initial seed
ori = orientation(SO3F.CS,SO3F.SS);

if isa(SO3F,'SO3FunComposition')
  for i = 1:length(SO3F.components)
    F = SO3F.components{i};
    if isa(F,'SO3FunBingham') || isa(F,'SO3FunCBF') || isa(F,'SO3FunRBF')
      p = calcModes(F,res);
      ori = [ori,p(:).']; %#ok<AGROW>
    end
  end
end
  
if isempty(ori)
  ori = equispacedSO3Grid(SO3F.CS,SO3F.SS,'resolution',res);
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

function [modes,values] = findMultipleModes(odf,varargin)

res = get_option(varargin,'resolution',5*degree);

S3G = extract_SO3grid(odf,'resolution',res,varargin{:});
f = eval(odf,S3G,varargin{:});


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
if nargin > 1 && isa(varargin{1},'double')
  num = varargin{1};
end

for k=1:length(cx)-1
  id = ix(cx(k)+1:cx(k+1));
  ls(id) = true;  
  ids(k) = ls(:,k)==0;
  
  if nnz(ids)>=num, break,end
end

% the retrived maximas
q = qa(ids);
values = f(ids);

accuracy = get_option(varargin,'accuracy',0.25*degree);
%centering of local max
for k=1:length(q)
  res2 = res/2;
  while res2 > accuracy
    res2 = res2/2;
    S3G = localOrientationGrid(odf.CS,odf.SS,res2*4,'center',q(k),'resolution',res2);
    f = eval(odf,S3G,varargin{:});
    
    [mo, ndx] = max(f);
    q(k) = S3G(ndx);
    values(k) = mo;
  end
end

modes = orientation(q,odf.CS,odf.SS);

end