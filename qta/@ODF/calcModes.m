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
%  find the local maxima of the [[SantaFe.html,SantaFe]] ODF
%
%    mode = calcModes(SantaFe)
%    plotpdf(SantaFe,Miller(0,0,1))
%    annotate(mode)
%
%
% See also
% ODF/max

% find multiple modes
if nargin > 1 && isnumeric(varargin{1})
  [modes, values] = findMultipleModes(odf,varargin{:});
  return
end

% initial resolution
res = 5*degree;

% target resolution
targetRes = get_option(varargin,'resolution',0.25*degree);

% extract symmetry
CS = odf(1).CS; SS = odf(1).SS;

% initial seed
S3G = [];

% TODO
for i = 1:length(odf) 
  
  switch class(odf(i))
  
      
    case'FibreODF' % fibre symmetric portion
     
      S3G = [S3G; orientation('fibre', odf(i).h, odf(i).r, CS, SS, 'resolution',res)]; %#ok<AGROW>
      
    case 'BinghamODF'
   
      S3G = [S3G;odf(i).A(:)]; %#ok<AGROW>
       
    case 'unimodalODF' % radially symmetric portion
      
      center = odf(i).center(odf(i).c>=quantile(odf(i).c,-20));
      S3G = [S3G;center(:)]; %#ok<AGROW>
      
  end
end

if isempty(S3G)
  S3G = equispacedSO3Grid(CS,SS,'resolution',res);
end

% first evaluation
f = eval(odf,S3G,varargin{:}); %#ok<EVLC>

% extract 20 largest values
g0 = S3G(f>=quantile(f(:),-20));

while res > targetRes

  % new grid
  S3G = [g0(:).',...
    localOrientationGrid(CS,SS,res,'center',g0,'resolution',res/4)];
    
  % evaluate ODF
  f = eval(odf,S3G,varargin{:}); %#ok<EVLC>
  
  % extract largest values
  g0 = S3G(f>=quantile(f(:),0));
  
  res = res / 2; 
end

[values,ind] = max(f(:));
modes = S3G(ind);

% -------------------------------------------------------

function [modes,values] = findMultipleModes(odf,varargin)

res = get_option(varargin,'resolution',5*degree);

S3G = extract_SO3grid(odf,'resolution',res,varargin{:});
f = eval(odf,S3G,varargin{:}); %#ok<EVLC>


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
  
  if nnz(ids)>=num, break,end;
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
    S3G = localOrientationGrid(odf(1).CS,odf(1).SS,res2*4,'center',q(k),'resolution',res2);
    f = eval(odf,S3G,varargin{:}); %#ok<EVLC>
    
    [mo, ndx] = max(f);
    q(k) = S3G(ndx);
    values(k) = mo;
  end
end

modes = orientation(q,odf(1).CS,odf(1).SS);

end