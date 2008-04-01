function [pf,interface,options,ipf] = loadPoleFigure(fname,varargin)
% import pole figure data 
%
%% Description
% *loadPoleFigure* is a high level method for importing pole figure data
% from external files. It autodetects the format of the file. As parameters
% the method requires the crystal and specimen @symmetry. Additionally it is
% sometimes required to pass a list of crystal directions and a list of
% structure coefficients. See [[interfaces_index.html,interfaces]] for an
% example how to import superposed pole figures. In the case of generic
% ascii files each of which consist of a table containing in each row a
% specimen direction and a diffraction intensity see
% [[loadPoleFigure_txt.html,loadPoleFigure_txt]] for additional options.
% Furthermore, you can specify a comment to be associated with the data.
%
%
%% Syntax
% pf = loadPoleFigure(fname,cs,ss,<options>)
%
% fnames = {fname1,...,fnameN}
% h = {h1,..,hN}
% c = {c1,..,cN}
% pf = loadPoleFigure(fnames,h,cs,ss,'superposition',c,<options>)
%
%% Input
%  fname     - filename(s)
%  h1,...,hN - @Miller crystal directions (optional)
%  c1,...,cN - structure coefficients for superposed pole figures (optional)
%  cs, ss    - crystal, specimen @symmetry (optional)
%
%% Options
%  interface  - specific interface to be used
%  comment    - comment to be associated with the data
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% interfaces_index PoleFigure/calcODF examples_index

%% proceed input argument
if nargin < 1
  [fname,PathName] = uigetfile( '*.*',...
  'Select Data files');
  fname = [PathName,fname];
end
if ischar(fname), fname = {fname};end

% get crystal directions
if nargin > 1 && (isa(varargin{1},'Miller') || isa(varargin{1},'cell'))
  h = vec2cell(varargin{1});
  varargin = {varargin{2:end}};
end

% get crystal and specimen symmetry
if ~isempty(varargin) && isa(varargin{1},'symmetry')
  cs = varargin{1};varargin = {varargin{2:end}};
end

if ~isempty(varargin) && isa(varargin{1},'symmetry')
  ss = varargin{1};varargin = {varargin{2:end}};
end

%% determine interface
if ~check_option(varargin,'interface')  
  [interface,options] = check_interfaces(fname{1},varargin{:});  
else
  interface = get_option(varargin,'interface');
  options = varargin;
end

pf = [];ipf = [];
if isempty(interface), return; end

%% import data
c = get_option(options,'superposition');
if isa(c,'double'), c = {c};end
varargin = delete_option(options,'superposition');


for i = 1:length(fname)  
  npf = feval(['loadPoleFigure_',char(interface)],fname{i},options{:});
  pf = [pf,npf]; 
  ipf(i) = length(npf);
end

for i = 1:length(pf)
  if exist('h','var'), pf(i) = set(pf(i),'h',h{i});end
  if exist('cs','var'), pf(i) = set(pf(i),'CS',cs);end
  if exist('ss','var'), pf(i) = set(pf(i),'SS',ss);end
  if ~isempty_cell(c), pf(i) = set(pf(i),'c',c{i});end
 
  [ps,fn,ext] = fileparts([fname{min(i,length(fname))}]);
  pf(i) = set(pf(i),'comment',get_option(varargin,'comment',[fn ext]));
  
end
