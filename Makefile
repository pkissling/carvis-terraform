default: dev

dev: state
	terraform init
	terraform workspace select dev
	terraform apply

live: state
	terraform init
	terraform workspace select live
	terraform apply -var 'env=live'

state:
	terraform -chdir=remote-state init
	terraform -chdir=remote-state apply
