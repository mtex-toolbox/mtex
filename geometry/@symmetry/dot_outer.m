function d = dot_outer(CS,SS,g1,g2)
% dout_outer modulo symmetry
%% Input
%  CS, SS - @symmetry
%  g1, g2 - @quaternion 

g1 = reshape(g1,1,[]);
g2 = reshape(g2,1,[]);

l1 = length(g1);
l2 = length(g2);
lCS = length(CS.quat);
lSS = length(SS.quat);

if (l1 < l2) && (l1>0)
	g1rot = reshape(reshape(SS.quat * g1,[],1) * CS.quat.',[lSS l1 lCS]);
	g1rot = shiftdim(g1rot,-1); % -> CS x SS x g1
						
	d = reshape(dot_outer(g1rot,g2),[lCS * lSS,l1,l2]); %-> CS * SS x g1 x g2
	d = reshape(max(d,[],1),l1,l2);
		
elseif l2>0
	g2rot = reshape(reshape(SS.quat * g2,[],1) * CS.quat.',[lSS l2 lCS]);
	g2rot = shiftdim(g2rot,1); % -> g2 x CS x SS
						
	d = reshape(dot_outer(g1,g2rot),[l1,l2,lCS * lSS]);
	d = max(d,[],3);
else
	d = [];
end
