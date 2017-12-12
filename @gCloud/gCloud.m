classdef gCloud < handle

    properties (GetAccess=public, SetAccess=public)
        
        % Local folder in the docker image
        localFolder = 'WorkDir';
        cloudBucket = '';
        
        % where to write output files
        outputFolder;
        
        % where to put scenes before rendering
        workingFolder;
        
        % Variables specific to cloud provider
        provider = 'Google';
        clusterName = 'rtb4';
        zone = 'us-central1-a';
        instanceType = 'n1-highcpu-32';
        minInstances = 1;
        maxInstances = 10;
        preemptible = true;
        autoscaling = true;
        namespace = '';
        
        dockerImage = '';
        
        targets;
        
    end
    
    methods
       
        % Constructor
        function obj = gCloud(varargin)
            
            p = inputParser;
            p.addOptional('provider','Google',@ishcar);
            p.addOptional('clusterName','rtb4',@ischar);
            p.addOptional('zone','us-central1-a',@ischar);
            p.addOptional('instanceType','n1-highcpu-32',@ischar);
            p.addOptional('minInstances',1,@isnumeric);
            p.addOptional('maxInstances',10,@isnumeric);
            p.addOptional('preemptible',true,@islogical);
            p.addOptional('autoscaling',true,@islogical);
            p.addOptional('cloudBucket','',@ischar);
            p.addOptional('dockerImage','',@ischar);
            
            p.parse(varargin{:});
            
            obj.provider = p.Results.provider;
            obj.clusterName = p.Results.clusterName;
            obj.zone = p.Results.zone;
            obj.instanceType = p.Results.instanceType;
            obj.minInstances = p.Results.minInstances;
            obj.maxInstances = p.Results.maxInstances;
            obj.preemptible = p.Results.preemptible;
            obj.autoscaling = p.Results.autoscaling;
            obj.cloudBucket = p.Results.cloudBucket;
            obj.dockerImage = p.Results.dockerImage;
            
            obj.namespace = getenv('USER');
        end
        
    end


end