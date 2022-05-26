# Welcome to ISET3d-V3!

ISET3d-V3 extended our ISETcam simulation tools by providing a physically-accurate simulation of how a 3D scene will look when rendered. This repository is no longer in active use by our lab, having shifted mainly to developing (ISET3d-V4)[https://github.com/ISET/iset3d-v4] (which enables rendering using certain Nvidia GPUs).

The tools in this repository calculate the spectral irradiance of realistic three-dimensional scenes. The tools work with a special version of PBRT **(pbrt-v3-spectral)** that we implemented. In addition to the source code, the implementation is available in a Docker container.

To use these tools you must have Docker and Matlab installed. This repository also depends on ISETCam (or ISETBio), and some people in our lab also require isetcloud. More on that in the wiki.

The general approach is the following

*   Begin with a set of PBRT files that define the scene. We typically create scenes via the PBRT export tool from Cinema4D or more recently Blender.

We have also built special tools to create complex automotive scenes.

Then a typical workflow might be:

*   The user builds a **recipe** for rendering the PBRT files into a spectral irradiance. The recipe is a Matlab class that specifies spatial resolution, number of rays, viewing distance, type of optics (pinhole, lens or light field microlens array)
*   The recipe also specifies information about the lens (which can contain multiple elements, spherical and certain aspherical shapes) and microlens array on the film surface

To see some examples, have a look at the tutorial directory. If you want to read more, please look through the [wiki pages](https://github.com/ISET/iset3d/wiki)

Note: This repository was formerly pbrt2iset, and before that we relied on RenderToolbox4.

ISET3d was originally developed by ImageEval and development is now led Brian Wandell's [Vistalab group](https://vistalab.stanford.edu/) at [Stanford University](stanford.edu), along with co-contributors from other research institutions and industry.
