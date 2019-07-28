# Attner & Keil et al. Current Biology (2019)
# Code and Data repository

This repository contains early somatic cell division timing data, GFP::hlh-2 data as well as MATLAB scripts to replicate key figures 
and statistical analyses in Attner & Keil et al. Current Biology (2019)

If you use this code please cite: Attner, Keil, Benadivez & Greenwald, 2019

For questions, please contact wolfgang.keil@curie.fr

## Cell lineage analysis
Executing statistical_analyses_Z1Z4lineages() will load all early somatic cell division timing 
data gathered at 25˚C, provide some statistics and scatter plots.
Within statistical_analyses_Z1Z4lineages.m, you may change the variable list_file to
'WT_20degrees_list.txt' to analyze and plot data gathered at 20˚C.
 
The subfolders
lineaging_data/20degrees & 
lineaging_data/25degrees 
contain the .txt files with early somatic cell division timings for individual animals

## hlh-2 fluorescence tracing
Executing fluorescence_tracing_GUI(); will open a graphical user interface (GUI) which allows the user to open a micro-manager data 
set and to outline ROIs in order to follow hlh-2 fluorescence in alpha and beta cells over time. This GUI was used to generate fluorescence intensity traces shown
in Figures 2 and S2. 

Execute statistics_hlh2_expression(); to calculate statistics of GFP::hlh-2 onset vs cell division timings. The function reads 
GS9062_hlh2_cell_cycle_timing.xlsx which contains hlh-2 onset timing and division times of Z1/Z4 and progeny for strain GS9062. 

It also contains a folder with tracings for the example individuals shown in Figures 2 and S2.

## Installation

Download by 

$ git clone https://github.com/wolfgangkeil/Attner_Keil_et_al_2019_code.git


## License
Copyright (c) [2019] [Wolfgang Keil]

This repositry contains free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

All code is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details at <https://www.gnu.org/licenses/>.