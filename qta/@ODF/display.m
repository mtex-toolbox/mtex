function display(odf,varargin)
% standard output

disp(' ');

h = 'ODF';
if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;
if ~isempty(odf(1).comment), h = [h ' (' odf(1).comment ')']; end

disp(h);
disp(repmat('-',1,length(h)));

disp([' symmetry: ',char(odf(1).CS),' - ',char(odf(1).SS)]);
disp(' ');
for i = 1:length(odf)
  if check_option(odf(i),'UNIFORM')
    disp(' uniform portion:');    
  elseif check_option(odf(i),'Fourier')
    disp(' portion specified by Fourier coefficients:');    
  elseif check_option(odf(i),'FIBRE')
    disp(' fibre symmetric portion:');
    disp(['  kernel: ',char(odf(i).psi)]);
    disp(['  center: ',char(odf(i).center{1}),'-',char(odf(i).center{2})]);
  elseif check_option(odf(i),'Bingham')
    disp(' Bingham distributed portion:');
    disp(['  Lambda: ',xnum2str(odf(i).c)]); 
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
