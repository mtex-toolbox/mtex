function Omega = logm(ori,varargin)
% the logarithmic map that translates a rotation into a spin tensor
%
% Syntax
%   Omega = logm(mori) % spin tensor of a misorientation
%
%   Omega = logm(ori,ori_ref) % spin tensor in crystal coordinates
%   Omega = logm(ori,ori_ref,'left') % spin tensor in specimen coordinates
%
% Input
%  mori - misorientation
%  ori - @orientation
%  ori_ref - @orientation
%
% Output
%  Omega - @spinTensor
%
% See also
% orientation/log spinTensor/exp 


m = log(ori,varargin{:});
Omega = spinTensor(m);

%T = logm@quaternion(ori,varargin{:});

%if check_option(varargin,'left')
%  T.CS = ori.SS;
%else
%  T.CS = ori.CS;
%end

end