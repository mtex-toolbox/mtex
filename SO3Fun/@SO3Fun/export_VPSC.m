function export_VPSC(SO3F,filename,varargin)
% export an SO3Fun to the VPSC format
%
% Syntax
%   export_VPSC(SO3F,'file.txt','points',points)
%
% Input
%  SO3F      - @SO3Fun to be exported
%  filename - name of the ascii file
%
% Options
%  points    - number of orientations
%
% See also
% ODFImport ODFExport
  
% get number of points
points = get_option(varargin,'points',10000);

% simulate orientations
ori = calcOrientations(SO3F,points,varargin{:});

% export EBSD
export_VPSC(ori,filename,varargin{:});
