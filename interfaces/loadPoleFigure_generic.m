function [pf,varargin] = loadPoleFigure_generic(fname,varargin)
% load pole figure data from (theta,rho,intensity) files
%
% Description 
%
% *loadPoleFigure_generic* is a generic function that reads any txt files of
% diffraction intensities that are of the following format
%
%  theta_1 rho_1 intensity_1
%  theta_2 rho_2 intensity_2
%  theta_3 rho_3 intensity_3
%  .      .       .
%  .      .       .
%  .      .       .
%  theta_M rho_M intensity_M
%
% The actual order of the columns in the file can be specified by the
% options |ColumnNames| and |Columns|. Furthermore, the files can be contain any number of
% header lines to be ignored using the option |HEADER|. 
%
% Input
%  fname - file name (text files only)
%
% Options
%  ColumnNames       - content of the columns to be imported
%  Columns           - positions of the columns to be imported
%  RADIANS           - treat input in radians
%  DELIMITER         - delimiter between numbers
%  HEADER            - number of header lines
% 
% Example
%   fname = [mtexDataPath '/PoleFigure/nja/seifert-111.nja'];
%   pf = loadPoleFigure_generic(fname,'HEADER',21,'degree',...
%        'ColumnNames',{'polar angle','azimuth angle','intensity'},...
%        'Columns',[1 2 3])
%
% See also
% ImportPoleFigureData loadPoleFigure


% load data
[d,varargin,header,columns] = load_generic(fname,varargin{:});

% no data found
if size(d,2) < 3
  error('Generic interface could not detect any numeric data in %s',fname);
end

% assume one big data block containing only intensities
if size(d,2)>15 || ...
    (~isempty(varargin) && isa(varargin{1},'vector3d') && size(varargin{1}) == size(d))

  % determine specimen directions
  if ~(~isempty(varargin) && isa(varargin{1},'vector3d') && size(varargin{1}) == size(d))

    % sometimes last line is a duplication of the first line
    if ~iseven(size(d,1)) && all(d(1,:) == d(end,:))
      d(end,:) = []; 
    end
    
    r = regularS2Grid('points',size(d),'antipodal',varargin{:});
    
    if ~check_option(varargin,'maxtheta') && size(d,2) ~= 19
      warning(['No grid of specimen directions was specified' ...
        ' I''m going to use a regular grid with ' size2str(d) ' points.' ...
        'You may use the option ''maxTheta'' to control the maximum polar angle. ' ...
        'Have a look at for more details.']); %#ok<WNTAG>
    end
  
  else   
    r = varargin{1};
  end
  
  % crystal direction
  h = string2Miller(fname);
  
  pf = PoleFigure(h,r,d,crystalSymmetry('cubic'));
  
  return
  
end

% assume columns of data

% no options given -> ask
if ~check_option(varargin,'ColumnNames')
  
  options = generic_wizard('data',d,'type','PoleFigure','header',header,'columns',columns);
  if isempty(options), pf = []; return; end 
  varargin = [options,varargin];

end

loader = loadHelper(d,varargin{:});

r      = loader.getVector3d();

I      = loader.getColumnData('Intensity');

opt    = loader.getOptions('ignoreColumns','Intensity');

% intensities
assert(numel(I)>=5,'To few data points'); %???

% crystal direction
h = string2Miller(fname);

pf = PoleFigure(h,r,I,'options',opt,varargin{:});



