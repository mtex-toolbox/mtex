function d = dot_outer(rot1,rot2,varargin)
% dot_outer
%
% Input
%  rot1, rot2 - @rotation
%
% Output
%  d - double length(rot1) x length(rot2)

if ~isempty(rot1) && ~isempty(rot2)

  q1 = [rot1.a(:) rot1.b(:) rot1.c(:) rot1.d(:)];
  q2 = [rot2.a(:) rot2.b(:) rot2.c(:) rot2.d(:)];
  
  d = abs(q1 * q2.');
  
  if isa(rot1,'rotation') && isa(rot2,'rotation') && ~check_option(varargin,'ignoreInv')
    i = bsxfun(@xor,rot1.i(:),rot2.i(:).');
    d = ~i .* d;
  elseif isa(rot1,'rotation') && ~check_option(varargin,'ignoreInv')
    d(rot1.i,:) = 0;
  end
else
    d = [];
end