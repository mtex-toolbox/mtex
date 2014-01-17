classdef BinghamODF < ODF
%
%% Description
% *BinhamODF* defines a Bingham distributed ODF with A and Lambda.
%
%% Syntax
%  odf = BinghamODF(kappa,A,CS,SS)
%  odf = BinghamODF(kappa,q,CS,SS)
%  odf = BinghamODF(kappa,h,r,CS,SS)
%
%% Input
%  kappa  - form parameter
%  A      - 
%  h,r    - fibre
%  CS, SS - crystal, specimen @symmetry
%
%% Output
%  odf - @ODF
%
%% See also
% ODF/ODF uniformODF unimodalODF fibreODF
  
  properties
    A
    kappa = [1,0,0,0];
  end
 
  methods
    
    function odf = BinghamODF(varargin)
          
      % call superclass constructor
      odf = odf@ODF(varargin{:});      
            
      if nargin == 1 && isa(varargin{1},'ODF'), return;end
      
      % get kappa
      odf.kappa = argin_check(varargin{1},'double');
      odf.kappa = odf.kappa(:);
      if numel(odf.kappa) < 4
        odf.kappa = [odf.kappa(:);zeros(4-length(odf.kappa),1)];
      end
      
      % get A
      if isa(varargin{2},'double')
        
        odf.A = quaternion(varargin{2});
        
      elseif isa(varargin{2},'vector3d') && isa(varargin{3},'vector3d')
        
        % if only one kappa was given extend in to the second one
        if numel(varargin{1}) == 1, odf.kappa(2) = varargin{1};end

        odf.A = fibre2A(h,r);
        
      else
        
        odf.A = argin_check(varargin{2},'quaternion');                
                        
      end
      
      % if only one orientation was given -> extend to matrix
      if length(odf.A) == 1, odf.A = odf.A * quaternion(eye(4)); end
      
      odf.A = orientation(odf.A,odf.CS,odf.SS);  
      
    
      %orthogonality check
      assert(isappr(abs(det(squeeze(double(odf.A)))),1),'Center must be orthogonal');
                  
    end
    
  end
  
  methods(Access=protected)
    f = doEval(odf,g,varargin)
    Z = doPDF(odf,h,r,varargin)
    odf = doRotate(odf,q,varargin)
    f_hat = doFourier(odf,L,varargin);
    doDisplay(odf)
  end    
  
end


function A = fibre2A(h,r)

h = normalize(h);
r = normalize(r);

qr = quaternion(0,r);
qh = quaternion(0,h);

q1 = idquaternion - qr*qh;
q2 = qr+qh;

if isnull(norm(h-r))
  v1 = orth(h);
  v2 = cross(h,v1);
  q3 = quaternion(0,v1);
  q4 = quaternion(0,v2);
else
  q3 = idquaternion + qr*qh;
  q4 = qr-qh;
end

A = normalize([q1,q2,q3,q4]);
 
% reverse:
%h_0 = q_1^* q_2
%r_0 = q_2 q_1^*.

end
