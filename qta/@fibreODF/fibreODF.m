classdef fibreODF < ODF
% defines an fibre symmetric ODF
%
% Description
% *fibreODF* defines a fibre symmetric ODF with respect to 
% a crystal direction |h| and a specimen directions |r|. The
% shape of the ODF is defined by a @kernel function.
%
% Syntax
%   h = Miller(h,k,l,CS)
%   r = vector3d(x,y,z);
%   odf = fibreODF(h,r) % default halfwith 10*degree
%   odf = fibreODF(h,r,'halfwidth',15*degree) % specify halfwidth
%   odf = fibreODF(h,r,kernel) % specify @kernel shape
%   odf = fibreODF(h,r,CS,SS)  % specify crystal and specimen symmetry
%
% Input
%  h      - @Miller / @vector3d crystal direction
%  r      - @vector3d specimen direction
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default -- 10°)
%  kernel - @kernel function (default -- de la Vallee Poussin)
%
% Output
%  odf - @ODF
%
% See also
% ODF/ODF uniformODF unimodalODF

  properties
    h
    r
    psi = kernel('de la Vallee Poussin','halfwidth',10*degree);
    c = 1;
  end
  
  methods
    function odf = fibreODF(varargin)

      % call superclass constructor
      odf = odf@ODF(varargin{:});      
      
      % copy constructor -> done
      if nargin > 0 && isa(varargin{1},'ODF'), return;end
            
      % get fibre
      odf.h = argin_check(varargin{1},'Miller');
      odf.r = argin_check(varargin{2},'vector3d');
      
      % check crystal symmetry
      if isCS(odf.CS)
        odf.h = ensureCS(odf.CS,{odf.h});
      else
        odf.CS = get(odf.h,'CS');
      end
      
      % get kernel
      if nargin > 2 && isa(varargin{3},'kernel')
        odf.psi = varargin{3};
      else
        hw = get_option(varargin,'halfwidth',10*degree);
        odf.psi = kernel('de la Vallee Poussin','halfwidth',hw);
      end
    
      % get weights
      odf.c = get_option(varargin,'weights',ones(size(odf.h)));
      assert(numel(odf.c) == length(odf.h),...
        'Number of orientations and weights must be equal!');
            
    end
  end
  
  methods(Access=protected)
    f = doEval(odf,g,varargin)
    Z = doPDF(odf,h,r,varargin)
    odf = doRotate(odf,q,varargin)
    f_hat = doFourier(odf,L,varargin)
    ori = discreteSample(odf,npoints,varargin)
    doDisplay(odf)
  end    
  
end
