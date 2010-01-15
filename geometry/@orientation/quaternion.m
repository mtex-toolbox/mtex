function q = quaternion(o,varargin)
% 
%
%% Input
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%  q  - @quaternion
%
%% Output
%  q - symmetrically equivalent orientations
%
%% Options
%  all, symeq - all symmetrically quaternions
%
%% See also

q = o.quaternion;

if check_option(varargin,{'all','symeq'})
  q = (q(:) * o.cs).'; % CS x M
  if length(o.ss)>1
    q = o.ss * q(:).';     % SS x (CS X M)
  end
  q = reshape(q,length(o.cs)*max(1,length(o.ss)),[]).'; % M x (CSxSS)
end
