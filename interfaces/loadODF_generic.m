function [odf,opt] = loadODF_generic(fname,varargin)
% load pole figure data from (alpha,beta,gamma) files
%
% Description
%
% |loadODF_generic| loads an ODF from any txt or exel files are of the
% following format
%
%  alpha_1 beta_1 gamma_1 weight_1
%  alpha_2 beta_2 gamma_2 weight_2
%  alpha_3 beta_3 gamma_3 weight_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  alpha_M beta_M gamma_M weight_m
%
% The assoziation of the columns as Euler angles, phase informationl, etc.
% is specified by the options |ColumnNames| and |Columns|. The file can
% contain any number of header lines.
%
% Syntax
%   cs = crystalSymmetry('432')
%   odf   = loadODF_generic(fname,'cs',cs,'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'weight'})
%
% Input
%  fname - file name (text files only)
%
% Options
%  ColumnNames  - names of the colums to be imported, mandatory are euler 1, euler 2, euler 3
%  Columns      - postions of the columns to be imported
%  radians      - treat input in radiand
%  delimiter    - delimiter between numbers
%  header       - number of header lines
%  ZXZ, BUNGE   - [phi1 Phi phi2] Euler angle in Bunge convention (default)
%  ZYZ, ABG     - [alpha beta gamma] Euler angle in Mathies convention
%
% Flags
%  interp       - determine the ODF by interpolation the weights
%  density      - determine the ODF as the density of the orientations
%
% Example
%
%    fname = fullfile(mtexDataPath,'ODF','odf.txt');
%    odf = loadODF_generic(fname,'cs',crystalSymmetry('cubic'),'header',5,...
%      'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'weight'},...
%      'Columns',[1,2,3,4])
%
  % See also
% import_wizard loadODF ODF_demo

% get options
ischeck = check_option(varargin,'check');
cs = get_option(varargin,'cs');
ss = get_option(varargin,'ss',specimenSymmetry('1'));
if ~isa(cs,'crystalSymmetry') && ~ischeck && ~check_option(varargin,'wizard')
  error('\nNo crystal Symmetry specified!\n','')
end

% load data
[d,varargin,header,c] = load_generic(char(fname),varargin{:});

% no data found<
if size(d,1) < 1 || size(d,2) < 3
  error('Generic interface could not detect any numeric data in %s',fname);
end

% no options given -> ask
if ~check_option(varargin,'ColumnNames')

  options = generic_wizard('data',d(1:end<101,:),'type','ODF','header',header,'columns',c);
  if isempty(options), odf = []; return; end
  varargin = [options,varargin];

end

loader = loadHelper(d,varargin{:});

q      = loader.getRotations();

% get weights
weights = loader.getColumnData({'weights','weight','intensity'});

% if no weights given - set to one
if isempty(weights), weights = ones(size(q)); end

% return varargin as options
options = varargin;
if ischeck, odf = uniformODF;return;end

if numel(unique(weights)) > 1
  defaultMethod = 'interp';
else
  defaultMethod = 'density';
end

if isempty(cs)
  ori = orientation(q,crystalSymmetry,ss);
  odf = unimodalODF(ori,'weights',weights);
  return
else
  ori = orientation(q,cs,ss,varargin{:});
end

method = get_flag(varargin,{'interp','density'},defaultMethod);

switch method

  case 'density'

    % load single orientations
    if ~check_option(varargin,{'exact','resolution'}), varargin = [varargin,'exact'];end

    % calc ODF
    odf = calcDensity(ori,'weights',weights,'silent',varargin{:});

  case 'interp'

    disp('  Interpolating the ODF. This might take some time...')
    odf = ODF.interp(ori,weights,varargin{:});

end
