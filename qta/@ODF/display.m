function display(odf,varargin)
% standard output

disp(' ');

%% variable name
if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = '];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = '];
else
  h = [];
end;

if isempty(odf)
  disp([h doclink('ODF_index','ODF') ' ' docmethods(inputname(1))]);
  disp(' ');
  return
end

csss = {'sample symmetry ','crystal symmetry'};

% symmetries
cs = odf(1).CS;
ss = odf(1).SS;

%% ODF / MDF
if isCS(ss) && isCS(cs)
  h = [h, doclink('MDF_index','MDF')];
else
  h = [h,doclink('ODF_index','ODF')];
end

disp([h ' ' docmethods(inputname(1))]);

if ~isempty(odf(1).comment)
  disp(['  comment: ' odf(1).comment]);
end

%% display symmtries and minerals
disp(['  ' csss{isCS(cs)+1} ': ', char(cs,'verbose')]);
disp(['  ' csss{isCS(ss)+1} ': ',char(ss,'verbose')]);

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
