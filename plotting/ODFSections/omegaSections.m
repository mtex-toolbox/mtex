classdef omegaSections < pfSections
% omega sections for ODF and orientation plotting
%
% Like @sigmaSections, but the sections are the rotations about the c*
% axis by a fixed angle omega rather than by sigma = phi1 - phi2.
%
% Syntax
%   oS = omegaSections(cs1,cs2)
%   oS = omegaSections(cs1,cs2,'sections',5)
%   oS = omegaSections(cs1,cs2,'omega',(0:15:90)*degree)
%
% Input
%  cs1, cs2 - @crystalSymmetry, @specimenSymmetry
%
% Options
%  sections - number of sections
%  omega    - explicit section values
%
% Class Properties
%  omega          - the value of each section
%  h1, h2         - the @Miller the sections are built from
%  sR             - @sphericalRegion each section is plotted on
%  referenceField - @S2VectorField omega is measured against
%
% See also
% ODFSections pfSections sigmaSections
%

  methods
    
    function oS = omegaSections(CS1,CS2,varargin)
            
      oS = oS@pfSections(CS1,CS2);
                
      oS.maxOmega = 2*pi / CS1.nfold(oS.h1);
      
      % get sections
      oS.omega = linspace(0,oS.maxOmega,1+get_option(varargin,'sections',6));
      oS.omega(end) = [];
      oS.omega = get_option(varargin,'omega',oS.omega,'double');
      
      oS.updateTol(oS.omega);
      
      oS.referenceField = S2VectorField.sigma;
      %if nargin < 4, r_ref = xvector; end
      %oS.referenceField = S2VectorField.polar(r_ref);
      
    end            
  end  
end
