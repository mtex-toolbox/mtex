function [pf,interface,options] = load(fname,varargin)
% import pole figure data 
%
% Description
%
% PoleFigure.load is a high level method for importing pole figure data
% from external files. It autodetects the format of the file. As parameters
% the method requires the crystal and specimen @symmetry. Additionally it
% is sometimes required to pass a list of crystal directions and a list of
% structure coefficients. See <PoleFigureImport.html interfaces> for an
% example how to import superposed pole figures. In the case of generic
% ascii files each of which consist of a table containing in each row a
% specimen direction and a diffraction intensity see
% <loadPoleFigure_generic.html loadPoleFigure_generic> for additional
% options. Furthermore, you can specify a comment to be associated with the
% data.
%
%
% Syntax
%   pf = PoleFigure.load(fname)
%
%   fnames = {fname1,...,fnameN}  % define filename(s)
%   h = {h1,..,hN}                % define crystal directions
%   c = {c1,..,cN}                % define structure coefficients
%   pf = PoleFigure.load(fnames,h,cs,ss,'superposition',c)
%
% Input
%  fname     - filename(s)
%  h1,...,hN - @Miller crystal directions
%  c1,...,cN - structure coefficients for superposed pole figures (optional)
%  cs, ss    - crystal, specimen @symmetry
%
% Options
%  interface  - specific interface to be used
%
% Output
%  pf - vector of @PoleFigure
%
% See also
% ImportPoleFigureData PoleFigure/calcODF examples_index

% extract file names
fname = getFileNames(fname);

%  determine interface 
if ~check_option(varargin,'interface')
  [interface,options] = check_interfaces(fname{1},'PoleFigure',varargin{:});
  if isempty(interface), return; end
elseif check_option(varargin,'columnNames')
  interface = 'generic';
  options = varargin;
else
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
end

% load the data
for k = 1:numel(fname)  
  pf{k} = feval(['loadPoleFigure_',char(interface)],...
    fname{k},options{:});   %#ok<AGROW>   
end

% combine data
pf = [pf{:}];

% set crystal directions
if nargin > 1 && iscell(varargin{1}) && ...
    all(cellfun('isclass',varargin{1},'Miller'))  
  pf.allH = varargin{1};
end

% structure coefficients
if check_option(varargin,'superposition')
  pf.c = get_option(varargin,'superposition');
end

