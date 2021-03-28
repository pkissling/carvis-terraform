default: dev live

dev: state
	terraform workspace select dev || terraform workspace new dev
	terraform init
	terraform apply

live:
	terraform workspace select live || terraform workspace new live
	terraform init
	terraform apply -var 'env=live'

state:
	cd remote-state && (terraform workspace select default || terraform workspace new default)
	cd remote-state && terraform init
	cd remote-state && terraform apply
