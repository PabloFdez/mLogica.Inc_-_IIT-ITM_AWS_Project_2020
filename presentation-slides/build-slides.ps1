#pandoc
# -i is for iterative (slides advance one bullet point at a time)
pandoc -i -t slidy -V theme:metropolis -V linkcolor=blue -s presentation.md -o presentation.html 
pandoc -t beamer -V theme:metropolis -V linkcolor=blue presentation.md -o presentation.pdf