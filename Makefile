.PHONY: image msi package install uninstall
.ONESHELL:
.SHELLFLAGS += -e

image:
	cd docker
	docker build -t dockerinwsl:latest .
	docker run --name dockerinwsl dockerinwsl:latest || true
	docker export --output=dockerinwsl.tar dockerinwsl
	docker rm --force dockerinwsl
	mv dockerinwsl.tar ../

msi:
	powershell.exe -ExecutionPolicy ByPass ./msi/BuildInstaller.ps1
	powershell.exe -ExecutionPolicy ByPass ./msi/SignInstaller.ps1
	mv msi/bin/Release/* ./

msi-release:
	powershell.exe -ExecutionPolicy ByPass ./msi/BuildInstaller.ps1
	powershell.exe -ExecutionPolicy ByPass ./msi/AzureSignInstaller.ps1
	mv msi/bin/Release/* ./

package:
	cp DockerInWSL*.msi chocolatey/tools/
	for f in chocolatey/tools/DockerInWSL*.msi; do mv "$$f" chocolatey/tools/DockerInWSL.msi; done
	cd chocolatey 
	choco pack
	mv *.nupkg ../

install: package
	choco install dockerinwsl --force -y -dv -pre -s .

uninstall:
	choco uninstall dockerinwsl -y
