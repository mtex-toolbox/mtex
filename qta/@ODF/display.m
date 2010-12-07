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

% collect tensor properties
props = {'specimen symmetry','crystal symmetry'};
propV = {get(odf(1).SS,'name'), get(odf(1).CS,'name')};
al = get(odf(1).CS,'alignment');
if ~isempty(al)
  propV{2} = option2str([propV(2) option2str(al)]);
end

if ~isempty(get(odf(1).CS,'mineral'))
  props{end+1} = 'mineral'; 
  propV{end+1} = get(odf(1).CS,'mineral');
end

% display all properties
cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

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
