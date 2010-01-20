function d = dot_outer(o1,o2)
% dot_outer
%
%% Input
%  o1, o2 - @orientation
%
%% Output
%


g1 = reshape(quaternion(o1),1,[]);
g2 = reshape(quaternion(o2),1,[]);

l1 = length(g1);
l2 = length(g2);
if isa(o1,'orientation')
  cs = quaternion(o1.CS);
  ss = quaternion(o1.SS);
else
  cs = quaternion(o2.CS);
  ss = quaternion(o2.SS);
end
lCS = length(cs);
lSS = length(ss);

if (l1 < l2) && (l1>0)
	g1rot = reshape(reshape(ss * g1,[],1) * cs.',[lSS l1 lCS]);
	g1rot = permute(g1rot,[3 1 2]); % -> CS x SS x g1
						
	d = reshape(dot_outer(g1rot,g2),[lCS * lSS,l1,l2]); %-> CS * SS x g1 x g2
	d = reshape(max(d,[],1),l1,l2);
		
elseif l2>0
	g2rot = reshape(reshape(ss * g2,[],1) * cs.',[lSS l2 lCS]);
	g2rot = shiftdim(g2rot,1); % -> g2 x CS x SS
						
	d = reshape(dot_outer(g1,g2rot),[l1,l2,lCS * lSS]);
	d = max(d,[],3);
else
	d = [];
end

d = max(min(d,1),-1);
