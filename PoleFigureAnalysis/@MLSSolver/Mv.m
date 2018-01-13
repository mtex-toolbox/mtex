function d = Mv(solver)
% forward operator
%
% Input
%   alpha
%   c
%   nfft_plan

%int ip,iP;

% pdf_trafo for all pole figures
% d_i = alpha_i Psi_i * c
for (ip=0,iP=0;ip<ths->NP;iP+=ths->pdf[ip].lr,ip++)
  
  v_cp_a_x_double(ths->c_temp,alpha[ip],c,ths->lc);
  
  pdf_trafo(&ths->pdf[ip],ths->c_temp,d+iP);
  
end

end