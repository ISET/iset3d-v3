function points = piThreeDCreate(pointsNum)
% Create cell array from a string. Suitable for situations where every
% three numbers are considered as a data point.
    if ischar(pointsNum)
        pointsNum = str2num(pointsNum);
    end

    points = []; % xyz position & triangle mesh
    for ii = 1:numel(pointsNum)/3
        pointList = zeros(1, 3);
        for jj = 1:3
            pointList(jj) = pointsNum((ii - 1) * 3 + jj);
        end
        points = [points; pointList];
    end
end