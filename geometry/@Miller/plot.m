function plot(m,varargin)
% plot Miller indece
%% Input
%  h  - qMiller
%
%% Options
%  ALL - plot symmetrically equivalent directions


colororder = ['b','g','r','c','m','k','y'];

if any(strcmpi(get(gcf,'Tag'),{'IPDF'}))  
  hold on
else
  clf;
  set(gcf,'Name','Miller indece in a Schmidt net');  
end

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

