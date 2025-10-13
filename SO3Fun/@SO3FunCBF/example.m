function f = example(varargin)
% example of and FibreODF
%

cs = crystalSymmetry.load('Ti-Titanium-alpha.cif');

% define the fibre to be the beta fibre
warning off
f = fibre.beta(cs);
warning on

% define a fibre ODF
f = fibreODF(f,'halfwidth',10*degree);

end