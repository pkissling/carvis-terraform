default: dev live

dev:
	terraform init
	terraform workspace select dev || terraform workspace new dev
	terraform apply

live:
	terraform init
	terraform workspace select live || terraform workspace new live
	terraform apply -var 'env=live'

state:
	cd remote-state && terraform init
	cd remote-state && (terraform workspace select default || terraform workspace new default)
	cd remote-state && terraform apply
