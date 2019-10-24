function G = shift(G,delta)
% shifts S1Grid by delta
%
% Syntax
%   G = shift(G,delta)
%
% Input
%  S1G   - @S1Grid
%  delta - double
%
% Output
%  S1G - @S1Grid

for i = 1:length(G)
    G(i).points = G(i).points + delta;
    if G(i).periodic
      G(i).points = mod(G(i).points - G(i).min ,G(i).max-G(i).min) + G(i).min;
    end  
end

