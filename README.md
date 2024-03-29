# FIJI_Fl_nuclei_count

VTB-P70:

Stained tissue was digitalized with a Pannoramic® SCAN II slidescanner (3DHISTECH, Budapest, Hungary) with a 20x objective and converted to 8-bit images in Tiled Tagged Image File Format (*.tif) with SlideConverter 2.2 (3DHISTECH, Budapest, Hungary) with a resolution of 0.4µm/Pixel. Image analyzes were made with FIJI (Schindelin et al, 2012), using a self-made ImageJ-script (supplementary *.ijm-file). After a background subtraction (rolling ball: 30) to reduce auto-fluorescence and unspecific signal, automatic contrast enhancement (saturation: 0.3) and a Gaussian Blur filter (sigma: 0.5) were used to get a segmentation of the nuclei with an automated threshold (“Yen Dark”). To separate merged nuclei, a watershed was applied and both Ki67-positive nuclei and Ki67-negative nuclei, counter-stained with DAPI, were analyzed by size and all between 10µm² and 200µm² were counted.

<a href="https://zenodo.org/badge/latestdoi/228417933"><img src="https://zenodo.org/badge/228417933.svg" alt="DOI"></a>
