Add the following gem to plugins:
jekyll-remote-theme

Add a remote theme to _config.yml, such as:
remote_theme: pages-themes/architect@v0.2.0

Add the example CV markdown from OhMyCV to index.markdown (or any markdown page).
Add a key to the top of the front matter in the markdown file:
layout: default

Make a directory called "_plugins" in the blog root, and add the "cv_converter.rb" file.
In _config.yml, add the following line:
markdown: CVProcessor

