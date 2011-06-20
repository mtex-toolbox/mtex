function display(odf,varargin)
% standard output

disp(' ');

csss = {'sample symmetry ','crystal symmetry'};

%% ODF / MDF
disp(' ');
if isCS(odf.SS) && isCS(odf.CS)
  h = doclink('MDF_index','MDF');
else
  h = doclink('ODF_index','ODF');
end

%% variable name
if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;
if ~isempty(odf(1).comment), h = [h ' (' odf(1).comment ')']; end

disp(h);

%% display symmtries and minerals  
disp(['  ' csss{isCS(odf.CS)+1} ': ', char(odf.CS,'verbose')]);
disp(['  ' csss{isCS(odf.SS)+1} ': ',char(odf.SS,'verbose')]);

% display components
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
    disp('  Bingham portion:');
    disp(['     kappa: ',xnum2str(odf(i).psi)]); 
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
