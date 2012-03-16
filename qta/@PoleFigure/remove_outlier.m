function npf = remove_outlier(pf)
% replace outlier by more meaningful data
%
% remove_outlier is in fact a quantile filter that replaces all data that
% lower or larger then the 95 percent quantile within a certain 
% neigborhood by the 95 percent quantile. 
%
%% Syntax
% npf = remove_outlier(pf)
%
%% Input
%  pf - @PoleFigure
%
%% Output
%  npf - @PoleFigure

for i=1:length(pf)
	
	pf(i).data = remove_outlier(pf(i).data);
	
end

npf  = pf;
