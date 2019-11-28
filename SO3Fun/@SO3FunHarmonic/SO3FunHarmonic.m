classdef SO3FunHarmonic < SO3Fun
% A class representing a harmonic function on the rotational group.

properties
  fhat = []; % harmonic coefficients
  CS = crystalSymmetry
  SS = specimenSymmetry
end

properties (Dependent=true)  
  bandwidth;  % maximum harmonic degree / bandwidth
  power       % harmonic power
  antipodal;
end

methods
 
  function F = SO3FunHarmonic(fhat,CS,SS,varargin)
    % initialize a SO(3)-valued function
    
     if nargin == 0, return;end
     if nargin>1, F.CS = CS;end
     if nargin>2, F.SS = SS;end
     F.antipodal = check_option(varargin,'antipodal');
    
    % extract fhat
     if isa(fhat,'SO3FunHarmonic')
         F.fhat = fhat.fhat;
     elseif isa(fhat,'cell')
         F.fhat = [];
         for l = 1:numel(fhat)
             F.fhat = [F.fhat,fhat{l}(:)];
         end
     else
        % Make entries to the next polynomial degree
         F.fhat=fhat;
         F.fhat(size(fhat,1)+1:deg2dim(dim2deg(size(fhat,1))+1),:)=0;
     end
    
    % truncate zeros
      %component.bandwidth = find(component.power>1e-10,1,'last'); %Stellt
      %fest, bis wann die fourierkoeefizienten sinnvoll nicht zu klein sind. Sollte das gemacht werden?????
  end
     
  function n = numArgumentsFromSubscript(varargin)
     n = 0;
  end
  
  function bandwidth = get.bandwidth(F)
     bandwidth = dim2deg(size(F.fhat,1));  
  end
  
  function F = set.bandwidth(F, bw)
     newLength = deg2dim(bw+1);
     s=size(F);
     oldLength = size(F.fhat,1);
     
     if newLength > oldLength % add some zeros
         F.fhat(oldLength+1:newLength,:)=0;
     else % delete zeros
         F.fhat = F.fhat(1:newLength,:);
         F=reshape(F,s);
     end
  end
  
  function pow = get.power(F)
     hat = abs(F.fhat).^2;
     pow = zeros(F.bandwidth+1,1);
     for l = 0:length(pow)-1
         pow(l+1) = sum(hat(deg2dim(l)+1:deg2dim(l+1))) ./ (2*l+1);
     end     
  end
    
  function out = get.antipodal(F)      
     if F.CS ~= F.SS
         out = false;
         return
     end
     n = norm(F);
     dd = 0;
     for l = 1:F.bandwidth
         ind = (deg2dim(l)+1):deg2dim(l+1);  
         d = reshape(F.fhat(ind),2*l+1,2*l+1) - reshape(F.fhat(ind),2*l+1,2*l+1)';
         dd  = dd + sum(d(:).^2)/(2*l+1);
     end
     out = sqrt(dd) / n < 1e-4;
  end
    
  function F = set.antipodal(F,value)
     if ~value, return; end
     if F.CS ~= F.SS
        error('ODF can only be antipodal if both crystal symmetry coincide!')
     end
     for l = 1:F.bandwidth
        ind = (deg2dim(l)+1):deg2dim(l+1);
        F.fhat(ind) = 0.5* (reshape(F.fhat(ind),2*l+1,2*l+1) + ...
           reshape(F.fhat(ind),2*l+1,2*l+1)');
     end
  end
  
  function d = size(F, varargin)
     d = size(F.fhat);
     d = d(2:end);
     if length(d) == 1, d = [d 1]; end
     if nargin > 1, d = d(varargin{1}); end
  end

  function n = numel(F)
     n = prod(size(F));
  end

end

end
