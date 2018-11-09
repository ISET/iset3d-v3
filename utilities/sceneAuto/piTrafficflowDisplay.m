function piTrafficflowDisplay(trafficflow)
%%
% plot number of objects with timestep
%%
figure;
for ii = 1: length(trafficflow)
    
    % check object.class and plot by class
    if isfield(trafficflow(ii).objects,'car')
        Car = plot(ii,length(trafficflow(ii).objects.car),'+');hold on
    end
    if isfield(trafficflow(ii).objects,'pedestrian')
        Ped = plot(ii,length(trafficflow(ii).objects.pedestrian),'o');hold on
    end
    if isfield(trafficflow(ii).objects,'bicycle')
        Bike = plot(ii,length(trafficflow(ii).objects.bicycle),'*');hold on
    end
    if isfield(trafficflow(ii).objects,'bus')
        Bus = plot(ii,length(trafficflow(ii).objects.bus),'x');hold on
    end
    if isfield(trafficflow(ii).objects,'truck')
        Truck = plot(ii,length(trafficflow(ii).objects.truck),'.');hold on
    end 
end
xlabel('timestep')
ylabel('number of objects')
legend([Car,Ped,Bike,Bus,Truck],'Cars','Pedestrain','Bike','Bus','Truck');
end