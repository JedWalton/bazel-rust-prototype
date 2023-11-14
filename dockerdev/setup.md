```text

 $$$$$$\            $$\                                        
$$  __$$\           $$ |                                       
$$ /  \__| $$$$$$\$$$$$$\  $$\   $$\  $$$$$$\                  
\$$$$$$\  $$  __$$\_$$  _| $$ |  $$ |$$  __$$\                 
 \____$$\ $$$$$$$$ |$$ |   $$ |  $$ |$$ /  $$ |                
$$\   $$ |$$   ____|$$ |$$\$$ |  $$ |$$ |  $$ |                
\$$$$$$  |\$$$$$$$\ \$$$$  \$$$$$$  |$$$$$$$  |$$\$$\$$\       
 \______/  \_______| \____/ \______/ $$  ____/ \__\__\__|      
                                     $$ |                      
                                     $$ |                      
                                     \__|                      
```

Instructions:
-------------
0) Setup your .ssh keys for Git.
1) Install & Run Docker Desktop.
2) Clone repo into /home/$USER/Git/
3) cd /home/$USER/Git/<repo>/dev
4) `chmod +x start.sh`
5) `./start.sh`
6) ssh dev@localhost -p 2222

Notes:
------
`~/.ssh` is mounted.
`~/Git` is mounted.

You may need to update permissions if you get an EACCES error.
E.g. $ chmod +x 777 <path/to/troublesome/dir>

It is recommendend you append the following to the end of your dockerfile.
  (Must be an absolute path)

RUN mkdir -p <path/to/troublesome/dir> \
    && chown -R dev:dev <path/to/troublesome/dir>\
    && chmod -R 777 <path/to/troublesome/dir>


Tips:
-----
- You may open the docker container in another terminal window using:
`docker exec -it <container-name> bash`
- To update rust\_analyzer use: 
`bazel run @rules_rust//tools/rust_analyzer:gen_rust_project`

