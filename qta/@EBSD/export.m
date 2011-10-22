function export(ebsd,fname,varargin)
% export EBSD data to a ascii file
%
%% Input
%  ebsd - @EBSD
%  fname - filename
%
%% Options
%  BUNGE   - Bunge convention (default)
%  ABG     - Matthies convention (alpha beta gamma)
%  DEGREE  - output in degree (default)
%  RADIANS - output in radians


fn = fields(ebsd.options);

% allocate memory
d = zeros(numel(ebsd),4+numel(fn));

% add Euler angles
[d(:,1:3),EulerNames] = get(ebsd,'Euler',varargin{:});
if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree;
end

% add phase
d(:,4) = get(ebsd,'phase',varargin{:});

% update fieldnames
fn = [EulerNames.';'phase';fn];

% add properties
for j = 5:numel(fn)
  if isnumeric(ebsd.options.(fn{j}))
    d(:,j) = vertcat(ebsd.options.(fn{j}));
  elseif isa(ebsd.options.(fn{j}),'quaternion')
    d(:,j) = angle(ebsd.options.(fn{j})) / degree;
  end
end
 
cprintf(d,'-Lc',fn,'-fc',fname,'-q',true);
