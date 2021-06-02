# Welcome to ISET3d!

The tools in this repository create spectral irradiance of realistic three-dimensional scenes. The tools work with a special version of PBRT **(pbrt-v3-spectral)** that we implemented.  The implementation is available in a Docker container.

To use these tools you must have Docker and Matlab installed. This repository also depends on ISETCam (or ISETBio), and some people in our lab also require isetcloud.  More on that in the wiki.

The general approach is the following

* A user begins with a set of PBRT files that define the scene.  We typically create scenes via the PBRT export tool from Cinema4D.  We also built an extensive set of special tools to create complex automotive scenes.  That requires Flywheel and scitran, however.
* The user  builds a **recipe** for rendering the PBRT files into a spectral irradiance.  The recipe is a Matlab class that specifies spatial resolution, number of rays, viewing distance, type of optics (pinhole, lens or light field microlens array)
* The recipe also specifies information about the lens (which can contain multiple elements, spherical and certain aspherical shapes) and microlens array on the film surface

To see some examples, have a look at the tutorial directory.  If you want to read more, please look through the [wiki pages](https://github.com/ISET/iset3d/wiki)

(Formerly pbrt2iset, and before that we relied on RenderToolbox4). 

