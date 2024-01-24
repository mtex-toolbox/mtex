function ind = isLocalMinD(v,x,res,varargin)
%
%

numLocal = 10*get_option(varargin,'numLocal',1);

if isa(x,'SO3Grid') || isa(x,'S2Grid')  
  % the neighbours
  T = find(x, x, res*1.5) - speye(length(x));
  [ix, iy] = find(T);

  % check whether is is a local minima
  v = v(:);
  delta = accumarray(iy,v(ix),[],@min) - v;

  ind = delta >= 0 & (v <= max(mink(v(delta>=0),numLocal)) | delta >= min(maxk(delta,numLocal)));
else  
  ind = v <= max(mink(v,numLocal));
end

end
