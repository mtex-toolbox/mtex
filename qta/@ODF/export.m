function export(odf,filename,varargin)
% export an ODF to an ASCII file
%
% Syntax
%   export(odf,'file.txt','resolution',10*degree)
%   export(odf,'file.txt','interface','VPSC')
%
% Input
%  odf      - ODF to be exported
%  filename - name of the ascii file
%
% Options
%  weights   - export weights of the ODF components
%  ZYZ, ABG  - Matthies (alpha, beta, gamma) convention (default)
%  ZXZ,BUNGE - Bunge (phi1,Phi,phi2) convention 
%
% See also
% ODFImportExport

% get the interface
interface = get_option(varargin,'interface','generic');

% call interface
feval(['export_' interface],odf,filename,varargin{:})
