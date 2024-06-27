# Shells Memory Test

We have tested the following shells on Alpine:3.20.1 docker base image :
```
/bin/sh
/bin/ash
/bin/bash
/bin/bashio

Note: sh & ash is a symlink to BusyBpx and turns out to be the same shells.
```

## PSS (Proportional Set Size)
> Is the count of pages it has in memory, where each page is divided by the number of processes sharing it. So if a process has 1000 pages all to itself, and 1000 shared with one other process, its PSS will be 1500.

From another site:
> Is the amound of memory shared with other processes, accounted in a way that the amount is divided evenly between the processes that share it. This is memory that would not be released if the process was terminated, but is indicative of the amount that this process is "contributing".

## USS (Unique Set Size)
> set of pages that are unique to a process. This is the amount of memory that would be freed if the application was terminated right now.


# Results

## test.sh (ash)
sh uses /bin/sh -> BusyBox
> {test.sh} /bin/sh ./test.sh

```
Proportional Set Size: 368 KB
Unique Set Size: 80 KB
Proportional Set Size: 336 KB
Unique Set Size: 72 KB
Proportional Set Size: 351 KB
Unique Set Size: 72 KB
```

## test.bash
bash uses /bin/bash
> {test.bash} /bin/bash ./test.bash

```
Proportional Set Size: 1039 KB
Unique Set Size: 252 KB
Proportional Set Size: 935 KB
Unique Set Size: 248 KB
Proportional Set Size: 1039 KB
Unique Set Size: 252 KB
```

## test.bashio
bashio uses /bin/bash
> bash /usr/bin/bashio ./test.bashio

```
Proportional Set Size: 4594 KB
Unique Set Size: 2072 KB
Proportional Set Size: 4712 KB
Unique Set Size: 2092 KB
Proportional Set Size: 4712 KB
Unique Set Size: 2088 KB
```
