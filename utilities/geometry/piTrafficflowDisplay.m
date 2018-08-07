function piTrafficflowDisplay(trafficflow)
%%
% plot number of objects with timestep
%%
for ii = 1: length(trafficflow)
    
    % check object.class and plot by class
    if isfield(trafficflow(ii).objects,'car')
    Car = plot(ii,length(trafficflow(ii).objects.car),'+');hold on
    end
    if isfield(trafficflow(ii).objects,'pedestrian')
    Ped = plot(ii,length(trafficflow(ii).objects.pedestrian),'o');hold on
    end
   
   
end
xlabel('timestep')
ylabel('number of objects')
legend([Car,Ped],'Cars','Pedestrain');
end