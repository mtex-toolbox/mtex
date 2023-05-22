function SO3F = abs(SO3F)
% absolute value of an SO3Fun
% 
% Syntax
%   aS3F = abs(S3F)
%
% Input
%  S3F - @SO3Fun
%
% Output
%  S3F - @SO3Fun
%

SO3F = SO3FunHandle(@(rot) abs(SO3F.eval(rot)),SO3F.SRight,SO3F.SLeft);