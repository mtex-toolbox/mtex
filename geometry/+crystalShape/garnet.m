function cS = garnet(varargin)
% simple morphology
%

if nargin == 0 || ~isa(varargin{1},'symmetry')
  cs = crystalSymmetry('m3m','mineral','garnet');
else
  cs = varargin{1};
end

if check_option(varargin,'simple')

  N= Miller({1,0,0},{2,1,1},cs);
  dist = [0.45, 1];
  cS = crystalShape(N./dist);
  
  %N = Miller({1,1,0},{2,1,1},cs);  
  %cS = crystalShape(N,1.5);
  
else
  
  N = Miller({1,0,0},{1,1,0},{4,3,1},{3,1,1},cs);
  dist = [0.92, 1.02, 3.93, 2.93];
  cS = crystalShape(N./dist);
  
end
    


