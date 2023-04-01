function ind = isLocalMinD(v,x,res,varargin)
%
%

numLocal = 10*get_option(varargin,'numLocal',1);

% the neighbours
T = find(x, x, res*1.5) - speye(length(x));
[ix, iy] = find(T);

% check whether is is a local minima
delta = accumarray(iy,v(ix),[],@min) - v;


ind = delta > 0 & (v <= max(mink(v(delta>0),numLocal)) | delta >= min(maxk(delta,numLocal)));

end
