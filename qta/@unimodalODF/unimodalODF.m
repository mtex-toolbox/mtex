classdef unimodalODF < ODF
% define a unimodal ODF
%
% Description
% *unimodalODF* defines a radially symmetric, unimodal ODF 
% with respect to a crystal orientation |mod|. The
% shape of the ODF is defined by a @kernel function.
%
% Syntax
%   mod = orientation('Euler',phi1,Phi,phi2,CS,SS)
%   odf = unimodalODF(mod) % default halfwidth 10 degree 
%   odf = unimodalODF(mod,'halfwidth',15*degree) % specify halfwidth
%   odf = unimodalODF(mod,CS,SS)  % specify crystal and specimen symmetry
%   odf = unimodalODF(mod,kernel) % specify @kernel shape 
%   odf = unimodalODF(mod,'weights',weights) % specify weights for each component
%
% Input
%  mod    - @quaternion modal orientation
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default -- 10°)
%  kernel - @kernel function (default -- de la Vallee Poussin)
%
%
% Output
%  odf - @ODF
%
% See also
% ODF/ODF uniformODF fibreODF

  properties
    center
    psi = kernel('de la Vallee Poussin','halfwidth',10*degree);
    c = 1;
  end
 
  methods
    
    function odf = unimodalODF(varargin)
      
      % call superclass constructor
      odf = odf@ODF(varargin{:});      
            
      if nargin > 0 && isa(varargin{1},'ODF'), return;end
      
      % get center
      if nargin > 0 && isa(varargin{1},'quaternion')

        odf.center = varargin{1};
        
        if isa(odf.center,'orientation')
          odf.CS = get(odf.center,'CS');
          odf.SS = get(odf.center,'SS');
        else
          odf.center = orientation(odf.center,odf.CS,odf.SS);
        end
      else
        odf.center = orientation(idquaternion,odf.CS,odf.SS);
      end

      % get kernel
      if nargin > 1 && isa(varargin{2},'kernel')
        odf.psi = varargin{2};
      else
        hw = get_option(varargin,'halfwidth',10*degree);
        odf.psi = kernel('de la Vallee Poussin','halfwidth',hw);
      end

      % get weights
      odf.c = get_option(varargin,'weights',ones(size(odf.center)));
      assert(numel(odf.c) == length(odf.center),...
        'Number of orientations and weights must be equal!');
            
    end
  end
  
  methods(Access=protected)
    f = doEval(odf,g,varargin)
    Z = doPDF(odf,h,r,varargin)
    mdf = doMDF(odf1,odf2,varargin)
    odf = doRotate(odf,q,varargin)
    f_hat = doFourier(odf,L,varargin)
    ori = discreteSample(odf,npoints,varargin)
    [v,varargout] = doVolume(odf,center,radius,varargin)
    doDisplay(odf)
  end    
  
end
