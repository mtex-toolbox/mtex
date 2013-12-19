function pf = fliplr(pf)
% flipes pole figures left to right
%
%% Syntax  
% pf = flipud(pf)
% 
%% Input
%  pf - @PoleFigure
%
%% Output
%  pf - @PoleFigure
%
%% See also
% PoleFigure/fliplr PoleFigure/rotate ODF/rotate

for ipf = 1:length(pf)
	pf(ipf).r =  fliplr(pf(ipf).r);
end
