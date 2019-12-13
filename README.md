[![Build Status](http://brainard-jenkins.psych.upenn.edu/buildStatus/icon?job=iset3d)](http://brainard-jenkins.psych.upenn.edu/job/iset3d/)

Welcome to ISET3d!

This repository contains tools that (a) Read a PBRT file, (b) Enable the user to edit the header blocks, and (c) Invokes the pbrt-v2-spectral docker image to render a scene spectral radiance or optical image irradiance file.

The manipulations of the PBRT file include spatial resolution, number of rays, viewing distance, type of optics (pinhole, lens or light field microlens array).

This repository depends on ISET.  We have eliminated dependencies on RenderToolbox4.

(Formerly pbrt2iset)
