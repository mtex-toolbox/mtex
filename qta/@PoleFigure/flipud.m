function pf = flipud(pf)
% flipes pole figures upside down
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
	pf(ipf).r =  flipud(pf(ipf).r);
end
