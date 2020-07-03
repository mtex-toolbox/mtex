classdef FourierComponent < ODFComponent
  % defines an ODF component by its Fourier coefficients
  
  properties
    f_hat    
    CS = crystalSymmetry
    SS = specimenSymmetry
  end
 
  properties (Dependent=true)
    bandwidth % harmonic degree
    power     % harmonic power
    antipodal
  end
  
  methods
    
    function component = FourierComponent(f_hat,CS,SS,varargin)
      
      component.f_hat = f_hat;
      
      component.CS = CS;
      if nargin>2, component.SS = SS;end
      
      component.antipodal = check_option(varargin,'antipodal');
                        
      % truncate zeros
      bw = find(component.power>1e-10,1,'last');
      if isempty(bw), bw = 1; end
      component.bandwidth = bw - 1;  
      
    end
    
    function L = get.bandwidth(component)
      L = dim2deg(numel(component.f_hat));
    end
    
    function component = set.bandwidth(component,L)
      newLength = deg2dim(L+1);
      oldLength = numel(component.f_hat);
      if newLength > oldLength
        component.f_hat(oldLength+1:newLength,:) = 0;
      else
        component.f_hat = component.f_hat(1:newLength);
      end
    end
    
    function pow = get.power(component)
      fhat = abs(component.f_hat).^2;
      pow = zeros(component.bandwidth+1,1);
      for l = 0:length(pow)-1
        pow(l+1) = sum(fhat(deg2dim(l)+1:deg2dim(l+1))) ./ (2*l+1);
      end     
    end
    
    function out = get.antipodal(component)      
      if component.CS ~= component.SS
        out = false;
        return
      end
      n = norm(component);
      dd = 0;
      for l = 1:component.bandwidth
        ind = (deg2dim(l)+1):deg2dim(l+1);
        d = reshape(component.f_hat(ind),2*l+1,2*l+1) - reshape(component.f_hat(ind),2*l+1,2*l+1)';
        dd  = dd + sum(abs(d(:)).^2)/(2*l+1);
      end
      out = sqrt(dd) / n < 1e-4;
    end
    
    function component = set.antipodal(component,value)
      
      if ~value, return; end
      if component.CS ~= component.SS
        error('ODF can only be antipodal if both crystal symmetry coincide!')
      end
      for l = 1:component.bandwidth
        ind = (deg2dim(l)+1):deg2dim(l+1);
        component.f_hat(ind) = 0.5* (reshape(component.f_hat(ind),2*l+1,2*l+1) + ...
          reshape(component.f_hat(ind),2*l+1,2*l+1)');
      end
      
    end
    
  end  
end
