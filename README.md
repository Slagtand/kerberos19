# kerberos19

Repositori de kerberos per m11 asix edt



docker build -t marcgc/k19:kserver .



docker run --rm --name kserver.edt.org -h kserver.edt.org --net mynet -d marcgc/k19:kserver
