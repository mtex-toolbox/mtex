function [q val]= max(odf,varargin)
% heuristic to find local maxima
%
%% Input
%  odf - @ODF 
%  n   - number of maximas
%
%% Output
%  q - @orientation
%
%% Options
%  num         - number of maximas
%  resolution  - search-grid resolution
%  accuracy    - in radians
%
%% Example
%  find the first five local maxima
%  max(odf,5)
%  max(odf,'num',5)
%
%% Output
%  odf - @ODF
%
%% See also
% ODF/modalorientation

res = get_option(varargin,'resolution',5*degree);
S3G = SO3Grid(res,odf(1).CS,odf(1).SS);
qa = getFundamentalRegion(S3G);

dof = eval(odf,S3G,varargin{:}); %#ok<EVLC>

% eliminate zeros
del = dof>0;
qa = qa(del);
dof = dof(del);

% the search grid
S3Gs = subGrid(S3G,del);
T = find(S3Gs,qa,res*1.5);

[dof ndx] = sort(dof,'descend');
qa = qa(ndx);

T = T(ndx,:);
T = T(:,ndx);
T = T -speye(size(T));


% look for maxima
nn = numel(dof);
ls = false(1,nn);
ids = false(1,nn);

[ix iy] = find(T);
cx = [0 ; find(diff(iy))];

num = get_option(varargin,'num',1);
if nargin > 1 && isa(varargin{1},'double')
  num = varargin{1};
end

for k=1:length(cx)-1
  id = ix(cx(k)+1:cx(k+1));
  ls(id) = true;  
  ids(k) = ls(:,k)==0;
  
  if nnz(ids)>=num, break,end;
end

% the retrived maximas
q = qa(ids);
val = dof(ids);

accuracy = get_option(varargin,'accuracy',0.25*degree);
%centering of local max
for k=1:numel(q)
  res2 = res/2;
  while res2 > accuracy
    res2 = res2/2;
    S3G = SO3Grid(res2,odf(1).CS,odf(1).SS,'center',q(k),'max_angle',res2*2);
    qa = getFundamentalRegion(S3G);
    dof = eval(odf,S3G,varargin{:});
    
    [mo ndx] = max(dof);
    q(k) = qa(ndx);
  end
end

q = orientation(q,odf(1).CS,odf(1).SS);


