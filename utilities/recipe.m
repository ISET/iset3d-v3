classdef recipe < handle  
% Contains essential information for rendering the PBRT file
%
%
% TL Scien Stanford, 2017

% PROGRAMMING TODO
%
%  Perhaps this class should be piRecipe.m
%
%  I think we should align the words here with the terms in PBRT.  So, for
%  example, integrator should be SurfaceIntegrator.  Then we should have the
%  permissible list of terms included.  Again, for SurfaceIntegrator in V2 these
%  appear to be described in http://www.pbrt.org/fileformat.html

%

    properties (GetAccess=public, SetAccess=public)
        % Can be set by user
        %
        % These are all structs that contain the parameters necessary
        % for piWrite to convert the structs to text output in the
        % scene.pbrt file.
        
        camera;      % A struct
        sampler;   
        film;
        filter;
        integrator;
        renderer;    %
        lookAt;      % from/to/up struct
        world;       % A big cell array with all the WorldBegin/End stuff
        inputFile;   % Original input file
        outputFile;  % Where outputFile = piWrite(recipe);
        
    end
    
    properties (Dependent)
    end
    
    methods
        % Constructor
        function obj = recipe(varargin)
            % Who knows what we will in the future.
        end
    end
    
end
