function export(ebsd,fname,varargin)
% export EBSD data to a ascii file
%
% Input
%  ebsd - @EBSD
%  fname - filename
%
% Options
%  Bunge   - Bunge convention (default)
%  ABG     - Matthies convention (alpha beta gamma)
%  degree  - output in degree (default)
%  radians - output in radians

% TODO

fn = fields(ebsd.prop);

% allocate memory
d = zeros(length(ebsd),4+numel(fn));

% add Euler angles
[d(:,1:3),EulerNames] = ebsd.rotations.Euler(varargin{:});
if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree;
end

% add phase
d(:,4) = reshape(ebsd.phase,1,[]);

% update fieldnames
fn = [EulerNames.';'phase';fn];

% add properties
for j = 5:numel(fn)
  if isnumeric(ebsd.prop.(fn{j}))
    d(:,j) = vertcat(reshape(ebsd.prop.(fn{j}),1,[]));
  elseif isa(ebsd.prop.(fn{j}),'quaternion')
    d(:,j) = angle(reshape(ebsd.prop.(fn{j}),1,[])) / degree;
  end
end
 
cprintf(d,'-Lc',fn,'-fc',fname,'-q',true);
