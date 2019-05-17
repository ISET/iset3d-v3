function [dockerExists, status, result] = piDockerExists()
% Check whether we can find and use Docker.
%
% Syntax:
%   [dockerExists, status, result] = piDockerExists()
%
% Description:
%    Returns true if Docker can be found on the host system, and if the
%    current user has permission to invoke Docker commands.
%
% Inputs:
%    None.
%
% Outputs:
%    dockerExists - Boolean. A boolean that indicates whether or not the
%                   user can find Docker.
%    status       - Boolean. A numeric boolean indicating whether or not
%                   the system query was successful. 0 indicates a pass,
%                   and any other number is the error code.
%    result       - Array. A character array containing the result of the
%                   system command call.
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * RenderToolbox4 Copyright (c) 2012-2016 The RenderToolbox Team.
%    * About Us://github.com/RenderToolbox/RenderToolbox4/wiki/About-Us
%    * RenderToolbox4 is released under the MIT License.  See LICENSE file.
%

%% Can we use Docker?
[status, result] = system('docker ps');
dockerExists = (0 == status);

end
