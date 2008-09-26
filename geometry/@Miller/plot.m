function plot(m,varargin)
% plot Miller indece
%
%% Input
%  m  - Miller
%
%% Options
%  ALL     - plot symmetrically equivalent directions
%  labeled - plot Miller indice as label
%  label   - plot user label

% store hold status
washold = ishold;
label = repcell(get_option(varargin,'label'),numel(m));

for i = 1:numel(m)

  % all symmetrically equivalent?
  if check_option(varargin,'ALL')  
    mm = vec2Miller(symvec(m(i),varargin{:}),m(i).CS);
  else
    mm = m(i);
  end

  options = {};
  if check_option(varargin,'labeled')
    % convert to cell
    s = mat2cell(mm,ones(1,size(mm,1)),ones(1,size(mm,2)));
    options = {'label',s,'MarkerEdgeColor','w'};
  elseif ~isempty(label)
    varargin = set_option(varargin,'label',{label{i}});
  end
  
  % plot
  plot(S2Grid(vector3d(mm)),options{:},varargin{:});
  
  hold all
end

% revert old hold status
if ~washold, hold off;end
