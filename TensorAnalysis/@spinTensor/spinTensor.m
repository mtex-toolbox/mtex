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
%  S - skew symmetric matrix
%  v - @vector3d
%  rot - @rotation
%  mori - mis@orientation
 
  methods
    function Omega = spinTensor(varargin)
            
      %Omega = Omega@velocityGradientTensor(varargin{:});
      Omega.rank = 2;
      
      if nargin == 0, return; else, in = varargin{1}; end
      
      if isa(in,'tensor') && in.rank==2

        % take only the antisymetric portion
        Omega.M = 0.5*(in.M - permute(in.M,[2 1 3:ndims(in.M)]));
        
        Omega.opt = in.opt;
        Omega.CS = in.CS;

      elseif isa(in,'rotation')
        
        Omega = logm(varargin{1});

        if isa(varargin{1},'orientation') && M.CS == M.SS, Omega.CS = M.CS; end
        
      elseif isa(in,'vector3d')
        
        [x,y,z] = double(in);
        
        Omega.M = zeros([3,3,size(z)]);
        Omega.M(2,1,:,:,:) =  z;
        Omega.M(3,1,:,:,:) = -y;
        Omega.M(3,2,:,:,:) =  x;

        Omega.M(1,2,:,:,:) = -z;
        Omega.M(1,3,:,:,:) =  y;
        Omega.M(2,3,:,:,:) = -x;
        
        if isa(in,'Miller'), Omega.CS = in.CS; end

      elseif isnumeric(in) % ensure it is antisymmetric

        Omega.M = 0.5*(in - permute(in,[2 1 3:ndims(in)]));
        
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
        v = reshape(v,size(Omega));
      end
    end
    
    function v = SO3TangentVector(Omega,varargin)
      
      if isa(Omega.CS,'crystalSymmetry')
        v = SO3TangentVector(Omega.M(3,2,:),-Omega.M(3,1,:),Omega.M(2,1,:),'right',varargin{:});
      else
        v = SO3TangentVector(Omega.M(3,2,:),-Omega.M(3,1,:),Omega.M(2,1,:),'left',varargin{:});
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
    
    function rot = exp(Omega,ori_ref,tS)
      
      rot = orientation(Omega);
      if nargin > 1
        if nargin>2 && tS.isLeft
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

