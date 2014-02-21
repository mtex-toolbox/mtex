function pf = scale(pf,alpha)
% scale polefigure by a factor
%
% Input
%  pf    - @PoleFigure
%  alpha - scaling factor
%
% Output
%  pf - @PoleFigure
%
% See also
% PoleFigure/mtimes

if length(alpha) ==1, alpha = repmat(alpha,1,pf.numPF);end

for i = 1:pf.numPF, pf.allI{i} = pf.allI{i} .* alpha(i); end
