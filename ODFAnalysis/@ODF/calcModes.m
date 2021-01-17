function [modes, values] = calcModes(odf,varargin)
% heuristic to find modal orientations
%
% Syntax
%   [modes, values] = calcModes(odf,n)
%
% Input
%  odf - @ODF 
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
% ODF/max

% find multiple modes
if nargin > 1 && isnumeric(varargin{1})
  [modes, values] = findMultipleModes(odf,varargin{:});
  return
end

% initial resolution
res = get_option(varargin,'resolution',5*degree);

% target resolution
targetRes = get_option(varargin,'accuracy',0.25*degree);


% initial seed
ori = orientation(odf.CS,odf.SS);

for i = 1:length(odf.components)   
  ori = [ori,calcModes(odf.components{i},res)];     %#ok<AGROW>
end
  
if isempty(ori)
  ori = equispacedSO3Grid(odf.CS,odf.SS,'resolution',res);
end

% first evaluation
f = eval(odf,ori,varargin{:});

% extract 20 largest values
oriNextSeed = ori(f>=quantile(f(:),-20));

while res > targetRes

  % new grid
  ori = [oriNextSeed(:).';...
    localOrientationGrid(odf.CS,odf.SS,res,'center',oriNextSeed,'resolution',res/4)];
    
  % evaluate ODF
  f = eval(odf,ori,varargin{:});
  
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

num = get_option(varargin,'num',1);
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
