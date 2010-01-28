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
  q = (q(:) * o.CS).'; % CS x M
  if length(o.SS)>1
    q = o.SS * q(:).';     % SS x (CS X M)
  end
  q = reshape(q,length(o.CS)*max(1,length(o.SS)),[]).'; % M x (CSxSS)
end
