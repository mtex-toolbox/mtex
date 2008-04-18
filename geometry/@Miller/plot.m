function plot(m,varargin)
% plot Miller indece
%
%% Input
%  m  - Miller
%
%% Options
%  ALL     - plot symmetrically equivalent directions
%  NO_CHAR - no description


%if any(strcmpi(get(gcf,'Tag'),{'IPDF'}))  
%  hold on
%else
%  clf;
%  set(gcf,'Name','Miller indece in a Schmidt net');  
%end

washold = ishold;

for i = 1:numel(m)

  if check_option(varargin,'ALL')  
    mm = vec2Miller(symvec(m(i),varargin{:}),m(i).CS);
  else
    mm = m(i);
  end
  
  s = cell(1,numel(mm));
  for ii = 1:numel(mm)
    s{ii} = char(char(mm(ii),'latex'));
  end
  
  plot(S2Grid(vector3d(mm)),varargin{:},'data',s);
  
  hold all
end

if ~washold, hold off;end
