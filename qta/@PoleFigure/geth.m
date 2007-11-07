function h = geth(pf)
% get crystal directions
%
%% Input
% pf - @PoleFigure
%
%% Output
%  h - @vector3d crystal directions
%
%% See also 
% PoleFigure/getMiller PoleFigure/getr PoleFigure/getdata PoleFigure/getbg

h = vector3d;
for i = 1:length(pf)
    h = [h,vector3d(pf(i).h)]; %#ok<AGROW>
end
