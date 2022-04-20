include .env
	export $(shell sed 's/=.*//' .env)

default: dev

dev: state
	terraform init
	terraform workspace select dev || terraform workspace new dev
	terraform apply

live: state
	terraform init
	terraform workspace select live || terraform workspace new live
	terraform apply -var 'env=live'

state:
	cd remote-state && terraform init
	cd remote-state && (terraform workspace select default || terraform workspace new default)
	cd remote-state && terraform apply

format:
	terraform fmt -recursive
