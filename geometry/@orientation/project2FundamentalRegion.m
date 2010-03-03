function [ori,omega] = project2FundamentalRegion(ori,varargin)
% projects orientation to a fundamental region
%
%% Syntax
%
% [ori,omega] = project2FundamentalRegion(ori,rot_ref)
%
%% Input
%  ori     - @rotation
%  rot_ref - reference @rotation
%
%% Output
%  ori     - @orientation
%  omega   - rotational angle to reference rotation
%

[ori.rotation,omega] = project2FundamentalRegion(ori.rotation,ori.CS,ori.SS,varargin{:});
