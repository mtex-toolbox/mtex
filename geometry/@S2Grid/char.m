function c = char(S2G)
% convert to char

S2G = S2G(1);
if length(S2G.Grid) == numel(S2G.Grid)
    s = int2str(length(S2G.Grid));
else
    s = [int2str(size(S2G.Grid,1)),'x',int2str(size(S2G.Grid,2))];
end

c = [s, ' points, ',...
	'res.: ',xnum2str(getResolution(S2G) * 180/pi),mtexdegchar];
