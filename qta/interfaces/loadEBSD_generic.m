function [ebsd,options] = loadEBSD_generic(fname,varargin)
% load pole figure data from (alpha,beta,gamma) files
%
%% Description
%
% *loadEBSD_txt* is a generic function that reads any txt or exel files of
% diffraction intensities that are of the following format
%
%  alpha_1 beta_1 gamma_1 phase_1
%  alpha_2 beta_2 gamma_2 phase_2
%  alpha_3 beta_3 gamma_3 phase_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  alpha_M beta_M gamma_M phase_m
%
% The assoziation of the columns as Euler angles, phase informationl, etc.
% is specified by the options |ColumnNames| and |Columns|. The files can be
% contain any number of header lines.
%
%% Syntax
%  pf   = loadEBSD_txt(fname,<options>)
%
%% Input
%  fname - file name (text files only)
%
%% Options
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
%% Example
%
%    fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');
%    CS = {'not indexed',...
%          symmetry('m-3m','mineral','Fe'),...
%          symmetry('m-3m','mineral','Mg')};
%    SS = symmetry('triclinic');
%    ebsd = loadEBSD_generic(fname,'CS',CS,'SS',SS, 'ColumnNames', ...
%      {'Index' 'Phase' 'x' 'y' 'Euler1' 'Euler2' 'Euler3' 'MAD' 'BC' 'BS'...
%      'Bands' 'Error' 'ReliabilityIndex'}, 'Bunge')
%
%% See also
% ImportEBSDData loadEBSD ebsd_demo

max_num_phases = 40;

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
  
  options = generic_wizard('data',d(1:end<101,:),'type','EBSD','header',header,'columns',c);
  if isempty(options), ebsd = []; return; end
  varargin = [options,varargin];
  
end

names = lower(get_option(varargin,'ColumnNames'));
cols = get_option(varargin,'Columns',1:length(names));


assert(length(cols) == length(names), 'Length of ColumnNames and Columns differ');

[names m] = unique(names);
cols = cols(m);

istype = @(in, a) all(cellfun(@(x) any(find(strcmpi(stripws(in),stripws(x)))),a));
layoutcol = @(in, a) cols(cell2mat(cellfun(@(x) find(strcmpi(stripws(in(:)),stripws(x))),a(:),'uniformoutput',false)));

euler = lower({'Euler 1' 'Euler 2' 'Euler 3'});
quat = lower({'Quat real' 'Quat i' 'Quat j' 'Quat k'});

if istype(names,euler) % Euler angles specified
  
  layout = layoutcol(names,euler);
  
  %extract options
  dg = degree + (1-degree)*check_option(varargin,{'radians','radiant','radiand'});
  
  % eliminate nans
  d(any(isnan(d(:,layout)),2),:) = [];
  
  % eliminate rows where angle is 4*pi
  ind = abs(d(:,layout(1))*dg-4*pi)<1e-3;
  d(ind,:) = [];
  
  % extract data
  alpha = d(:,layout(1))*dg;
  beta  = d(:,layout(2))*dg;
  gamma = d(:,layout(3))*dg;
  
  assert(all(beta >=0 & beta <= pi & alpha >= -2*pi & alpha <= 4*pi & gamma > -2*pi & gamma<4*pi));
  
  % check for choosing
  if max([alpha(:);beta(:);gamma(:)]) < 10*degree
    warndlg('The imported Euler angles appear to be quite small. Perhaps your data are in radians and not in degrees as you specified?');
  end
  
  % transform to quaternions
  noSymmetry = cellfun(@(x) ~isa(x,'symmetry'),varargin);
  q = rotation('Euler',alpha,beta,gamma,varargin{noSymmetry});
  
elseif istype(names,quat) % import quaternion
  
  layout = layoutcol(names,quat);
  d(any(isnan(d(:,layout)),2),:) = [];
  
  q = rotation(quaternion(d(:,layout(1)),d(:,layout(2)),d(:,layout(3)),d(:,layout(4))));
  
else
  
  error('You should at least specify three Euler angles or four quaternion components!');
  
end

% assign phases
if istype(names,{'Phase'})
  
  phase = d(:,layoutcol(names,{'Phase'}));
  
  % In some software, selecting/partitioning data points is done by setting
  % the phase value to -1. All phase values must be positive integers in
  % mtex. To fix this, add a 'dummy' phase to contain the excluded points.
  if any(phase < 0)
      loc = check_option(varargin, 'cs');
      tmp=varargin{loc+1};
      assignin('base','tmp2',tmp)
      phase(phase < 0) = max(phase)+1;
      tmp{length(tmp)+1} = symmetry('1', 'mineral', 'Excluded points');
      assignin('base','tmp3',tmp)
      varargin{loc+1} = tmp(:);      
      clear tmp
  end  
  
  %[ig,ig,phase] = unique(phase);
else
  
  phase = ones(size(d,1),1);
  
end

if max(phase)>max_num_phases
    
  warning('MTEX:toomanyphases', ...
      ['Found more than ' num2str(max_num_phases) '. I''m going to ignore them all.']);
  phase = ones(size(d,1),1);
  
end

if check_option(varargin,{'passive','passive rotation'}), q = inverse(q); end


% compute unit cells
if istype(names,{'x' 'y'})
  
  varargin = [varargin,'unitCell',calcUnitCell(d(:,layoutcol(names,{'x' 'y' 'z'})),varargin{:})];
  
end

% assign all other as options
opt = struct;
opts = delete_option(names,  [euler quat {'Phase'}]);
if ~isempty(opts)
  
  for i=1:length(opts),
    if layoutcol(names,opts(i)) <= size(d,2)
      opts_struct{i} = [strrep(opts{i},' ','') {d(:,layoutcol(names,opts(i)))}]; %#ok<AGROW>
    end
  end
  opts_struct = [opts_struct{:}];
  opt = struct(opts_struct{:});
end

% return varargin as options
options = varargin;

% set up EBSD variable
ebsd = EBSD(q,symmetry('cubic'),symmetry,varargin{:},'phase',phase,'options',opt);

catch
  interfaceError(fname)
end

function str = stripws(str)

str = strrep(str,' ','');
