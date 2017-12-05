function [ obj ] = render( obj )

for t=1:length(obj.targets)
    
    jobName = lower(obj.targets(t).remote);
    jobName(jobName == '_' | jobName == '.' | jobName == '-' | jobName == '/' | jobName == ':') = '';
    jobName = jobName(max(1,length(jobName)-62):end);
    
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
    
    [status, result] = system(kubeCmd);
    
    fprintf('%s\n',result);
end

end

