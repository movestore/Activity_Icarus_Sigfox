# Activity Icarus Sigfox

MoveApps

Github repository: *github.com/movestore/Activity_Icarus_Sigfox*

## Description
Reformat and plot the VeDBA based activity index from Icarus Sigfox tags.

## Documentation
This App is tailor made for the extraction of the VeDBA based activity index from Icarus Sigfox tag as developed at the MPIAB. It expects that the activity index is provided via Movebank in the attribute `sigfox_sensor_data_raw` and formatted as 6 successive measures in one hexadecimal string.

Here, the timestamp and activity index measure will be transformed into single, decimal time-referenced values. These are provided as a csv output file. 

Furthermore, the activity vedba index is plotted against time, with additional lines of running mean (centred around each location) of provided segment length. A background information of hourly mean +/- standard deviation over all days of data is added to the plot to enable to user to pick out unusual behaviour of the tracked animal. The plot is provided as multipage pdf.

Note that in each plot the full time interval of the provided data for the respective track/animal is plotted. If that is too long, please either download less data or use the [`Filter by Time Interval App`](https://www.moveapps.org/apps/browser/168ca35d-ff6c-44ed-894c-f13ba561957b) or [`Filter by Individual Time Intervals`](https://www.moveapps.org/apps/browser/39b9ab83-4fe6-455d-afe9-da5d725e76ed) prior to this App.

The extracted activity vedba index is added as extra track attribute to the input data as a string of 6 values. Note that for each row the attribute timestamp relates to the last of those 6 values.

### Input data
non-location move2 object in Movebank format

### Output data
non-location move2 object in Movebank format

### Artefacts
`activity_vedba_index.csv`: .csv table providing the complete set of decimal activity vedba index values for all tracks/animals. The timestamps relate directly to each activity index. Running means as used for the plot are provided for convenience.

`activity_vedba_index.pdf`: multipage .pdf file where for each track/animal the extracted activity vedba index (red line) is plotted against time. A running mean is added (blue line) as well as a background hourly mean over all data.

### Settings 
**Time interval length between activity measures (dt):** Mandatory input from user defining the time interval between the measures in each cluster of raw activity measures. No default. See below for possible units, value needs to be integer.

**Unit of time difference between activity measures (dt_unit):** Time unit for time interval length between activity measures. Possible values are `seconds`, `minutes` and `hours`. Default `minutes`.

**Interval length for running mean (runm_n):** Segement length (number of successive activity index values) for the calculation of running means. Default: 1 (indicating no averaging)

### Most common errors
none yet

### Null or error handling
**Setting `dt`:** If this measure does not fit your data, the results will be wrong.

**Setting `dt_unit`:** If this unit is incorrect, your results will be wrong.

**Setting `runm_n`:** If this value is too large and/or the data set too short, the running mean might become very crude. If this value is too small and/or the data too long, it might not differ much from the raw activity vedba index. Minimum value 1. Value 0 will lead to an error.

**data**: If there are missing values of `sigfox_sensor_data_raw`, the addition of the string of activity vedba indices can lead to an error.
