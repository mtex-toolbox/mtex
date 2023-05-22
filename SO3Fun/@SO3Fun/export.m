function export(SO3F,filename,varargin)
% export an ODF to an ASCII file
%
% Syntax
%   export(SO3F,'file.txt','resolution',10*degree)
%   export(SO3F,'file.txt','interface','VPSC')
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

% get the interface
interface = get_option(varargin,'interface','generic');

% call interface
feval(['export_' interface],SO3F,filename,varargin{:})
