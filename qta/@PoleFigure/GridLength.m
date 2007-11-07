function l = GridLength(pf)
% vector of sizes of the Pole Figures
%
%% Input
% pf - @PoleFigure
%
%% Output
% l - number of specimen directions per pole figure
%
%% See also
% S2Grid/GridLength

for i = 1:length(pf)
    l(i) = sum(GridLength(pf(i).r)); %#ok<AGROW>
end
