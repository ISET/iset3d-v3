function status = piRunAssetsTutorialsAll
% Run all iset3d tutorials and collect up status
%
% Syntax
%    status = piRunAssetsTutorialsAll
%
% Description
%    Run all of the iset3d assets tutorials that we think should work, and print
%    out a report at the end as to whether they threw errors, or not.
%    Scripts inside of piRootPath/tutorials/introduciton are run, except that
%    scripts within any directory named 'underDevelopment' or "support"
%    are skipped.
%
% Inputs:
%    None
%
% Outputs:
%    status    - Set to true if all tutorials ran OK, false otherwise.
% 
% See also: piValidateFullAll
%

% History:
%   07/26/17  dhb  Wrote this, because we care.

% User/project specific preferences
p = struct(...
    'rootDirectory',            fileparts(which(mfilename())), ...
    'tutorialsSourceDir',       fullfile(piRootPath, 'tutorials', 'assets') ...                % local directory where tutorial scripts are located
    );

%% List of scripts to be skipped
%
% Anything with this in its path name is skipped.
scriptsToSkip = {...
    'underDevelopment' ...
    'support' ...
    };

%% Use UnitTestToolbox method to do this.
status = UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');

end