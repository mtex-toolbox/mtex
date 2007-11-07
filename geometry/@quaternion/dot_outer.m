function d = dot_outer(g1,g2)
% outer inner product between two quaternions
%% Input
%  g1, g2 - @quaternion
%% Output
%  d - double
%
% formuala:
% cos angle(g1,g2)/2 = dout(g1,g2)

if ~isempty(g1) && ~isempty(g2)

	d = reshape(g1.a,[],1) * reshape(g2.a,1,[]) + ...
		reshape(g1.b,[],1) * reshape(g2.b,1,[]) + ...
		reshape(g1.c,[],1) * reshape(g2.c,1,[]) + ...
		reshape(g1.d,[],1) * reshape(g2.d,1,[]);

	d = abs(d);
	d = reshape(d,[numel(g1),numel(g2)]);
	
else
		d = [];
end
