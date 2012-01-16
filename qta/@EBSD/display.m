function  display(ebsd,varargin)
% standard output

disp(' ');
h = doclink('EBSD_index','EBSD');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

if numel(ebsd)>0 && ~isempty(ebsd.comment)
  s = ebsd.comment;
  if length(s) > 60, s = [s(1:60) '...'];end

  h = [h,' (',s,')'];
end

disp(h)


if numel(ebsd)>0 && ~isempty(fields(ebsd.options))
  disp(['  Properties: ',option2str(fields(ebsd.options))]);
end


% ebsd.phaseMap
matrix = cell(numel(ebsd.phaseMap),5);
for ip = 1:numel(ebsd.phaseMap)

  % phase
  matrix{ip,1} = num2str(ebsd.phaseMap(ip)); %#ok<*AGROW>

  % orientations
  matrix{ip,2} = int2str(nnz(ebsd.phase == ip));

    % mineral
  CS = ebsd.CS{ip};
  % abort in special cases
  if isempty(CS), 
    continue
  elseif ischar(CS)
    matrix{ip,3} = CS;  
    continue
  else
    matrix{ip,3} = char(get(CS,'mineral'));
  end

  % symmetry
  matrix{ip,4} = get(CS,'name');

  % reference frame
  matrix{ip,5} = option2str(get(CS,'alignment'));

end

if numel(ebsd)>0
  cprintf(matrix,'-L','  ','-Lc',...
    {'Phase' 'Orientations' 'Mineral'  'Symmetry' 'Crystal reference frame'},...
    '-ic','F');
else
  disp('  EBSD is empty!')
end

disp(docmethods(inputname(1)));

if 0 < numel(ebsd) && numel(ebsd) <= 20
  fn = fields(ebsd.options);
  d = zeros(sum(numel(ebsd)),numel(fn));
  for j = 1:numel(fn)
    if isnumeric(ebsd.options.(fn{j}))
      d(:,j) = vertcat(ebsd.options.(fn{j}));
    elseif isa(ebsd.options.(fn{j}),'quaternion')
      d(:,j) = angle(ebsd.options.(fn{j})) / degree;
    end
  end
  cprintf(d,'-Lc',fn);
end
