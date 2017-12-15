function [ obj ] = render( obj )

symbols = ['a':'z' '0':'9'];

for t=1:length(obj.targets)
    
    if isfield(obj.targets(t),'renderingComplete') && (obj.targets(t).renderingComplete == 1) 
        continue;
    end
        
    
    jobName = lower(obj.targets(t).remote);
    jobName(jobName == '_' | jobName == '.' | jobName == '-' | jobName == '/' | jobName == ':') = '';
    fprintf('Rendering: %s\n',jobName);
    jobName = jobName(max(1,length(jobName)-30):end);
    
    nums = randi(numel(symbols),[1 31]);
    randName = symbols(nums);
    jobName = [randName jobName];
    
    
    % Kubernetess does not allow two jobs with the same name.
    % We need to delete the old one first
    kubeCmd = sprintf('kubectl delete job --namespace=%s %s',obj.namespace,jobName);
    [status, result] = system(kubeCmd);
    
    
    pos = strfind(obj.instanceType,'-');
    nCores = str2double(obj.instanceType(pos(end)+1:end));
    
    
    % Before we can issue a new one
    kubeCmd = sprintf('kubectl run %s --image=%s --namespace=%s --restart=OnFailure --limits cpu=%im  -- ./cloudRenderPBRT2ISET.sh  "%s" ',...
        jobName,...
        obj.dockerImage,...
        obj.namespace,...
        (nCores-0.9)*1000,...
        obj.targets(t).remote);
    
    cntr = 0;
    while cntr < 100
        [status, result] = system(kubeCmd);
        if status == 0, break; end;
        pause(60);
        fprintf('Error issuing kubectl command, pausing for 60 seconds, %i/%i\n',cntr/100);
    end
    
    
    fprintf('%s\n',result);
end

end

