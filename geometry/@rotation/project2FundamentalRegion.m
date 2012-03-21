function [rot,omega] = project2FundamentalRegion(rot,varargin)
% projects rotation to a fundamental region
%
%% Syntax
%
% project2FundamentalRegion(rot,CS,SS,rot_ref)
%
%% Input
%  rot     - @rotation
%  CS, SS  - crystal / specimen @symmetry      
%  rot_ref - reference @rotation
%
%% Output
%  rot     - @rotation
%  omega   - rotational angle to reference rotation
%

[rot.quaternion,omega] = project2FundamentalRegion(rot.quaternion,varargin{:});
