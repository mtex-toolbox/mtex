function display(odf,varargin)
% standard output

disp(' ');

h = doclink('ODF_index','ODF');
if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;
if ~isempty(odf(1).comment), h = [h ' (' odf(1).comment ')']; end

disp(h);

disp(['  symmetry: ',char(odf(1).CS),' - ',char(odf(1).SS)]);
disp(' ');
for i = 1:length(odf)
  if check_option(odf(i),'UNIFORM')
    disp('  Uniform portion:');    
  elseif check_option(odf(i),'Fourier')
    disp('  Portion specified by Fourier coefficients:');    
  elseif check_option(odf(i),'FIBRE')
    disp('  Fibre symmetric portion:');
    disp(['    kernel: ',char(odf(i).psi)]);
    disp(['    center: ',char(odf(i).center{1}),'-',char(odf(i).center{2})]);
  elseif check_option(odf(i),'Bingham')
    disp('  Bingham distributed portion:');
    disp(['    lambda: ',xnum2str(odf(i).psi)]); 
  else
    disp('  Radially symmetric portion:');
    disp(['    kernel: ',char(odf(i).psi)]);
    disp(['    center: ',char(odf(i).center)]);
  end
  if ~isempty(odf(i).c_hat)
    disp(['    degree: ',int2str(dim2deg(length(odf(i).c_hat)))]);
  end
  disp(['    weight: ',num2str(sum(odf(i).c(:)))]);
  disp(' ');
end
