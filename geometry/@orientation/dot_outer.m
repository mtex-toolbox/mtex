function d = dot_outer(o1,o2,varargin)
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
  
  g1rot = symmetrise(g1,cs,ss,varargin{:}); % -> CS x SS x g1
  d = reshape(dot_outer(g1rot,g2),[lCS * lSS,l1,l2]); %-> CS * SS x g1 x g2
  if check_option(varargin,'all')
    d = permute(d,[2 3 1]); % g1 x g2 x CS * SS
  else
    d = reshape(max(d,[],1),l1,l2);
  end
		
elseif l2>0
  
	g2rot = symmetrise(g2,cs,ss,varargin{:}).'; % g2 x CS x SS
  d = reshape(dot_outer(g1,g2rot),[l1,l2,lCS * lSS]); % g1 x g2 x CS * SS
  
  if ~check_option(varargin,'all')
    d = max(d,[],3);
  end
	  
else
	d = [];
end

d = max(min(d,1),-1);
