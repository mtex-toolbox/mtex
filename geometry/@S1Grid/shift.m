function NG = shift(G,delta)
% shifts S1Grid by delta
%% Syntax
%  NG = shift(G,delta)
%
%% Input
%  S1G   - @S1Grid
%  delta - double
%% Output
%  S1G + delta

NG = G;
for i = 1:length(G)
    NG(i).points = G(i).points + delta;
		if NG(i).periodic
			NG(i).points = mod(NG(i).points - G(i).min ,G(i).max-G(i).min) + G(i).min;
		end	
end

