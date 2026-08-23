classdef pairShifts
    % @pairShifts class constructor
    % class to store local XY shifts between test and ref images
    % also stores cross-correlation function (XCF) parameters and
    % region of interest (ROI) positions used to calculate shifts


    properties % related to shifts
        % xy units should be in um lengths, not pixels
        xShiftsMap = [] % renamed from shifts.x;] 2D array, 1 value per pixel, x shifts
        yShiftsMap = [] % renamed from shifts.y;] 2D array, 1 value per pixel, y shifts
 
        xShiftsFit = [] % [renamed from shifts.xshiftsROI;] column vector, 1 value per ROI, x shifts after surface fit
        yShiftsFit = [] % [renamed from shifts.yshiftsROI;]  column vector, 1 value per ROI, y shifts after surface fit

        xShiftsXcf = [] % [renamed from ROI.Shift_X_1] column vector, 1 value per ROI, x shifts measured from cross-correlation
        yShiftsXcf = [] % [renamed from ROI.Shift_Y_1] column vector, 1 value per ROI, x shifts measured from cross-correlation

        % add pixel dimensions here to enable conversions
        dx = [] % pixel length in um
        dy = [] % pixel length in um
    end

    properties % related to ROI
        % these are in pixel units
        roiPosX % ROI centre positions (x == columns) in image [renamed from ROI.position_X_pass_1]
        roiPosY % ROI centre positions (y == rows) in image [renamed from ROI.position_Y_pass_1]
        roiSize % ROI side length [renamed from ROI.size_pass_1]
    end


    methods
        function shifts = pairShifts(x,y,xshiftsROI,yshiftsROI,...
                xShiftsXcf, yShiftsXcf, roiPosX, roiPosY, roiSize, dx, dy, varargin)
            % Construct an instance of this class
            % inputs / outputs described in script header
            %TODO - check input types
            if nargin == 0, return; end

            % copy constructor
            if isa(x,'pairShifts')
                props=properties(x);
                for i = 1:numel(props)
                    shifts.(props{i}) = x.(props{i});
                end
                return
            end

            shifts.xShiftsMap = x;
            shifts.yShiftsMap = y;
            shifts.xShiftsFit = xshiftsROI(:);
            shifts.yShiftsFit = yshiftsROI(:);
            shifts.xShiftsXcf = xShiftsXcf(:);
            shifts.yShiftsXcf = yShiftsXcf(:);

            shifts.dx = dx;
            shifts.dy = dy;

            shifts.roiSize = roiSize;           
            shifts.roiPosX = roiPosX;
            shifts.roiPosY = roiPosY;

        end
    end
end