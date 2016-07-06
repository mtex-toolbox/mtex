function odf = FourierODF(C,CS,varargin)
% defines an ODF by its Fourier coefficients
%
% Syntax
%   odf = FourierODF(C,CS,SS)
%
% Input
%  C      - Fourier coefficients / C coefficients
%  CS, SS - crystal, specimen @symmetry
%
% Output
%  odf - @ODF
%
% See also
% ODF/ODF uniformODF fibreODF unimodalODF
  
% extract f_hat
if isa(C,'cell')
  f_hat = [];
  for l = 0:numel(C)-1
    f_hat = [f_hat;C{l+1}(:) * sqrt(2*l+1)]; %#ok<AGROW>
  end
else
  f_hat = C;
end

component = FourierComponent(f_hat,CS,varargin{:});
  
odf = ODF(component,1);

end
