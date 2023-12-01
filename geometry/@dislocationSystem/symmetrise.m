function dS = symmetrise(dS,varargin)
% find all symmetrically equivalent slips systems

if ~isa(dS.b,'Miller'), return; end

b = [];
l =  [];
u = [];
for i = 1:length(dS)

  % find all symmetrically equivalent
  mm = symmetrise(dS.b(i),'unique',varargin{:});
  ll = symmetrise(dS.l(i),'unique','antipodal'); %#ok<*PROP>
  
  % find those which have the same angles as the original system
  % for slip system this is of course 90 degree
  [r,c] = find(isnull(dot(dS.l(i),dS.b(i),'noSymmetry')-...
    dot_outer(mm,ll,'noSymmetry')));

  % restricht to the orthogonal ones
  b = [b;mm(r(:))]; %#ok<*AGROW>
  l= [l;ll(c(:))];
  u = [u;repmat(dS.u(i),length(r),1)];
end

dS.b = b;
dS.l = l;
dS.u = u;  

end
