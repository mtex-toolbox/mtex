classdef specimenFrame < referenceFrame
% the reference frame a sample is expressed in
%
% Named instances make moving between specimen frames an explicit
% operation: the measurement frame of the instrument (X, Y, Z), the
% rolling frame (RD, TD, ND), the geological frame. The axis labels are
% identity and display only for now - nothing else consumes them yet.
%
% Syntax
%
%   sF = specimenFrame.measurement
%   sF = specimenFrame.rolling
%   sF = specimenFrame.geological
%
% Class Properties
%  axisLabels - names of the three axes, default {'X','Y','Z'}
%
% See also
% referenceFrame crystalFrame specimenSymmetry

  properties
    axisLabels = {'X','Y','Z'}  % names of the three axes
  end

  methods

    function sF = specimenFrame(varargin)
      sF = sF@referenceFrame(varargin{:});
      sF.axisLabels = get_option(varargin,'axisLabels',sF.axisLabels);
    end

  end

  methods (Static = true)

    function sF = measurement
      % the frame of the instrument the data was measured in
      sF = specimenFrame('name','measurement');
    end

    function sF = rolling
      % rolling direction, transverse direction, normal direction
      sF = specimenFrame('name','rolling','axisLabels',{'RD','TD','ND'});
    end

    function sF = geological
      % north, east, down - the lower hemisphere convention of structural
      % geology; the labels are display only and may still change
      sF = specimenFrame('name','geological','axisLabels',{'N','E','D'});
    end

  end

end
