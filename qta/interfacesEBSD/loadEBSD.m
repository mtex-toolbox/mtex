function [ebsd,interface,options,iebsd] = loadEBSD(fname,varargin)
% import ebsd data 
%
%% Description
% *loadEBSD* is a high level method for importing EBSD data from external
% files. It autodetects the format of the file. As parameters the method
% requires a filename and the crystal and specimen @symmetry. Furthermore,
% you can specify a comment to be associated with the data. In the case of
% generic ascii files each of which consist of a table containing in each
% row the euler angles of a certain orientation see
% [[loadEBSD_txt.html,loadEBSD_txt]] for additional options.
%
%% Syntax
%  pf = loadEBSD(fname,cs,ss,<options>)
%
%% Input
%  fname     - filename
%  cs, ss    - crystal, specimen @symmetry (optional)
%
%% Options
%  interface  - specific interface to be used
%  comment    - comment to be associated with the data
%
%% Output
%  ebsd - @EBSD
%
%% See also
% interfacesEBSD_index ebsd/calcODF ebsd_demo loadEBSD_txt

%% proceed input argument
if nargin < 1
  [fname,PathName] = uigetfile( '*.*',...
  'Select Data files');
  fname = [PathName,fname];
end
if ischar(fname), fname = {fname};end

% get crystal and specimen symmetry
if ~isempty(varargin) && isa(varargin{1},'symmetry')
  cs = varargin{1};varargin = {varargin{2:end}};
end

if ~isempty(varargin) && isa(varargin{1},'symmetry')
  ss = varargin{1};varargin = {varargin{2:end}};
end

%% determine interface
if ~check_option(varargin,'interface')  
  [interface,options] = check_ebsd_interfaces(fname{1},varargin{:});  
else
  interface = get_option(varargin,'interface');
  options = varargin;
end

if isempty(interface), ebsd = []; return; end

%% import data
ebsd = [];
for i = 1:length(fname)  
  ebsd = [ebsd,feval(['loadEBSD_',char(interface)],fname{i},options{:})]; 
end

if exist('cs','var')
  if numel(cs) > 1
    for i = 1:numel(cs), ebsd = set(ebsd,i,'CS',cs(i)); end
  else
    for i = 1:numel(ebsd), ebsd = set(ebsd,i,'CS',cs); end
  end
end
if exist('ss','var'), ebsd = set(ebsd,'SS',ss);end

[ps,fn,ext] = fileparts([fname{min(1,length(fname))}]);
ebsd = set(ebsd,'comment',get_option(varargin,'comment',[fn ext]));
  
iebsd = numel(ebsd);
%end
