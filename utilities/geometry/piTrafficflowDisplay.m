function piTrafficflowDisplay(trafficflow)
%%
% plot number of objects with timestep
%%
for ii = 1: length(trafficflow)
    
    % check object.class and plot by class
    plot(ii,length(trafficflow(ii).objects),'+');hold on
    xlabel('timestep')
    ylabel('number of objects')
end
end