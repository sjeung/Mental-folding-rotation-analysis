This repository contains the MATLAB scripts and R Markdown documents used for preprocessing, statistical analysis, and visualization in the publication below.    

**Related publication**    
Is mental folding a series of mental rotations?
Sein Jeung, Klaus Gramann, Christopher Hilton
DOI: 10.22541/au.172115498.85907966/v1 (Stage 1 registered report, IPA granted)

**Related Data set**     
openneuro ds008769: the repository is not yet public; will be published upon acceptance of our stage 2 manuscript.

**Usage**    
FR_main.m script iterates over all participants calls the other m functions in the order of implementation.    
stat_foldrot.Rmd reads in the tabular output of the Matlab pipeline and conducts statistical tests and visualizes the results.    

**Requirements**    
Matlab (r2023b was used for creation of the scripts)        
- EEGLAB v.2023.1.    
- the BeMoBIL pipeline v.2.0.    

R v.4.4.2.    
- lme4 1.1.36    
- emmeans 1.10.6    

