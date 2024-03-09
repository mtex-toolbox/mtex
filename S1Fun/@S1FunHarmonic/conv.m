function sF = conv(sF1, sF2, varargin)
% convolution of Fourier series 
%
% Syntax
%   sF = conv(sF1, sF2)
%
% Input
%  sF1, sF1 - @S1FunHarmonic
%
% Output
%  sF   - @S1FunHarmonic
%

if isnumeric(sF1)
  sF = conv(sF2,sF1,varargin{:});
  return
end
if isnumeric(sF2)
  sF = conv(sF1,S1FunHarmonic(sF2),varargin{:});
  return
end


% ------------------- convolution of S1Funs -------------------
bw = get_option(varargin,'bandwidth',min(sF1.bandwidth,sF2.bandwidth));

sF1 = S1FunHarmonic(sF1);
sF1.bandwidth = bw;
sF2 = S1FunHarmonic(sF2);
sF2.bandwidth = bw;

fhat = sF1.fhat.*sF2.fhat;
sF = S1FunHarmonic(fhat);

end