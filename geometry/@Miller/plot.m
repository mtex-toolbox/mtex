function plot(m,varargin)
% plot Miller indece
%
%% Input
%  m  - Miller
%
%% Options
%  ALL     - plot symmetrically equivalent directions
%  NO_CHAR - no description

% store hold status
washold = ishold;

for i = 1:numel(m)

  % all symmetrically equivalent?
  if check_option(varargin,'ALL')  
    mm = vec2Miller(symvec(m(i),varargin{:}),m(i).CS);
  else
    mm = m(i);
  end
  
  % generate strings
  s = cell(1,numel(mm));
  for ii = 1:numel(mm)
    s{ii} = char(char(mm(ii),'latex'));
  end
  
  % plot
  plot(S2Grid(vector3d(mm)),varargin{:},'data',s);
  
  hold all
end

% revert old hold status
if ~washold, hold off;end
