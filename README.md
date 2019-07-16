# Attner & Keil et al. Current Biology (2019) Code and Data repository

This repository contains lineaging data, hlh-2 GFP data as well as MATLAB scripts to replicate key figures in
Attner & Keil et al. Current Biology (2019) . 

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
Executing fluorescence_tracing_GUI(); will open a GUI which allows the user to open a micro-manager data 
set and to outline ROIs in order to follow hlh-2 fluorescence over time

The folder data contains an .xlsx file with all information about hlh-2 onset and division times of Z1/Z4 and progeny 
It also contains a folder with tracings for the examples 

## License
Copyright (c) [2019] [Wolfgang Keil]

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details at <https://www.gnu.org/licenses/>.