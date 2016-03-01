function sS = symmetrise(sS,varargin)
% find all symmetrically equivalent slips systems

if ~isa(sS.b,'Miller'), return; end

b = [];
n =  [];
for i = 1:length(sS)

  % find all symmetrically equivalent
  [mm,~] = symmetrise(sS.b(i),varargin{:});
  [nn,~] = symmetrise(sS.n(i),'antipodal'); %#ok<*PROP>
  
  % find orthogonal ones
  [r,c] = find(isnull(dot_outer(vector3d(mm),vector3d(nn))));

  % restricht to the orthogonal ones
  b = [b;mm(r)]; %#ok<*AGROW>
  n = [n;nn(c)];
end

sS.b = b;
sS.n = n;
  
end