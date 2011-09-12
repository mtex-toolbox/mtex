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
  disp(['  properties: ',option2str(fields(ebsd.options))]);
end

phases = unique(ebsd.phase).';
for ip = 1:length(phases)

  p = phases(ip);

  % phase
  matrix{ip,1} = num2str(p); %#ok<*AGROW>

  % orientations
  matrix{ip,2} = int2str(nnz(ebsd.phase == p));

  % abort in special cases
  if p == 0 || isempty(ebsd.CS{p}), continue;end

  % mineral
  CS = ebsd.CS{p};
  matrix{ip,3} = char(get(CS,'mineral'));

  % symmetry
  matrix{ip,4} = get(CS,'name');

  % reference frame
  matrix{ip,5} = option2str(get(CS,'alignment'));

end

if numel(ebsd)>0
  cprintf(matrix,'-L','  ','-Lc',...
    {'phase' 'orientations' 'mineral'  'symmetry' 'crystal reference frame'},...
    '-ic','F');
end

disp(' ');

if numel(ebsd) <= 20
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
