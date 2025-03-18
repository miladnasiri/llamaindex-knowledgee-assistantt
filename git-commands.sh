#!/bin/bash

# Navigate to your project directory
cd ~/Desktop/llamaindex-knowledge-assistant

# Initialize git repository (if it doesn't exist already)
git init

# Add all files to git
git add .

# Commit the changes
git commit -m "Initial commit: LlamaIndex Knowledge Assistant project"

# Add the remote repository
git remote add origin git@github.com:miladnasiri/llamaindex-knowledgee-assistantt.git

# Push to the main branch (or master, depending on your GitHub default)
# If you're using a newer GitHub repository, the default branch is likely "main"
git push -u origin main

# If the above command fails with "error: failed to push some refs"
# Try this instead:
# git push -u origin master

# Note: If you get an authentication error, make sure your SSH key is set up correctly
# Or you can use HTTPS method instead:
# git remote add origin https://github.com/miladnasiri/llamaindex-knowledgee-assistantt.git
# (You'll need to enter your GitHub username and password/token when prompted)
