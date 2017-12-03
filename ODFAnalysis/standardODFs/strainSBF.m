function odf = strainSBF(varargin)
% define a strain basis function
%
% Syntax
%
%   cs = crystalSymmetry('222');
%   sS = slipSystem(Miller(1,0,0,cs,'uvw'),Miller(0,1,0,cs,'hkl'))
%
%   E = tensor(diag([1 -0.3 -0.7]),'name','strain')
%
%   odf = strainSBF(sS,E)
%
% Input
%  sS - @slipSystem
%  E  - strain @tensor
%
% Output
%  odf - @ODF
%
                      
component = strainComponent(varargin{:});

odf = ODF(component,1);

end
