classdef sigmaSections < pfSections
% sigma sections for ODF and orientation plotting
%
% The MTEX default for plotting an ODF. Sigma sections are the pole figure
% of the c* axis, split up by sigma = phi1 - phi2. Unlike Euler angle
% sections they distort orientation space only mildly, so a component
% keeps its shape across the sections.
%
% Syntax
%   oS = sigmaSections(cs1,cs2)
%   oS = sigmaSections(cs1,cs2,'sections',5)
%   oS = sigmaSections(cs1,cs2,'sigma',(0:15:90)*degree)
%
% Input
%  cs1, cs2 - @crystalSymmetry, @specimenSymmetry
%
% Options
%  sections - number of sections
%  sigma    - explicit section values
%
% Class Properties
%  omega          - the sigma value of each section
%  h1, h2         - the @Miller the sections are built from
%  sR             - @sphericalRegion each section is plotted on
%  referenceField - @S2VectorField sigma is measured against
%
% Example
%
%   mtexdata dubna
%   odf = calcODF(pf,'silent');
%   plotSection(odf,sigmaSections(odf.CS,odf.SS))
%
% See also
% ODFSections pfSections omegaSections SO3Fun/plotSection
%

  methods
    
    function oS = sigmaSections(CS1,CS2,varargin)
            
      if nargin == 1, CS2 = specimenSymmetry.default; end

      oS = oS@pfSections(CS1,CS2);
                
      oS.maxOmega = 2*pi / CS1.nfold(oS.h1);
      
      % get sections
      oS.omega = linspace(0,oS.maxOmega,1+get_option(varargin,'sections',6));
      oS.omega(end) = [];
      oS.omega = get_option(varargin,'sigma',oS.omega,'double');
      
      oS.updateTol(oS.omega);
      
      oS.referenceField = S2VectorField.sigma(varargin{:},oS.SS.how2plot);
            
    end            
  end  
end
