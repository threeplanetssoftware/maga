```
============================================
        Make Analysis Great Again
============================================

   _____      _____    ________    _____   
  /     \    /  _  \  /  _____/   /  _  \  
 /  \ /  \  /  /_\  \/   \  ___  /  /_\  \ 
/    Y    \/    !    \    \_\  \/    !    \
\____!__  /\____!__  /\______  /\____!__  /
        \/         \/        \/         \/ 

============================================
        Make Analysis Great Again
============================================
```

# Author
Jon Baumann, Three Planets Software (https://github.com/threeplanetssoftware/)

# About
MAGA is a quick script hacked together in SANS FOR408 to automate the vast majority of the command line work for students not used to CLI. It is not intended as a fully functional forensic suite, merely a tool to help demonstrate the types of information available for forensic analysts after using these command-line tools. MAGA uses the common tools provided for FOR408, primarily those by tzworks due to consistant output, good documentation, and ease of scripting.

# Requirements
MAGA was made to be used with the SIFT Workstation provided in SANS FOR408 in 2016. Later versions which preserve a similar tool path will likely also work. The SIFT workstation version 2 from 2016 included a ridiculously outdated version of RegRipper which is unstable. Grab the newest version (https://github.com/keydet89/RegRipper2.8) and use that to replace everything in your RegRipper folder.

# Installation
1. Download MAGA.bat from this repository
2. Save it on your SIFT workstation desktop
3. Double-click and fill in three values as noted below
4. Find all the results in the MAGA/output folder where you saved MAGA.bat to.

# Usage
MAGA is launched from a command prompt as a regular batch script with no arguments (i.e. maga.bat). MAGA will then prompt for th following input:

*Hostname*: This value doesn't impact the analysis, it simply organizes the results if you are running it against multiple data sets on the same SIFT workstation. Inside the MAGA ouput directory will be a folder for all results from this hostname.

*Target Drive*: This value should be the drive letter you have your target image mounted to. For example, if the target image is mounted in E:\, the value would be E:\.

*Target User*: MAGA will present a list of the users who have a home directory on the target drive and prompt for the user you want to pull from. After MAGA is done, the output will be in a folder named for this user under the hostname you specified in the first step.
