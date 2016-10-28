function [ori,options] = loadOrientation_generic(fname,varargin)
% load Orientation data from generic text files
%
% Description
%
% loadOrientation_generic loads individual orientations
% from text or exel files that have a column oriented format as
%
%  phi1_1 Phi_1 phi2_1
%  phi1_2 Phi_2 phi2_2
%  phi1_3 Phi_3 phi2_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  phi1_M Phi_M phi2_M
%
% The assoziation of the columns as Euler angles, phase informationl, etc.
% is specified by the options |ColumnNames| and |Columns|. The files can be
% contain any number of header lines.
%
% Syntax
%   ori   = loadOrientation_generic(fname,'ColumnNames',{'Euler1','Euler2','Euler3'})
%
% Input
%  fname - file name (text files only)
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

try

  % load data
  [d,options,header,c] = load_generic(char(fname),varargin{:});

  varargin = options;

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

  names = lower(get_option(varargin,'ColumnNames'));
  cols = get_option(varargin,'Columns',1:length(names));

  assert(length(cols) == length(names), 'Length of ColumnNames and Columns differ');

  [names, m] = unique(names);
  cols = cols(m);

  istype = @(in, a) all(cellfun(@(x) any(find(strcmpi(stripws(in),stripws(x)))),a));
  layoutcol = @(in, a) cols(cell2mat(cellfun(@(x) find(strcmpi(stripws(in(:)),stripws(x))),a(:),'uniformoutput',false)));

  euler = lower({'Euler 1' 'Euler 2' 'Euler 3'});
  bunge = lower({'Phi1' 'Phi' 'Phi2'});
  quat = lower({'Quat real' 'Quat i' 'Quat j' 'Quat k'});

  if istype(names,euler) || istype(names,bunge) % Euler angles specified
  
    if istype(names,euler)
      layout = layoutcol(names,euler);
    else
      layout = layoutcol(names,bunge);
    end
  
    %extract options
    dg = degree + (1-degree)*check_option(varargin,{'radians','radiant','radiand'});
  
    % eliminate nans
    if ~check_option(varargin,'keepNaN')
      d(any(isnan(d(:,layout)),2),:) = [];
    end
  
    % eliminate rows where angle is 4*pi
    ind = abs(d(:,layout(1))*dg-4*pi)<1e-3;
    d(ind,:) = [];
  
    % extract data
    alpha = d(:,layout(1))*dg;
    beta  = d(:,layout(2))*dg;
    gamma = d(:,layout(3))*dg;
  
    assert(all((beta >=0 & beta <= pi &...
      alpha >= -2*pi & alpha <= 4*pi &...
      gamma > -2*pi & gamma<4*pi) | ...
      isnan(alpha)));
  
    % check for choosing
    if max([alpha(:);beta(:);gamma(:)]) < 10*degree
      warndlg('The imported Euler angles appears to be quit small, maybe your data are in radians and not in degree as you specified?');
    end
  
    % transform to quaternions
    noSymmetry = cellfun(@(x) ~isa(x,'symmetry'),varargin);
    q = rotation('Euler',alpha,beta,gamma,varargin{noSymmetry});
  
  elseif istype(names,quat) % import quaternion
  
    layout = layoutcol(names,quat);
    d(any(isnan(d(:,layout)),2),:) = [];
  
    q = quaternion(d(:,layout(1)),d(:,layout(2)),d(:,layout(3)),d(:,layout(4)));
  
  else
  
    error('You should at least specify three Euler angles or four quaternion components!');
  
  end

  if check_option(varargin,{'passive','passive rotation'}), q = inv(q); end
  % In some software, selecting/partitioning data points is done by setting
  % the phase value to -1. All phase values must be positive integers in
  % mtex. To fix this, add a 'dummy' phase to contain the excluded points.
  
  % return varargin as options
  options = varargin;

  % set up ori variable
  CS = getClass(varargin,'crystalSymmetry',crystalSymmetry);
  SS = getClass(varargin,'specimenSymmetry',specimenSymmetry);
  ori = orientation(q,CS,SS);

catch
  interfaceError(fname)
end

function str = stripws(str)

str = strrep(str,' ','');
