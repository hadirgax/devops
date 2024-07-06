# Quick & Dirty powershell script to use the containter with Docker & WSL2 containers.
# Run this wherever you want the folder created and mapped to.

# create a folder in the current directory
cd (mkdir -ea 0 code-server)

# create the '.config' and 'project' folders in the current location.
mkdir -ea 0 .local,.config,project

# reformat the current folder as a unix-style path 
$LOC = "/$(((pwd).path).substring(0,1).tolower()+((pwd).path).substring(1))" -replace '\\' ,'/' -replace ':',''

# Run the docker image, map it back to port 8080 on the host, and map the .config and project folders  
# docker run -it --name code-server `
#     -p 127.0.0.1:8487:8487 `
#     -v "$LOC/.config:/home/coder/.config" `
#     -v "$LOC/project:/home/coder/project" `
#     -e PASSWORD=Hi-Mom! `
#     codercom/code-server:latest

docker run -it --name code-server `
  -p 8487:8080 `
  -v "$LOC/.local:/home/coder/.local" `
  -v "$LOC/.config:/home/coder/.config" `
  -v "$LOC/project:/home/coder/project" `
  -e "DOCKER_USER=hadirgax" `
  codercom/code-server:latest
