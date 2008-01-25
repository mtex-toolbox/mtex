function plot(m,varargin)
% plot Miller indece
%% Input
%  m  - Miller
%
%% Options
%  ALL     - plot symmetrically equivalent directions
%  NO_CHAR - no description


colororder = ['b','g','r','c','m','k','y'];

if any(strcmpi(get(gcf,'Tag'),{'IPDF'}))  
  hold on
else
  clf;
  set(gcf,'Name','Miller indece in a Schmidt net');  
end

for i = 1:numel(m)

  if check_option(varargin,'ALL')  
    mm = vec2Miller(symvec(m(i),varargin{:}),m(i).CS);
  else
    mm = m(i);
  end
  
  s = cell(1,numel(mm));
  for ii = 1:numel(mm)
    s{ii} = char(char(mm(ii),'no_scopes'));
  end
  
  plot(S2Grid(vector3d(mm)),varargin{:},'dots',...
    'data',s,...
    'color',colororder(1+mod(i-1,length(colororder))));
  
  hold on
end

hold off
return

s = cell(1,numel(m));
for i = 1:numel(m)
  s{i} = char(char(m(i),'latex'));
end

plot(S2Grid(vector3d(m)),'data',s,varargin{:});
if check_option(varargin,'ALL')  
  for i = 1:numel(m)
    hold on
    plot(S2Grid(m(1).CS*vector3d(m(i)),'hemisphere'),varargin{:},'dots',...
      'color',colororder(1+mod(i-1,length(colororder))));
  end
  
end
hold off

%% Example
%
% plot([Miller(0,0,1),Miller(1,0,0),Miller(1,1,0),Miller(1,-1,0),Miller(0,1
% ,0),Miller(-1,1,0),Miller(-1,0,0),Miller(-1,-1,0),Miller(0,-1,0),Miller(2
% ,-1,0),Miller(-1,2,0),Miller(1,-2,0),Miller(-2,1,0)],CS)

