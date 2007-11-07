function c = getcomment(odf)
% return comment corresponding to the odf
%
%% Input 
%  odf - @ODF
%
%% Output
%  c   - comment specified for the ODF
%
%% See also
% ODF/ODF

c = odf(1).comment;
