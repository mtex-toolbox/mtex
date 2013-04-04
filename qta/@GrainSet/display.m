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

disp([h ' ' docmethods(inputname(1))])

% show comment
if ~isempty(grains.comment)
  disp(['  comment: ' grains.comment(1:end-1)]);  
end

% show properties
properties = fields(grains.options);
if any(grains) && ~isempty(properties)
  disp(['  grain properties: ',option2str(properties)]);
end

% show ebsd properties
if numel(get(grains,'ebsd'))>0
  disp(['  EBSD properties: ',option2str(get(get(grains,'ebsd'),'propertyNames'))]);
end

%
CS        = get(grains,'CSCell');
phaseMap  = get(grains,'phaseMap');
ebsdPhase = get(grains.EBSD,'phase');

matrix = cell(numel(phaseMap),6);

for ip = 1:numel(phaseMap)
  
  % phase
  matrix{ip,1} = num2str(phaseMap(ip)); %#ok<*AGROW>
  
  % grains
  matrix{ip,2} = int2str(nnz(grains.phase == ip));
  
  % orientations
  matrix{ip,3} = int2str(nnz(ebsdPhase==phaseMap(ip)));
  
  
  % abort in special cases
  if isempty(CS{ip})
    continue
  elseif ischar(CS{ip})
    matrix{ip,4} = CS{ip};
    continue
  else
    % mineral
    matrix{ip,4} = char(get(CS{ip},'mineral'));
  end
  
  % symmetry
  matrix{ip,5} = get(CS{ip},'name');
  
  % reference frame
  matrix{ip,6} = option2str(get(CS{ip},'alignment'));
  
end

if any(grains)
  cprintf(matrix,'-L','  ','-Lc',...
    {'Phase' 'Grains' 'Orientations' 'Mineral'  'Symmetry' 'Crystal reference frame'},...
    '-ic','F');
else
  disp('  GrainSet is empty!')
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
