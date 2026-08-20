function varargout = clim(varargin)
% clim was introduced in R2022a (version 9.12) as the replacement for caxis
%
% The folder name is the version the shim is needed *below* - startup_mtex
% excludes a compatibility/less<v> folder as soon as the running MATLAB is
% not older than <v>. This lived in less9.8 (R2020a) until Aug 2026, which
% left R2020a to R2021b without a clim of any kind, so every plot going
% through vector3d/smooth died on "Unrecognized function or variable
% 'clim'" (#2148).

[varargout{1:nargout}] = caxis(varargin{:});
