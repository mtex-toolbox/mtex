function [ori,omega] = project2FundamentalRegion(ori,varargin)
% projects orientation to a fundamental region
%
% Syntax
%   [ori,omega] = project2FundamentalRegion(ori,rot_ref)
%
% Input
%  ori     - @orientation
%  ori_ref - reference @rotation
%
% Output
%  ori     - @orientation
%  omega   - rotational angle to reference rotation
%

% TODO
% [ori,omega] = project2FundamentalRegion@rotation(ori,ori.CS,ori.SS,varargin{:});

[ori,omega] = project2FundamentalRegion@rotation(ori,ori.CS,varargin{:});
