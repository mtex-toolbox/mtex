function d = dot_outer(g1,g2)
% outer inner product between two quaternions
%% Input
%  g1, g2 - @quaternion
%% Output
%  d - double
%
%% formuala:
% cos angle(g1,g2)/2 = dot(g1,g2)

if ~isempty(g1) && ~isempty(g2)

  a = g1.a(:) * g2.a(:).';
  b = g1.b(:) * g2.b(:).';
  c = g1.c(:) * g2.c(:).';
  d = g1.d(:) * g2.d(:).';

  d = a + b + c + d;

% 	d = g1.a(:) * g2.a(:).' + g1.b(:) * g2.b(:).' + ...
% 		g1.c(:) * g2.c(:).' + g1.d(:) * g2.d(:).';

  %d = quaternion_dot_outer(g1.a,g1.b,g1.c,g1.d,g2.a,g2.b,g2.c,g2.d);
	%d = abs(d);
		
else
		d = [];
end
