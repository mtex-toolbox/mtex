classdef FourierComponent < ODFComponent
  % defines an ODF component by its Fourier coefficients
  
  properties
    f_hat    
    CS = symmetry
    SS = symmetry
  end
 
  methods
    
    function component = FourierComponent(f_hat,CS,SS)
                       
      component.CS = CS;
      if nargin>2, component.SS = SS;end
      
      % extract f_hat
      if isa(f_hat,'cell')
        component.f_hat = [];
        for l = 0:numel(f_hat)-1
          component.f_hat = [component.f_hat;f_hat{l+1}(:) * sqrt(2*l+1)];
        end
      else
        component.f_hat = f_hat;
      end
    end
  end  
end
