

names =  {'Abel Poisson','de la Vallee Poussin','von Mises Fisher',...
  'local','Square Singularity','fibre von Mises Fisher','Gauss Weierstrass'};

ranges = {...
  
  [1.3.^(0:23),499],...
  };
  

kappa = ;
hw_list = calculate_hw_list('von Mises Fisher',kappa);

hw = 5*degree;
p = interp1q(hw_list(:,1),hw_list(:,2),hw)

psi = kernel('von Mises Fisher',pp)

pp = abs(fzero(@(p) (hw - interp1(hw_list(:,1),hw_list(:,2),p,'spline')),...
  median(hw_list(:,1))))


