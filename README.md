# Spectrophotometer-data-compiler
This is an open source program that takes a .opj input and processes that data into various .csv files based on user preferences
This program was written in R and used the following packages:
(Rcpp)
(Ropj)
(ggplot2)
(shiny)

# Explanation
This program was made from data generated with the Horiba FluoroLog - Modular Spectrofluorometer

see product here: https://www.selectscience.net/products/fluorolog-modular-spectrofluorometer/?prodID=93422

this is not a product endorsement nor am I affiliated with Horiba scientific

More specifically this program works to generate a graph and spreadsheet with information pertaining to the intensity of reflected light at a specified wavelength.

A series of spreadsheets are generated based on the number of measurements that were taken for a sample within a group.

If you would like to test the program for yourself I suggest downloading the .OPJ from the main page and taking that for a test run.

# How to use it
1. Launce the program and hit the ">Run app" button near the top right of the workspace.

2. Once the app is running it will ask for the working directiory. Simply select the folder that has your .opj file and hit ok.

3. After you have selected the working directory you will set the emission peak you wish to analyze (in the example this is 509nm).

4. Select how many measurements you took per sample (in the example this is 27).

5. Name your samples (already done for the example).

6. Once all of that is done hit "See Data" and you will be shown a graph made from your data, and your spreadsheets will be in the same folder your .opj file was in.

# Known issues
The current version of this program does not work with multiple .opj files at the same time

Not selecting a working directory will crash the program

Putting the wrong number of samples or the wrong number of measurements will simply cut off portions of the dataset with no warning to the user

I am still fairly new to R and I am only developing this program in my free time, so while I intend to fix these issues they either lie outside of my ability or I simply have not had the time to fix them properly.

# Notes
The code is a bit of a mess since I made it rather hastily to compile my own data; I am happy to accept any contributions that clean up or enhance my code in any way.
