function [isInside,tId,bario] = checkInside(sT,v,tId)
%
%
%

tId = tId(:);

bario = dot(repmat(v(:),1,3),sT.edges(tId,:));

bario(-1e-6 < bario & bario < 0) = 0;
isInside = all(bario>=0,2);

[~,dir] = min(bario,[],2);

tId(~isInside) = sT.neighbours((tId((~isInside))-1)*3 + dir(~isInside));

end
