function display(odf)
% standard output

disp(' ');
if ~isempty(odf(1).comment)
  disp(odf(1).comment);
  disp(repmat('-',1,length(odf(1).comment)));
else
  disp([inputname(1),' = ODF',]);
end
disp([' symmetry: ',char(odf(1).CS),' - ',char(odf(1).SS)]);
disp(' ');
for i = 1:length(odf)
  if check_option(odf(i),'UNIFORM')
    disp(' uniform portion:');    
  elseif check_option(odf(i),'FIBRE')
    disp(' fibre symmetric portion:');
    disp(['  kernel: ',char(odf(i).psi)]);
    disp(['  center: ',char(odf(i).center{1}),'-',char(odf(i).center{2})]);
  else
    disp(' radially symmetric portion:');
    disp(['  kernel: ',char(odf(i).psi)]);
    disp(['  center: ',char(odf(i).center)]);
  end
  if ~isempty(odf(i).c_hat)
    disp(['  degree: ',int2str(dim2deg(length(odf(i).c_hat)))]);
  end
  disp(['  weight: ',num2str(sum(odf(i).c(:)))]);
  disp(' ');
end
