function c = getcomment(ebsd)
% return comment corresponding to the ebsd
%
%% Input 
%  ebsd - @EBSD
%
%% Output
%  c   - comment specified for the EBSD
%
%% See also
% EBSD/EBSD

c = ebsd(1).comment;
