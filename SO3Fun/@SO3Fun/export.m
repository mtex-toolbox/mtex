function export(SO3F,filename,varargin)
% export an ODF to an ASCII file
%
% Syntax
%   export(SO3F,'file.txt','resolution',10*degree)
%   export(SO3F,'file.txt','interface','VPSC')
%   export(SO3F,'file.txt','VPSC')
%
% Input
%  SO3F      - @SO3Fun to be exported
%  filename  - name of the ascii file
%
% Options
%  weights   - export weights of the ODF components
%  ZYZ, ABG  - Matthies (alpha, beta, gamma) convention (default)
%  ZXZ,BUNGE - Bunge (phi1,Phi,phi2) convention
%  interface - generic (default), mtex, VPSC
%
% See also
% ODFImport ODFExport

% the known interfaces, i.e. the export_* methods of this class
interfaces = {'generic','mtex','VPSC'};

% get the interface - it may be given as an option or, since the name is
% unambiguous, as a bare flag
interface = get_option(varargin,'interface','');

if isempty(interface)
  isFlag = cellfun(@(i) check_option(varargin,i),interfaces);
  if any(isFlag)
    interface = interfaces{find(isFlag,1)};
  else
    interface = 'generic';
  end
end

% spelled as written above, so that the file name matches on case sensitive
% file systems and an unknown interface is reported as such
ind = find(strcmpi(interface,interfaces),1);
if isempty(ind)
  error('MTEX:export:unknownInterface',...
    'Unknown export interface "%s". Available are: %s.',...
    interface,strjoin(interfaces,', '));
end

% call interface
feval(['export_' interfaces{ind}],SO3F,filename,varargin{:})
