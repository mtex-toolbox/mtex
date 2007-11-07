function hw_list = calculate_hw_list(name,kappa)
% calculate a list (kappa,hw)

hw_list(:,1) = kappa;

progress(0,length(kappa))
for i = 1:length(kappa)
  progress(i,length(kappa))
  
  psi = kernel(name,kappa(i));
  hw_list(i,2) = gethw(psi);
  
end