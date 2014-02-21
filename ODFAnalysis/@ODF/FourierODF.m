function odf = FourierODF(odf,varargin)
% compute FourierODF from another ODF

f_hat = calcFourier(odf,varargin{:});

if abs(f_hat(1)) > 1e-10
  odf.weights = f_hat(1);
  f_hat = f_hat ./ odf.weights;
else
  odf.weights = 1;
end

odf.components = {FourierComponent(f_hat,odf.CS,odf.SS)};

end
