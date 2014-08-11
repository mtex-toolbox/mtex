function s = disjoint(s1,s2)
% returns the disjoint of two symmetry groups

% both symmetries are equal -> nothing is to do
if s1 == s2
  s = s1;
  return;
end

% check for equal rotations
[is1,is2] = find(isappr(dot_outer(s1,s2),1));

% no common rotation -> take triclinic
if numel(is1) == 1, s = crystalSymmetry; return; end

% take the equal ones
s = unique(s1.subSet(is1));

% find a symmetry that exactly contains s
% TODO!!
for i=1:32 % check all Laue groups
  
  ss = crystalSymmetry('pointId',i);
  
  if length(ss) == length(s) && all(any(isappr(dot_outer(s,ss),1)))
    s = ss;
    return
  end
  
end

% TODO:
% if length(s) == 6
%   s.laue = '-3m';
% elseif length(s) == 12
%   s.laue = '6/mmm';
% else
%   s.laue = 'unknown';
% end
