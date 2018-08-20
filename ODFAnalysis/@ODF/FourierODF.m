function odf = FourierODF(odf,varargin)
% compute FourierODF from another ODF

if length(odf.components) == 1 && isa(odf.components{1},'FourierComponent')
  return
end

f_hat = calcFourier(odf,varargin{:});
f_hat(1) = real(f_hat(1));

if abs(f_hat(1)) > 1e-10
  odf.weights = f_hat(1);
  f_hat = f_hat ./ odf.weights;
else
  odf.weights = 1;
end

ap = odf.antipodal;
odf.components = {FourierComponent(f_hat,odf.CS,odf.SS)};
odf.antipodal = ap;

end
