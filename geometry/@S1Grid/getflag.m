function out = getflag(G,flag)
% return flags

if nargin == 1
  out = G.flags;
else
  out = getflag(G.flags,S1G_flags,flag);
end
