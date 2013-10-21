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

if length(alpha) ==1, alpha = repmat(alpha,size(pf));end

for i = 1:length(pf)
  pf(i).intensities = pf(i).intensities * alpha(i);
end
