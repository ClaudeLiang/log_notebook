## log_notebook

A little tool for me to write note, then output with format like a log file.

usage: lua main.lua [options]                                             

Available options are:                                                    

    --help      get help info                                             

    --author    set author, override author in conf.yaml                  

    --level     set level, override level in conf.yaml                    

Format:         YYYY-MM-DD|author|level|content                           

Output files type:                                                        

    .log        log file, use \n between each line                       

    .dat        dat file, use %0A between each line, for data analysis,    
                also, you can use cat NAME.dat|sed 's/%0A/\n/g' to read