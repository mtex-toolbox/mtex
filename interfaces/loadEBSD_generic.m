function [ebsd,options] = loadEBSD_generic(fname,varargin)
% load ebsd data from generic text files
%
% Description
%
% *loadEBSD_generic* loads EBSD data from text or exel files that have a
% column oriented format as
%
%  x1 y1 phi1_1 Phi_1 phi2_1 phase_1
%  x2 y2 phi1_2 Phi_2 phi2_2 phase_2
%  x2 y3 phi1_3 Phi_3 phi2_3 phase_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  xM yM phi1_M Phi_M phi2_M phase_m
%
% The assoziation of the columns as Euler angles, phase informationl, etc.
% is specified by the options |ColumnNames| and |Columns|. The files can be
% contain any number of header lines.
%
% Syntax
%   ebsd   = loadEBSD_generic(fname,'ColumnNames',{'x','y','Euler1','Euler2','Euler3','phase'},'cs',cs)
%
% Input
%  fname - file name (text files only)
%  cs - @crystalSymmetry or cell array of @crystalSymmetry
%
% Options
%  ColumnNames       - names of the colums to be imported, mandatory are euler 1, euler 2, euler 3
%  Columns           - postions of the columns to be imported
%  radians           - treat input in radiand
%  delimiter         - delimiter between numbers
%  header            - number of header lines
%  Bunge             - [phi1 Phi phi2] Euler angle in Bunge convention (default)
%  ABG               - [alpha beta gamma] Euler angle in Mathies convention
%  passive           -
%
%
% Example
%
%   fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');
%   CS = {'notIndexed',...
%          crystalSymmetry('m-3m','mineral','Fe'),...
%          crystalSymmetry('m-3m','mineral','Mg')};
%   SS = specimenSymmetry('triclinic');
%   ebsd = loadEBSD_generic(fname,'CS',CS,'SS',SS, 'ColumnNames', ...
%     {'Index' 'Phase' 'x' 'y' 'Euler1' 'Euler2' 'Euler3' 'MAD' 'BC' 'BS'...
%     'Bands' 'Error' 'ReliabilityIndex'}, 'Bunge')
%
% See also
% ImportEBSDData loadEBSD ebsd_demo

max_num_phases = 40;

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

    options = generic_wizard('data',d(1:end<101,:),'type','EBSD','header',header,'columns',c);
    if isempty(options), ebsd = []; return; end
    varargin = [options,varargin];

  end

  loader = loadHelper(d,varargin{:});

  q      = loader.getRotations();

  % assign phases
  if loader.hasColumn('Phase')

    phase = loader.getColumnData('Phase');

  else

    phase = ones(length(q),1);

  end

  if max(phase)>max_num_phases

    warning('MTEX:toomanyphases', ...
      ['Found more than ' num2str(max_num_phases) '. I''m going to ignore them all.']);
    phase = ones(size(d,1),1);

  end

  % compute unit cells
  if loader.hasColumn({'x' 'y'})

    varargin = [varargin,'unitCell',....
      calcUnitCell(loader.getColumnData({'x' 'y' 'z'}),varargin{:})];

  end

  % return varargin as options
  opt = loader.getOptions('ignoreColumns','Phase');

  % set up EBSD variable
  CSList = get_option(varargin,'CS',repcell('notIndexed',1,3));
  ebsd = EBSD(q,phase,CSList,opt,varargin{:});

catch
  interfaceError(fname)
end
