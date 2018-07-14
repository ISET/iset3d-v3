function object=piObjectRotate(object,degree)
% only rotate around y axis is allowed 


for ii=1:length(object)
    % rotate car 
    object(ii).rotate = [degree 0 1 0];
    if ~isempty(object(ii).child)
    d = pdist([0,0;object(ii).size.pmin]);
    
    % rotate pmin and pmax
    object(2).size.pmin = [-d*cosd(degree) -d*sind(degree)];
    end
    % rotate lights
    if contains(object(ii).name,'lightfront_left')
        d_lightfront_left = pdist([0,0;object(ii).position(1),object(ii).position(3)]);
        object(ii).position = [d_lightfront_left*cosd(degree) object(ii).position(2) d_lightfront_left*sind(degree)];
    end
    if contains(object(ii).name,'lightfront_right')
        d_lightfront_right = pdist([0,0;object(ii).position(1),object(ii).position(3)]);
        object(ii).position = [d_lightfront_right*cosd(degree) object(ii).position(2) -d_lightfront_right*sind(degree)];
    end
    if contains(object(ii).name,'lightback_left')
        d_lightback_left = pdist([0,0;object(ii).position(1),object(ii).position(3)]);
        object(ii).position = [-d_lightback_left*cosd(degree) object(ii).position(2) d_lightback_left*sind(degree)];
    end
    if contains(object(ii).name,'lightback_right')
        d_lightback_right = pdist([0,0;object(ii).position(1),object(ii).position(3)]);
        object(ii).position = [-d_lightback_right*cosd(degree) object(ii).position(2) -d_lightback_right*sind(degree)];
    end
end
end