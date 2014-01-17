function odf = FourierODF(odf,varargin)
% compute FourierODF from another ODF

f_hat = calcFourier(odf,varargin{:});
odf.weights = f_hat(1);
f_hat = f_hat ./ odf.weights;

odf.components = FourierComponent(f_hat,odf.CS,odf.SS);

end
