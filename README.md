# Attner & Keil et al. Current Biology (2019) Code and Data repository

This repository contains lineaging data, hlh-2 GFP data as well as MATLAB scripts to replicate key figures in
Attner & Keil et al. Current Biology (2019) . 

For questions, please contact wolfgang.keil@curie.fr

## Cell lineage analysis
Executing statistical_analyses_Z1Z4lineages() will load all early somatic cell division timing 
data gathered at 25˚C, provide some statistics and scatter plots.
Within statistical_analyses_Z1Z4lineages.m, you may change the variable list_file to
'WT_20degrees_list.txt' to analyze and plot data gathered at 20˚C.
 

## hlh-2 fluorescence tracing
Executing fluorescence_tracing_GUI(); will open a GUI which allows the user to open a micro-manager data 
set and to outline ROIs in order to follow hlh-2 fluorescence over time

The folder data contains an .xlsx file with all information about hlh-2 onset and division times of Z1/Z4 and progeny 
It also contains a folder with tracings for the examples 

## License
Copyright (c) [2019] [Wolfgang Keil]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.