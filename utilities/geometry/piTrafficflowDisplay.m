function piTrafficflowDisplay(trafficflow)
%%
% plot number of objects with timestep
%%
for ii = 1: length(trafficflow)
    
    % check object.class and plot by class
    if isfield(trafficflow(ii).objects,'Car')
    plot(ii,length(trafficflow(ii).objects.Car),'+');hold on
    end
    if isfield(trafficflow(ii).objects,'Pedestrian')
    plot(ii,length(trafficflow(ii).objects.Pedestrian),'o');hold on
    end
    xlabel('timestep')
    ylabel('number of objects')
%     legend('Car','Pedestrian')
end
end