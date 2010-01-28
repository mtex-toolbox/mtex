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
%
% 
%% Example
%
% ebsd = loadEBSD('ebsd.txt',symmetry('cubic'),symmetry,'header',1,...
%        'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y' 'phase'},...
%        'Columns',[1,2,3,5,6,7])
%
%% See also
% interfacesEBSD_index loadEBSD ebsd_demo

% get options
cs = get_option(varargin,'cs',symmetry('m-3m'));
ss = get_option(varargin,'ss',symmetry('-1'));


if ~iscell(cs), cs = {cs}; end

% load data
[d,varargin,header,c] = load_generic(char(fname),varargin{:});

% no data found
if size(d,1) < 1 || size(d,2) < 3
  error('Generic interface could not detect any numeric data in %s',fname);
end

% check for old version call
if check_option(varargin,'layout')
  
  warning('MTEX:obsoleteSyntax',...
    ['Option ''layout'' is obsolete. ' ...
    'Use ''ColumnNames'' and ''Columns'' instead. '...
    'You might also simply rerun the import wizzard.']);
  layout = get_option(varargin,'layout');
  varargin = delete_option(varargin,'layout',1);
  ColumnNames = {'Euler 1','Euler 2','Euler 3'};
  Columns = layout(1:3);
  
  if length(layout) == 4
    ColumnNames = [ColumnNames,{'Phase'}];
    Columns = layout;
  end
  
  if check_option(varargin,'xy')
    xy = get_option(varargin,'xy');
    ColumnNames = [ColumnNames,{'x','y'}];
    Columns = [layout,xy];
    varargin = delete_option(varargin,'xy',1);
  end
  
  
  varargin = [varargin,{'ColumnNames',ColumnNames,'Columns',Columns}];
end

% no options given -> ask
if ~check_option(varargin,'ColumnNames')
  
  options = generic_wizard('data',d(1:end<101,:),'type','EBSD','header',header,'colums',c);
  if isempty(options), ebsd = []; return; end
  varargin = [options,varargin];

end

names = lower(get_option(varargin,'ColumnNames'));
cols = get_option(varargin,'Columns',1:length(names));


assert(length(cols) == length(names), 'Length of ColumnNames and Columns differ');

[names m] = unique(names);
cols = cols(m);

istype = @(in, a) all(cellfun(@(x) any(find(strcmpi(stripws(in),stripws(x)))),a));
layoutcol = @(in, a) cols(cellfun(@(x) find(strcmpi(stripws(in),stripws(x))),a));
   
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
  if max(alpha) < 10*degree
    warndlg('The imported Euler angles appears to be quit small, maybe your data are in radians and not in degree as you specified?');
  end
    
  % transform to quaternions
  q = orientation('Euler',alpha,beta,gamma,cs{1},ss,varargin{:});
  
elseif istype(names,quat) % import quaternion
    
  layout = layoutcol(names,quat);
  d(any(isnan(d(:,layout)),2),:) = [];
  q = orientation(quaternion(d(:,layout(1)),d(:,layout(2)),d(:,layout(3)),d(:,layout(4))));
  
else
  error('You should at least specify three Euler angles or four quaternion components!');
end
   
if check_option(varargin,'passive rotation'), q = inverse(q); end
 
%treat other options
xy = [];
if istype(names,{'x' 'y'}),
  xy = d(:,layoutcol(names,{'x' 'y'}));
end
  
phase = [];
if istype(names,{'Phase'}),
  phase = d(:,layoutcol(names,{'Phase'}));
end
  
%all other as options
opt = struct;
opts = delete_option(names,  [euler quat {'Phase' 'x' 'y'}]);
if ~isempty(opts)
  
  for i=1:length(opts),
    if layoutcol(names,opts(i)) <= size(d,2)
      opts_struct{i} = [opts{i} {d(:,layoutcol(names,opts(i)))}]; %#ok<AGROW>
    end
  end
  opts_struct = [opts_struct{:}];
  opt = struct(opts_struct{:});
end

%% split according to phase

phases = unique(phase);
ignorePhase = get_option(varargin,'ignorePhase',0);
phases(arrayfun(@(x) any(x == ignorePhase),phases)) = [];

if length(phases)>20
  warning('MTEX:tomanyphases','Found more then 20 phases. I''m going to ignore them.');
  phases = [];
end

% return varargin as options
options = varargin;

% load single phase
if isempty(phases) || sum(phase ~= 0) < 10
  ebsd = EBSD(q,cs,ss,varargin{:},'xy',xy,'options',opt,'phase',1); 
  return
end

%
if numel(cs) < length(phases), cs = repmat({cs{1}},1,length(phases));end


% load multiple phases
for ip = 1:length(phases)

  ind = phase == phases(ip);
  if isempty(xy)
    pxy = [];
  else
    pxy = xy(ind,:);
  end
  popt = structfun(@(x) x(ind),opt,'uniformOutput',false);

  ebsd(ip) = EBSD(set(q(ind),'CS',cs(ip)),varargin{:},'xy',pxy,'phase',phases(ip),'options',popt); %#ok<AGROW>
end


function str = stripws(str)

str = strrep(str,' ','');
