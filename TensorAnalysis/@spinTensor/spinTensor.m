classdef spinTensor < velocityGradientTensor
%
% Syntax
%
%   Omega = spinTensor(v)
%   Omega = spinTensor(S)
%   Omega = spinTensor(rot)
%   Omega = spinTensor(mori)
%
% Input
%  S - skew symmetry matrix
%  v - @vector3d
%  rot - @rotation
%  mori - mis@orientation
  
  
  methods
    function Omega = spinTensor(varargin)
      
      
      Omega = Omega@velocityGradientTensor(varargin{:},'rank',2);
      
      % ensure it is antisymmetric
      Omega.M = 0.5*(Omega.M - permute(Omega.M,[2 1 3:ndims(Omega.M)]));
      
      if nargin == 0; return; end
      
      if isa(varargin{1},'rotation')
        
        Omega = logm(varargin{:});
        
      elseif isa(varargin{1},'vector3d')
        
        [x,y,z] = double(varargin{1});
        
        Omega.M = zeros([3,3,size(z)]);
        Omega.M(2,1,:) =  z;
        Omega.M(3,1,:) = -y;
        Omega.M(3,2,:) =  x;

        Omega.M(1,2,:) = -z;
        Omega.M(1,3,:) =  y;
        Omega.M(2,3,:) = -x;
        
        Omega.rank = 2;
        if isa(varargin{1},'Miller'), Omega.CS = varargin{1}.CS; end        
      end
      
    end    

    function v = vector3d(Omega)
      
      if Omega.rank == 1
        v = vector3d@tensor(Omega);
      else
        v = vector3d(Omega.M(3,2,:),-Omega.M(3,1,:),Omega.M(2,1,:));
        if isa(Omega.CS,'crystalSymmetry')
          v = Miller(v,Omega.CS);
        end
      end
    end
    
    
    function rot = rotation(Omega)
      
      rot = rotation(expquat(Omega));
      
    end
    
    function rot = orientation(Omega)
      
      if isa(Omega.CS,'crystalSymmetry')
        rot = orientation(expquat(Omega),Omega.CS,Omega.CS);
      else
        rot = rotation(expquat(Omega));
      end
      
    end
    
    function rot = exp(Omega,ori_ref,varargin)
      rot = orientation(Omega);
      if nargin > 1
        if check_option(varargin,'left')
          rot = rot .* ori_ref;          
        else
          rot = ori_ref .* rot;
        end
      end
    end
    
    function omega = angle(Omega)
      
      omega = reshape(sqrt(Omega.M(2,1,:).^2 + Omega.M(3,1,:).^2 + Omega.M(3,2,:).^2),size(Omega));
      
    end
    
    
  end
  

end

