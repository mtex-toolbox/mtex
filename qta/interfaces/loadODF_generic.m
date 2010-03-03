function [odf,options] = loadODF_generic(fname,varargin)
% load pole figure data from (alpha,beta,gamma) files
%
%% Description 
%
% *loadEBSD_txt* is a generic function that reads any txt or exel files of
% diffraction intensities that are of the following format
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
% is specified by the options |ColumnNames| and |Columns|. The files can be
% contain any number of header lines.
%
%% Syntax
%  odf   = loadODF_generic(fname,<options>)
%
%% Input
%  fname - file name (text files only)
%
%% Options
%  ColumnNames  - names of the colums to be imported, mandatory are euler 1, euler 2, euler 3 
%  Columns      - postions of the columns to be imported
%  RADIANS      - treat input in radiand
%  DELIMITER    - delimiter between numbers
%  HEADER       - number of header lines
%  ZXZ, BUNGE   - [phi1 Phi phi2] Euler angle in Bunge convention (default)
%  ZYZ, ABG     - [alpha beta gamma] Euler angle in Mathies convention
%
% 
%% Example
%
% odf = loadODF_generic('odf.txt','cs',symmetry('cubic'),'header',1,...
%        'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'weight'},...
%        'Columns',[1,2,3,5])
%
%% See also
% interfacesODF_index loadODF ODF_demo

% get options
ischeck = check_option(varargin,'check');
cs = get_option(varargin,'cs',symmetry('m-3m'));
ss = get_option(varargin,'ss',symmetry('-1'));

% load data
[d,varargin,header,c] = load_generic(char(fname),varargin{:});

% no data found
if size(d,1) < 1 || size(d,2) < 3
  error('Generic interface could not detect any numeric data in %s',fname);
end

% no options given -> ask
if ~check_option(varargin,'ColumnNames')
  
  options = generic_wizard('data',d(1:end<101,:),'type','ODF','header',header,'colums',c);
  if isempty(options), odf = []; return; end
  varargin = [options,varargin];

end

names = lower(get_option(varargin,'ColumnNames'));
cols = get_option(varargin,'Columns',1:length(names));

assert(length(cols) == length(names), 'Length of ColumnNames and Columns differ');

[names m] = unique(names);
cols = cols(m);

istype = @(in, a) all(cellfun(@(x) any(find(strcmpi(in,x))),a));
layoutcol = @(in, a) cols(cellfun(@(x) find(strcmpi(in,x)),a));
   
euler = lower({'Euler 1' 'Euler 2' 'Euler 3' 'weight'});
quat = lower({'Quat real' 'Quat i' 'Quat j' 'Quat k' 'weight'});
      
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
  weight = d(:,layout(4));

  assert(all(beta >=0 & beta <= pi & alpha >= -2*pi & alpha <= 4*pi & gamma > -2*pi & gamma<4*pi));
  
  % check for choosing
  if ~ischeck && max(alpha) < 10*degree
    warndlg('The imported Euler angles appears to be quit small, maybe your data are in radians and not in degree as you specified?');
  end
    
  % transform to quaternions
  q = euler2quat(alpha,beta,gamma,varargin{:});
  
elseif istype(names,quat) % import quaternion
    
  layout = layoutcol(names,quat);
  d(any(isnan(d(:,layout)),2),:) = [];
  q = quaternion(d(:,layout(1)),d(:,layout(2)),d(:,layout(3)),d(:,layout(4)));
  weight = d(:,layout(4));
  
else
  error('You should at least specify three Euler angles or four quaternion components and the corresponding weight!');
end
   
if check_option(varargin,'passive rotation'), q = inverse(q); end
 
% return varargin as options
options = varargin;
if ischeck, odf = ODF;return;end


% load single orientations
if ~check_option(varargin,{'exact','resolution'}), varargin = [varargin,'exact'];end
ebsd = EBSD(q,cs,ss,varargin{:});

% calc ODF
odf = calcODF(ebsd,'weight',weight,'silent',varargin{:});
