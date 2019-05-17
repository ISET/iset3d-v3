function piRunTutorialsAll
% Run all iset3d tutorials and collect up status
%
% Syntax:
%   piRunTutorialsAll
%
% Description:
%    Run all of the isetbio tutorials that we think should work, and print
%    out a report at the end as to whether they threw errors, or not.
%    Scripts inside of isetbioRootPath/tutorials are run, except that
%    scripts within the directory 'underDevelopment' are skipped.
%
% Inputs:
%    None
%
% Outputs:
%    status    - Set to true if all tutorials ran OK, false otherwise.
%
% Optional key/value pairs:
%    None
%
% See Also:
%   piValidateFullAll
%

% History:
%    07/26/17  dhb  Wrote this, because we care.
%    03/19/19  JNM  Documentation pass

%% User/project specific preferences
% The tutorialsSourceDir is the local directory where the scripts live.
p = struct('rootDirectory', fileparts(which(mfilename())), ...
    'tutorialsSourceDir', fullfile(piRootPath, 'tutorials'));

%% List of scripts to be skipped
% Anything with this in its path name is skipped.
scriptsToSkip = {'underDevelopment' 'support'};

%% Use UnitTestToolbox method to do this.
% status = UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');
UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');

end