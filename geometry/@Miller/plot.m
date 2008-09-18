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
  
  % convert to cell
  s = mat2cell(mm,ones(1,size(mm,1)),ones(1,size(mm,2)));
  
  % plot
  plot(S2Grid(vector3d(mm)),'data',s,'grid','markerEdgeColor','w','SizeData',70,varargin{:});
  
  hold all
end

% revert old hold status
if ~washold, hold off;end
