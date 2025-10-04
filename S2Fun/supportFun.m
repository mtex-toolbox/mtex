function sptFun = supportFun(sF,varargin)

bw = get_option(varargin,'bandwidth',100);

S2G = quadratureS2Grid(bw,'antipodal');

values = sF.eval(S2G);

neighbors = S2G.find(S2G,1000);

newValues = sum(dot(S2G,S2G(neighbors)) .* values(neighbors),2);

sptFun = S2FunHarmonic.quadrature(S2G,newValues);


end