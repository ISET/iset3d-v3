# Welcome to ISET3d!

The tools in this repository use PBRT (physically based ray tracing) to create spectral irradiance of realistic three-dimensional scenes. The tools work with a special version of PBRT **(pbrt-v3-spectral)** that we implemented.  The implementation is available in a Docker container.

The concept is the following.  
* The user begins with a set of PBRT files that define the scene.  We create such a scene, often, via Cinema4D or via special tools we have created to build automotive scenes
* The user  builds a **recipe** for rendering the PBRT files into a spectral irradiance.  The recipe is a Matlab class that specifies spatial resolution, number of rays, viewing distance, type of optics (pinhole, lens or light field microlens array)
* The recipe also specifies information about the lens (which can contain multiple elements, spherical and certain aspherical shapes) and microlens array on the film surface

This repository depends on ISETCam.  We have eliminated dependencies on RenderToolbox4.

(Formerly pbrt2iset)

