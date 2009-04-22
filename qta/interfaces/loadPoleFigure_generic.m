function [pf,options] = loadPoleFigure_generic(fname,varargin)
% load pole figure data from (theta,rho,intensity) files
%
%% Description 
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
%% Syntax
%  pf   = loadPoleFiguretxt(fname,<options>)
%
%% Input
%  fname - file name (text files only)
%
%% Options
%  ColumnNames       - content of the columns to be imported
%  Columns           - positions of the columns to be imported
%  RADIANS           - treat input in radians
%  DELIMITER         - delimiter between numbers
%  HEADER            - number of header lines
% 
%% Example
%
%  pf = loadPoleFigure_generic('pf001.txt','HEADER',5,'degree',...
%        'ColumnNames',{'polar angle','azimuth angle','intensity'},...
%        'Columns',[1 2 3])
%
%% See also
% interfaces_index munich_interface loadPoleFigure


% load data
[d,varargin,header,colums] = load_generic(fname,varargin{:});

% no data found
if size(d,1) < 10 || size(d,2) < 3
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
  ColumnNames = {'Polar Angle','Azimuth Angle','Intensity'};
  Columns = layout(1:3);
  
  varargin = {varargin{:},'ColumnNames',ColumnNames,'Columns',Columns};
end


% no options given -> ask
if ~check_option(varargin,'ColumnNames') || ~check_option(varargin,'Columns')
  
  options = generic_wizard('data',d,'type','PoleFigure','header',header,'colums',colums);
  if isempty(options), pf = []; return; end 
  varargin = {options{:},varargin{:}};

end

% get data
cols = get_option(varargin,'Columns');
names = lower(get_option(varargin,'ColumnNames'));

mtex_assert(length(cols) == length(names), 'Length of ColumnNames and Columns differ');

[names m] = unique(names);
cols = cols(m);

istype = @(in, a) all(cellfun(@(x) any(find(strcmpi(in,x))),a));
layoutcol = @(in, a) cols(cellfun(@(x) find(strcmpi(in,x)),a));
sphcoord = lower({'Polar Angle','Azimuth Angle','Intensity'});

mtex_assert(istype(names,sphcoord) ...
  ,'You should at least specify the columns of the spherical coordinates and the intensities!');
  
layout = layoutcol(names,sphcoord);
  
% eliminate nans
d(any(isnan(d(:,layout)),2),:) = [];
  
%extract options
dg = degree + (1-degree)*check_option(varargin,{'RADIAND','radiant','radians'});
  
th = d(:,layout(1))*dg;
rh = d(:,layout(2))*dg;
v = d(:,layout(3));
  
if max(rh) < 10*degree
  warndlg('The imported polar angles appears to be quit small, maybe your data are in radians and not in degree as you specified?');
end
  
if all(th<=0), th = -th;end
mtex_assert(length(v)>=5,'To few data points');
mtex_assert(all(th>=0 & th <= pi) && ...
  all(rh>=-360) && all(rh<=720),'Polar coordinates out of range!');

% specimen directions
r = S2Grid(sph2vec(th,rh),'reduced');
  
% crystal direction
h = string2Miller(fname);
  
%all other as options
opt = struct;
opts = delete_option(names,  sphcoord);
if ~isempty(opts)
  for i=1:length(opts),
    opts_struct{i} = [opts{i} {d(:,layoutcol(names,opts(i)))}]; %#ok<AGROW>
  end
  opts_struct = [opts_struct{:}];
  opt = struct(opts_struct{:});
end
  
pf = PoleFigure(h,r,v,symmetry('cubic'),symmetry,'options',opt);
options = varargin;
