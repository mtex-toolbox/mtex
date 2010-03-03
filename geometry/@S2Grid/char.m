function c = char(S2G,varargin)
% convert to char

if length(S2G) == numel(S2G)
    s = int2str(length(S2G));
else
    s = [int2str(size(S2G,1)),'x',int2str(size(S2G,2))];
end

c = [s, ' points'];
if ~check_option(varargin,'short')
  c = [s, ', res.: ',xnum2str(S2G.res * 180/pi),mtexdegchar];
end
