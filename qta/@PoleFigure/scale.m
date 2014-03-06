function new = scale(pf,alpha)
% scale polefigure by a factor
%
%% Input
% pf    - @PoleFigure
% alpha - scaling factor
%
%% Output
%
% new - scaled @PoleFigure
%
%% See also
% PoleFigure/mtimes

if length(alpha) ==1
		alpha= repmat(alpha,size(pf));
end

for i = 1:length(pf)
    pf(i).data = pf(i).data * alpha(i);
end

new = pf;
