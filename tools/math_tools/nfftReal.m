function r = nfftReal
% whether nfftmex takes real valued plans (NFFT_REAL)
%
% Description
% An nfftmex built before NFFT_REAL ignores the flag and keeps the full
% spectrum of a complex plan, so the length of the spectrum of a small real
% plan tells the two apart. The answer is kept for the session.
%
% Syntax
%   r = nfftReal
%
% Output
%  r - true if the real plans of nfftmex hold the half spectrum
%

persistent isR
if isempty(isR)
  p = nfftmex('init_guru',{2,4,4,1,8,8,2,1+2^10+2^14,int8(64)});
  isR = numel(nfftmex('get_f_hat',p)) == 8;
  nfftmex('finalize',p);
end
r = isR;

end
