function pf = loadPoleFigure_aachen2(fname,varargin)
% import data from aachen file
%
%% Syntax
% pf = loadPoleFigure_aachen2(fname,<options>)
%
%% Input
%  fname  - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% interfacesPoleFigure_index aachen_interface loadPoleFigure

% Alpha Beta Intensität Defokus BG korIntensität
try
  
  h = string2Miller(fname);
  
  data = txt2mat(fname,1,6,'ReadMode','matrix','InfoLevel',0);

  % correction / should be column 6
  d = (data(:,3)-data(:,5))./data(:,4);
  % pd = find(abs(pfdata- data(:,6)) > 0.0001)

  r = sph2vec(data(:,1)*degree, data(:,2)*degree);

  pf = PoleFigure(h,S2Grid(r),d,symmetry('cubic'),symmetry,varargin{:});

catch
  if ~exist('pf','var')
    error('format Aachen2 does not match file %s',fname);
  end
end
