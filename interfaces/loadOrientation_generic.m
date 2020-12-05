function [ori,S] = loadOrientation_generic(fname,varargin)
% load Orientation data from generic text files
%
% Description
%
% |loadOrientation_generic| loads individual orientations from text or exel
% files that have a column oriented format as
%
%  phi1_1 Phi_1 phi2_1 prop1_1 prop2_1
%  phi1_2 Phi_2 phi2_2 prop1_2 prop2_2
%  phi1_3 Phi_3 phi2_3 prop1_3 prop2_3
%  .      .       .       .      .
%  .      .       .       .      .
%  .      .       .       .      .s
%  phi1_M Phi_M phi2_M prop1_M prop2_M
%
% The assoziation of the columns as Euler angles, phase informationl, etc.
% is specified by the options |ColumnNames| and |Columns|. The files can be
% contain any number of header lines.
%
% Syntax
%   [ori,prop] = loadOrientation_generic(fname,'ColumnNames',{'Euler1','Euler2','Euler3','prop1','prop2'})
%
% Input
%  fname - file name (text files only)
%
% Output
%  ori  - @orientation
%  prop - struct with fields for the additional columns
%
% Options
%  ColumnNames       - names of the colums to be imported, mandatory are euler 1, euler 2, euler 3
%  Columns           - postions of the columns to be imported
%  RADIANS           - treat input in radiand
%  DELIMITER         - delimiter between numbers
%  HEADER            - number of header lines
%  BUNGE             - [phi1 Phi phi2] Euler angle in Bunge convention (default)
%  ABG               - [alpha beta gamma] Euler angle in Mathies convention
%  PASSIVE           - 
%
% Example
%
%   fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');
%   CS = crystalSymmetry('m-3m','mineral','Mg');
%   SS = specimenSymmetry('triclinic');
%   
%   ori = loadOrientation_generic(fname,'CS',CS,'SS',SS, 'ColumnNames', ...
%     {'Euler1' 'Euler2' 'Euler3'},'Columns',[5,6,7],'Bunge')
%
% See also
% loadOrientation

isCheck = check_option(varargin,'check');

try
  % load data
  if ~isnumeric(fname)
    [d,options,header,c] = load_generic(char(fname),varargin{:});
    varargin = options;
  else
    d = fname;
  end

  % no data found
  if size(d,1) < 1 || size(d,2) < 3
    error('Generic interface could not detect any numeric data in %s',fname);
  end

  % no options given -> ask
  if ~check_option(varargin,'ColumnNames')

    options = generic_wizard('data',d(1:end<101,:),'type','Orientation','header',header,'columns',c);
    if isempty(options), ori = []; return; end
    varargin = [options,varargin];

  end

  loader = loadHelper(d,varargin{:});

  q = loader.getRotations();

  % correct for passive rotation
  if check_option(varargin,{'passive','passive rotation'}), q = inv(q); end
  
  % extract additional properties
  S = loader.getOptions();

  % set up ori variable
  CS = getClass(varargin,'crystalSymmetry',crystalSymmetry);
  SS = getClass(varargin,'specimenSymmetry',specimenSymmetry);
  ori = orientation(q,CS,SS);

  if isCheck, S = options; end
  
catch
  interfaceError(fname)
end
