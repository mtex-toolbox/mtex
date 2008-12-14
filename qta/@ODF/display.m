function display(odf)
% standard output

disp(' ');
disp([inputname(1) ' = ']);
disp(' '); 
disp(['  ODF: '  odf(1).comment]);

for i = 1:numel(odf)
  n = ['   ' ind2char(i,size(odf)) ' ' char(odf(i).CS),'/',char(odf(i).SS) ': ' ]; 
  if check_option(odf(i),'UNIFORM')
    disp([ n 'uniform portion']);    
  elseif check_option(odf(i),'Fourier')
    disp([ n 'portion specified by Fourier coefficients']);    
  elseif check_option(odf(i),'FIBRE')
    disp([ n 'fibre symmetric portion']);
    disp(['           kernel: ',char(odf(i).psi)]);
    disp(['           center: ',char(odf(i).center{1}),'-',char(odf(i).center{2})]);
  else
    disp([ n 'radially symmetric portion']);
    disp(['           kernel: ',char(odf(i).psi)]);
    disp(['           center: ',char(odf(i).center)]);
  end
  if ~isempty(odf(i).c_hat)
    disp(['           degree: ',int2str(dim2deg(length(odf(i).c_hat)))]);
  end
  disp(['           weight: ',num2str(sum(odf(i).c(:)))]);
end
disp(' ');