function [ori,sym2,dSym1,dSym2] = project2FundamentalRegion(ori,varargin)
% projects orientation to a fundamental region
%
% Syntax
%   ori = project2FundamentalRegion(ori,rot_ref)
%
%   % compute sym1, sym2 such that 
%   % angle(inv(sym1) * mori * sym2, mori_ref) is minimum
%   [sym1, sym2] = project2FundamentalRegion(mori,mori_ref)
%
% Input
%  ori     - @orientation
%  ori_ref - reference @rotation
%
% Output
%  ori     - @orientation
%  sym1, sym2 - @rotation
%  
%
%

if nargout >= 2


  moriRef = varargin{1};

  sym1 = moriRef.CS.properGroup.rot;
  sym2 = moriRef.SS.properGroup.rot;
  
  omega = angle(sym1 * moriRef * sym2,moriRef,'noSymmetry');

  ind1 = min(omega,[],1) < 1e-5;
  ind2 = min(omega,[],2) < 1e-5;
  
  dSym1 = crystalSymmetry.byElements(sym1(ind1));
  dSym2 = crystalSymmetry.byElements(sym2(ind2));

  rSym1 = factor(moriRef.CS.properGroup,dSym1);
  rSym2 = factor(moriRef.SS.properGroup,dSym2);


  %mori = inv(ori1) * ori2;
  %
  % goal: find s1, s2 that minimizes
  %    angle(inv(ori1 * s1) * ori2 * s2,mori_ref)
  %    = angle(inv(ori1) * ori2,s1 * mori_ref * inv(s2))

  % factorizes s1 and s2 into rot1, d and rot2 such that 
  % s1 = rot1 * d and s2 = d * rot2
  
  mori_sym = sym1 * moriRef * inv(sym2); %#ok<MINV>

  d = dot_outer(ori,mori_sym,'noSymmetry');
  [~,id] = max(d,[],2);
  [id1,id2] = ind2sub(size(mori_sym),id);

  % a = inv(sym1(id1)) * mori * sym2(id2)

  ori = sym1(id1);
  sym2 = sym2(id2);
  
elseif isempty(ori.SS) || ismember(ori.SS.id, [1,2]) 
  ori = project2FundamentalRegion@quaternion(ori,ori.CS,varargin{:});
else
  if ori.antipodal, ap = {'antipodal'}; else, ap = {}; end
  CS = ori.CS; SS = ori.SS;
  ori = project2FundamentalRegion@quaternion(ori,CS,SS,varargin{:},ap{:});

  % ensure result is of type orientation
  if ~isa(ori,'orientation')
    ori = orientation(ori,CS,SS,ap{:});
  end
  
end
