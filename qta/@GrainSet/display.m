function  display(grains,varargin)
% standard output

disp(' ');
h = [doclink([class(grains) '_index'], class(grains)) '-' ...
  doclink('GrainSet_index','Set')];

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

if numel(grains)>0 && ~isempty(grains.comment)
  s = grains.comment;
  if length(s) > 60, s = [s(1:60) '...'];end

  h = [h,' (',s,')'];
end

disp(h)

properties = fields(grains.options);

if numel(grains)>0 && ~isempty(properties)
  disp(['  properties: ',option2str(properties)]);
end


CS = get(grains.EBSD,'CSCell');

phases = unique(grains.phase).';

for ip = 1:numel(phases)

  p = phases(ip);

  % phase
  matrix{ip,1} = num2str(p); %#ok<*AGROW>

  % grains
  matrix{ip,2} = int2str(nnz(grains.phase == p));
  
  % orientations
  matrix{ip,3} = int2str(nnz(get(grains.EBSD,'phase')==p));

  
  % abort in special cases
  if p == 0 || isempty(CS{p}), continue;end

  % mineral
  matrix{ip,4} = char(get(CS{p},'mineral'));

  % symmetry
  matrix{ip,5} = get(CS{p},'name');

  % reference frame
  matrix{ip,6} = option2str(get(CS{p},'alignment'));

end

if numel(grains)>0
  cprintf(matrix,'-L','  ','-Lc',...
    {'phase' 'grains' 'orientations' 'mineral'  'symmetry' 'crystal reference frame'},...
    '-ic','F');
end

disp(' ');

% if numel(grains) <= 20
%   fn = fields(grains.options);
%   d = zeros(sum(numel(grains)),numel(fn));
%   for j = 1:numel(fn)
%     if isnumeric(grains.options.(fn{j}))
%       d(:,j) = vertcat(grains.options.(fn{j}));
%     elseif isa(grains.options.(fn{j}),'quaternion')
%       d(:,j) = angle(grains.options.(fn{j})) / degree;
%     end
%   end
%   cprintf(d,'-Lc',fn);
% end
