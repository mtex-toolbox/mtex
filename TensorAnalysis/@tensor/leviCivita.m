function eps = leviCivita
% the Levi Civita permutation tensor
%
% Syntax
%   eps = tensor.leviCivita
%

eps = zeros(3,3,3);
eps(1,2,3) = 1;
eps(3,1,2) = 1;
eps(2,3,1) = 1;

eps(1,3,2) = -1;
eps(3,2,1) = -1;
eps(2,1,3) = -1;
      
eps = tensor(eps,'rank',3,'name','Levi Cevita');
      
end