buildr:
	R CMD build .

builddocker:
	docker build -t dockerr.dashboard .

buildall: buildr builddocker

runlocal:
	docker run --user shiny -p 80:3838 dockerr.dashboard

push:
	docker tag dockerr.dashboard dashboards.azurecr.io/cloudexploration/dockerr.dashboard
	docker push dashboards.azurecr.io/cloudexploration/dockerr.dashboard

deploy:
	az acr repository list --name <registry-name> --output table

runcloud:
	docker run --user shiny -p 80:3838 dashboards.azurecr.io/cloudexploration/dockerr.dashboard

builddockerslim:
	docker build -t dockerr.dashboard.slim -f ./Dockerfile.slim .

runlocalslim:
	docker run -p 80:3838 dockerr.dashboard.slim