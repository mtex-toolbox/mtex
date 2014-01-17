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
if numel(is1) == 1, s = symmetry; return; end

% take the equal ones
s = unique(subsref(s1,is1));

% find a symmetry that exactly contains s
for i=1:11 % check all Laue groups
  
  ss = symmetry(i);
  
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
